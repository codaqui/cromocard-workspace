# Plano — CCD099 Aplicar Sanção a Usuário

- **Spec:** [spec.md](spec.md), aprovada em 2026-10-22
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade

## Solução

Migrations dos dados de sanção; o domínio `users` ganha advertir, suspender com prazo, banir e reativar; o `community` ganha remover e advertir, advertir grupo e o filtro de gravidade; um job encerra as suspensões vencidas; o `auth` bloqueia `BLOCKED`.

## Dependências

- CCD059 (suspender e reativar) e CCD062 (fila de moderação).
- CCD004 (bloqueio no login).

## Dados e migrations

Cada coluna entra com esta story, numa migration própria (ADR-053, item 10).

| Tabela | Migration | O que muda | Requisitos |
|---|---|---|---|
| `users` | `add_suspended_until_to_users_table` | `suspended_until` e valor `BLOCKED` em `user_status` | R5, R6 |
| `user_warnings` | `create_user_warnings_table` | tabela | R4 |
| `groups` | `add_warned_to_group_status` | valor `WARNED` | R12 |

## Contrato da API

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `POST /api/v1/users/:id/warn` | `{ reason, reportId? }` | `201` | `400`, `404` | R4, R7 |
| `POST /api/v1/users/:id/suspend` (CCD059) | acrescenta `days?` | `200` | `400`, `404`, `409`, `422` | R5, R7 |
| `POST /api/v1/users/:id/block` | `{ reason }` | `200` | `400`, `404`, `409`, `422` | R6, R7 |
| `POST /api/v1/users/:id/reactivate` (CCD059) | aceita também `BLOCKED` | `200` | `404`, `409` | R10 |
| `POST /api/v1/admin/community/reports/:id/remove-and-warn` | `{ reason }` | `200` | `400`, `404`, `409` | R8 |
| `POST /api/v1/admin/community/groups/:id/warn` | `{ reason }` | `200` | `400`, `404`, `409` | R12 |
| `GET /api/v1/admin/community/reports` (CCD062) | acrescenta `severity` | acrescenta `category`, `authorAccountAgeDays`, `authorWarnings`, `reportersCount` | — | R13, R14 |

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + 3 migrations | colunas, enums e `user_warnings` | R4–R6, R12 |
| `user-sanctions.service.ts` + `.spec.ts` (domínio `users`) | advertir, suspender com prazo, banir, reativar e auditoria | R3–R7, R10 |
| `auth.service.ts` | `BLOCKED` não loga nem renova | R11 |
| `src/jobs/lift-expired-suspensions.job.ts` | job a cada hora | R9 |
| `community` (service e repository) | remover e advertir, advertir grupo, gravidade e dados do autor | R8, R12–R14 |
| routes · swagger | rotas acima | R1 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/admin/users/` e `community/` (api, queries) | rotas novas | R4–R14 |
| `components/SanctionDialog/` | advertir, suspender com prazo e banir, com justificativa | R2, R3, R5, R6, R10 |
| `CommunityPage` | remover e advertir, advertir grupo, filtro de gravidade e dados do autor | R8, R12–R14 |

## Testes

| Critério | Onde |
|---|---|
| CA1–CA5, CA7 | `user-sanctions.service.spec.ts` · integração |
| CA6 | `lift-expired-suspensions.job.spec.ts` |
| CA8, CA9 | `community` · integração |
| CA10 | integração |

## Decisões técnicas

- O job roda de hora em hora (`node-cron`, ADR-010).
