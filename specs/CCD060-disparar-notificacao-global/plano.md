# Plano — CCD060 Disparar Notificação Global (com CCD100 e CCD101)

- **Spec:** [spec.md](spec.md), aprovada em 2026-10-22; revisões de 12/11/2026 e de 16/11/2026 (L9–L14)
- **Data:** 2026-10-21, refeito em 2026-11-16 · **Autor:** Daniel Andrade
- **Entrega conjunta (L9):** este plano consolida o contrato da CCD060, da [CCD100](../CCD100-agendar-notificacao-global/plano.md)
  e da [CCD101](../CCD101-segmentar-notificacao-global/plano.md). Os planos delas continuam valendo para as regras de cada
  uma; onde divergirem deste, vale este.

## Solução

`POST /api/v1/global-notifications` valida o disparo, calcula os destinatários do público e:

- **disparo imediato:** numa transação, grava o disparo `SENT` com `sent_at`, um `createMany` em `notifications` (canal
  plataforma, em lotes de 1.000) e o `recipient_count`; depois grava `audit_logs` e, com o canal e-mail, envia os e-mails
  em lotes fora da requisição;
- **agendado (CCD100):** grava o disparo `SCHEDULED` com `scheduled_at` e `audit_logs`; um job de minuto em minuto entrega
  os vencidos do mesmo jeito do disparo imediato, calculando os destinatários na hora (CCD100, L1).

A tela tem o formulário (título, mensagem, link, público com a contagem de cada um, canais, quando enviar), a
pré-visualização, o aviso e o botão com o total de destinatários, o modal de sucesso e o histórico paginado com o
cancelar agendamento.

## Dados e migrations

Cada coluna entra numa migration própria (ADR-053, item 10). O DBML já tem as colunas.

| Tabela | Migration | O que muda | Story |
|---|---|---|---|
| `global_notifications` | `add_scheduling_fields_to_global_notifications_table` | `reference_link`, `status` (enum `notification_dispatch_status`), `scheduled_at`, `sent_at` | CCD100 |
| `global_notifications` | `add_audience_fields_to_global_notifications_table` | `audience`, `channels` | CCD101 |

## Destinatários

| Público (`audience`) | Quem | Origem |
|---|---|---|
| `ALL` (Toda a base) | `status = ACTIVE`, `deleted_at` nulo, menos o admin que disparou | `60`, FP 7 (L10) |
| `ACTIVE_COLLECTORS` (Colecionadores ativos) | os de `ALL` com `role = CUSTOMER` e `last_login_at` nos últimos 30 dias | `101`, FP 2 (L2) |
| `SELLERS` (Vendedores) | os de `ALL` com `role = SELLER` | `101`, FP 2 |

## Contrato da API

Todas com `authenticate` + `authorize('ADMIN')`.

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `POST /api/v1/global-notifications` | `{ title, content, link?, audience = 'ALL', channels = ['IN_APP'], scheduledAt? }` | `201` `{ data: GlobalNotification }` | `400 VALIDATION_ERROR` (com `details`, inclusive `scheduledAt` com menos de 5 minutos e `channels` vazio), `422 EMPTY_AUDIENCE` | 060 R3–R6, R8–R15 · 100 R2–R5 · 101 R2, R4–R9 |
| `GET /api/v1/global-notifications` | `page`, `pageSize` | `200` `{ data: GlobalNotification[], meta }`, do mais recente ao mais antigo | — | 060 R16 · 100 R8 · 101 R10 |
| `GET /api/v1/global-notifications/recipients-count` | — | `200` `{ data: { ALL, ACTIVE_COLLECTORS, SELLERS } }` | — | 060 R18 · 101 R3 |
| `POST /api/v1/global-notifications/:id/cancel` | — | `200` `{ data: GlobalNotification }` | `404 GLOBAL_NOTIFICATION_NOT_FOUND`, `409 NOT_SCHEDULED` | 100 R9 |

`GlobalNotification`: `{ id, title, content, referenceLink, audience, channels, status, recipientCount, scheduledAt,
sentAt, createdAt, admin: { id, name } }`.

- `link`: caminho começando com `/` ou URL `http(s)`, até 255 caracteres (L12).
- `channels`: `IN_APP` e `EMAIL`, pelo menos um, gravado como `IN_APP,EMAIL` (CCD101).
- `recipientCount` de um agendado é `0` até o envio.

## Auditoria

| Ação | Quando | `entityType` / `details` |
|---|---|---|
| `GLOBAL_NOTIFICATION_SENT` | disparo imediato e entrega do agendado (`adminId` = quem agendou) | `global_notification` · `{ audience, channels, recipientCount }` |
| `GLOBAL_NOTIFICATION_SCHEDULED` (nova) | agendamento | `global_notification` · `{ audience, channels, scheduledAt }` |
| `GLOBAL_NOTIFICATION_CANCELED` (nova) | cancelar agendamento | `global_notification` |

## Backend

| Arquivo | O que muda |
|---|---|
| `database/schema.prisma` + 2 migrations | colunas e enum |
| `src/domains/notifications/global-notifications.validator.ts` | corpo, paginação |
| `global-notifications.audience.ts` | o filtro de cada público (Strategy) |
| `global-notifications.repository.ts` | contagem, histórico, entrega em transação, agendados vencidos com `FOR UPDATE SKIP LOCKED`, cancelar condicional |
| `global-notifications.service.ts` + `.spec.ts` | disparar, agendar, entregar, cancelar, auditoria, e-mail |
| `global-notifications.controller.ts` · `.routes.ts` · `.swagger.ts` · `notifications.module.ts` | rotas |
| `src/jobs/send-scheduled-notifications.job.ts` + `.spec.ts` | job de minuto em minuto |
| `src/providers/mail/templates/global-notification.mail.ts` | e-mail do disparo |
| `src/domains/admin/audit-logs/audit-logs.validator.ts` | as duas ações novas |

## Frontend

| Arquivo | O que muda |
|---|---|
| `src/features/admin/notifications/` (`.types`, `.api`, `.queries`, `.schemas`, `.labels`) | chamadas, schema espelhando o validator, rótulos |
| `components/NotificationForm/` · `AudienceSelector/` · `ChannelSelector/` · `ScheduleSelector/` | formulário |
| `components/NotificationPreview/` | item da central de notificações, com o ícone do CromoCard |
| `components/DispatchHistory/` · `CancelScheduleDialog/` · `DispatchResultDialog/` | histórico, cancelar, modal de enviada/agendada |
| `pages/GlobalNotificationPage/` | a tela em `/backoffice/notificacoes` |
| `src/features/admin/audit-logs/audit-logs.labels.ts` · `.types.ts` | rótulos das ações novas |

## Testes

| Critério | Onde |
|---|---|
| 060 CA1, CA4 · 100 CA1, CA2, CA4 · 101 CA2–CA4 | `global-notifications.service.spec.ts` · integração |
| 100 CA3 | `send-scheduled-notifications.job.spec.ts` · integração |
| 060 CA2, CA3, CA5, CA7–CA9 · 100 CA4, CA5, CA7 · 101 CA1, CA5 | `GlobalNotificationPage.spec.tsx` e componentes |
| 060 CA6 · 100 CA6 · 101 CA6 | integração |

## Decisões técnicas

- Entrega síncrona com `createMany` em lotes de 1.000; com a base do MVP não precisa de fila (ADR-010 cita BullMQ só como
  evolução).
- O job usa `node-cron` (já usado pelo `cleanup-expired-tokens`) e `SELECT … FOR UPDATE SKIP LOCKED` para não entregar duas
  vezes com mais de uma instância.
- Os e-mails saem em lotes de 50 depois da resposta, pelo `MailProvider`; falha num e-mail é registrada no log e não
  desfaz a entrega na plataforma.
