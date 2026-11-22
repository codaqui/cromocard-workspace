# Plano — CCD072 Comprar

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L14 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

"Comprar" no detalhe do anúncio (CCD079) abre o checkout (`/anuncios/:id/checkout`), que carrega o anúncio, os endereços e
se falta o CPF, e cota o frete no Melhor Envio para o endereço escolhido. "Ir para o pagamento" chama `POST /orders`: numa
transação, o backend confere o anúncio, baixa uma unidade (reserva), grava o pedido `AWAITING_PAYMENT` e o pagamento
`PENDING`, cria a sessão do Stripe Checkout e devolve a URL. O webhook da Stripe fecha o ciclo: `completed` deixa o pedido
`PAID` e avisa o vendedor por e-mail; `expired` cancela e devolve a unidade. Na volta, `/pedidos/:id/pagamento` mostra
"Pagamento confirmado" ou "Pagamento não concluído". Stripe e Melhor Envio ficam atrás do `PaymentProvider` e do
`ShippingProvider` (ADR-009), com versões falsas nos testes e no PC.

## Dependências

- **CCD079**: `GET /listings/:id` com `availability` e `isOwner`, e a página `/anuncios/:id` com o `ListingPurchasePanel`
  ("Indisponível" e "Outros anúncios", R16).
- **CCD097** (ADR-054): cria `listings`, `orders` e `payments` no banco, só de leitura; pelo ADR-054, item 3, esta story
  passa a gravar nelas sem migration nova. Se a CCD097 ainda não tiver entrado, as migrations dela vêm antes desta story.
- **CCD084**: `card_conditions` e a criação de anúncios.
- **CCD048**: os endpoints dos endereços do cliente (`/me/addresses`) e o formulário, reaproveitado no "+ Cadastrar novo
  endereço" (depende da L7).
- **CCD030 / CCD055**: `LoginToContinueModal` (R15).
- **CCD077**: "Meus pedidos" e o detalhe, para onde levam "Ver pedido" e o pedido cancelado (R20). Esta story cria o
  `GET /orders/:id` com os campos da tela de resultado; a CCD077 o estende.
- **PR de docs no DBML** antes do código para o número do pedido (L1).
- `src/providers/payment/` e `src/providers/shipping/` existem vazios: esta story cria os dois providers.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `orders` | da CCD097 | — (ADR-054, item 3) | passa a ser gravada: pedido, status e `cancel_reason` (R10, R12, R19) |
| `payments` | da CCD097 | — (ADR-054, item 3) | passa a ser gravada: `PENDING` e `APPROVED` (R11, R12) |
| `listings` | da CCD097 | — | `available_quantity` baixa ao criar o pedido e volta ao cancelar (reserva, depende da L2) |
| `users` | sim | — | `cpf` (R7) |
| `addresses` | sim | — | entrega do comprador e `is_primary` do vendedor (R6, R8) |
| número do pedido (`#PED-…`) | não (o DBML não tem) | depende da L1 | R14: PR de docs no DBML antes do código |

## Regras

- **Quem compra** (R1): `CUSTOMER` e `SELLER` com `status = ACTIVE`; suspenso ou bloqueado → `403 ACCOUNT_INACTIVE`.
- **Anúncio comprável** (R2): `ACTIVE`, `available_quantity > 0`, `deleted_at` nulo e `seller_id` diferente do comprador;
  senão `422 LISTING_UNAVAILABLE` ou `422 OWN_LISTING`. Mesma função de disponibilidade da CCD079.
- **Pré-seleção** (R6): o endereço principal do comprador e nenhum frete (depende da L8).
- **CPF** (R7): pedido só com `users.cpf` nulo; validado com `src/shared/validators/cpf.ts`; gravado na mesma transação do
  pedido; já usado por outra conta → `409 CPF_IN_USE` (mensagem depende da L9).
- **Cotação** (R8): origem = CEP do endereço principal do vendedor; pacote 16 × 11 × 2 cm, 100 g, valor declarado = preço;
  só Correios e Jadlog. Vendedor sem endereço principal → `422 SELLER_WITHOUT_ADDRESS` (depende da L10); provider com erro
  → `502 SHIPPING_PROVIDER_ERROR` (texto depende da L12).
- **Criar o pedido** (R5, R10, R17): o backend cota de novo e usa o preço do serviço escolhido, nunca o valor vindo da tela.
  A reserva é um `updateMany` em `listings` com `available_quantity > 0` e `status = ACTIVE` (baixa 1); zero linhas →
  `422 LISTING_UNAVAILABLE` e nada é gravado. `quantity = 1`; `items_amount` = preço; `total_amount` = preço + frete;
  `shipping_method` = transportadora e `shipping_service` = id do serviço no Melhor Envio (depende da L3).
- **Sessão** (R11): `mode: payment`, `brl`, duas linhas (carta e frete), `expires_at` = agora + 30 min, `metadata.orderId`,
  `success_url` e `cancel_url` para `/pedidos/:id/pagamento`. Se a Stripe falha, a transação desfaz pedido e reserva.
- **`checkout.session.completed`** (R12): pedido `AWAITING_PAYMENT` → `PAID` com `paid_at`; pagamento → `APPROVED` com
  `charge_id` e `paid_at`; e-mail ao vendedor (texto depende da L11).
- **`checkout.session.expired`** e volta pelo `cancel_url` (R19): o `cancel_url` expira a sessão pela API (depende da L4);
  o evento leva o pedido a `CANCELED` com `cancel_reason = 'pagamento não concluído'` e devolve a unidade; o pagamento
  continua `PENDING` (depende da L14).
- **Idempotência** (R13): cada transição é um `updateMany` condicionado ao status atual (`AWAITING_PAYMENT`); evento
  repetido não muda nada e responde `200`. Assinatura inválida → `400 INVALID_SIGNATURE`.
- **Cartão recusado** (R21): tratado na página da Stripe; o backend não muda nada até `completed` ou `expired`.
- **Volta antes do webhook** (R14): a tela consulta o pedido a cada 2 s, por até 30 s, enquanto ele está
  `AWAITING_PAYMENT` (texto da espera depende da L5).
- "Tentar de novo" volta ao checkout do mesmo anúncio, que cria outro pedido (depende da L6); "Voltar ao anúncio" e
  "Continuar comprando" só com a L6 e a L5.

## Contrato da API

Convenções do ADR-011; dinheiro como string decimal.

```ts
Checkout = { listing: { id, price, card: { id, name, number, frontImageUrl }, condition: { name }, seller: { id, username } },
  addresses: Address[], defaultAddressId: string | null, cpfRequired: boolean }
ShippingOption = { serviceId, carrier: 'Correios' | 'Jadlog', service, price, deliveryDays }
OrderResult = { id, code, status, cardName, totalAmount, cancelReason, listingId }   // code depende da L1
```

| Método e caminho | Acesso | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|---|
| `GET /api/v1/listings/:id/checkout` | `authenticate` + `authorize('CUSTOMER', 'SELLER')` | — | `200` `{ data: Checkout }` | `401`, `403 ACCOUNT_INACTIVE`, `404 LISTING_NOT_FOUND`, `422 LISTING_UNAVAILABLE`, `422 OWN_LISTING` | R1–R4, R6, R7 |
| `POST /api/v1/listings/:id/shipping-quotes` | igual | `{ addressId }` | `200` `{ data: ShippingOption[] }` | `400 VALIDATION_ERROR`, `404 ADDRESS_NOT_FOUND`, `422 NO_SHIPPING_AVAILABLE`, `422 SELLER_WITHOUT_ADDRESS` (L10), `502 SHIPPING_PROVIDER_ERROR` (L12) | R8, R18 |
| `POST /api/v1/orders` | igual | `{ listingId, addressId, shippingServiceId, cpf? }` | `201` `{ data: { order: OrderResult, checkoutUrl } }` | `400 VALIDATION_ERROR` (CPF ausente ou inválido), `403`, `404`, `409 CPF_IN_USE` (L9), `422 LISTING_UNAVAILABLE`, `422 OWN_LISTING`, `422 NO_SHIPPING_AVAILABLE`, `502 PAYMENT_PROVIDER_ERROR` | R1, R2, R5, R7, R9–R11, R17 |
| `GET /api/v1/orders/:id` | `authenticate` (só o comprador) | — | `200` `{ data: OrderResult }` | `401`, `404 ORDER_NOT_FOUND` | R14, R20 |
| `POST /api/v1/orders/:id/cancel-checkout` | igual | — | `200` `{ data: OrderResult }` | `401`, `404`, `409 ORDER_NOT_AWAITING_PAYMENT` | R19, R20 |
| `POST /api/v1/payments/webhook` | público, assinatura `Stripe-Signature` | corpo cru | `200` `{ received: true }` | `400 INVALID_SIGNATURE` | R12, R13, R19 |

## Providers — `src/providers/`

| Arquivo | O que faz | Requisitos |
|---|---|---|
| `payment/payment.provider.ts` | interface `PaymentProvider`: `createCheckoutSession`, `expireCheckoutSession`, `parseWebhookEvent(rawBody, signature)` → `{ id, type, sessionId, chargeId? }` | R11–R13, R19, R22 |
| `payment/stripe.payment-provider.ts` + `.spec.ts` | SDK `stripe`, com `STRIPE_SECRET_KEY` e `STRIPE_WEBHOOK_SECRET` | R11–R13, R19 |
| `payment/fake.payment-provider.ts` | guarda as sessões em memória; a `checkoutUrl` é a `success_url`; no PC dispara `completed` no mesmo handler do webhook; nos testes o evento é disparado pelo teste | R22 |
| `payment/payment.factory.ts` | escolhe pelo `PAYMENT_DRIVER` (`fake` ou `stripe`) | R22 |
| `shipping/shipping.provider.ts` | interface `ShippingProvider`: `quote({ fromZipCode, toZipCode, package, declaredValue })` → `ShippingOption[]` | R8, R22 |
| `shipping/melhor-envio.shipping-provider.ts` + `.spec.ts` | `POST /api/v2/me/shipment/calculate`, com `MELHOR_ENVIO_TOKEN` e `MELHOR_ENVIO_BASE_URL` (sandbox em homologação); filtra Correios e Jadlog e descarta os serviços com erro | R8, R18 |
| `shipping/fake.shipping-provider.ts` | frete fixo de Correios e Jadlog; CEPs de uma lista de teste sem frete (CA10) | R22 |
| `shipping/shipping.factory.ts` | escolhe pelo `SHIPPING_DRIVER` (`fake` ou `melhor-envio`) | R22 |
| `src/config/env.ts` | as variáveis acima; em produção, `fake` é recusado | R22 |

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/marketplace/orders/checkout.{validator,service,controller,routes,swagger}.ts` + `.service.spec.ts` | checkout e cotação | R1–R4, R6–R8, R18 |
| `orders.{validator,errors,repository,service,controller,routes,swagger}.ts` + `orders.module.ts` + `.service.spec.ts` | criar pedido com reserva e sessão, ler o resultado, cancelar a sessão | R5, R9–R11, R14, R17, R19, R20 |
| `orders.package.ts` | pacote padrão de uma carta | R8 |
| `src/domains/marketplace/payments/payments.{webhook.controller,service,routes,swagger}.ts` + `payments.module.ts` + `.service.spec.ts` | webhook: assinatura, `completed`, `expired`, idempotência | R12, R13, R19, R21 |
| `src/app.ts` | `express.raw({ type: 'application/json' })` na rota do webhook, antes do `express.json()` | R13 |
| `src/providers/mail/templates/order-paid-seller.mail.ts` | e-mail "venda paga para enviar" (texto depende da L11) | R12 |
| `src/routes.ts` | registra `ordersModule`, `checkout` e `paymentsModule` | R1 |
| `database/seeds/` | anúncios compráveis, endereços principais dos vendedores e um cliente sem CPF | R4, R7, R8 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/marketplace/orders/`, no modelo de `src/features/users/` (ADR-040).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `checkout.types.ts` · `.api.ts` · `.queries.ts` · `.schemas.ts` (CPF com `lib/cpf.ts`) · `.labels.ts` | contrato, chamadas e textos | R4–R11, R17, R18 |
| `pages/CheckoutPage/` | "COMPRA", "Checkout", blocos 1–3 e o resumo, frames `1112-7309` e `1112-7631`; carregando da cotação (CA15) | R4–R9, R17, R18, R23 |
| `components/AddressSelector/` | endereços do cliente, principal marcado, "+ Cadastrar novo endereço" com o formulário da CCD048 (depende da L7) | R6, R18 |
| `components/BuyerCpfField/` | bloco "2. CPF do comprador", só com `cpfRequired` (depende da L9) | R7 |
| `components/ShippingOptions/` · `OrderSummary/` | opções com preço e prazo, aviso sem frete, resumo carta + frete = total, botão "Ir para o pagamento" desabilitado sem frete | R4, R8, R9, R18 |
| `pages/PaymentResultPage/` | "Pagamento confirmado" (`1112-7935`) e "Pagamento não concluído" com "Tentar de novo" (`1112-8190`); espera pelo webhook (depende da L5); chama `cancel-checkout` na volta pelo `cancel_url` | R14, R19, R20, R23 |
| `src/features/marketplace/listings/components/ListingPurchasePanel/` (CCD079) | "Comprar" leva ao checkout; visitante abre o `LoginToContinueModal` e volta ao anúncio; `isOwner` esconde o botão | R3, R15, R16, R23 |
| `orders.routes.ts` · `src/routes/paths.ts` · `app/router.tsx` | `/anuncios/:id/checkout` e `/pedidos/:id/pagamento` com `RequireAuth` | R1, R3 |

- **Componentes reaproveitados:** `Button`, `Badge`, `FormField`, `TextField`, `Modal`, `Toast`, `LoadingState`,
  `ErrorState`; `LoginToContinueModal` (CCD055).

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1, CA15 | checkout com carta, condição, vendedor, endereços e opções de Correios e Jadlog; resumo; cotação carregando | `checkout.service.spec.ts` · `tests/integration/checkout.spec.ts` · `CheckoutPage.spec.tsx` |
| CA2 | pedido `AWAITING_PAYMENT` com `quantity = 1` e os valores, `payments` `PENDING`, reserva, `checkoutUrl` | `orders.service.spec.ts` · `tests/integration/orders.spec.ts` |
| CA3 | `completed` → `PAID`, `APPROVED`, e-mail ao vendedor (`MemoryMailProvider`); tela "Pagamento confirmado" | `payments.service.spec.ts` · `tests/integration/payments-webhook.spec.ts` · `PaymentResultPage.spec.tsx` |
| CA4 | evento repetido não muda nada (`200`); assinatura inválida `400` | `payments.service.spec.ts` · integração |
| CA5 | sem CPF: erro e nada gravado; com CPF informado: gravado; com CPF no cadastro: bloco some | `orders.service.spec.ts` · `BuyerCpfField.spec.tsx` |
| CA6 | visitante → "Entre para continuar" → volta ao anúncio | `ListingPurchasePanel.spec.tsx` |
| CA7 | "Indisponível" e outros anúncios; dono sem "Comprar" | `ListingPurchasePanel.spec.tsx` |
| CA8 | próprio, pausado ou esgotado → `422`, nenhum pedido | integração |
| CA9 | duas compras da última unidade: uma cria o pedido, a outra recebe `422` e volta ao anúncio | integração (`Promise.all`) · `CheckoutPage.spec.tsx` |
| CA10 | CEP sem frete: aviso, frete "—", botão sem seguir | `fake.shipping-provider` · `ShippingOptions.spec.tsx` |
| CA11 | `expired` e `cancel-checkout` → `CANCELED`, unidade devolvida, tela "Pagamento não concluído" | `payments.service.spec.ts` · integração · `PaymentResultPage.spec.tsx` |
| CA12 | cartão recusado não muda o pedido | `payments.service.spec.ts` (evento ignorado) |
| CA13 | `401`, `403` suspenso, `SELLER` compra | integração · `tests/unit/orders-routes.spec.ts` |
| CA14 | os testes rodam com `PAYMENT_DRIVER=fake` e `SHIPPING_DRIVER=fake` | `env.spec.ts` · `payment.factory.spec.ts` · `shipping.factory.spec.ts` |
| CA16–CA22 | print em 1280 px igual aos frames `1112-5772`, `1112-6152`, `1112-5461`, `1112-7309`, `1112-7631`, `1112-7935` e `1112-8190`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Decisões técnicas

- A reserva é a própria baixa de `available_quantity` num `updateMany` condicional, que resolve a corrida da última
  unidade sem lock explícito e sem coluna nova (depende da L2).
- A idempotência do webhook vem das transições condicionadas ao status, porque o DBML não tem tabela de eventos
  processados; o id do evento vai para o log.
- O frete é cotado de novo no `POST /orders`: o total gravado nunca depende de um valor vindo do navegador.
- A sessão da Stripe é criada dentro da transação do pedido, depois das escritas e antes do commit; se ela falha, nada fica
  gravado. Se o commit falha depois da sessão criada, a sessão expira sozinha em 30 minutos e o webhook não acha o pedido.
- O token do Melhor Envio vem do secret do ambiente (ADR-067, item 2); a renovação automática não é requisito desta spec.
