# Tarefas — CCD037 Buscar Categoria do Card

- **Plano:** [plano.md](plano.md) · **User story:** AB#140
- **Fase MVP** desde 22/11/2026 (ADR-068).
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende de `GET /collections/me/cards` (CCD007 ou CCD013) e de `cards.variants` (CCD105).

## Backend — `apps/cromocard-backend`, branch `feature/140-buscar-categoria-do-card`

- [ ] **T1** · Acrescentar validação e erro dos filtros de elementos — R2, R3 · AB#1147
  - Pronto quando: o validator aceita os parâmetros novos e `InvalidFilterError` responde `422 INVALID_FILTER`.
- [ ] **T2** · Aplicar os filtros de elementos na lista de cartas da coleção — R3, R4 · CA1, CA2, CA4 · AB#1148
  - Pronto quando: `collection-cards.service.spec.ts` cobre nome, número, raridade, idioma e variante combinados e o `422`, com 90% de cobertura.
- [ ] **T3** · Documentar e testar os filtros da rota GET /collections/me/cards — R1 · CA1, CA2, CA4, CA5 · AB#1149
  - Pronto quando: os parâmetros aparecem no `/docs` e `tests/integration/collection-cards-filter.spec.ts` cobre `200`, `401` e `422`.

## Frontend — `apps/cromocard-frontend`, branch `feature/140-buscar-categoria-do-card`

- [ ] **T4** [P] · Criar api, queries e textos dos filtros de elementos — R2, R5 · AB#1150
  - Pronto quando: o typecheck passa.
- [ ] **T5** · Criar filtros de elementos da grade da coleção — R2, R4, R6 · CA1, CA2, CA6, CA7 · AB#1151
  - Pronto quando: `CollectionCardFilters.spec.tsx` cobre os campos do detalhe e do Início; print em 1280 px igual aos frames `1160-23696` e `1122-17812` e sem quebra em 375/768/1024 px.
- [ ] **T6** · Criar estado sem resultado com limpar filtros — R5 · CA3 · AB#1152
  - Pronto quando: `NoCardsFound.spec.tsx` cobre a mensagem e a limpeza, no estilo da grade.

## Fechamento — workspace

- [ ] **T7** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1153
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3 |
| R2 | T1, T4, T5 |
| R3 | T1, T2 |
| R4 | T2, T5 |
| R5 | T4, T6 |
| R6 | T5 |
