# Plano — CCD065 Log de Auditoria Admin

- **Spec:** [spec.md](spec.md), aprovada em 2026-10-22
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade

## Solução

Leitura do `audit_logs` gravado pelas outras stories: `GET /api/v1/admin/audit-logs` com filtros e paginação, e
`GET /api/v1/admin/audit-logs/:id` com os detalhes. A tela mostra o total de 30 dias, os filtros e a tabela.

## Dependências

- Fundação (`audit_logs`, `AuditLogService` com a lista de ações, `DataTable`, `PeriodFilter`, `Drawer`).

## Contrato da API

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `GET /api/v1/admin/audit-logs` | `adminId`, `action`, `entityType`, `entityId`, `from`, `to`, `page`, `pageSize` | `200` `{ data: [{ id, action, entityType, entityId, reason, admin: { id, name }, createdAt }], meta: { …, last30Days } }` | `400` | R3–R5 |
| `GET /api/v1/admin/audit-logs/:id` | — | `200` com `details` completo | `404 AUDIT_LOG_NOT_FOUND` | R6 |

Ambas com `authenticate` + `authorize('ADMIN')`; sem rotas de escrita (R8).

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/admin/audit-logs/audit-logs.validator.ts` | filtros | R5 |
| `audit-logs.repository.ts` | consultas com o admin incluído mesmo excluído | R3, R4, R8 |
| `audit-logs.service.ts` + `.spec.ts` | lista, detalhe e total de 30 dias | R3–R6 |
| `audit-logs.controller.ts` · `.routes.ts` · `.swagger.ts` | rotas de leitura | R1 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/admin/audit-logs/` (api, queries, types, labels das ações) | chamadas e rótulos | R4, R10 |
| `pages/AuditLogsPage/` | total, filtros, tabela e `Drawer` com o detalhe | R2–R7, R9 |

## Testes

| Critério | Onde |
|---|---|
| CA1–CA3, CA5 | `audit-logs.service.spec.ts` · integração |
| CA4 | `AuditLogsPage.spec.tsx` |
| CA6 | integração |
