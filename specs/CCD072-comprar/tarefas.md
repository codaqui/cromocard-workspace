# Tarefas — CCD072 Comprar

- **Plano:** [plano.md](plano.md) · **User story:** AB#1352
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende de `listings`, `orders` e `payments` no banco (CCD097, ADR-054), de `card_conditions` (CCD084), do detalhe do anúncio (CCD079), dos endereços (CCD048) e do
  `LoginToContinueModal` (CCD030).

## Docs — workspace

- [ ] **T1** · Registrar no DBML o número do pedido — R14 · AB#1353
  - Pronto quando: a L1 está decidida e os três `.dbml` têm a coluna (PR de docs mergeado).

## Backend — `apps/cromocard-backend`, branch `feature/1352-comprar`

- [ ] **T2** · Criar seed de compra do marketplace — R4, R7, R8, R10 · AB#1354
  - Pronto quando: `orders` e `payments` da CCD097 estão no `schema.prisma` e o seed tem anúncios compráveis, endereços principais dos vendedores e um cliente sem CPF.
- [ ] **T3** [P] · Criar PaymentProvider com Stripe Checkout e versão falsa — R11–R13, R19, R22 · CA14 · AB#1355 · liberada antes da aprovação da spec (L15)
  - Pronto quando: `stripe.payment-provider.spec.ts` (SDK mockado) e `payment.factory.spec.ts` passam, e o `fake` é recusado em produção.
- [ ] **T4** [P] · Criar ShippingProvider com Melhor Envio e versão falsa — R8, R18, R22, R24 · CA10, CA14, CA23 · AB#1356 · liberada antes da aprovação da spec (L15)
  - Pronto quando: `melhor-envio.shipping-provider.spec.ts` (HTTP mockado) filtra Correios e Jadlog e `shipping.factory.spec.ts` passa.
- [ ] **T5** · Criar endpoints de checkout e cotação de frete — R1–R4, R6–R8, R18, R24 · CA1, CA8, CA10, CA13, CA15, CA23 · AB#1357
  - Pronto quando: `checkout.service.spec.ts` e `tests/integration/checkout.spec.ts` cobrem `200`, `401`, `403`, `422` (próprio, pausado, esgotado, sem frete), `502 SHIPPING_PROVIDER_ERROR` e `cpfRequired`.
- [ ] **T6** · Criar endpoint POST /orders com reserva e sessão de pagamento — R1, R2, R5, R7, R9–R11, R17 · CA2, CA5, CA8, CA9 · AB#1358
  - Pronto quando: `orders.service.spec.ts` e `tests/integration/orders.spec.ts` cobrem o pedido gravado, o CPF, a corrida da última unidade e a falha da Stripe sem nada gravado.
- [ ] **T7** · Criar webhook da Stripe para pagamento confirmado e expirado — R12, R13, R19, R21 · CA3, CA4, CA11, CA12 · AB#1359
  - Pronto quando: `payments.service.spec.ts` e `tests/integration/payments-webhook.spec.ts` cobrem `PAID`, `CANCELED` com a unidade devolvida, evento repetido, assinatura inválida e o e-mail ao vendedor.
- [ ] **T8** · Criar endpoints GET /orders/:id e POST /orders/:id/cancel-checkout — R14, R19, R20 · CA3, CA11 · AB#1360
  - Pronto quando: só o comprador lê o pedido (`404` para os outros) e a volta pelo `cancel_url` expira a sessão (L4).

## Frontend — `apps/cromocard-frontend`, branch `feature/1352-comprar`

- [ ] **T9** [P] · Criar tipos, api, queries e schema do checkout — R4–R11, R17, R18 · AB#1361
  - Pronto quando: o typecheck passa e `checkout.api.spec.ts` e `checkout.schemas.spec.ts` (CPF) passam.
- [ ] **T10** · Ligar o botão Comprar do detalhe do anúncio ao checkout — R3, R15, R16, R23 · CA6, CA7, CA16–CA18 · AB#1362
  - Pronto quando: `ListingPurchasePanel.spec.tsx` cobre cliente, visitante com volta ao anúncio, dono e indisponível; print em 1280 px igual aos frames `1112-5772`, `1112-6152` e `1112-5461` e sem quebra em 375/768/1024 px.
- [ ] **T11** · Criar página de checkout com endereço, CPF e frete — R4–R9, R17, R18, R23, R24 · CA1, CA5, CA9, CA10, CA15, CA19, CA20, CA23 · AB#1363
  - Pronto quando: `CheckoutPage.spec.tsx`, `ShippingOptions.spec.tsx` e `BuyerCpfField.spec.tsx` cobrem os estados; print em 1280 px igual aos frames `1112-7309` e `1112-7631` e sem quebra em 375/768/1024 px.
- [ ] **T12** · Criar página de resultado do pagamento — R14, R19, R20, R23 · CA3, CA11, CA21, CA22 · AB#1364
  - Pronto quando: `PaymentResultPage.spec.tsx` cobre confirmado, espera pelo webhook (depende da L5) e não concluído com "Tentar de novo"; print em 1280 px igual aos frames `1112-7935` e `1112-8190` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T13** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1365
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T5, T6 |
| R2 | T5, T6 |
| R3 | T10 |
| R4, R6 | T5, T9, T11 |
| R5, R9 | T6, T9, T11 |
| R7 | T5, T6, T9, T11 |
| R8 | T4, T5, T9, T11 |
| R10 | T2, T6, T9 |
| R11 | T3, T6, T9 |
| R12 | T3, T7 |
| R13 | T3, T7 |
| R14 | T1, T8, T12 |
| R15, R16 | T10 |
| R17 | T6, T9, T11 |
| R18 | T4, T5, T9, T11 |
| R19 | T3, T7, T8, T12 |
| R20 | T8, T12 |
| R21 | T7 |
| R22 | T3, T4 |
| R23 | T10, T11, T12 |
| R24 | T4, T5, T11 |
