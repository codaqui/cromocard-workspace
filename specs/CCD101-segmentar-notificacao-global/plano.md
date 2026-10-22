# Plano — CCD101 Segmentar Notificação Global

- **Spec:** [spec.md](spec.md) — feito sobre a spec em Rascunho (pedido do PO em 2026-10-22), com as propostas das lacunas
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade

## Solução

Migration com público e canais; o serviço de notificação global calcula os destinatários pelo público, cria as notificações no app e enfileira os e-mails em lote.

## Dependências

- CCD060 e CCD100 (mesma tabela e tela).
- CCD098 (`last_login_at`).

## Dados e migrations

Cada coluna entra com esta story, numa migration própria (ADR-053, item 10).

| Tabela | Migration | O que muda | Requisitos |
|---|---|---|---|
| `global_notifications` | `add_audience_fields_to_global_notifications_table` | `audience`, `channels` | R6 |

## Contrato da API

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `POST /api/v1/global-notifications` (CCD060) | acrescenta `audience`, `channels` | `201` | `400`, `422 EMPTY_AUDIENCE` | R2, R4–R9 |
| `GET /api/v1/global-notifications/recipients-count` (CCD060) | acrescenta `audience` | `200` `{ count }` | `400` | R3 |
| `GET /api/v1/global-notifications` (CCD060) | — | acrescenta `audience`, `channels` | — | R10 |

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + migration | colunas novas | R6 |
| `global-notifications.service.ts` + `.spec.ts` · `audience.ts` | destinatários por público, canais e contagem | R2, R3, R5, R6, R8, R9 |
| `src/jobs/send-notification-emails.job.ts` | e-mails em lote pelo `MailProvider` | R5 |
| validator · swagger | campos novos | R1, R9 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/admin/notifications/` (api, schema) | público e canais | R2–R4 |
| `components/AudienceSelector/` · `ChannelSelector/` | público com contagem e canais | R2–R4, R7–R9 |
| histórico | colunas público e canal | R10 |

## Testes

| Critério | Onde |
|---|---|
| CA2–CA4 | `global-notifications.service.spec.ts` |
| CA1, CA5 | `GlobalNotificationPage.spec.tsx` |
| CA6 | integração |

## Decisões técnicas

- `channels` é gravado como lista separada por vírgula (`IN_APP,EMAIL`), como no DBML.
