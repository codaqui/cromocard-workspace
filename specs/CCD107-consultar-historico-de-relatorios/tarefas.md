# Tarefas — CCD107 Consultar Histórico de Relatórios

- **Plano:** [plano.md](plano.md) · **User story:** AB#611
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/611-historico-de-relatorios`

- [ ] **T1** · Criar migration de report_exports — R2, R4 · AB#719
  - Pronto quando: a tabela existe e o `schema.prisma` bate com o DBML.
- [ ] **T2** · Guardar o arquivo exportado no storage e registrar em report_exports — R2, R4 · CA1 · AB#720
  - Pronto quando: `reports.service.spec.ts` cobre CA1.
- [ ] **T3** · Criar histórico e download com expiração — R3, R5, R6 · CA2, CA3 · AB#721
  - Pronto quando: `reports.service.spec.ts` cobre CA2 e CA3.
- [ ] **T4** · Criar job de limpeza dos relatórios vencidos — R7 · CA4 · AB#722
  - Pronto quando: `cleanup-expired-reports.job.spec.ts` cobre CA4.
- [ ] **T5** · Criar rota de download do relatório — R1 · CA6 · AB#723
  - Pronto quando: a rota aparece no `/docs` e responde `403` para quem não é ADMIN.

## Frontend — `apps/cromocard-frontend`, branch `feature/611-historico-de-relatorios`

- [ ] **T6** [P] · Criar api e queries do histórico de relatórios — R2, R3 · AB#724
  - Pronto quando: o typecheck passa.
- [ ] **T7** · Atualizar o histórico da tela de Relatórios com Baixar, vencido e vazio — R2, R3, R5, R6 · CA5 · AB#725
  - Pronto quando: `ReportsPage.spec.tsx` cobre o vencido e o vazio.

## Fechamento — workspace

- [ ] **T8** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#726
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T5 |
| R2 | T1, T2, T6, T7 |
| R3 | T3, T6, T7 |
| R4 | T1, T2 |
| R5, R6 | T3, T7 |
| R7 | T4 |
