# Tarefas — CCD034 Buscar Categoria do Álbum

- **Plano:** [plano.md](plano.md) · **User story:** AB#137
- **Fase Futuro:** implementar depois do MVP.
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende de `GET /collections/me/cards` (CCD007 ou CCD013).

## Backend — `apps/cromocard-backend`, branch `feature/137-buscar-categoria-do-album`

- [ ] **T1** · Criar repository da hierarquia de categorias da coleção — R2–R4 · AB# a criar
  - Pronto quando: traz os descendentes de uma categoria e as categorias com cartas na coleção, coberto em integração.
- [ ] **T2** · Acrescentar o filtro por categoria à lista de cartas da coleção — R3, R4 · CA1, CA2 · AB# a criar
  - Pronto quando: `collection-cards.service.spec.ts` cobre seleção, categoria com subcategorias, categoria do álbum (depende da L3) e `422 CATEGORY_NOT_FOUND`.
- [ ] **T3** · Criar endpoint GET /collections/me/categories — R1, R2 · CA4 · AB# a criar
  - Pronto quando: a rota aparece no `/docs` e `tests/integration/collection-cards-filter.spec.ts` cobre `200`, `401` e o filtro.

## Frontend — `apps/cromocard-frontend`, branch `feature/137-buscar-categoria-do-album`

- [ ] **T4** [P] · Criar api, queries e textos do filtro por categoria — R2, R5 · AB# a criar
  - Pronto quando: o typecheck passa.
- [ ] **T5** · Criar filtro de categoria, seleção e time na grade da coleção — R2, R4–R6 · CA1–CA3, CA5–CA7 · AB# a criar
  - Pronto quando: `CategoryFilter.spec.tsx` cobre os dois níveis e o vazio; print em 1280 px igual ao frame `1122-17812` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T6** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3 |
| R2 | T1, T3, T4, T5 |
| R3 | T1, T2 |
| R4 | T1, T2, T5 |
| R5 | T4, T5 |
| R6 | T5 |
