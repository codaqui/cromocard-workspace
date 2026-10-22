# Plano — CCD060 Disparar Notificação Global

- **Spec:** [spec.md](spec.md), aprovada em 2026-10-22
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade

## Solução

`POST /api/v1/global-notifications` grava o disparo e, na mesma transação, um `createMany` em `notifications` para os
destinatários (ativos, não excluídos, menos o admin), atualiza `recipient_count` e grava `audit_logs`. A tela tem o
formulário com pré-visualização, o diálogo de confirmação e o histórico.

## Dependências

- Fundação (tabelas, `AuditLogService`, `ConfirmDialog`, `Textarea`, `DataTable`).

## Contrato da API

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `POST /api/v1/global-notifications` | `{ title, content, link? }` | `201` `{ data: { id, title, content, recipientCount, createdAt } }` | `400 VALIDATION_ERROR` | R3–R6, R8–R13, R15 |
| `GET /api/v1/global-notifications` | `page`, `pageSize` | `200` `{ data: [{ id, title, recipientCount, adminName, createdAt }], meta }` | — | R16 |
| `GET /api/v1/global-notifications/recipients-count` | — | `200` `{ data: { count } }` | — | R6 (texto do diálogo) |

Todas com `authenticate` + `authorize('ADMIN')`.

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/notifications/global-notifications.validator.ts` | título 1–120, conteúdo 1–500, link URL opcional | R3–R5 |
| `global-notifications.repository.ts` | transação: disparo + `createMany` + `recipient_count` | R8–R10 |
| `global-notifications.service.ts` + `.spec.ts` | destinatários, auditoria | R8, R13, R14 |
| `global-notifications.controller.ts` · `.routes.ts` · `.swagger.ts` · `notifications.module.ts` | rotas | R1, R12 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/notifications/global-notifications.api.ts` · `.queries.ts` · `.schemas.ts` | chamadas e schema | R3–R5 |
| `pages/GlobalNotificationPage/` | formulário com contadores, pré-visualização, `ConfirmDialog` "Enviar para N usuários?", confirmação e histórico | R2, R6, R7, R11 |

## Testes

| Critério | Onde |
|---|---|
| CA1, CA4 | `global-notifications.service.spec.ts` · integração |
| CA2, CA3, CA5 | `GlobalNotificationPage.spec.tsx` |
| CA6 | integração |

## Decisões técnicas

- Entrega síncrona com `createMany` em lotes de 1.000; com a base do MVP não precisa de fila (ADR-010 cita BullMQ só
  como evolução).
