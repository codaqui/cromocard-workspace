# Tarefas — CCD075 Visualizar Histórico de Preços

- **Plano:** [plano.md](plano.md) · **User story:** não encontrada no board (AB# a criar)
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende de `price_history` (CCD097/CCD007, ADR-054) e do perfil da carta (CCD030).

## Backend — `apps/cromocard-backend`, branch `feature/<id>-visualizar-historico-de-precos`

- [ ] **T1** · Criar cálculo do histórico de preços por período — R2–R4, R6, R7 · CA1–CA4 · AB# a criar
  - Pronto quando: `price-history.stats.spec.ts` e `price-history.service.spec.ts` cobrem pontos, mínimo, máximo, média, variação (depende da L3), só `SALE` e sem vendas.
- [ ] **T2** · Criar endpoint GET /cards/:id/price-history — R1, R2, R5 · CA1–CA4 · AB# a criar
  - Pronto quando: a rota aparece no `/docs`, `tests/integration/price-history.spec.ts` cobre `200` sem token, `400` e `404`, e o seed tem as vendas de exemplo.

## Frontend — `apps/cromocard-frontend`, branch `feature/<id>-visualizar-historico-de-precos`

- [ ] **T3** [P] · Criar tipos, api e query do histórico de preços — R2, R4–R7 · AB# a criar
  - Pronto quando: o typecheck passa e `price-history.api.spec.ts` e `price-history.format.spec.ts` passam.
- [ ] **T4** · Criar bloco Histórico de preços no perfil da carta — R1, R2, R4–R8 · CA1, CA2, CA4–CA7 · AB# a criar
  - Pronto quando: `PriceHistory.spec.tsx` cobre 7 dias, troca para 1 ano, sem dados, carregando e erro; print em 1280 px igual aos frames `1112-4615` e `1112-5038` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T5** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T2, T4 |
| R2, R4, R6, R7 | T1, T3, T4 |
| R3 | T1 |
| R5 | T2, T3, T4 |
| R8 | T4 |
