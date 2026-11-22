# Tarefas — CCD067 Buscar por Vendedor

- **Plano:** [plano.md](plano.md) · **User story:** a criar (L2)
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- AB# de cada Task: a criar (as Tasks no Azure só serão criadas com o pedido do Daniel).
- Fase Futuro Marketplace: implementar depois do MVP, da CCD078 e da CCD080.

## Backend — `apps/cromocard-backend`, branch `feature/<id>-buscar-por-vendedor`

- [ ] **T1** · Criar endpoint GET /sellers — R3, R5, R7 · CA1, CA2, CA4 · AB# a criar
  - Pronto quando: `sellers.service.spec.ts` e `tests/integration/sellers.spec.ts` cobrem CA1, CA2 e CA4 sem token, e a rota aparece no `/docs`.
- [ ] **T2** · Acrescentar o filtro sellerId em GET /listings — R4, R6 · CA1, CA3 · AB# a criar
  - Pronto quando: a integração devolve só os ativos do vendedor e `total: 0` para quem só tem pausados.

## Frontend — `apps/cromocard-frontend`, branch `feature/<id>-buscar-por-vendedor`

- [ ] **T3** [P] · Criar api e queries da busca de vendedores e do filtro sellerId — R3, R4, R7 · AB# a criar
  - Pronto quando: o typecheck passa.
- [ ] **T4** · Criar lista de vendedores encontrados — R3, R5, R8 · CA1, CA2 · AB# a criar
  - Pronto quando: `SellerResultList.spec.tsx` cobre a lista e “Nenhum vendedor encontrado.”; print em 1280 px igual ao estilo do frame `1112-3970` e sem quebra em 375/768/1024 px.
- [ ] **T5** · Ligar os anúncios ativos do perfil público ao filtro sellerId — R4, R6, R8 · CA1, CA3, CA8 · AB# a criar
  - Pronto quando: `SellerActiveListings.spec.tsx` cobre a lista e “Este vendedor não possui anúncios ativos.”; print em 1280 px igual ao frame `1160-1396` e sem quebra em 375/768/1024 px.
- [ ] **T6** · Criar a escolha Cartas ou Vendedores na busca do Explorar — R1, R2, R8 · CA1, CA5, CA6 · AB# a criar
  - Pronto quando: `ListingSearchScope.spec.tsx` cobre a troca de escopo; print em 1280 px igual ao frame `1112-3281` (e ao frame da opção, quando a L4 o pedir) e sem quebra em 375/768/1024 px.
- [ ] **T7** · Mostrar os vendedores no Explorar e abrir o perfil escolhido — R1–R3 · CA1, CA2 · AB# a criar
  - Pronto quando: `ExploreMarketplacePage.spec.tsx` cobre buscar "tiago", escolher "tiago_trocas" e abrir `/usuarios/tiago_trocas`.

## Fechamento — workspace

- [ ] **T8** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1, R2 | T6, T7 |
| R3 | T1, T3, T4, T7 |
| R4 | T2, T3, T5 |
| R5 | T1, T4 |
| R6 | T2, T5 |
| R7 | T1, T3 |
| R8 | T4, T5, T6 |
