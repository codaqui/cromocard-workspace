# Tarefas — CCD024 Buscar por Nome (agrupa CCD025–CCD029)

- **Plano:** [plano.md](plano.md) · **User story:** AB#157 (com AB#158, AB#159, AB#160, AB#161, AB#162)
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure criadas em 22/11/2026 (Sprint 08), atribuídas a quem o plano final indica.
- As branches dos apps saem depois do merge da CCD002 e da CCD078.

## Backend — `apps/cromocard-backend`, branch `feature/157-buscar-cartas`

- [ ] **T1** · Criar validator da pesquisa de cartas e da lista de álbuns — R13 · AB#1097
  - Pronto quando: `catalog-public.validator.spec.ts` cobre uuids inválidos, `q` longo e paginação.
- [ ] **T2** · Criar repository e service da pesquisa de cartas do catálogo — R3–R9, R12 · CA1–CA6, CA10 · AB#1098
  - Pronto quando: `catalog-public.service.spec.ts` cobre CA1–CA6 e CA10, com 90% de cobertura nos arquivos alterados.
- [ ] **T3** · Criar endpoints públicos GET /cards, /albums, /rarities e /languages — R1, R5, R7, R8, R13 · CA9 · AB#1099
  - Pronto quando: as rotas aparecem no `/docs` e respondem conforme a L2 sem token.
- [ ] **T4** · Cobrir a pesquisa de cartas nos testes de integração — R1, R3–R12 · CA1–CA6, CA8–CA10 · AB#1100
  - Pronto quando: `tests/integration/catalog-public.spec.ts` cobre os CAs com o seed de "Lionel" e da Nº 10.

## Frontend — `apps/cromocard-frontend`, branch `feature/157-buscar-cartas`

- [ ] **T5** [P] · Criar api e queries da pesquisa de cartas e das opções dos filtros — R3–R9 · AB#1101
  - Pronto quando: o typecheck passa e os filtros entram em `search.search-params.ts`.
- [ ] **T6** · Criar filtros de coleção, categoria, raridade e idioma — R2, R5–R8, R14 · CA3–CA6, CA13 · AB#1102
  - Pronto quando: `CardSearchFilters.spec.tsx` cobre CA3–CA6; print em 1280 px igual ao frame dos filtros (L1) e sem quebra em 375/768/1024 px.
- [ ] **T7** · Criar resultado da carta do catálogo — R9, R10 · CA7 · AB#1103
  - Pronto quando: `CatalogCardResult.spec.tsx` cobre os campos e o link para `/cartas/:id`.
- [ ] **T8** · Ligar a aba Cartas da Pesquisar aos filtros e ao vazio — R2, R3, R4, R9, R11, R14 · CA1, CA2, CA8, CA11, CA12, CA14 · AB#1104
  - Pronto quando: `SearchPage.spec.tsx` cobre CA1, CA2 e CA8; print em 1280 px igual aos frames `1112-3970` e `1112-4356` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T9** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1105
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3, T4 |
| R2 | T6, T8 |
| R3, R4 | T2, T4, T5, T8 |
| R5, R7, R8 | T2, T3, T4, T5, T6 |
| R6 | T2, T4, T5, T6 |
| R9 | T2, T4, T5, T7, T8 |
| R10 | T7 |
| R11 | T4, T8 |
| R12 | T2, T4 |
| R13 | T1, T3 |
| R14 | T6, T8 |
