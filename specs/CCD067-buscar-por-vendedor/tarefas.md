# Tarefas — CCD067 Buscar por Vendedor

- **Plano:** [plano.md](plano.md) · **User story:** a criar (L2)
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- AB# de cada Task: a criar (as Tasks no Azure só serão criadas com o pedido do Daniel).
- Fase MVP desde 22/11/2026 (ADR-068); sai depois da CCD078.

## Backend — `apps/cromocard-backend`, branch `feature/<id>-buscar-por-vendedor`

- [ ] **T1** · Criar endpoint GET /sellers — R3, R5, R7 · CA1, CA2, CA4 · AB# a criar
  - Pronto quando: `sellers.service.spec.ts` e `tests/integration/sellers.spec.ts` cobrem CA1, CA2 e CA4 sem token, e a rota aparece no `/docs`.
- [ ] **T2** · Acrescentar o filtro sellerId em GET /listings — R4, R6 · CA1, CA3 · AB# a criar
  - Pronto quando: a integração devolve só os ativos do vendedor e `total: 0` para quem só tem pausados.

## Frontend — `apps/cromocard-frontend`, branch `feature/<id>-buscar-por-vendedor`

- [ ] **T3** [P] · Criar api e queries da busca de vendedores e do filtro sellerId — R3, R4, R7 · AB# a criar
  - Pronto quando: o typecheck passa.
- [ ] **T4** · Criar o seletor Vendedor com a lista de vendedores — R1–R3, R5, R7, R8 · CA1, CA2, CA5 · AB# a criar
  - Pronto quando: `SellerFilter.spec.tsx` cobre a busca, a lista e “Nenhum vendedor encontrado.”; print em 1280 px igual aos frames `1226-1280` e `1226-1576` e sem quebra em 375/768/1024 px.
- ~~**T5**~~ removida em 22/11/2026: a L4 escolheu o filtro no Explorar, e o perfil público da CCD080 não muda.
- [ ] **T6** · Acrescentar o filtro Vendedor na linha de filtros do Explorar — R1, R2, R8 · CA6 · AB# a criar
  - Pronto quando: `ExploreMarketplacePage.spec.tsx` mostra "Vendedor: Todos"; print em 1280 px igual aos frames `1112-3281` e `1112-3674` e sem quebra em 375/768/1024 px.
- [ ] **T7** · Filtrar o Explorar pelo vendedor escolhido, com o chip e o estado vazio — R4, R6, R8 · CA1, CA3, CA9 · AB# a criar
  - Pronto quando: `ExploreMarketplacePage.spec.tsx` cobre escolher "tiago_trocas", o chip que desfaz o filtro e “Este vendedor não possui anúncios ativos.”; print em 1280 px igual aos frames `1226-1862` e `1226-2142` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T8** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1, R2 | T4, T6 |
| R3 | T1, T3, T4 |
| R4 | T2, T3, T7 |
| R5 | T1, T4 |
| R6 | T2, T7 |
| R7 | T1, T3, T4 |
| R8 | T4, T6, T7 |
