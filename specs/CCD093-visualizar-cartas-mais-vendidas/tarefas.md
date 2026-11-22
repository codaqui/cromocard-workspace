# Tarefas — CCD093 Visualizar Cartas Mais Vendidas

- **Plano:** [plano.md](plano.md) · **User story:** AB#352
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure: a criar (só com o pedido do Daniel). Entra depois da CCD092.

## Backend — `apps/cromocard-backend`, branch `feature/352-visualizar-cartas-mais-vendidas`

- [ ] **T1** · Acrescentar ao seed as vendas por carta do vendedor — R3, R5 · AB# a criar
  - Pronto quando: o seed tem Suicune, Charizard (mês passado) e Messi com as quantidades do CA1.
- [ ] **T2** · Criar service do ranking de cartas mais vendidas — R3–R6 · CA1–CA3 · AB# a criar
  - Pronto quando: `seller-metrics.service.spec.ts` cobre a ordem, o limite, o preço médio, a condição e o período.
- [ ] **T3** · Criar endpoint GET /me/top-cards e os testes de integração — R1, R3, R5 · CA1–CA3, CA5 · AB# a criar
  - Pronto quando: a rota aparece no `/docs` e a integração passa, com 90% de cobertura nos arquivos alterados.

## Frontend — `apps/cromocard-frontend`, branch `feature/352-visualizar-cartas-mais-vendidas`

- [ ] **T4** [P] · Criar api e queries do ranking — R3–R6 · AB# a criar
  - Pronto quando: o typecheck passa.
- [ ] **T5** · Criar bloco Cartas mais vendidas na Visão geral — R2, R4–R7 · CA1, CA4, CA6–CA8 · AB# a criar
  - Pronto quando: `TopCardsTable.spec.tsx` cobre CA1, CA4 e CA6; print em 1280 px igual aos frames `492-2007` e
    `1112-9866` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T6** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3 |
| R2 | T5 |
| R3 | T1, T2, T3, T4 |
| R4 | T2, T4, T5 |
| R5 | T1, T2, T3, T5 |
| R6 | T2, T4, T5 |
| R7 | T5 |
