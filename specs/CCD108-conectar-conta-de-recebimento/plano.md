# Plano — CCD108 Conectar Conta de Recebimento

- **Spec:** [spec.md](spec.md), com as lacunas L1–L7 decididas em 24/11/2026
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

A Visão geral do Painel do vendedor (`/vendedor`) lê `GET /api/v1/me/stripe-account` e mostra o aviso conforme o estado
da conta. "Conectar conta Stripe" chama `POST /api/v1/me/stripe-account/onboarding-link`, que cria a conta conectada
Express no `PaymentProvider` (só se o vendedor ainda não tiver uma), grava `stripe_account_id` e devolve o link de
cadastro; o navegador vai para a Stripe. Na volta (`/vendedor/stripe/retorno`), a tela chama
`POST /api/v1/me/stripe-account/refresh`, que consulta a conta e grava o estado. O evento `account.updated` do webhook da
Stripe mantém o estado em dia e marca a conta `READY`, o que libera a criação de anúncios (CCD084).

## Dependências

- **Onda 0 (backend #43):** o `PaymentProvider` (interface, fábrica, Stripe e falso), `PaymentProviderError` (`502 PAYMENT_PROVIDER_ERROR`) e `InvalidSignatureError` (`400 INVALID_SIGNATURE`) já existem; esta story acrescenta os métodos do Connect. A branch do backend sai do #43 com o #44 (base do marketplace) mesclado.
- **CCD072 (Comprar):** o plano dela cria a base do `PaymentProvider` (interface, fábrica, `StripePaymentProvider`,
  `FakePaymentProvider`) e a rota `POST /api/v1/payments/webhook` com corpo bruto, conferência da assinatura e despacho por
  tipo de evento. Esta story acrescenta os métodos do Connect e o tratamento de `account.updated`. Como a CCD108 é
  pré-condição da CCD084, que vem antes da compra, se ela for implementada primeiro cria essa base exatamente como o plano
  da CCD072 descreve, e a CCD072 só acrescenta os eventos dela. Conferir os nomes abaixo com o plano da CCD072 quando ele
  sair.
- **Painel do vendedor:** não existe no frontend. Esta story cria a rota `/vendedor`, o guarda `RequireRole role="SELLER"`
  e o grupo "Vendedor" do menu lateral único (`escopo-adicional.md`, 20/11/2026); CCD092, CCD093, CCD084, CCD085 e CCD109
  acrescentam blocos e itens.
- **Variáveis:** `STRIPE_SECRET_KEY` e `STRIPE_WEBHOOK_SECRET` (CCD072) e o `FRONTEND_URL` que já existe em
  `src/config/env.ts`, para montar `return_url` e `refresh_url`.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `users` | sim, com as colunas da Stripe | `add_stripe_account_to_users_table`, criada pela base do marketplace (backend #44, Onda 0) | `stripe_account_id` varchar(60) único e `stripe_account_status` do enum `stripe_account_status` (`PENDING`, `VERIFYING`, `READY`), iguais ao DBML; esta story só acrescenta o seed |

Estados de `stripe_account_status` (L3): nulo = sem conta conectada; `PENDING` = cadastro não terminado, pedido
de mais informações ou recusa; `VERIFYING` = cadastro enviado e em análise; `READY` = transferências liberadas. Sem enum,
como no DBML.

## Regras

- **Mapa do estado** (`connected-accounts.status.ts`, função pura): `transfersEnabled` → `READY`; `detailsSubmitted` sem
  pendência → `VERIFYING`; o resto → `PENDING` (R4, R5, R8; L3).
- **Motivo da pendência:** com `PENDING`, o `GET` consulta a conta no provider e devolve `pendingReason`
  (`NOT_SUBMITTED`, `MORE_INFO_REQUIRED` ou `REJECTED`), que escolhe o texto do aviso (R7, R8; L4). Se a Stripe
  não responder, `pendingReason` vem `null` e o aviso usa o texto do cadastro não terminado.
- **Uma conta por vendedor:** o link de cadastro reaproveita `stripe_account_id` quando ele existe (R7, CA6).
- **Volta da Stripe** (`return_url`): consulta a conta e grava o estado; o link vencido (`refresh_url`) gera outro link
  (L5).
- **Webhook:** `account.updated` acha o vendedor por `stripe_account_id`, reconsulta a conta no provider
  (`getConnectedAccount`) e grava o estado atual (R6; L6, ADR-071). Evento repetido ou fora de ordem dá o mesmo resultado,
  por isso não há tabela de eventos processados. Conta desconhecida é ignorada com `200`.
- **Conta que deixa de estar pronta:** o estado volta a `PENDING`; anúncios ativos continuam ativos, e só a criação e a
  reativação ficam bloqueadas (L7).
- **Guarda para os anúncios:** `connectedAccountsService.assertReady(sellerId)` lança `422 STRIPE_ACCOUNT_NOT_READY`
  quando o estado não é `READY`; a CCD084 (criar) e a CCD085 (reativar) chamam (R5, R8).

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }`, JSON camelCase, erros `{ error, message, details? }`.

### `GET /api/v1/me/stripe-account` — R2, R4, R7, R8

- **Acesso:** `authenticate` + `authorize('SELLER')`
- **Sucesso:** `200`

  ```json
  { "data": { "status": "NOT_CONNECTED", "pendingReason": null } }
  ```

  `status`: `NOT_CONNECTED` (coluna nula), `PENDING`, `VERIFYING` ou `READY`; `pendingReason` só com `PENDING`.

- **Erros:** `401 UNAUTHORIZED`, `403 FORBIDDEN` (R1).

### `POST /api/v1/me/stripe-account/onboarding-link` — R3, R7

- **Acesso:** `authenticate` + `authorize('SELLER')`
- **Entrada:** sem corpo.
- **Sucesso:** `200` `{ "data": { "url": "https://connect.stripe.com/setup/e/…" } }`
- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 401 / 403 | `UNAUTHORIZED` / `FORBIDDEN` | sem token / papel diferente de `SELLER` | R1 |
  | 502 | `PAYMENT_PROVIDER_ERROR` | a Stripe não respondeu ou recusou a chamada | R3 (CA9) |

### `POST /api/v1/me/stripe-account/refresh` — R4, R5, R8

- **Acesso:** `authenticate` + `authorize('SELLER')`
- **Sucesso:** `200`, o mesmo corpo do `GET`, já com o estado gravado.
- **Erros:** `401`, `403` (R1); `404 STRIPE_ACCOUNT_NOT_FOUND` (vendedor sem conta conectada); `502
  PAYMENT_PROVIDER_ERROR` (R4).

### `POST /api/v1/payments/webhook` (CCD072) — evento `account.updated` — R5, R6

- **Acesso:** público, com a assinatura `Stripe-Signature` conferida pelo `STRIPE_WEBHOOK_SECRET`.
- **Sucesso:** `200` `{ "received": true }`.
- **Erros:** `400 INVALID_SIGNATURE` (assinatura inválida; nada muda) — R6.

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + migration `add_stripe_account_to_users_table` | `stripeAccountId`, `stripeAccountStatus` no `User` | R3, R4 |
| `database/seeds/data/users.json` · `users.seed.ts` | vendedores sem conta, com `PENDING`, `VERIFYING` e `READY` | R2, R4, R5 |
| `src/providers/payment/payment.provider.ts` | `createConnectedAccount({ email })`, `createOnboardingLink({ accountId, returnUrl, refreshUrl })`, `getConnectedAccount(accountId)` → `{ detailsSubmitted, transfersEnabled, requirementsDue, disabledReason }` | R3, R7, R9 |
| `src/providers/payment/stripe.payment-provider.ts` | `accounts.create({ type: 'express', country: 'BR' })`, `accountLinks.create({ type: 'account_onboarding' })`, `accounts.retrieve` | R3, R7 |
| `src/providers/payment/fake.payment-provider.ts` (+ `.spec.ts`) | contas em memória, link falso e estado controlável pelo teste | R9 |
| `src/domains/marketplace/payments/connected-accounts.{repository,service,controller,routes,swagger,errors}.ts` + `payments.module.ts` (registra a conta de recebimento, em `/me/stripe-account`, e o webhook) | os três endpoints, `assertReady` e os erros `STRIPE_ACCOUNT_NOT_FOUND`, `STRIPE_ACCOUNT_NOT_READY`, `PAYMENT_PROVIDER_ERROR` | R1–R5, R7, R8 |
| `connected-accounts.status.ts` | mapa conta → estado e motivo da pendência | R4, R5, R8 |
| `src/domains/marketplace/payments/payments-webhook.{controller,routes,service,swagger}.ts` (base que a CCD072 reaproveita) | webhook da Stripe com a assinatura conferida e o handler de `account.updated` | R5, R6 |
| `src/routes.ts` | registra o `paymentsModule` | R1 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/routes/paths.ts` | `seller: { overview: '/vendedor', stripeReturn: '/vendedor/stripe/retorno', stripeRefresh: '/vendedor/stripe/renovar' }` | R2–R4, R7 |
| `src/app/layouts/SiteShell/siteMenu.ts` · `SiteShell.tsx` | divisória com o grupo "Vendedor" e o item "Visão geral", só para `SELLER` | R2 |
| `src/features/marketplace/marketplace.routes.ts` · `src/app/router.tsx` | rotas do vendedor dentro de `RequireRole role="SELLER"` | R1 |
| `src/features/marketplace/seller-account/seller-account.{types,api,queries,labels}.ts` | estado da conta, link de cadastro, refresh e os textos do aviso | R2–R8 |
| `components/StripeAccountNotice/` | aviso "Conecte sua conta de recebimento para vender" (frame `1112-9866`) e "Estamos verificando sua conta na Stripe" com o selo "Verificando" (frame `1112-10347`); cadastro não terminado e pedido de informação no mesmo estilo (L4); ajudas da L1; botão em carregamento e erro (CA9) | R2, R4, R7, R8, R10 |
| `pages/SellerOverviewPage/` | Visão geral do vendedor com o aviso no topo; as métricas entram com a CCD092 e a CCD093 | R2 |
| `pages/StripeReturnPage/` · `pages/StripeRefreshPage/` | volta: chama o refresh e leva a `/vendedor`; renovação: pede outro link e redireciona | R4, R7 |

- **Estados:** carregando, erro e vazio com `LoadingState` e `ErrorState`.
- **Componentes reaproveitados de `src/components/`:** `Button`, `Badge`, `Icon`, `Toast`, `LoadingState`, `ErrorState`.
- "Criar Novo Anúncio" e "Criar Anúncio" do topo ficam desabilitados até `READY` (L2), com o motivo no `title`; a ação deles é da CCD084.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | vendedor sem conta vê o aviso e "Conectar conta Stripe" | `SellerOverviewPage.spec.tsx` |
| CA2 | cria a conta no provider falso, grava o id e devolve o link | `connected-accounts.service.spec.ts` · `tests/integration/marketplace/connected-accounts.spec.ts` |
| CA3 | volta da Stripe com cadastro enviado grava `VERIFYING`; painel mostra "Verificando" | `connected-accounts.service.spec.ts` · `StripeReturnPage.spec.tsx` · `SellerOverviewPage.spec.tsx` |
| CA4 | `account.updated` com transferências liberadas grava `READY` e o aviso some | `connected-accounts.status.spec.ts` · integração do webhook · `SellerOverviewPage.spec.tsx` |
| CA5 | assinatura inválida responde `400` sem mudança; o mesmo evento duas vezes e dois eventos fora de ordem gravam o estado atual da conta | `payments-webhook.service.spec.ts` · integração do webhook |
| CA6 | o segundo link reaproveita a mesma conta conectada | `connected-accounts.service.spec.ts` |
| CA7 | conta com pedido de informação mostra "Completar cadastro" e `assertReady` lança `422` | `connected-accounts.service.spec.ts` · `SellerOverviewPage.spec.tsx` |
| CA8 | `401` sem token; `403` para `CUSTOMER` e `ADMIN` | integração |
| CA9 | provider fora do ar responde `502`; o botão mostra carregamento e depois o erro | `connected-accounts.service.spec.ts` · `StripeAccountNotice.spec.tsx` |
| CA12 | `account.updated` com transferências suspensas volta a `PENDING`, sem mexer no anúncio ativo | `connected-accounts.status.spec.ts` · integração do webhook, que cria um anúncio ativo, confere que ele continua ativo depois da suspensão e que o `assertReady` volta a recusar |
| CA10, CA11 | print em 1280 px igual aos frames `1112-9866` e `1112-10347`, sem quebra em 375/768/1024 px | revisão visual (`/cromocard-revisor`) |

## Decisões técnicas

- O estado guardado é só o resumo (`stripe_account_status`); o motivo da pendência é consultado na Stripe ao abrir o
  painel, porque o DBML não tem coluna para ele e a consulta só acontece com `PENDING`.
- O `account.updated` não usa o estado que veio no evento: reconsulta a conta na Stripe e grava o estado atual, porque a
  Stripe não garante a ordem de entrega (L6, ADR-071). Sem tabela de eventos, e o id do evento vai para o log.
- A conta Express é criada com `country: 'BR'` e o e-mail do vendedor, e o link pede `collect: 'eventually_due'`, para o
  cadastro sair completo de uma vez.
