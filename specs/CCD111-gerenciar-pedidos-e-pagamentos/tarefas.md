# Tarefas — CCD111 Gerenciar Pedidos e Pagamentos

- **Plano:** [plano.md](plano.md) · **User story:** AB#923
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure: a criar (só com o pedido do Daniel). Depende da CCD072, da CCD109 e da CCD110 no `develop`.

## Backend — `apps/cromocard-backend`, branch `feature/923-gerenciar-pedidos-e-pagamentos`

- [ ] **T1** · Acrescentar o reembolso ao PaymentProvider — R9 · AB# a criar
  - Pronto quando: Stripe e provider falso têm `refundCharge` com `idempotencyKey`, e o falso simula a recusa.
- [ ] **T2** · Acrescentar ao seed pedidos e pagamentos em todos os status — R3–R5 · AB# a criar
  - Pronto quando: o seed tem um pedido por status, um `PAID` há 3 dias sem etiqueta e um `DELIVERED` vencido sem transferência.
- [ ] **T3** · Criar totais, lista e detalhe dos pedidos do BackOffice — R3–R7, R12, R13 · CA1–CA3, CA7, CA8 · AB# a criar
  - Pronto quando: `admin-orders.service.spec.ts` e `admin-orders.status-detail.spec.ts` cobrem os totais da L1, abas,
    busca, período, selos e as ações por status.
- [ ] **T4** · Criar cancelamento com reembolso e auditoria — R8–R10, R12 · CA4, CA5, CA11 · AB# a criar
  - Pronto quando: o service cobre o reembolso, o motivo vazio, a recusa da Stripe, o estoque de volta e o `audit_logs`, e o
    e-mail `order-canceled.mail.ts` sai às duas partes depois do commit.
- [ ] **T5** · Criar Liberar agora com auditoria — R11, R12 · CA6, CA8 · AB# a criar
  - Pronto quando: o service usa o `PaymentReleaseService` da CCD110, grava `audit_logs` e recusa conta não pronta com `422`.
- [ ] **T6** · Criar rotas GET /admin/orders, /summary, /:id e POST /:id/cancel e /:id/release — R1 · CA10 · AB# a criar
  - Pronto quando: as rotas aparecem no `/docs` e estão em `src/routes.ts`.
- [ ] **T7** · Criar testes de integração de pedidos e pagamentos do admin — R1, R3–R12 · CA1–CA8, CA10 · AB# a criar
  - Pronto quando: `tests/integration/admin/orders.spec.ts` passa, com 90% de cobertura nos arquivos alterados.

## Frontend — `apps/cromocard-frontend`, branch `feature/923-gerenciar-pedidos-e-pagamentos`

- [ ] **T8** [P] · Criar rota, item de menu, api e queries de pedidos e pagamentos — R2–R13 · AB# a criar
  - Pronto quando: "Pedidos e pagamentos" aparece abaixo de Catálogo, `/backoffice/orders` abre só para `ADMIN` e o
    typecheck passa.
- [ ] **T9** · Criar página Pedidos e pagamentos com totais, abas, busca e vazio — R2–R6, R13, R14 · CA1, CA2, CA9, CA12, CA13, CA19 · AB# a criar
  - Pronto quando: `AdminOrdersPage.spec.tsx` cobre CA1, CA2, CA9 e CA12; print em 1280 px igual aos frames `1157-29979` e
    `1157-35305` e sem quebra em 375/768/1024 px.
- [ ] **T10** · Criar painel lateral do detalhe do pedido — R7, R8, R11, R12, R14 · CA3, CA7, CA8, CA14 · AB# a criar
  - Pronto quando: `OrderDetailDrawer.spec.tsx` cobre CA3, CA7 e CA8; print em 1280 px igual ao frame `1157-30793` e sem
    quebra em 375/768/1024 px.
- [ ] **T11** · Criar diálogos Cancelar e reembolsar e Liberar agora com o retorno da operação — R8–R11, R14 · CA4–CA6, CA11, CA15–CA18 · AB# a criar
  - Pronto quando: `CancelRefundDialog.spec.tsx` e `ReleaseNowDialog.spec.tsx` cobrem CA4–CA6 e CA11; print em 1280 px igual
    aos frames `1157-31707`, `1157-32634`, `1157-33562` e `1157-34488` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T12** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T6, T7, T8 |
| R2 | T8, T9 |
| R3, R4, R5, R6 | T2, T3, T8, T9 |
| R7 | T3, T10 |
| R8 | T4, T10, T11 |
| R9 | T1, T4, T11 |
| R10 | T4, T11 |
| R11 | T5, T10, T11 |
| R12 | T3, T4, T5, T10 |
| R13 | T3, T9 |
| R14 | T9, T10, T11 |
