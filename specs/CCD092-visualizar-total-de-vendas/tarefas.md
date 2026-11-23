# Tarefas — CCD092 Visualizar Total de Vendas

- **Plano:** [plano.md](plano.md) · **User story:** AB#351
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure criadas em 22/11/2026 (Sprint 08), atribuídas a quem o plano final indica.
  (CCD072/CCD097) no `develop`.

## Backend — `apps/cromocard-backend`, branch `feature/351-visualizar-total-de-vendas`

- [ ] **T1** · Acrescentar ao seed os pedidos do vendedor em todos os status — R3 · AB#1492
  - Pronto quando: o vendedor do seed tem vendas em dias diferentes do mês e há pedidos de outro vendedor.
- [ ] **T2** · Criar service do resumo de vendas do vendedor — R3–R6 · CA1, CA2 · AB#1493
  - Pronto quando: `seller-metrics.service.spec.ts` cobre CA1, CA2, os períodos, a variação, o melhor dia e o zerado.
- [ ] **T3** · Criar endpoint GET /me/sales-summary — R1 · CA5 · AB#1494
  - Pronto quando: a rota aparece no `/docs` e está em `src/routes.ts`.
- [ ] **T4** · Criar testes de integração do resumo de vendas — R1, R3 · CA1, CA2, CA5 · AB#1495
  - Pronto quando: `tests/integration/marketplace/seller-metrics.spec.ts` passa, com 90% de cobertura nos arquivos alterados.

## Frontend — `apps/cromocard-frontend`, branch `feature/351-visualizar-total-de-vendas`

- [ ] **T5** [P] · Criar api, queries e formatação do resumo de vendas e a opção Este Mês no filtro — R3–R6 · AB#1496
  - Pronto quando: o typecheck passa e o `PeriodFilter.spec.tsx` cobre "Este Mês" sem mudar o BackOffice.
- [ ] **T6** · Criar cartões, gráfico e destaques da Visão geral do vendedor — R2, R4–R7 · CA1, CA3, CA4, CA6, CA7–CA9 · AB#1497
  - Pronto quando: `SellerOverviewPage.spec.tsx` e `SalesChart.spec.tsx` cobrem CA1, CA3, CA4 e CA6; print em 1280 px igual
    aos frames `492-2007`, `1112-9866` e `1112-10347` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T7** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1498
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3, T4 |
| R2 | T6 |
| R3 | T1, T2, T4, T5 |
| R4, R5 | T2, T5, T6 |
| R6 | T2, T5, T6 |
| R7 | T6 |
