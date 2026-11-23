# Plano — CCD110 Confirmar Entrega e Liberar Pagamento

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L8 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

O aviso `order.delivered` do Melhor Envio chega em `POST /api/v1/webhooks/melhor-envio`, que confere a assinatura, responde
`200` e marca o pedido `DELIVERED`; um job de hora em hora consulta o rastreio dos pedidos `SHIPPED` para cobrir o aviso
perdido. O comprador recebe o e-mail e vê no detalhe do pedido a data da liberação e "Confirmar recebimento"
(`POST /api/v1/me/orders/:id/confirm-receipt`). Confirmar, ou passar o prazo (job de liberação), chama o
`PaymentReleaseService`, que cria a transferência na Stripe (carta menos 5%, origem na cobrança do pedido), marca o pedido
`COMPLETED` e avisa o vendedor. O mesmo service atende o "Liberar agora" da CCD111.

## Dependências

- **CCD072 (Comprar):** `orders`, `payments` (`charge_id` gravado no `checkout.session.completed`), o `PaymentProvider` e o
  padrão de rota de webhook com corpo bruto. Esta story acrescenta ao provider a transferência por pedido.
- **CCD109:** `shipping_label_id`, `tracking_code` e o `ShippingProvider.getTracking`; e `order-deadlines.ts`, que ganha
  aqui a data da liberação e a regra de repasse pendente.
- **CCD108:** `users.stripe_account_id` e `stripe_account_status` do vendedor (destino da transferência).
- **CCD084:** `platform-fee.ts` (taxa de 5% arredondada para baixo).
- **CCD077 (Visualizar Pedidos):** dona do detalhe do pedido do comprador (`GET /api/v1/me/orders/:id` e a página do frame
  `1112-8820`). Esta story acrescenta `releaseAt` e `canConfirmReceipt` ao detalhe e o botão com o diálogo.
- **CCD111:** usa `PaymentReleaseService` no "Liberar agora" e `isReleasePending` no selo "Repasse pendente".
- **ADR-010:** jobs com `node-cron` em `src/jobs/` (a pasta real do backend), só com `JOBS_ENABLED=true`.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `orders` | não | — (CCD072) | `SHIPPED` → `DELIVERED` → `COMPLETED`; grava `delivered_at`, `platform_fee`, `stripe_transfer_id`, `released_at` |
| `payments` | não | — (CCD072) | só leitura: `charge_id` |
| `users` | sim | — (CCD108) | `email`, `stripe_account_id`, `stripe_account_status` |

Nenhuma coluna nova: o repasse pendente é calculado (depende da L5) e o prazo vem de variável de ambiente (depende da L4).

## Regras

- **Prazo de liberação** (R3, depende da L4 e da L7): `releaseAt = delivered_at + PAYMENT_RELEASE_DAYS × 24 h`, com
  `PAYMENT_RELEASE_DAYS` em `src/config/env.ts` (padrão 7; 0 em homologação).
- **Entrega** (R1, R2): `markDelivered(orderId, deliveredAt)` só muda pedido `SHIPPED` (update condicional
  `where status = SHIPPED`); se nada mudou, não manda e-mail. Assim o aviso repetido e a consulta periódica não duplicam
  (CA2). O webhook acha o pedido por `shipping_label_id`.
- **Assinatura** (R1): `X-ME-Signature` = HMAC-SHA256 do corpo bruto com `MELHOR_ENVIO_WEBHOOK_SECRET`, comparado em tempo
  constante; inválida → `400 INVALID_WEBHOOK_SIGNATURE` e nada muda. Válida → `200` na hora e o processamento depois da
  resposta.
- **Liberação** (R6, R7, R11): com lock do pedido (`pg_advisory_xact_lock`), só `DELIVERED` sem `stripe_transfer_id`;
  `platformFee = floor(items_amount × 5%)` em centavos, `net = items_amount − platformFee` (R$ 1.750,00 → R$ 87,50 / R$
  1.662,50; R$ 10,99 → R$ 0,54 / R$ 10,45); `createTransfer({ amount: net, destination: stripe_account_id,
  sourceTransaction: charge_id, transferGroup: order.id, idempotencyKey: 'release-' + order.id })`; o frete não entra. Grava
  `COMPLETED`, `platform_fee`, `stripe_transfer_id`, `released_at` e, depois do commit, o e-mail ao vendedor.
- **Falha** (R10): erro da Stripe deixa o pedido `DELIVERED` sem transferência e registra no log; o job tenta de novo na
  próxima execução. Conta do vendedor fora de `READY`: não tenta e fica pendente (depende da L8).
- **Repasse pendente** (R10, depende da L5): `isReleasePending(order, now)` = `DELIVERED`, `now ≥ releaseAt` e sem
  `stripe_transfer_id`, em `order-deadlines.ts`; o BackOffice mostra (CCD111).
- **Cancelado** (R9): pedido `CANCELED` nunca é liberado; confirmar responde `422 INVALID_ORDER_STATUS`.
- **Jobs** (R2, R8, depende da L6): `sync-shipments.job.ts` e `release-payments.job.ts`, os dois de hora em hora, chamando
  os services (ADR-010: o job só agenda).

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }`, JSON camelCase, dinheiro como string decimal, erros `{ error, message,
details? }`.

### `POST /api/v1/webhooks/melhor-envio` — R1

- **Acesso:** público, com `X-ME-Signature` conferida; corpo bruto (`express.raw`) só nesta rota.
- **Entrada:** o evento do Melhor Envio (`event: "order.delivered"`, `data.id` = id da etiqueta, `data.delivered_at`);
  outros eventos são aceitos e ignorados.
- **Sucesso:** `200` `{ "received": true }`
- **Erros:** `400 INVALID_WEBHOOK_SIGNATURE` (assinatura ausente ou inválida) — R1.

### `POST /api/v1/me/orders/:id/confirm-receipt` — R4–R7, R9, R11, R12

- **Acesso:** `authenticate`; só o comprador do pedido (`buyer_id` do token).
- **Entrada:** sem corpo.
- **Sucesso:** `200` `{ "data": { "id": "uuid", "status": "COMPLETED", "releasedAt": "…", "platformFee": "87.50",
  "sellerNetAmount": "1662.50" } }`
- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 401 | `UNAUTHORIZED` | sem token | R12 |
  | 404 | `ORDER_NOT_FOUND` | pedido inexistente ou de outro comprador | R12 |
  | 422 | `INVALID_ORDER_STATUS` | pedido fora de `DELIVERED` (inclusive `CANCELED` e `COMPLETED`) | R9, R11 |
  | 502 | `PAYMENT_TRANSFER_FAILED` | a Stripe recusou a transferência; o pedido continua `DELIVERED` | R10 |

### `GET /api/v1/me/orders/:id` (CCD077) — R3, R4

- Acrescenta ao corpo `releaseAt` (com `DELIVERED`) e `canConfirmReceipt` (`DELIVERED` e sem transferência).

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/config/env.ts` · `.env.example` | `PAYMENT_RELEASE_DAYS` (padrão 7) e `MELHOR_ENVIO_WEBHOOK_SECRET` | R1, R3, R8 |
| `src/providers/payment/payment.provider.ts` · `stripe.payment-provider.ts` · `fake.payment-provider.ts` | `createTransfer({ amountCents, destination, sourceTransaction, transferGroup, idempotencyKey })` → `{ transferId }` e erro `PaymentTransferFailedError` | R6, R7, R10 |
| `src/domains/marketplace/orders/order-deadlines.ts` (CCD109) | `releaseAt` e `isReleasePending` | R3, R8, R10 |
| `src/domains/marketplace/orders/order-delivery.service.ts` (+ `.spec.ts`) | `markDelivered` idempotente, e-mail ao comprador e consulta do rastreio dos `SHIPPED` | R1–R3 |
| `src/domains/marketplace/orders/payment-release.service.ts` (+ `.spec.ts`) | liberação com lock, taxa, transferência, e-mail ao vendedor, falha e lote dos vencidos | R6–R11 |
| `src/domains/marketplace/orders/buyer-orders.{controller,routes,swagger,errors}.ts` (CCD077) | ação `confirm-receipt` e os campos novos do detalhe | R4, R11, R12 |
| `src/domains/marketplace/shipping/melhor-envio-webhook.{controller,routes,signature}.ts` + módulo (`basePath: '/webhooks/melhor-envio'`) | rota com corpo bruto e conferência da assinatura | R1 |
| `src/providers/mail/templates/order-delivered.mail.ts` · `payment-released.mail.ts` | e-mail ao comprador (com a data da liberação) e ao vendedor | R3, R6 |
| `src/jobs/sync-shipments.job.ts` · `release-payments.job.ts` (+ `.spec.ts`) · `src/jobs/index.ts` | os dois jobs de hora em hora | R2, R8, R10 |
| `src/app.ts` · `src/routes.ts` | `express.raw` na rota do webhook antes do `express.json()`; registro dos módulos | R1 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/marketplace/orders/orders.{types,api,queries,labels}.ts` (CCD077) | `releaseAt`, `canConfirmReceipt`, a ação de confirmar e os textos (L2) | R3–R6 |
| `components/ConfirmReceiptDialog/` | diálogo do frame `1112-9136`: "Confirmar recebimento?", o texto da liberação com "Depois disso não é possível pedir reembolso pela CromoCard." (L3), "Cancelar" e "Confirmar recebimento" em carregamento e sem segundo clique; erro dentro do diálogo (CA12) | R5, R6, R13 |
| `pages/OrderDetailPage/` (CCD077) | no frame `1112-8820`: "Status: Entregue…", o passo "Concluído" com "O valor é liberado ao vendedor em <data>…", o botão "Confirmar recebimento" no "Resumo", a orientação e "Falar com o suporte" para a Central de ajuda (L1); depois de confirmar, o passo marcado e o aviso da L2 | R3, R4, R13 |

- **Componentes reaproveitados:** `ConfirmDialog`/`OverlayDialog`, `Button`, `Toast`, `FormError`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | `order.delivered` válido → `200`, `DELIVERED`, `delivered_at`, e-mail e liberação 7 dias depois (0 com `PAYMENT_RELEASE_DAYS=0`) | `order-delivery.service.spec.ts` · `tests/integration/marketplace/melhor-envio-webhook.spec.ts` · `OrderDetailPage.spec.tsx` |
| CA2 | assinatura inválida não muda nada; o mesmo aviso duas vezes muda uma vez e manda um e-mail | `melhor-envio-webhook.signature.spec.ts` · integração |
| CA3 | a consulta periódica marca entregue o pedido cujo aviso se perdeu | `order-delivery.service.spec.ts` · `sync-shipments.job.spec.ts` |
| CA4 | confirmar cria a transferência de R$ 1.662,50 com `source_transaction` e grava `COMPLETED`, taxa, id e data; e-mail ao vendedor | `payment-release.service.spec.ts` · `tests/integration/marketplace/confirm-receipt.spec.ts` |
| CA5 | R$ 10,99 → taxa R$ 0,54 e líquido R$ 10,45 | `platform-fee.spec.ts` · `payment-release.service.spec.ts` |
| CA6 | "Cancelar" no diálogo não chama a API | `ConfirmReceiptDialog.spec.tsx` |
| CA7 | 7 dias sem confirmação liberam; 6 dias não | `payment-release.service.spec.ts` · `release-payments.job.spec.ts` |
| CA8 | pedido cancelado não é liberado e confirmar responde `422` | `payment-release.service.spec.ts` · integração |
| CA9 | Stripe recusando deixa `DELIVERED` sem transferência, pendente, e a próxima execução tenta de novo | `payment-release.service.spec.ts` |
| CA10 | `SHIPPED` e `COMPLETED` respondem `422` sem transferência | integração |
| CA11 | `401` sem token; `404` para outro cliente | integração |
| CA12 | botão em carregamento, sem segundo clique; erro mostrado e pedido continua Entregue | `ConfirmReceiptDialog.spec.tsx` |
| CA13, CA14 | print em 1280 px igual aos frames `1112-8820` e `1112-9136`, sem quebra em 375/768/1024 px | revisão visual (`/cromocard-revisor`) |

## Decisões técnicas

- Um service só (`PaymentReleaseService`) libera o pagamento na confirmação, no job e no "Liberar agora" da CCD111, com lock
  do pedido e `idempotencyKey` da Stripe por pedido: uma transferência por pedido, mesmo com chamadas simultâneas.
- A entrega é idempotente pelo update condicional do status, sem guardar ids de eventos do Melhor Envio.
- A frequência de hora em hora dos jobs (L6) não está no ADR-010; se o PO aceitar a proposta, entra num ADR novo `Proposto`
  ou numa revisão do ADR-010 antes do código.
- Risco: sem coluna para a confirmação, se a transferência falhar logo depois de o comprador confirmar, o pedido continua
  `DELIVERED` e o job só o pega quando o prazo vence; até lá o comprador pode confirmar de novo, e o admin só o vê como
  pendente depois do prazo (L5). Levar para a decisão da L5.
