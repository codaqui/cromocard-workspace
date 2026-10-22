# Tarefas — CCD097 Visualizar Indicadores Financeiros

- **Plano:** [plano.md](plano.md) · **User story:** AB#601
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/601-visualizar-indicadores-financeiros`

- [ ] **T1** · Criar migrations e seed das tabelas do marketplace usadas nos indicadores — R2–R5, R9, R10 · AB#634
  - Pronto quando: as 5 tabelas existem, uma migration por tabela, e o seed cria pedidos e pagamentos em cada status.
- [ ] **T2** · Criar consultas dos indicadores financeiros e do livro razão — R2–R4, R6–R8 · CA1–CA4 · AB#635
  - Pronto quando: `finance.service.spec.ts` cobre CA1–CA4.
- [ ] **T3** · Criar consultas de volume e reputação por vendedor, população e preço por carta e volume por grupo — R5, R9, R10 · CA5, CA6 · AB#636
  - Pronto quando: `finance.service.spec.ts` cobre CA5 e CA6.
- [ ] **T4** · Criar rotas dos indicadores financeiros e o relatório de volume e custódia — R1, R11 · CA7, CA8 · AB#637
  - Pronto quando: as rotas aparecem no `/docs` e o relatório exporta em CSV e PDF.

## Frontend — `apps/cromocard-frontend`, branch `feature/601-visualizar-indicadores-financeiros`

- [ ] **T5** [P] · Criar api, queries e types dos indicadores financeiros — R2–R10 · AB#638
  - Pronto quando: o typecheck passa.
- [ ] **T6** · Criar cards financeiros e o livro razão no Dashboard — R2–R4, R6–R8 · AB#639
  - Pronto quando: os cards e o livro razão mostram os dados do seed.
- [ ] **T7** · Acrescentar volume, reputação, população, preço médio e volume por grupo nas listas — R5, R9, R10 · AB#640
  - Pronto quando: as três listas mostram as colunas novas.

## Fechamento — workspace

- [ ] **T8** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#641
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1, R11 | T4 |
| R2–R4 | T1, T2, T5, T6 |
| R5, R9, R10 | T1, T3, T5, T7 |
| R6–R8 | T2, T5, T6 |
