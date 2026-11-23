# Tarefas — CCD078 Mostrar Todas as Cartas

- **Plano:** [plano.md](plano.md) · **User story:** AB#1397
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure criadas em 22/11/2026 (Sprint 08), atribuídas a quem o plano final indica.

## Backend — `apps/cromocard-backend`, branch `feature/1397-mostrar-todas-as-cartas`

- [ ] **T1** · Criar migrations de card_conditions, listings e listing_photos e o seed do marketplace — R4, R5, R8 · AB#1398
  - Pronto quando: as tabelas existem como no DBML (ou já vieram da CCD084/CCD097) e o seed tem as 5 condições, 20 anúncios ativos, um pausado e um excluído.
- [ ] **T2** · Criar endpoints públicos de categorias padrão e condições — R7, R8 · CA4 · AB#1399
  - Pronto quando: `GET /categories/default` e `GET /card-conditions` respondem `200` sem token, na ordem do plano, cobertos em `tests/integration/catalog-public.spec.ts`.
- [ ] **T3** · Criar validator e repository da listagem pública de anúncios — R4, R6–R9, R11 · CA5, CA10 · AB#1400
  - Pronto quando: `listings.validator.spec.ts` cobre uuids, preços, `minPrice > maxPrice` e `sort` fora da lista; o repository filtra ativos, não excluídos e as subcategorias.
- [ ] **T4** · Criar service da listagem com categoria, imagem e paginação — R4–R7, R10, R11 · CA1–CA3, CA6 · AB#1401
  - Pronto quando: `listings.service.spec.ts` cobre CA1–CA3 e CA6, com 90% de cobertura nos arquivos alterados.
- [ ] **T5** · Criar rota GET /listings, swagger e module — R1 · CA1–CA6, CA9, CA10 · AB#1402
  - Pronto quando: a rota aparece no `/docs` e `tests/integration/listings-public.spec.ts` cobre os CAs sem token.

## Frontend — `apps/cromocard-frontend`, branch `feature/1397-mostrar-todas-as-cartas`

- [ ] **T6** [P] · Criar types, api, queries e parâmetros de URL dos anúncios — R4–R6, R11, R12 · AB#1403
  - Pronto quando: o typecheck passa e `listings.search-params.spec.ts` lê e grava os filtros.
- [ ] **T7** [P] · Criar queries públicas de categorias padrão e condições — R7, R8 · AB#1404
  - Pronto quando: `useDefaultCategories` e `useCardConditions` saem pelo `index.ts` do catálogo.
- [ ] **T8** · Mover ActiveFilters para src/components — R12, R14 · CA3 · AB#1405
  - Pronto quando: o catálogo do admin continua com os testes verdes importando de `src/components/ActiveFilters`.
- [ ] **T9** · Criar cartão do anúncio — R4, R13 · CA7 · AB#1406
  - Pronto quando: `ListingCard.spec.tsx` cobre os campos e o link; print em 1280 px igual ao frame `1112-3281` e sem quebra em 375/768/1024 px.
- [ ] **T10** · Criar filtros de categoria, condição, preço, busca e ordenação — R7–R10 · CA3–CA6 · AB#1407
  - Pronto quando: `ListingFilters.spec.tsx` e `PriceRangeFilter.spec.tsx` cobrem CA3–CA6; print em 1280 px igual ao frame `1112-3281` e sem quebra em 375/768/1024 px.
- [ ] **T11** · Criar página Explorar marketplace com grade, total, carregar mais e vazio — R1–R6, R11, R12, R14, R15 · CA1–CA3, CA8, CA9, CA11–CA13 · AB#1408
  - Pronto quando: `ExploreMarketplacePage.spec.tsx` cobre CA1–CA3, CA8 e CA9; print em 1280 px igual aos frames `1112-3281` e `1112-3674` e sem quebra em 375/768/1024 px.
- [ ] **T12** · Registrar a rota /marketplace e o item Marketplace nos menus — R1, R2 · CA1, CA9 · AB#1409
  - Pronto quando: "Marketplace" abre a página e fica destacado para o visitante e para o cliente (`SiteShell.spec.tsx`).

## Fechamento — workspace

- [ ] **T13** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1410
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T5, T11, T12 |
| R2 | T11, T12 |
| R3 | T11 |
| R4 | T1, T3, T4, T6, T9, T11 |
| R5 | T1, T4, T6, T11 |
| R6 | T3, T4, T6, T11 |
| R7 | T2, T3, T4, T7, T10 |
| R8 | T1, T2, T3, T7, T10 |
| R9 | T3, T10 |
| R10 | T4, T10 |
| R11 | T3, T4, T6, T11 |
| R12 | T6, T8, T11 |
| R13 | T9 |
| R14 | T8, T11 |
| R15 | T9, T10, T11 |
