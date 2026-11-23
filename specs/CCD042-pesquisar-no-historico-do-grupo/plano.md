# Plano — CCD042 Pesquisar no Histórico do Grupo

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em `Rascunho` (lacunas L1–L10 pendentes)
- **Repositórios:** backend · frontend
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

O ícone "⌕" do topo do chat abre o painel "Buscar no grupo" (frame `675-14484`). Digitar o termo chama
`GET /groups/:id/messages/search`, que procura no texto das mensagens não excluídas e no nome da carta compartilhada,
e devolve cada resultado com o autor, a data e as posições do termo. Selecionar um resultado chama
`GET /groups/:id/messages?around=<messageId>`, que traz a página ao redor da mensagem; o chat rola até ela e a destaca.

## Dependências

- CCD039: `group-access.ts` (`assertMember`).
- CCD044: histórico por cursor (`GET /groups/:id/messages`), `MessageList` e `GroupChatHeader`.
- CCD044, L1: mensagens `CARD` e `LISTING` só existem se aceitas; até lá a busca encontra só texto, e o trecho do nome da
  carta já fica pronto para quando existirem.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `group_messages` | sim | — | `content`, `card_id`, `pinned`, `deleted_at` |
| `cards` | sim | — | `name` da carta compartilhada |
| `listings` | não (marketplace ainda sem tabela no `develop`) | — | busca no anúncio depende da L1 e da CCD044 L1 |

## Regras

- **Termo:** 2 a 100 caracteres, sem espaços nas pontas; `ILIKE` sem diferenciar maiúsculas (depende da L6). Sem
  diferenciar acentos só com a extensão `unaccent`, que exige ADR novo (depende da L6).
- **Onde procura:** `group_messages.content` e `cards.name` da mensagem `CARD`; anúncio pelo nome da carta e pela
  `description` do anúncio quando `listings` existir (depende da L1).
- **Só não excluídas:** `group_messages.deleted_at` nulo (inclui as removidas pela moderação).
- **Ordem e página:** da mais nova para a mais antiga, por cursor (`limit` 20), com `meta.total` (depende da L8).
- **Destaque:** o backend devolve `matches` (`[{ start, length }]`) do termo no `content`; o front pinta o trecho.
- **Ao redor:** `around` devolve até 25 mensagens antes e 25 depois, em ordem cronológica, com `meta.nextCursor` (mais
  antigas) e `meta.prevCursor` (mais novas) (depende da L7).

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, erros `{ error, message, details? }`.
Acesso: `authenticate` + `authorize('CUSTOMER', 'SELLER')` + membro (`403 NOT_GROUP_MEMBER`); grupo excluído
`404 GROUP_NOT_FOUND`.

### `GET /api/v1/groups/:id/messages/search` — R1, R3–R6, R8

- **Entrada:** `q` (2–100), `cursor?`, `limit` (1–50, padrão 20)
- **Sucesso:** `200`

  ```json
  { "data": [{ "id": "uuid", "contentType": "TEXT", "content": "Alguém tem Charizard?", "cardName": null,
      "matches": [{ "start": 11, "length": 9 }], "createdAt": "…",
      "author": { "id": "uuid", "name": "…", "username": "…", "avatarUrl": null } }],
    "meta": { "nextCursor": null, "total": 12 } }
  ```

- **Erros:** `400 VALIDATION_ERROR` (termo curto ou longo), `401`, `403`, `404`

### `GET /api/v1/groups/:id/messages?around=<messageId>` (amplia a CCD044) — R7

- **Entrada:** `around` (id), exclusivo com `cursor`
- **Sucesso:** `200` `{ data: GroupMessage[], meta: { nextCursor, prevCursor } }`
- **Erros:** `400 VALIDATION_ERROR` (`around` e `cursor` juntos), `404 GROUP_MESSAGE_NOT_FOUND` (excluída ou de outro grupo)

## Backend — `apps/cromocard-backend`

Domínio `src/domains/community/group-messages/` (da CCD044).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `group-messages.validator.ts` | `searchGroupMessagesQuerySchema`; `around` no `listGroupMessagesQuerySchema` | R3, R7 |
| `group-messages.repository.ts` | `search` (texto e nome da carta, total) e `listAround` | R4, R5, R7, R8 |
| `group-message-search.ts` | posições do termo no texto (`matches`) | R6 |
| `group-messages.service.ts` · `.controller.ts` · `.routes.ts` · `.swagger.ts` | rota da busca e o `around` | R1, R4, R7 |
| `database/seeds/data/group-messages.json` | mensagens com "Charizard", uma delas excluída | R4, R5 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/community/chat/` (da CCD044).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `group-chat-search.api.ts` · `.queries.ts` | busca com debounce e página ao redor | R3, R4, R7 |
| `components/GroupSearchPanel/` | painel "Buscar no grupo" do frame `675-14484`: campo, lista com autor, data e trecho destacado, "✕" (depende da L10); só a lista de mensagens, sem abas Links e Fotos (L1, L2), filtros (L3) e selos (L5) | R2, R3, R6, R8, R9 |
| `components/HighlightedText/` | pinta os `matches` | R6 |
| `components/MessageList/` · `hooks/useGroupChat.ts` (CCD044) | modo "ao redor": carrega a página do `around`, rola até a mensagem e a destaca, com os cursores para os dois lados | R7 |
| `components/GroupChatHeader/` (CCD044) | "⌕" abre o painel | R2 |

- **Estados:** sem resultado ("nenhum conteúdo correspondente foi encontrado no histórico do grupo"), carregando e erro
  dentro do painel, com `EmptyState`, `LoadingState` e `ErrorState` (depende da L9).
- **Componentes reaproveitados de `src/components/`:** `SearchBar`, `Drawer`, `EmptyState`, `LoadingState`, `ErrorState`.
- Fora do frame até decisão: faixa "Resultado 1 de 12" com "↑" e "↓" (L4).

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | resultados com o autor, a data e o termo destacado | `group-messages.service.spec.ts` · `tests/integration/group-messages-search.spec.ts` · `GroupSearchPanel.spec.tsx` |
| CA2 | mensagem `CARD` achada pelo nome da carta | integração (com mensagem `CARD` do seed) |
| CA3 | `around` traz a página e o chat rola e destaca | integração · `MessageList.spec.tsx` |
| CA4 | sem resultado mostra o aviso | `GroupSearchPanel.spec.tsx` |
| CA5 | mensagem excluída fora dos resultados | integração |
| CA6 | `401` sem token, `403` para não membro | integração |
| CA7 | print em 1280 px igual ao frame `675-14484`; 375/768/1024 px sem quebra | revisão visual (`/cromocard-revisor`) |

Cobertura de 90% nos arquivos alterados (ADR-060).

## Dependências e riscos

- Sem diferenciar acentos (L6) depende de ADR novo para a extensão `unaccent`; até lá, "pokemon" não acha "Pokémon".
- Anúncios (R4) dependem da tabela `listings` (marketplace) e da L1 da CCD044.
- Volume: `ILIKE '%termo%'` não usa índice; com o histórico grande, um índice `pg_trgm` vira ADR.

## Decisões técnicas

- As posições do termo vêm do backend, para o destaque bater com a mesma comparação da busca.
- "Ao redor" amplia o endpoint do histórico em vez de criar outro, porque devolve o mesmo `GroupMessage` e a mesma lista.
