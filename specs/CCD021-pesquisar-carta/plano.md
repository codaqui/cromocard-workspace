# Plano — CCD021 Pesquisar Carta

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L7 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

O botão "+ Adicionar carta" do detalhe do álbum abre o modal "Adicionar carta" (L1). O campo de busca, com debounce, chama
`GET /api/v1/cards/search?q=&albumId=`, que procura o termo no nome e no número das cartas `ACTIVE` não excluídas do
catálogo inteiro, com as do álbum aberto primeiro (L3). Cada resultado mostra imagem, nome e "<álbum> • Nº <número> •
<raridade>" (L4); "Adicionar" segue para a CCD022. Sem resultado, o modal mostra a mensagem do FA 1.

## Dependências

- **CCD106** — coluna `cards.status` (`add_status_and_release_year_to_cards_table`) e o filtro `ACTIVE` nas consultas
  públicas do catálogo; sem ela, R4 só filtra `deleted_at`.
- **CCD013** — detalhe do álbum (frame `1160-23696`), onde fica "+ Adicionar carta" que abre o modal.
- **CCD022 / CCD036** — a ação "Adicionar" e o selo "JÁ ESTÁ NA COLEÇÃO" nos resultados; **CCD023** — o link de solicitar.
- **CCD030** — também usa o módulo público `src/domains/catalog/cards/` (`/cards`); quem entrar primeiro cria o módulo.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `cards` | sim, sem `status` | `status` da CCD106 | só leitura: `name`, `number`, `album_id`, `rarity_id`, `front_image_url`, `status`, `deleted_at` |
| `albums` | sim | — | `title` na linha do resultado |
| `rarities` | sim | — | `name` no terceiro item da linha (depende da L4) |

## Regras

- **Termo** (R3): mínimo de 2 caracteres e máximo de 60; procura `contains` no `name` e no `number`, sem diferenciar
  maiúsculas (`mode: 'insensitive'`, como o catálogo do admin). Ignorar acento depende da L5 e de ADR (ver Decisões).
- **Filtro** (R4): `status = ACTIVE`, `deleted_at` nulo e o álbum também não excluído.
- **Ordem e limite** (depende da L3 e da L5): cartas do `albumId` informado primeiro, depois por `name`; até 20 resultados.
- **Quem pesquisa** (R1): `CUSTOMER` e `SELLER`; `ADMIN` recebe `403` (depende da L7).

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }`, JSON camelCase, erros `{ error, message, details? }`.

### `GET /api/v1/cards/search` — R1, R3–R5

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')` (depende da L7)
- **Entrada (query):** `q` (2 a 60 caracteres), `albumId` (uuid, opcional — o álbum aberto, para ordenar).
- **Sucesso:** `200`, lista vazia quando nada corresponde (R7)

  ```json
  { "data": [{ "id": "uuid", "name": "Kylian Mbappé", "number": "09", "frontImageUrl": "https://…",
               "album": { "id": "uuid", "title": "Copa do Mundo 2026" }, "rarity": { "name": "Refractor" } }] }
  ```

- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | `q` ausente, curto ou longo; `albumId` não é uuid | R3 |
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 403 | `FORBIDDEN` | papel `ADMIN` (depende da L7) | R1 |

## Backend — `apps/cromocard-backend`

Módulo público `src/domains/catalog/cards/`, no modelo de `src/domains/users/` (ADR-004), registrado em `src/routes.ts`
com `basePath: '/cards'`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `cards.validator.ts` | `searchCardsQuery` (Zod) | R3 |
| `cards.repository.ts` | `searchActive({ q, albumId, limit })` com o filtro e a ordem das Regras | R3, R4 |
| `cards.service.ts` + `.spec.ts` | busca e mapeamento para o contrato | R3–R5 |
| `cards.controller.ts` · `cards.routes.ts` · `cards.swagger.ts` · `cards.module.ts` | rota `GET /search` com `authenticate` e `authorize` | R1 |
| `src/routes.ts` | registra o `cardsModule` | R1 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/collection/` (o modal pertence à coleção do cliente).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `card-search.types.ts` · `card-search.api.ts` · `card-search.queries.ts` · `card-search.labels.ts` | contrato, `useCardSearch(q, albumId)` com `useDebounce`, "Procure a carta no catálogo pelo nome ou pelo número." e "Nenhuma carta encontrada com os termos informados" | R2, R3, R7 |
| `components/AddCardModal/` | modal "Adicionar carta", campo de busca, lista, "Fechar" e "✕" — frame `1160-28449` | R2, R6, R8, R9 |
| `components/CardSearchResult/` | imagem, nome e "<álbum> • Nº <número> • <raridade>", com o espaço da ação "Adicionar" (CCD022) — frame `1160-28449` | R5, R6, R9 |
| `pages/AlbumDetailPage/` (CCD013) | "+ Adicionar carta" abre o modal com o `albumId` | R2 |

- **Estados:** carregando com `LoadingState` dentro do modal e sem resultado com `EmptyState`, no estilo do modal (L6).
- **Componentes reaproveitados de `src/components/`:** `Modal`, `SearchBar`, `EmptyState`, `LoadingState`, `ErrorState`, `Button`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | "mbappé" traz as três, com imagem, nome e a linha | `cards.service.spec.ts` · `tests/integration/cards-search.spec.ts` · `AddCardModal.spec.tsx` |
| CA2 | "09" acha pelo número | `cards.service.spec.ts` · integração |
| CA3 | rascunho e excluída não aparecem | integração |
| CA4 | termo sem carta: "Nenhuma carta encontrada com os termos informados" | `AddCardModal.spec.tsx` |
| CA5 | "Adicionar" dispara a ação da CCD022 para a carta | `CardSearchResult.spec.tsx` |
| CA6 | "Fechar" e "✕" fecham | `AddCardModal.spec.tsx` |
| CA7 | sem token `401` | integração |
| CA8 | print em 1280 px igual ao frame `1160-28449`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Decisões técnicas

- A busca é uma rota própria do catálogo público (`/cards/search`), separada da busca do admin (`/admin/catalog/cards`),
  porque filtra rascunho, exige o papel de cliente e devolve só o necessário ao modal.
- Ignorar acento (L5: "mbappé" = "mbappe") pede a extensão `unaccent` do PostgreSQL numa migration e consulta crua:
  decisão de arquitetura que nenhum ADR cobre. Se o PO aceitar a L5, abrir ADR `Proposto` antes do código; até lá a busca
  só ignora maiúsculas, como o resto do catálogo.
