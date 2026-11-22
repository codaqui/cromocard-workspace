# Tarefas — CCD001 Visualizar Destaques

- **Plano:** [plano.md](plano.md) · **User story:** AB#88
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- AB# de cada Task: a criar (as Tasks no Azure só serão criadas com o pedido do Daniel).
- As branches dos apps saem depois do merge da CCD078.

## Backend — `apps/cromocard-backend`, branch `feature/88-visualizar-destaques`

- [ ] **T1** · Criar migration de orders e o seed de vendas — R4, R5 · CA1, CA3 · AB# a criar
  - Pronto quando: `orders` existe como no DBML (ou já veio da CCD097) e o seed tem vendas nos últimos 30 dias e uma de 40 dias.
- [ ] **T2** · Criar consulta e service das cartas mais procuradas — R4, R5, R11 · CA1, CA3, CA9 · AB# a criar
  - Pronto quando: `listings.service.spec.ts` cobre top 4, ordem, `fromPrice`, os 30 dias e a lista vazia.
- [ ] **T3** · Criar endpoint GET /listings/most-wanted — R1 · CA2, CA3, CA9 · AB# a criar
  - Pronto quando: a rota aparece no `/docs` e `tests/integration/listings-most-wanted.spec.ts` responde `200` sem token.

## Frontend — `apps/cromocard-frontend`, branch `feature/88-visualizar-destaques`

- [ ] **T4** [P] · Criar menu do visitante, topo e rodapé das telas públicas — R13–R15 · CA11, CA12 · AB# a criar
  - Pronto quando: `SiteShell.spec.tsx` e `SiteFooter.spec.tsx` cobrem os menus do visitante e do cliente, o rodapé e a barra; print em 1280 px igual ao topo, menu e rodapé do frame `1112-2169` e sem quebra em 375/768/1024 px.
- [ ] **T5** [P] · Criar api, queries e textos da Home — R2, R4, R12 · AB# a criar
  - Pronto quando: o typecheck passa.
- [ ] **T6** · Criar destaque principal e os três passos — R2, R3, R16 · CA8 · AB# a criar
  - Pronto quando: `HomeHero.spec.tsx` cobre os atalhos; print em 1280 px igual ao frame `1112-2169` e sem quebra em 375/768/1024 px.
- [ ] **T7** · Criar seção Mais procuradas nos últimos 30 dias — R4, R8, R11, R16 · CA1, CA6, CA9 · AB# a criar
  - Pronto quando: `MostWantedSection.spec.tsx` cobre os cartões, o link da carta e a seção escondida; print em 1280 px igual ao frame `1112-2169` e sem quebra em 375/768/1024 px.
- [ ] **T8** · Criar seção Cartas recém-anunciadas com o filtro de categorias — R6, R7, R9, R10, R12, R16 · CA1, CA4, CA5, CA7, CA10 · AB# a criar
  - Pronto quando: `RecentListingsSection.spec.tsx` cobre CA4, CA5, CA7 e CA10; print em 1280 px igual ao frame `1112-2169` e sem quebra em 375/768/1024 px.
- [ ] **T9** · Criar página Home e registrar a rota índice — R1–R13, R16 · CA1, CA9, CA11, CA13 · AB# a criar
  - Pronto quando: `HomePage.spec.tsx` cobre CA1 e CA9, a URL base abre a Home sem login e `/destaques` saiu; print em 1280 px igual ao frame `1112-2169` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T10** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3, T9 |
| R2 | T5, T6, T9 |
| R3 | T6 |
| R4 | T1, T2, T5, T7 |
| R5 | T1, T2 |
| R6, R7, R9, R10 | T8, T9 |
| R8 | T7 |
| R11 | T2, T7 |
| R12 | T5, T8 |
| R13 | T4, T9 |
| R14, R15 | T4 |
| R16 | T6, T7, T8, T9 |
