# Tarefas — CCD034 Buscar Categoria do Álbum

- **Plano:** [plano.md](plano.md) · **User story:** AB#137
- **Fase MVP** desde 22/11/2026 (ADR-068).
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende de `GET /collections/me/cards` (CCD007 ou CCD013).

## Backend — `apps/cromocard-backend`, branch `feature/137-buscar-categoria-do-album`

- [ ] **T1** · Criar repository da hierarquia de categorias da coleção — R2–R4 · AB#1126
  - Pronto quando: traz os descendentes de uma categoria e as categorias com cartas na coleção, coberto em integração.
- [ ] **T2** · Acrescentar o filtro por categoria à lista de cartas da coleção — R3, R4 · CA1, CA2 · AB#1127
  - Pronto quando: `collection-cards.service.spec.ts` cobre seleção, categoria com subcategorias, categoria do álbum (depende da L3) e `422 CATEGORY_NOT_FOUND`.
- [ ] **T3** · Criar endpoint GET /collections/me/categories — R1, R2 · CA4 · AB#1128
  - Pronto quando: a rota aparece no `/docs` e `tests/integration/collection-cards-filter.spec.ts` cobre `200`, `401` e o filtro.

## Frontend — `apps/cromocard-frontend`, branch `feature/137-buscar-categoria-do-album`

- [ ] **T4** [P] · Criar api, queries e textos do filtro por categoria — R2, R5 · AB#1129
  - Pronto quando: o typecheck passa.
- [ ] **T5** · Criar filtro de categoria raiz na grade do Início — R2, R4, R6 · CA2, CA6 · AB#1130
  - Pronto quando: `CategoryFilter.spec.tsx` cobre a categoria com subcategorias; print em 1280 px igual ao frame `1122-17812` e sem quebra em 375/768/1024 px.
- [ ] **T7** · Criar filtro Seleção no detalhe do álbum — R2–R6 · CA1, CA3, CA5, CA7 · AB#1131
  - Pronto quando: `SelectionFilter.spec.tsx` cobre a lista com as quantidades, o filtro aplicado e o vazio; print em 1280 px igual aos frames `1160-23696`, `1226-2361`, `1226-3003` e `1226-3625` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T6** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1132
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3 |
| R2 | T1, T3, T4, T5, T7 |
| R3 | T1, T2, T7 |
| R4 | T1, T2, T5, T7 |
| R5 | T4, T7 |
| R6 | T5, T7 |
