# Plano — CCD034 Buscar Categoria do Álbum

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

> **Fase MVP** desde 22/11/2026: o filtro "Seleção" foi desenhado no Figma (ADR-069).

- **Spec:** [spec.md](spec.md), em Rascunho (L1 decidida em 22/11/2026; L2–L5 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

A lista das cartas da coleção (`GET /collections/me/cards`, da grade do Início e do detalhe do álbum) ganha o filtro
`categoryId`, que inclui as subcategorias (seleções e times) do item escolhido. O cliente escolhe a categoria raiz nos
botões do Início (`1122-17812`); no detalhe do álbum, escolhe a seleção ou o time no seletor "Seleção" da linha de filtros
(`1160-23696`, lista aberta em `1226-2361`, filtrado em `1226-3003`). Sem cartas no item, a grade mostra "Nenhuma figurinha
encontrada para esta categoria". As opções vêm de `GET /collections/me/categories`, só com as categorias que têm cartas na
coleção do cliente, na ordem da CCD104.

## Dependências

- **CCD007** — domínio `collection`, tabelas e a grade de cartas do Início (frame `1122-17812`); **CCD013** — a grade do
  detalhe do álbum. Uma das duas cria `GET /collections/me/cards`; esta story acrescenta o filtro.
- **CCD104** — `categories.display_order` e `is_pinned` (já no `schema.prisma`) para a ordem dos botões.
- **ADR-063** (Proposto) — a franquia da carta com álbum; a L3 decide se a subcategoria da carta vale.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `categories` | sim | — | hierarquia por `parent_category_id`; ordem por `is_pinned`, `display_order`, `name` (R3) |
| `cards` · `albums` | sim | — | `cards.category_id` e, sem ela, `albums.category_id` (depende da L3) |
| `collection_cards` | não | da CCD007 | cartas da coleção do cliente (R4) |

Nenhuma coluna nova.

## Regras

- **Item e descendentes** (R3, R4): o filtro pega o `categoryId` e todos os descendentes não excluídos (consulta recursiva).
- **Categoria da carta** (depende da L3): `cards.category_id`; sem ela, `albums.category_id`.
- **Status** (depende da L4): todas as marcações não excluídas (`OWNED`, `DUPLICATE` e `MISSING`), combinável com o filtro de
  status da grade.
- **Opções** (R2): só as categorias com pelo menos uma carta na coleção, com `parentCategoryId`, para a tela montar os níveis.
- **Quem filtra** (R1): `CUSTOMER` e `SELLER`; `ADMIN` recebe `403` (depende da L5).

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, erros `{ error, message, details? }`.

### `GET /api/v1/collections/me/cards` (CCD007/CCD013) — R1, R3, R4

- **Entrada nova (query):** `categoryId` (uuid, opcional).
- **Sucesso:** `200` `{ data: CollectionCard[], meta }` — lista vazia quando o item não tem cartas (R5).
- **Erros novos:** `422 CATEGORY_NOT_FOUND` (categoria inexistente ou excluída) — R3; `401` sem token — R1.

### `GET /api/v1/collections/me/categories` — R2, R3

- **Acesso:** `authenticate` + `authorize('CUSTOMER', 'SELLER')` (depende da L5)
- **Sucesso:** `200`

  ```json
  { "data": [{ "id": "uuid", "name": "Futebol", "parentCategoryId": null, "cardsCount": 120 },
             { "id": "uuid", "name": "Argentina", "parentCategoryId": "uuid", "cardsCount": 18 }] }
  ```

- **Erros:** `401 UNAUTHORIZED`, `403 FORBIDDEN` — R1.

## Backend — `apps/cromocard-backend`

Domínio `src/domains/collection/` (CCD007).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection.validator.ts` | `categoryId` na query da lista | R3 |
| `collection.errors.ts` | `CategoryNotFoundError` (`422 CATEGORY_NOT_FOUND`) | R3 |
| `collection-categories.repository.ts` | descendentes da categoria (CTE recursiva) e as categorias com cartas na coleção | R2–R4 |
| `collection-cards.repository.ts` · `collection-cards.service.ts` + `.spec.ts` | filtro por categoria e descendentes na lista | R3, R4 |
| `collection-categories.service.ts` + `.spec.ts` | opções do filtro | R2 |
| `collection.controller.ts` · `collection.routes.ts` · `collection.swagger.ts` | `GET /collections/me/categories` e o parâmetro novo | R1 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/collection/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection.api.ts` · `collection.queries.ts` · `collection.labels.ts` | `categoryId` na query da grade, `useCollectionCategories`, "Nenhuma figurinha encontrada para esta categoria" | R2, R5 |
| `components/CategoryFilter/` | botões das categorias raiz ("Todas", …) do Início — frame `1122-17812` | R2, R6 |
| `components/SelectionFilter/` | seletor "Seleção" na linha de filtros do detalhe do álbum, com "Todas as seleções" e a quantidade de figurinhas de cada opção — frames `1160-23696` e `1226-2361` | R2, R3, R6 |
| grade do detalhe do álbum (CCD013) | aplica o filtro, atualiza "Exibindo N de M itens" e mostra o vazio (`1226-3003`, `1226-3625`) | R4–R6 |
| grade do Início (CCD007) | aplica o filtro e mostra o vazio com `EmptyState` | R4, R5 |

- **Estados:** carregando e erro da grade com `LoadingState` e `ErrorState`; vazio com `EmptyState`.
- **Componentes reaproveitados de `src/components/`:** `Tabs` ou `Button` (botões), `EmptyState`, `LoadingState`, `ErrorState`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | "Argentina": só as cartas da Argentina | `collection-cards.service.spec.ts` · `tests/integration/collection-cards-filter.spec.ts` · `SelectionFilter.spec.tsx` |
| CA2 | "Futebol": cartas de Futebol e das subcategorias | `collection-categories.repository` na integração |
| CA3 | time sem cartas: "Nenhuma figurinha encontrada para esta categoria" | `SelectionFilter.spec.tsx` |
| CA4 | sem token `401` | integração |
| CA5–CA7 | print em 1280 px igual aos frames `1226-2361` (CA5), `1122-17812` (CA6), `1160-23696`, `1226-3003` e `1226-3625` (CA7); sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Decisões técnicas

- Os descendentes saem de uma CTE recursiva em `$queryRaw` no repository, porque o Prisma não percorre a hierarquia; a
  profundidade é pequena (categoria › seleção › time).
- As opções vêm de uma rota própria da coleção, e não do catálogo inteiro, para não oferecer seleção sem carta.
