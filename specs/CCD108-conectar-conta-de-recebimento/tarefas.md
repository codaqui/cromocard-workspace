# Tarefas — CCD108 Conectar Conta de Recebimento

- **Plano:** [plano.md](plano.md) · **User story:** AB#920
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure: a criar (só com o pedido do Daniel).
- Se a CCD072 ainda não tiver criado a base do `PaymentProvider` e do webhook da Stripe, a T2 e a T4 criam essa base como
  o plano da CCD072 descreve.

## Backend — `apps/cromocard-backend`, branch `feature/920-conectar-conta-de-recebimento`

- [ ] **T1** · Criar migration add_stripe_account_to_users_table e o seed dos vendedores — R3, R4 · AB# a criar
  - Pronto quando: `users` tem `stripe_account_id` (único) e `stripe_account_status`, e o seed traz vendedores sem conta,
    `PENDING`, `VERIFYING` e `READY`.
- [ ] **T2** · Acrescentar a conta conectada Express ao PaymentProvider — R3, R7, R9 · AB# a criar
  - Pronto quando: Stripe e provider falso têm `createConnectedAccount`, `createOnboardingLink` e `getConnectedAccount`, e o
    `.spec.ts` do falso passa.
- [ ] **T3** · Criar service da conta de recebimento com o mapa de status — R3–R5, R7, R8 · CA2, CA3, CA6, CA7, CA9 · AB# a criar
  - Pronto quando: `connected-accounts.service.spec.ts` e `connected-accounts.status.spec.ts` cobrem CA2, CA3, CA6, CA7 e
    CA9, inclusive o `assertReady` com `422 STRIPE_ACCOUNT_NOT_READY`.
- [ ] **T4** · Tratar o evento account.updated no webhook da Stripe — R5, R6 · CA4, CA5 · AB# a criar
  - Pronto quando: o evento válido grava o estado, o repetido não muda nada e a assinatura inválida responde `400`.
- [ ] **T5** · Criar rotas GET /me/stripe-account, POST /onboarding-link e POST /refresh — R1 · CA8 · AB# a criar
  - Pronto quando: as rotas aparecem no `/docs` e estão registradas em `src/routes.ts`.
- [ ] **T6** · Criar testes de integração da conta de recebimento — R1–R8 · CA2, CA4, CA5, CA7, CA8 · AB# a criar
  - Pronto quando: `tests/integration/marketplace/connected-accounts.spec.ts` passa, com 90% de cobertura nos arquivos
    alterados.

## Frontend — `apps/cromocard-frontend`, branch `feature/920-conectar-conta-de-recebimento`

- [ ] **T7** [P] · Criar rotas e menu do Painel do vendedor — R1, R2 · AB# a criar
  - Pronto quando: `/vendedor` abre só para `SELLER` e o menu lateral tem o grupo "Vendedor" com "Visão geral".
- [ ] **T8** · Criar api e queries da conta de recebimento — R3–R8 · AB# a criar
  - Pronto quando: o typecheck passa e o `.api.spec.ts` cobre os três endpoints.
- [ ] **T9** · Criar aviso da conta de recebimento na Visão geral — R2, R4, R7, R8, R10 · CA1, CA3, CA6, CA7, CA9–CA11 · AB# a criar
  - Pronto quando: `SellerOverviewPage.spec.tsx` e `StripeAccountNotice.spec.tsx` cobrem os quatro estados, o carregamento
    e o erro; print em 1280 px igual aos frames `1112-9866` e `1112-10347` (o aviso; as métricas do fundo entram com a
    CCD092) e sem quebra em 375/768/1024 px.
- [ ] **T10** · Criar páginas de volta e de renovação do cadastro na Stripe — R4, R7 · CA3, CA6 · AB# a criar
  - Pronto quando: `StripeReturnPage.spec.tsx` grava o estado e volta ao painel, e a renovação redireciona para o link novo.

## Fechamento — workspace

- [ ] **T11** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T5, T6, T7 |
| R2 | T1, T7, T9 |
| R3 | T1, T2, T3, T8 |
| R4 | T1, T3, T8, T9, T10 |
| R5 | T3, T4, T8 |
| R6 | T4, T6 |
| R7 | T2, T3, T8, T9, T10 |
| R8 | T3, T8, T9 |
| R9 | T2 |
| R10 | T9 |
