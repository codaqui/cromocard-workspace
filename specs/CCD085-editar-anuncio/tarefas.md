# Tarefas — CCD085 Editar Anúncio (agrupa CCD086, CCD087 e CCD088)

- **Plano:** [plano.md](plano.md) · **User stories:** AB#344, AB#345, AB#346, AB#347
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure criadas em 22/11/2026 (Sprint 08), atribuídas a quem o plano final indica.
  (CCD072/CCD097) e da `suspended_until` (CCD099) no `develop`.

## Backend — `apps/cromocard-backend`, branch `feature/344-editar-anuncio`

- [ ] **T1** · Acrescentar ao seed anúncios ativos, pausados, esgotados e excluídos do vendedor — R2 · AB#1461
  - Pronto quando: o vendedor do seed tem os quatro casos e um pedido `AWAITING_PAYMENT` num anúncio ativo.
- [ ] **T2** · Criar lista e detalhe dos anúncios do vendedor — R1–R3 · CA1, CA11, CA12 · AB#1462
  - Pronto quando: `seller-listings.service.spec.ts` cobre abas, contagem, busca, ordenação e o `404` de outro vendedor.
- [ ] **T3** · Criar edição de anúncio com troca de fotos — R3–R6, R15 · CA2, CA3 · AB#1463
  - Pronto quando: o service grava preço, condição, quantidade, descrição e fotos e recusa status inválido.
- [ ] **T4** · Criar exclusão de anúncio com soft delete — R7–R9, R15 · CA4 · AB#1464
  - Pronto quando: `deleted_at` é gravado no anúncio e nas fotos e o pedido aberto bloqueia com `422`.
- [ ] **T5** · Criar ações pausar e reativar anúncio — R10–R15 · CA6–CA10 · AB#1465
  - Pronto quando: o service cobre a pausa bloqueada, a restrição de conta, a conta não pronta e as transições inválidas.
- [ ] **T6** · Criar rotas GET, PATCH e DELETE /me/listings/:id e POST /pause e /reactivate — R1 · CA11 · AB#1466
  - Pronto quando: as rotas aparecem no `/docs`.
- [ ] **T7** · Criar testes de integração da gestão de anúncios — R1–R15 · CA1–CA4, CA6–CA11 · AB#1467
  - Pronto quando: a integração passa, inclusive o anúncio pausado fora da listagem pública, com 90% de cobertura nos
    arquivos alterados.

## Frontend — `apps/cromocard-frontend`, branch `feature/344-editar-anuncio`

- [ ] **T8** [P] · Criar api, queries e textos da gestão de anúncios — R2–R15 · AB#1468
  - Pronto quando: o typecheck passa e o `.api.spec.ts` cobre as seis chamadas.
- [ ] **T9** · Criar página Meus anúncios — R2, R16 · CA1, CA12, CA13 · AB#1469
  - Pronto quando: `MyListingsPage.spec.tsx` cobre CA1 e CA12; print em 1280 px igual ao frame `675-1452` e sem quebra em
    375/768/1024 px.
- [ ] **T10** · Criar modal Editar anúncio — R3–R6, R16 · CA2, CA3, CA14 · AB#1470
  - Pronto quando: `EditListingModal.spec.tsx` cobre CA2 e CA3; print em 1280 px igual ao frame `675-4218` e sem quebra em
    375/768/1024 px.
- [ ] **T11** · Criar diálogo Excluir anúncio — R7–R9, R16 · CA4, CA5, CA15 · AB#1471
  - Pronto quando: `DeleteListingDialog.spec.tsx` cobre CA4 e CA5; print em 1280 px igual ao frame `675-2112` e sem quebra em
    375/768/1024 px.
- [ ] **T12** · Criar diálogo Pausar anúncio e a reativação — R10–R14, R16 · CA6–CA9, CA16, CA17 · AB#1472
  - Pronto quando: `PauseListingDialog.spec.tsx` e `useReactivateListing.spec.tsx` cobrem CA6–CA9; print em 1280 px igual
    aos frames `675-2808` e `675-3522` (depois da L6) e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T13** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1473
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T2, T6, T7 |
| R2 | T1, T2, T8, T9 |
| R3 | T2, T3, T8, T10 |
| R4, R5, R6 | T3, T8, T10 |
| R7, R8, R9 | T4, T8, T11 |
| R10, R11, R12 | T5, T7, T8, T12 |
| R13, R14 | T5, T8, T12 |
| R15 | T3, T4, T5, T7 |
| R16 | T9, T10, T11, T12 |
