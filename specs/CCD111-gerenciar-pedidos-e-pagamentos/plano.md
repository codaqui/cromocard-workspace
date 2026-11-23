# Plano — CCD111 Gerenciar Pedidos e Pagamentos

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L12 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

O item "Pedidos e pagamentos" do BackOffice (`/backoffice/orders`, abaixo de Catálogo) abre a página com os 4 totais
(`GET /api/v1/admin/orders/summary`) e a lista paginada com abas, busca e período (`GET /api/v1/admin/orders`). "Ver" abre o
painel lateral com o detalhe (`GET /api/v1/admin/orders/:id`). "Cancelar e reembolsar" pede o motivo e chama
`POST /:id/cancel`, que reembolsa pela Stripe, cancela o pedido, avisa as duas partes e grava `audit_logs`. "Liberar agora"
chama `POST /:id/release`, que usa o `PaymentReleaseService` da CCD110 e grava `audit_logs`.

## Dependências

- **CCD072 (Comprar):** `orders`, `payments` (`gateway_reference`, `charge_id`) e o `PaymentProvider`; esta story acrescenta
  ao provider o reembolso.
- **CCD110:** `PaymentReleaseService` (liberação com lock, taxa e transferência), `releaseAt` e `isReleasePending` em
  `order-deadlines.ts`.
- **CCD109:** `isShipmentLate` (selo "Atrasado", R5) e `order-number.ts` (número legível, depende da L3).
- **CCD084:** `platform-fee.ts`; `listings.available_quantity`, que recebe a unidade de volta no cancelamento de pedido não
  enviado (depende da L9).
- **CCD065 (Implementada):** `auditLogService` para as duas ações (ADR-034).
- **CCD097 (Planejada):** o "Em custódia" do Dashboard; a L1 propõe alinhar a regra das duas telas (`PAID`, `SHIPPED` e
  `DELIVERED`). Se o PO aceitar, a CCD097 muda junto, no plano dela.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `orders` · `payments` | não | — (CCD072) | cancelamento grava `CANCELED` e `cancel_reason`; pagamento `REFUNDED` e `refunded_at`; liberação como na CCD110 |
| `listings` | não | — (CCD084) | `available_quantity` + `quantity` ao cancelar pedido `PAID` (depende da L9) |
| `users` · `cards` · `albums` · `categories` · `card_conditions` | sim / não | — | comprador, vendedor, carta e "<categoria> • <álbum> • <condição>" (L6) |
| `audit_logs` | sim | — | `ORDER_REFUNDED` e `ORDER_PAYMENT_RELEASED`, `entity_type: 'order'`, `details` com o motivo ou o valor |

Nenhuma coluna nova.

## Regras

- **Totais** (R3, depende da L1): "Em custódia" = soma de `total_amount` e contagem dos `PAID`, `SHIPPED` e `DELIVERED`;
  "A liberar em 7 dias" = líquido dos `DELIVERED` com `releaseAt` nos próximos 7 dias; "Liberado no mês" = líquido e
  contagem dos `COMPLETED` com `released_at` no mês (fuso de Brasília); "Repasses pendentes" = contagem de
  `isReleasePending`. Os totais não dependem do filtro de período (depende da L2).
- **Lista** (R4, R6): mais recentes primeiro (`created_at desc`); abas por `status` com contagem; período padrão 30 dias por
  `created_at` (depende da L2); busca pelo número do pedido, ou por nome ou `username` do comprador ou do vendedor, sem
  diferenciar maiúsculas (depende da L11); 8 por página (depende da L12).
- **Selos e linha de apoio** (R5, depende da L4): "Atrasado" com `isShipmentLate`; "Repasse pendente" com `isReleasePending`;
  a linha de apoio sai do status e das datas ("Libera em …", "Sem etiqueta há <n> dias", "Liberado em …", "Reembolsado",
  "Reserva até …").
- **Ações por status** (R8, R11, R12): "Cancelar e reembolsar" em `PAID`, `SHIPPED` e `DELIVERED`; "Liberar agora" só em
  `DELIVERED`; `COMPLETED` e `CANCELED` → `422 ORDER_ALREADY_CLOSED`; `AWAITING_PAYMENT` → `422 INVALID_ORDER_STATUS`.
- **Cancelar e reembolsar** (R9, R10): motivo obrigatório (1–255, sem só espaços). Com lock do pedido, reembolsa
  `total_amount` (carta e frete) pela `charge_id` com `idempotencyKey = 'refund-' + order.id`; se a Stripe recusar, nada
  muda e a API responde `502 PAYMENT_REFUND_FAILED` (CA11). Com sucesso, numa transação: pedido `CANCELED` com
  `cancel_reason`, pagamento `REFUNDED` com `refunded_at`, unidade de volta ao estoque se o pedido era `PAID`, e `audit_logs`;
  a etiqueta já comprada não é cancelada (depende da L9). Depois do commit, e-mail ao comprador e ao vendedor com o motivo.
- **Liberar agora** (R11): `PaymentReleaseService.release(orderId)` da CCD110, que já impede a liberação dupla; conta do
  vendedor fora de `READY` → `422 STRIPE_ACCOUNT_NOT_READY` com "A conta Stripe do vendedor não está pronta" (depende da
  L10); grava `audit_logs` na mesma transação.
- **Identificador do pagamento** (R7, depende da L5): "Pagamento na Stripe" mostra `payments.charge_id`.

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, dinheiro como string decimal, erros
`{ error, message, details? }`. Todas as rotas: `authenticate` + `authorize('ADMIN')`, com `401 UNAUTHORIZED` e
`403 FORBIDDEN` para `CUSTOMER` e `SELLER` (R1).

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `GET /api/v1/admin/orders/summary` | — | `200` `{ data: { custody: { amount, orders }, toReleaseIn7Days: { amount, orders }, releasedThisMonth: { amount, orders }, pendingTransfers: { orders } } }` | — | R3 |
| `GET /api/v1/admin/orders` | `status` (`order_status`, opcional), `q`, `period` (`7d` \| `30d` \| `90d` \| `all`, padrão `30d`), `page`, `pageSize` (padrão 8) | `200` `{ data: AdminOrder[], meta: { page, pageSize, total, counts: { all, AWAITING_PAYMENT, PAID, SHIPPED, DELIVERED, COMPLETED, CANCELED } } }` | `400 VALIDATION_ERROR` | R4–R6, R13 |
| `GET /api/v1/admin/orders/:id` | — | `200` `{ data: AdminOrderDetail }` | `404 ORDER_NOT_FOUND` | R7, R8, R11, R12 |
| `POST /api/v1/admin/orders/:id/cancel` | `{ "reason": "string 1–255" }` | `200` `{ data: AdminOrderDetail }` | `400 VALIDATION_ERROR` ("O motivo é obrigatório."), `404 ORDER_NOT_FOUND`, `422 ORDER_ALREADY_CLOSED`, `422 INVALID_ORDER_STATUS`, `502 PAYMENT_REFUND_FAILED` | R8–R10, R12 |
| `POST /api/v1/admin/orders/:id/release` | sem corpo | `200` `{ data: AdminOrderDetail }` | `404 ORDER_NOT_FOUND`, `422 ORDER_ALREADY_CLOSED`, `422 INVALID_ORDER_STATUS`, `422 STRIPE_ACCOUNT_NOT_READY`, `502 PAYMENT_TRANSFER_FAILED` | R11, R12 |

```ts
AdminOrder = { id, number, createdAt, status, card: { name, frontImageUrl },
  buyer: { name, username }, seller: { name, username }, totalAmount, late: boolean, releasePending: boolean,
  statusDetail: { kind: 'RELEASES_ON' | 'NO_LABEL_FOR' | 'SHIP_BY' | 'TRANSFER_FAILED' | 'RELEASED_ON' | 'REFUNDED' | 'RESERVED_UNTIL' | null, date?, days?, service? } }
AdminOrderDetail = AdminOrder & {
  card: { name, frontImageUrl, category, album, condition },
  timeline: { paidAt, shippedAt, deliveredAt, releaseAt, releasedAt, canceledAt },
  payment: { itemsAmount, shippingAmount, shippingService, totalAmount, platformFee, sellerNetAmount, chargeId, transferId, refundedAt },
  shipping: { service, trackingCode, trackingUrl },
  buyer: { id, name, username }, seller: { id, name, username, stripeAccountReady },
  cancelReason, actions: { canCancel, canRelease } }
```

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/providers/payment/payment.provider.ts` · `stripe.payment-provider.ts` · `fake.payment-provider.ts` | `refundCharge({ chargeId, amountCents, idempotencyKey })` → `{ refundId }` e erro `PaymentRefundFailedError` | R9 |
| `src/domains/admin/orders/admin-orders.{validator,repository,service,controller,routes,swagger,errors}.ts` + `admin-orders.module.ts` (`basePath: '/admin/orders'`) | totais, lista, detalhe, cancelar e liberar, com auditoria | R1, R3–R13 |
| `admin-orders.status-detail.ts` (+ `.spec.ts`) | selos e linha de apoio do status | R4, R5 |
| `src/providers/mail/templates/order-canceled.mail.ts` | e-mail do cancelamento ao comprador e ao vendedor, com o motivo | R9 |
| `database/seeds/data/orders.json` · `payments.json` (CCD072/CCD097) | pedidos em todos os status, um `PAID` há 3 dias sem etiqueta e um `DELIVERED` vencido sem transferência | R3–R5 |
| `src/routes.ts` | registra o módulo | R1 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/admin/orders/`, no modelo das outras telas de `src/features/admin/` (ADR-040).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/routes/paths.ts` · `app/layouts/AdminLayout/adminMenu.ts` (+ ícone em `assets/`) | `backoffice.orders: '/backoffice/orders'` e o item "Pedidos e pagamentos" logo abaixo de Catálogo | R2 |
| `orders.{types,api,queries,labels,format}.ts` · `admin-orders.routes.ts` | chamadas, textos (L7, L8), número do pedido e moeda | R3–R13 |
| `pages/AdminOrdersPage/` | página do frame `1157-29979`: "BACKOFFICE • MARKETPLACE", título, subtítulo, totais, busca, "Período", abas com contagem, "PEDIDOS" com "<n> de <total> pedidos", tabela, selos, "Ver" e paginação; vazio do frame `1157-35305` com "Limpar filtros" | R2–R6, R13, R14 |
| `components/OrdersSummaryCards/` · `components/AdminOrdersTable/` | os 4 totais; linhas com "vendido por @…", selo e linha de apoio | R3–R5, R14 |
| `components/OrderDetailDrawer/` | painel do frame `1157-30793`: carta com "<categoria> • <álbum> • <condição>", "Linha do tempo", "Pagamento", "Envio" com "Abrir rastreio no Melhor Envio ↗", "Comprador e vendedor" (L6), as ações por status e o aviso de pedido encerrado (L7) | R7, R8, R11, R12, R14 |
| `components/CancelRefundDialog/` | diálogos dos frames `1157-31707` e `1157-32634` ("O motivo é obrigatório."), "Voltar" e "Cancelar e reembolsar" em carregamento; erro da Stripe | R8–R10, R14 |
| `components/ReleaseNowDialog/` | diálogo do frame `1157-33562`, "Voltar" e "Liberar agora"; erro da conta não pronta (L10) | R11, R14 |
| `components/OrderOperationResult/` | retorno do frame `1157-34488` ("Pedido #… cancelado e reembolsado…") e o de "Liberar agora" (L8) | R9, R11, R14 |

- **Estados:** `LoadingState` e `ErrorState` com "Tentar de novo" (CA12); `EmptyState` do frame `1157-35305`.
- **Componentes reaproveitados:** `DataTable`, `Tabs`, `SearchBar`, `Select`, `Pagination`, `KpiCard`, `Badge`, `Drawer`,
  `ConfirmDialog`, `Textarea`, `FormError`, `Button`, `Toast`, `EmptyState`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | 4 totais, lista do mais recente ao mais antigo com os campos, selo "Atrasado" | `admin-orders.service.spec.ts` · `admin-orders.status-detail.spec.ts` · `tests/integration/admin/orders.spec.ts` · `AdminOrdersPage.spec.tsx` |
| CA2 | aba "Entregue" só com `DELIVERED`; busca por @vendedor e por número | `admin-orders.service.spec.ts` · integração · `AdminOrdersPage.spec.tsx` |
| CA3 | detalhe do `DELIVERED` com linha do tempo, pagamento, `charge_id`, "Aguardando liberação" e envio | integração · `OrderDetailDrawer.spec.tsx` |
| CA4 | reembolso de R$ 1.788,40 no provider falso, `CANCELED` com motivo, `REFUNDED`, dois e-mails, `audit_logs` e a mensagem de sucesso | `admin-orders.service.spec.ts` · integração · `CancelRefundDialog.spec.tsx` |
| CA5 | motivo vazio mostra "O motivo é obrigatório." e a API responde `400` | `CancelRefundDialog.spec.tsx` · integração |
| CA6 | "Liberar agora" cria a transferência, `COMPLETED` com id e data, `audit_logs` | `admin-orders.service.spec.ts` · integração · `ReleaseNowDialog.spec.tsx` |
| CA7 | `PAID` só com "Cancelar e reembolsar"; `DELIVERED` com as duas | `admin-orders.service.spec.ts` · `OrderDetailDrawer.spec.tsx` |
| CA8 | `COMPLETED` e `CANCELED` sem ações, com o aviso; API `422` | integração · `OrderDetailDrawer.spec.tsx` |
| CA9 | busca "CC-99999" mostra o vazio e "Limpar filtros" volta à lista | `AdminOrdersPage.spec.tsx` |
| CA10 | `401` sem token; `403` para `CUSTOMER` e `SELLER` | integração |
| CA11 | Stripe recusando o reembolso: erro, status anterior, nada cancelado | `admin-orders.service.spec.ts` · `CancelRefundDialog.spec.tsx` |
| CA12 | carregamento e erro com nova tentativa | `AdminOrdersPage.spec.tsx` |
| CA13–CA19 | print em 1280 px igual aos frames `1157-29979`, `1157-30793`, `1157-31707`, `1157-32634`, `1157-33562`, `1157-34488` e `1157-35305`, sem quebra em 375/768/1024 px | revisão visual (`/cromocard-revisor`) |

## Decisões técnicas

- O reembolso é chamado na Stripe antes da transação do banco, com `idempotencyKey` por pedido; se o banco falhar depois,
  a nova tentativa do admin não reembolsa duas vezes.
- "Liberar agora" reaproveita o `PaymentReleaseService` da CCD110, para a regra da taxa e da liberação única ficar num lugar
  só; o domínio `admin/orders` só acrescenta a auditoria.
- Os totais vêm num endpoint próprio, sem o filtro da lista, para a busca não recalcular as somas a cada tecla.
