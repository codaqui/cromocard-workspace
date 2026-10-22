# Plano — CCD064 Aprovar Solicitações

- **Spec:** [spec.md](spec.md), aprovada em 2026-10-22
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade

## Solução

Subdomínio `catalog/requests`: lista e detalhe das solicitações, aprovar (usa o `catalogService` da CCD061 para criar
o item, numa transação com a mudança de status) e recusar com motivo. Cada decisão grava `audit_logs` e avisa o
solicitante com uma notificação.

## Dependências

- CCD061 (`catalogService` exportado) e fundação (`catalog_requests`, seeds, `AuditLogService`, `ConfirmDialog`).

## Contrato da API

Todas com `authenticate` + `authorize('ADMIN')`, prefixo `/api/v1/admin/catalog-requests`.

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `GET /` | `type`, `status` (padrão `PENDING`), `page`, `pageSize` | `200` `{ data, meta }` + `meta.pendingByType` | `400` | R3, R4 |
| `GET /:id` | — | `200` com `data` e o solicitante | `404 CATALOG_REQUEST_NOT_FOUND` | R5 |
| `POST /:id/approve` | — | `200` com o item criado | `404`, `409 REQUEST_ALREADY_REVIEWED`, `409 CARD_NUMBER_TAKEN` | R6–R11, R13 |
| `POST /:id/reject` | `{ reason }` | `200` | `404`, `409 REQUEST_ALREADY_REVIEWED` | R14 |

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/catalog/requests/catalog-requests.validator.ts` · `.errors.ts` | filtros, motivo e erros | R11, R14 |
| `catalog-requests.repository.ts` | lista, detalhe, mudança de status com checagem `status = PENDING` | R3, R5, R7, R11 |
| `catalog-requests.service.ts` + `.spec.ts` | aprovar (cria via `catalogService`), recusar, auditoria, notificação | R6–R15 |
| `catalog-requests.controller.ts` · `.routes.ts` · `.swagger.ts` | rotas | R1 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/catalog/requests/` (api, queries, types) | chamadas | R3–R7 |
| `pages/CatalogRequestsPage/` | abas por tipo com contadores e lista de cartões | R2–R4 |
| `components/CatalogRequestCard/` | dados por tipo (carta, álbum com lista de cartas, categoria), "Aprovar e integrar" e "Recusar" com `ConfirmDialog` | R5–R12 |

## Testes

| Critério | Onde |
|---|---|
| CA2–CA6 | `catalog-requests.service.spec.ts` · integração |
| CA1, CA4 | `CatalogRequestsPage.spec.tsx` |
| CA7 | integração |
