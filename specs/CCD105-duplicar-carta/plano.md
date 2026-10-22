# Plano — CCD105 Duplicar Carta

- **Spec:** [spec.md](spec.md) — feito sobre a spec em Rascunho (pedido do PO em 2026-10-22), com as propostas das lacunas
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade

## Solução

Migration com código e variantes; o catálogo (CCD061) aceita os campos, ganha o resumo, o filtro por ano e a exclusão em lote; o frontend abre o formulário de criar preenchido a partir da carta de origem.

## Dependências

- CCD061 (catálogo, formulário de carta e lista).
- CCD064 (solicitações de álbum pendentes).

## Dados e migrations

Cada coluna entra com esta story, numa migration própria (ADR-053, item 10).

| Tabela | Migration | O que muda | Requisitos |
|---|---|---|---|
| `cards` | `add_code_and_variants_to_cards_table` | `code`, `variants` | R8 |

## Contrato da API

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `GET /api/v1/admin/catalog/summary` | — | `200` `{ albums, licensedAlbums, pendingAlbumRequests }` | — | R7 |
| `GET /api/v1/admin/catalog/cards` (CCD061) | acrescenta `year` | acrescenta `code`, `variants` | — | R8, R9 |
| `POST` · `PATCH /api/v1/admin/catalog/cards` (CCD061) | acrescenta `code?`, `variants?` | `201` / `200` | `409 CARD_CODE_TAKEN` | R3–R5, R8 |
| `POST /api/v1/admin/catalog/cards/bulk-delete` | `{ ids, reason }` | `200` `{ deleted }` | `400`, `422 CARD_IN_USE` | R10 |

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + migration | colunas novas | R8 |
| `cards.validator.ts` · `catalog.service.ts` + `.spec.ts` | código, variantes, resumo, filtro por ano e exclusão em lote com auditoria | R4, R7–R10 |
| routes · swagger | rotas acima | R1 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/admin/catalog/` (api, queries, schemas) | campos e rotas novas | R7–R10 |
| `CardForm` · `CatalogPage` | "Duplicar", indicadores, código, variantes, filtro por ano, chips e seleção em lote | R2–R10 |

## Testes

| Critério | Onde |
|---|---|
| CA3, CA5, CA7, CA8 | `catalog.service.spec.ts` · integração |
| CA1, CA2, CA6 | `CatalogPage.spec.tsx` · `CardForm.spec.tsx` |
| CA4 | integração |

## Decisões técnicas

- A duplicação é só no frontend (L1, proposta).
