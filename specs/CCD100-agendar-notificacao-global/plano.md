# Plano — CCD100 Agendar Notificação Global

- **Spec:** [spec.md](spec.md) — feito sobre a spec em Rascunho (pedido do PO em 2026-10-22), com as propostas das lacunas
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade

## Solução

Migration com as colunas de agendamento; o serviço de notificação global (CCD060) passa a aceitar `scheduledAt`; um job de minuto em minuto entrega os vencidos; o histórico mostra o status e permite cancelar.

## Dependências

- CCD060 (disparo e histórico).

## Dados e migrations

Cada coluna entra com esta story, numa migration própria (ADR-053, item 10).

| Tabela | Migration | O que muda | Requisitos |
|---|---|---|---|
| `global_notifications` | `add_scheduling_fields_to_global_notifications_table` | `reference_link`, `status`, `scheduled_at`, `sent_at` e o enum | R5, R7, R9 |

## Contrato da API

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `POST /api/v1/global-notifications` (CCD060) | acrescenta `scheduledAt?` | `201` com `status` | `400 SCHEDULE_IN_PAST` | R2–R6 |
| `POST /api/v1/global-notifications/:id/cancel` | — | `200` | `404`, `409 NOT_SCHEDULED` | R9 |
| `GET /api/v1/global-notifications` (CCD060) | — | acrescenta `status`, `scheduledAt`, `sentAt` | — | R8 |

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + migration | colunas e enum | R5 |
| `global-notifications.service.ts` + `.spec.ts` | agendar, cancelar e auditoria | R4, R5, R9 |
| `src/jobs/send-scheduled-notifications.job.ts` | entrega dos vencidos | R7 |
| validator · routes · swagger | `scheduledAt` e rota de cancelar | R1, R4 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/admin/notifications/` (api, queries, schema) | `scheduledAt` e cancelar | R2–R5, R9 |
| `components/ScheduleSelector/` | disparo imediato ou agendado, calendário e horário | R2–R4, R6 |
| `GlobalNotificationPage` (histórico) | status e cancelar | R8, R9 |

## Testes

| Critério | Onde |
|---|---|
| CA1, CA2, CA4 | `global-notifications.service.spec.ts` |
| CA3 | `send-scheduled-notifications.job.spec.ts` |
| CA5 | `GlobalNotificationPage.spec.tsx` |
| CA6 | integração |

## Decisões técnicas

- O job usa `SELECT … FOR UPDATE SKIP LOCKED` para não entregar duas vezes com mais de uma instância.
