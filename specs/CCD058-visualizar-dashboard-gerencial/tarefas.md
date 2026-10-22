# Tarefas — CCD058 Visualizar Dashboard Gerencial

- **Plano:** [plano.md](plano.md) · **User story:** AB#333
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/333-dashboard-gerencial`

- [ ] **T1** · Criar validator e repository do dashboard — R5–R10, R14, R15 · AB#532
  - Pronto quando: o repository conta usuários, cartas e cadastros por mês sem excluídos.
- [ ] **T2** · Criar service do dashboard com período e estado vazio — R11, R12 · CA1–CA4 · AB#533
  - Pronto quando: `dashboard.service.spec.ts` cobre CA1–CA4.
- [ ] **T3** · Criar rotas GET /admin/dashboard e /admin/dashboard/recent-sellers — R1, R9 · CA7 · AB#534
  - Pronto quando: as rotas aparecem no `/docs` e respondem `403` para quem não é ADMIN.
- [ ] **T4** · Criar teste de integração do dashboard — CA1–CA4, CA7 · AB#535
  - Pronto quando: `npm run test:integration` passa.

## Frontend — `apps/cromocard-frontend`, branch `feature/333-dashboard-gerencial`

- [ ] **T5** [P] · Criar types, api e queries do dashboard — R4, R11 · AB#536
  - Pronto quando: as query keys mudam com o período e o typecheck passa.
- [ ] **T6** · Criar página do Dashboard com KPIs e filtro de período — R2, R3, R5–R7, R10, R12, R13, R16 · CA1, CA2, CA5, CA6, CA8 · AB#537
  - Pronto quando: `DashboardPage.spec.tsx` cobre carregando, vazio, erro e troca de período.
- [ ] **T7** · Criar gráfico de novos cadastros e lista de vendedores recentes — R8, R9 · CA3, CA4 · AB#538
  - Pronto quando: o gráfico mostra as duas séries e a lista pagina.

## Fechamento — workspace

- [ ] **T8** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#539
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3 |
| R2, R3 | T6 |
| R4 | T5 |
| R5–R7 | T1, T6 |
| R8 | T1, T7 |
| R9 | T1, T3, T7 |
| R10, R11 | T1, T2, T5, T6 |
| R12, R13 | T2, T6 |
| R14, R15 | T1 |
| R16 | T6 |
