# Tarefas — CCD096 Acompanhar Evolução de Cadastros

- **Plano:** [plano.md](plano.md) · **User story:** AB#600
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/600-acompanhar-evolucao-de-cadastros`

- [ ] **T1** · Criar consultas da evolução de cadastros agrupadas por período — R2, R4 · CA1, CA2 · AB#627
  - Pronto quando: o repository devolve os pontos por hora, dia ou mês no horário de Brasília.
- [ ] **T2** · Acrescentar meta, variação, divisão por papel e novas cartas ao resumo do dashboard — R3, R7–R11 · CA3, CA4, CA6 · AB#628
  - Pronto quando: `dashboard.service.spec.ts` cobre CA3, CA4 e CA6.
- [ ] **T3** · Criar rota da evolução de cadastros — R1, R6 · CA7 · AB#629
  - Pronto quando: a rota aparece no `/docs` e responde `403` para quem não é ADMIN.

## Frontend — `apps/cromocard-frontend`, branch `feature/600-acompanhar-evolucao-de-cadastros`

- [ ] **T4** [P] · Criar api e queries da evolução de cadastros — R2, R3 · AB#630
  - Pronto quando: o typecheck passa.
- [ ] **T5** · Criar gráfico de evolução com tooltip e estado vazio — R2, R4–R6 · CA5 · AB#631
  - Pronto quando: `SignupsEvolutionChart.spec.tsx` cobre o tooltip e o estado vazio.
- [ ] **T6** · Atualizar os cards de KPI com meta, variação e divisão por papel — R3, R7, R9–R11 · AB#632
  - Pronto quando: os cards mostram a meta e a variação com os dados do seed.

## Fechamento — workspace

- [ ] **T7** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#633
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3 |
| R2 | T1, T4, T5 |
| R3 | T2, T4, T6 |
| R4 | T1, T5 |
| R5 | T5 |
| R6 | T3, T5 |
| R7, R9–R11 | T2, T6 |
| R8 | T2 |
