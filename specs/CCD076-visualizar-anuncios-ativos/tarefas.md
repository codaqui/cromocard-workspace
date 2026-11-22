# Tarefas — CCD076 Visualizar Anúncios Ativos

- **Plano:** [plano.md](plano.md) · **User story:** não encontrada no board (AB# a criar)
- **Fase MVP** desde 22/11/2026 (ADR-068).
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende de `listings` (CCD097) e `card_conditions` (CCD084); a tela depende da L2 e da L3.

## Backend — `apps/cromocard-backend`, branch `feature/<id>-visualizar-anuncios-ativos`

- [ ] **T1** · Criar service dos anúncios ativos do usuário — R3, R4 · CA1, CA2 · AB# a criar
  - Pronto quando: `my-listings.service.spec.ts` cobre só ativos, só do usuário e a ordem.
- [ ] **T2** · Criar endpoint GET /me/listings — R1, R3, R4 · CA1, CA2, CA4 · AB# a criar
  - Pronto quando: a rota aparece no `/docs` e `tests/integration/my-listings.spec.ts` cobre `200`, `400` e `401`.

## Frontend — `apps/cromocard-frontend`, branch `feature/<id>-visualizar-anuncios-ativos`

- [ ] **T3** [P] · Criar tipos, api e query dos anúncios ativos — R3, R4 · AB# a criar
  - Pronto quando: o typecheck passa e `my-listings.api.spec.ts` cobre a chamada.
- [ ] **T4** · Criar seção Anúncios Ativos com a lista — R2, R4–R6 · CA3, CA5–CA7 · AB# a criar
  - Pronto quando: `ActiveListingsTable.spec.tsx` cobre lista, vazia, carregando e erro; print em 1280 px igual aos frames `675-1452` e `492-2007` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T5** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T2 |
| R2, R5, R6 | T4 |
| R3, R4 | T1, T2, T3, T4 |
