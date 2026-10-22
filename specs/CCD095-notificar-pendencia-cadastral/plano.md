# Plano — CCD095 Notificar Pendência Cadastral

- **Spec:** [spec.md](spec.md) — feito sobre a spec em Rascunho (pedido do PO em 2026-10-22), com as propostas das lacunas
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade

## Solução

Rota de envio no domínio do credenciamento: monta a mensagem a partir do modelo, cria a notificação, envia o e-mail fora da transação e marca o cadastro como pendente com o prazo.

## Dependências

- CCD094 (`seller_verifications` e o dossiê).
- Fundação (`AuditLogService`, `Modal`, `Select`, `Textarea`).

## Dados e migrations

Cada coluna entra com esta story, numa migration própria (ADR-053, item 10).

| Tabela | Migration | O que muda | Requisitos |
|---|---|---|---|
| `global_settings` | — (seed) | chave `seller.pending_templates` | R12 |

## Contrato da API

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `GET /api/v1/admin/seller-verifications/pending-templates` | — | `200` `{ data: [{ key, title, body }] }` | — | R4, R12 |
| `POST /api/v1/admin/seller-verifications/:id/pending-notice` | `{ templateKey?, message, deadlineHours }` | `200` `{ data: { sentAt, channels, emailDelivered } }` | `400`, `404`, `409` | R5–R8, R11 |

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/seeds/settings.seed.ts` | chave `seller.pending_templates` | R12 |
| `seller-verifications/pending-notice.validator.ts` · `pending-notice.service.ts` + `.spec.ts` | modelo, variáveis, notificação, e-mail, prazo e auditoria | R4–R8, R11 |
| controller · routes · swagger | rotas acima | R1 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/admin/seller-verifications/` (api, queries) | modelos e envio | R4–R8 |
| `components/PendingNoticeModal/` · `PendingNoticeSent/` | formulário com modelos, prazo e confirmação | R2–R6, R9, R10 |

## Testes

| Critério | Onde |
|---|---|
| CA3, CA5, CA6 | `pending-notice.service.spec.ts` · integração |
| CA1, CA2, CA4 | `PendingNoticeModal.spec.tsx` |
| CA7 | integração |

## Decisões técnicas

- Novo `notifications.type`: `SELLER_PENDING` (ADR-051, item 2).
- O e-mail sai depois do commit da transação; a falha só é registrada no log e devolvida em `emailDelivered`.
