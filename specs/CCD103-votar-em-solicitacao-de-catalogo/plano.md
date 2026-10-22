# Plano — CCD103 Votar em Solicitação de Catálogo

- **Spec:** [spec.md](spec.md) — feito sobre a spec em Rascunho (pedido do PO em 2026-10-22), com as propostas das lacunas
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade

## Solução

Tabela de votos e rotas do cliente para listar e votar; o detalhe da solicitação no BackOffice (CCD064) ganha o quórum, os campos extras e a planilha; aprovar categoria cria as subcategorias.

## Dependências

- CCD064 (fila de solicitações; a mudança no `catalog-requests.service` é combinada com o Felipe Consulim).
- CCD061 (`catalogService` para criar categorias).

## Dados e migrations

Cada coluna entra com esta story, numa migration própria (ADR-053, item 10).

| Tabela | Migration | O que muda | Requisitos |
|---|---|---|---|
| `catalog_request_votes` | `create_catalog_request_votes_table` | tabela e enum `catalog_vote` | R3 |
| `global_settings` | — (seed) | chave `catalog.voting_goal` | R9 |

## Contrato da API

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `GET /api/v1/catalog-requests/voting` | cliente | `200` sugestões abertas com contagem e o voto do cliente | `401` | R2, R4 |
| `PUT /api/v1/catalog-requests/:id/vote` | `{ vote }` | `200` | `400`, `401`, `404`, `409 VOTING_CLOSED` | R3, R7, R8 |
| `GET /api/v1/admin/catalog-requests/:id` (CCD064) | — | acrescenta `votes { for, neutral, against, total, goal }` | — | R5, R9, R10 |
| `GET /api/v1/admin/catalog-requests/:id/checklist.csv` | — | `200` `text/csv` | `404` | R11 |

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + migration · seed | tabela, enum e meta | R3, R9 |
| `catalog-request-votes.service.ts` + `.spec.ts` | votar, trocar e recusar voto em sugestão encerrada | R3, R4, R6–R8 |
| `catalog-requests.service.ts` (CCD064) | quórum no detalhe e subcategorias na aprovação | R5, R9, R12 |
| `checklist.exporter.ts` | CSV do checklist | R11 |
| routes · swagger | rotas acima | R1 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/catalog-requests/` (api, queries) | votação do cliente | R2–R4, R7, R8 |
| `pages/CommunitySuggestionsPage/` | lista e botões de voto | R2–R4, R7, R8 |
| `CatalogRequestCard` (CCD064) | quórum, campos extras, checklist e subcategorias | R5, R10–R12 |

## Testes

| Critério | Onde |
|---|---|
| CA1–CA3 | `catalog-request-votes.service.spec.ts` |
| CA4–CA6 | `catalog-requests.service.spec.ts` · integração |
| CA7 | integração |

## Decisões técnicas

- O voto usa `upsert` na PK composta, o que garante um voto por cliente.
