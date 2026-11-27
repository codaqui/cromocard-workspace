# Plano — CCD014 Marcar Carta como Possuo (agrupa CCD015 e CCD016)

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L11 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

Cada carta do detalhe do álbum (CCD013) ganha os marcadores "Possuo", "Falta" e "Repetida". O clique atualiza a carta na
tela na hora (otimista, depende da L9) e chama `PUT /api/v1/collections/me/cards/:cardId/status`, que aplica a transição
de status e quantidade, restaura a linha excluída se houver, recalcula `user_albums.progress_percentage` na mesma
transação e devolve a carta e o progresso. Esta story cria a regra de estado da carta (`collection-card-state.ts`) e o
recálculo do progresso (`collection-progress.ts`), que a CCD017 e a CCD018 reaproveitam, e liga a `CardUsage` que a
CCD061 deixou pendente.

## Dependências

- **CCD007**: domínio `collection` e a tabela `collection_cards`.
- **CCD013**: a página do detalhe, o `AlbumCardTile`, o `AlbumCardRow` e as queries das cartas e do cabeçalho.
- **CCD061**: a interface `CardUsage` (`isCardInCollections(cardId)`) no `catalog.service.ts`, hoje sem implementação
  no `catalog.module.ts`, e o modal "Não é possível excluir esta carta" (R12).
- **CCD106**: `cards.status`, para só marcar carta `ACTIVE` (dependência herdada da CCD013).

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `collection_cards` | da CCD007 | — | `upsert` em (`collection_id`, `card_id`), com `deleted_at = null` (R3, ADR-015, item 7) |
| `user_albums` | da CCD007 | — | grava `progress_percentage` (R9) |
| `albums`, `cards` | sim | — | só leitura: `total_cards`, `album_id`, `status`, `deleted_at` |

Nenhuma coluna nova: o "contador de repetidas" é `quantity − 1` (depende da L4).

## Regras

Estado da carta (`collection-card-state.ts`, depende da L4–L7), com "atual" = a linha ativa ou, sem linha, `MISSING` com 0
(depende da L3):

| Ação | De `MISSING` (0) | De `OWNED` (1) | De `DUPLICATE` (n ≥ 2) |
|---|---|---|---|
| `OWNED` | `OWNED`, 1 | `422 CARD_STATUS_UNCHANGED` (L6) | `OWNED`, 1 (L6) |
| `MISSING` | `422 CARD_STATUS_UNCHANGED` (R5) | `MISSING`, 0 | `MISSING`, 0, sem confirmação (L7) |
| `DUPLICATE` | `OWNED` e depois `DUPLICATE`, 2 (R8) | `DUPLICATE`, 2 (R7, L5) | `422 CARD_STATUS_UNCHANGED` (L5) |

- **Carta válida** (R1, depende da L11): carta `ACTIVE`, não excluída, com `album_id` de um álbum ativo da coleção do
  cliente; senão `404`. Carta avulsa (`album_id` nulo) também `404`.
- **Progresso** (R9, depende da L8): `cartas OWNED ou DUPLICATE do álbum / albums.total_cards × 100`, com 2 casas;
  `total_cards = 0` grava 0 (a CCD019 mostra "Progresso indisponível").
- **Carta usada em coleções** (R12): existe `collection_cards` sem `deleted_at` com o `card_id`.
- **Só no detalhe** (depende da L10): o Início (CCD007) só mostra o status.

## Contrato da API

Convenções do ADR-011.

### `PUT /api/v1/collections/me/cards/:cardId/status` — R1–R9

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')` (depende da L1)
- **Entrada:**

  ```json
  { "status": "OWNED" }
  ```

- **Sucesso:** `200`

  ```json
  { "data": { "card": { "cardId": "uuid", "status": "OWNED", "quantity": 1 },
      "album": { "albumId": "uuid", "progressPercentage": 81.48,
        "counts": { "all": 54, "owned": 44, "missing": 10, "duplicates": 6 } } } }
  ```

- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | `status` fora do enum ou `cardId` não é uuid | R3 |
  | 401 | `UNAUTHORIZED` | sem token | R1 |
  | 403 | `FORBIDDEN` | papel `ADMIN` (depende da L1) | R1 |
  | 404 | `COLLECTION_CARD_NOT_FOUND` | carta inexistente, não publicada, avulsa ou de álbum fora da coleção (depende da L11) | R1 |
  | 422 | `CARD_STATUS_UNCHANGED` | a carta já está no status pedido (L5, L6) | R5, R6 |

### `DELETE /api/v1/admin/catalog/cards/:id` (CCD061) — R12

- Sem mudança de contrato: passa a responder o `CARD_IN_USE` da CCD061 quando a carta está em alguma coleção.

## Backend — `apps/cromocard-backend`

Domínio `src/domains/collection/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection-card-state.ts` + `.spec.ts` | a tabela de transições acima, função pura reaproveitada pela CCD017 e pela CCD018 | R3–R8 |
| `collection-progress.ts` + `.spec.ts` | `recalculateAlbumProgress(tx, collectionId, albumId)` e as contagens do álbum | R9 |
| `collection-cards-marking.repository.ts` | carta válida da coleção, linha atual, `upsert` restaurando `deleted_at` | R1, R3 |
| `collection-cards-marking.service.ts` + `.spec.ts` | transação: lê, aplica o estado, grava, recalcula, devolve | R1–R9 |
| `collection-card-usage.ts` | `PrismaCardUsage implements CardUsage` | R12 |
| `catalog.module.ts` (CCD061) | passa `cardUsage: new PrismaCardUsage(prisma)` ao `CatalogService` | R12 |
| `collection.errors.ts` | `COLLECTION_CARD_NOT_FOUND`, `CARD_STATUS_UNCHANGED` | R1, R5, R6 |
| `collection.validator.ts` · `.controller.ts` · `.routes.ts` · `.swagger.ts` | body e a rota `PUT /me/cards/:cardId/status` | R1 |
| `tests/integration/collection-card-marking.spec.ts` | rota de ponta a ponta e a exclusão bloqueada no catálogo | CA1–CA3, CA5, CA6, CA8, CA9 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/collection/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection-marking.api.ts` · `collection-marking.queries.ts` | `setCardStatus` e `useSetCardStatus`, com `onMutate` otimista na lista de cartas e nas contagens do cabeçalho, `onError` que desfaz e `onSuccess` que grava a resposta (depende da L9) | R10, R11 |
| `collection-marking.optimistic.ts` + `.spec.ts` | a mesma tabela de transições do backend, para prever a carta na tela | R10 |
| `components/CardStatusMarkers/` | "Possuo", "Falta" e "Repetida", normal, selecionado e desabilitado (o do status atual), com o texto "Clique nos marcadores Possuo, Falta ou Repetida para atualizar instantaneamente." (depende da L2); frame `1160-23696` | R2, R5, R13 |
| `components/AlbumCardTile/` · `AlbumCardRow/` (CCD013) | os marcadores no cartão e na linha; selos "NO ÁLBUM", "<n> REPETIDAS", "FALTANDO" atualizados | R2, R7, R10, R13 |
| `pages/AlbumDetailPage/` (CCD013) | aviso "Não foi possível salvar. Verifique a conexão e tente novamente." com o `Toast` (depende da L9) | R11 |

- **Componentes reaproveitados:** `Button`, `Badge`, `Toast`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | "Possuo" na #09: `OWNED`, progresso 81,48, carta e contagens na tela | `collection-cards-marking.service.spec.ts` · integração · `CardStatusMarkers.spec.tsx` |
| CA2 | linha excluída restaurada, sem linha nova | `collection-cards-marking.service.spec.ts` · integração |
| CA3 | "Faltante": `MISSING`, 0, progresso cai | `collection-card-state.spec.ts` · integração |
| CA4 | "Falta" desabilitado na carta faltante | `CardStatusMarkers.spec.tsx` |
| CA5 | "Repetida" na possuída: 2 unidades, selo de repetida | `collection-card-state.spec.ts` · integração |
| CA6 | "Repetida" na faltante: passa por possuo, fica repetida, progresso sobe | `collection-card-state.spec.ts` · integração |
| CA7 | erro de rede: aviso e carta volta ao status anterior | `AlbumDetailPage.spec.tsx` |
| CA8 | `401` sem token; marcar não muda a coleção de outro cliente | integração |
| CA9 | carta marcada bloqueia a exclusão no catálogo | `tests/integration/collection-card-marking.spec.ts` (chama o `DELETE` da CCD061) |
| CA10 | print em 1280 px igual a `1160-23696` nos marcadores e selos; 375, 768 e 1024 px sem quebra | revisão visual |

## Decisões técnicas

- Um endpoint para as três user stories (`PUT .../status`): o status é um sub-recurso da carta na coleção, e o `PUT` é
  idempotente por natureza, como o voto da CCD103.
- A regra de estado é uma função pura com a tabela de transições, testada sozinha, e usada também pela CCD017 e pela
  CCD018; o frontend tem uma cópia só para a atualização otimista, e a resposta da API sempre prevalece.
- Status, quantidade e progresso são gravados numa transação, para o progresso nunca ficar diferente das marcações.
- A `CardUsage` é implementada no domínio `collection` e injetada no catálogo: o catálogo continua sem ler tabela de
  outro domínio (ADR-001), como a CCD061 planejou.
