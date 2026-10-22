# Plano — CCD062 Gestão de Comunidade

- **Spec:** [spec.md](spec.md), aprovada em 2026-10-22
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade

## Solução

Rotas de admin no domínio `community`: lista de grupos com indicadores, suspender, reativar e excluir; fila de
denúncias de mensagens com remover mensagem e dispensar. Cada ação pede motivo e grava `audit_logs`.

## Dependências

- Fundação (tabelas de comunidade e `reports`, seeds com grupos e denúncias, `AuditLogService`, `ConfirmDialog`).

## Contrato da API

Todas com `authenticate` + `authorize('ADMIN')`, prefixo `/api/v1/admin`.

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `GET /groups` | `q`, `status`, `page`, `pageSize` | `200` `{ data: [{ id, name, accessType, status, membersCount, creatorName }], meta }` | `400` | R3 |
| `GET /groups/summary` | — | `200` `{ data: { activeGroups, messagesLast7Days, pendingReports } }` | — | R14 |
| `GET /groups/:id` | — | `200` | `404 GROUP_NOT_FOUND` | R4 |
| `POST /groups/:id/suspend` · `POST /groups/:id/reactivate` | `{ reason }` | `200` | `404`, `409 GROUP_ALREADY_SUSPENDED`, `409 GROUP_NOT_SUSPENDED` | R5, R13 |
| `DELETE /groups/:id` | `{ reason }` | `204` | `404` | R6 |
| `GET /reports/group-messages` | `status` (padrão `PENDING`), `page`, `pageSize` | `200` `{ data: [{ id, reason, description, reporterName, message: { id, content, authorName, groupName, createdAt } }], meta }` | — | R7 |
| `POST /reports/:id/remove-message` | `{ reason }` | `200` | `404 REPORT_NOT_FOUND`, `409 REPORT_ALREADY_RESOLVED` | R8, R9 |
| `POST /reports/:id/dismiss` | `{ reason }` | `200` | `404`, `409` | R9 |

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/community/admin/community-admin.validator.ts` · `.errors.ts` | filtros, motivo, erros | R3–R9 |
| `community-admin.repository.ts` | grupos com contagem de membros, status, soft delete; fila de denúncias; remover mensagem e resolver denúncia em transação | R3–R9 |
| `community-admin.service.ts` + `.spec.ts` | regras e auditoria | R5–R9, R12 |
| `community-admin.controller.ts` · `.routes.ts` · `.swagger.ts` · `community.module.ts` | rotas | R1 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/community/admin/` (api, queries, types) | chamadas | R3–R9 |
| `pages/CommunityAdminPage/` | indicadores, lista de grupos e fila de moderação | R2–R4, R7 |
| `components/GroupActionsDialog/` · `ReportActionsDialog/` | `ConfirmDialog` com motivo | R5, R6, R8–R11 |

## Testes

| Critério | Onde |
|---|---|
| CA2–CA7 | `community-admin.service.spec.ts` · integração |
| CA1, CA5 | `CommunityAdminPage.spec.tsx` |
| CA8 | integração |
