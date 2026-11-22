# Tarefas — CCD081 Visualizar Avaliações

- **Plano:** [plano.md](plano.md) · **User story:** não encontrada no board (AB# a criar)
- **Fase Futuro Marketplace: implementar depois do MVP.**
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende da CCD079, da CCD080 e de `reviews` (CCD097) no `schema.prisma`; o frontend depende do frame da L1.

## Backend — `apps/cromocard-backend`, branch `feature/<id>-visualizar-avaliacoes`

- [ ] **T1** · Criar repository e service das avaliações do vendedor — R3–R6 · CA1, CA3 · AB# a criar
  - Pronto quando: `reviews.service.spec.ts` cobre média com uma casa, total, ordem, vazio e avaliação sem comentário (depende da L5), com 90% de cobertura.
- [ ] **T2** · Criar endpoint GET /profiles/:userId/reviews — R1, R3–R5 · CA1, CA4 · AB# a criar
  - Pronto quando: a rota aparece no `/docs` e `tests/integration/profile-reviews.spec.ts` responde `200`, `401` sem token, `404` e `400`.

## Frontend — `apps/cromocard-frontend`, branch `feature/<id>-visualizar-avaliacoes`

- [ ] **T3** [P] · Criar tipos, api e queries das avaliações — R3–R6 · AB# a criar
  - Pronto quando: o typecheck passa e `reviews.api.spec.ts` cobre a chamada com paginação.
- [ ] **T4** · Criar seção de avaliações do vendedor — R2, R4–R8 · CA1, CA3, CA5, CA6 · AB# a criar
  - Pronto quando: `SellerReviewsSection.spec.tsx` cobre abrir, nota, lista, vazio, carregando e erro; print em 1280 px igual ao frame da seção e ao do vazio (L1) e sem quebra em 375/768/1024 px.
- [ ] **T5** · Incluir a seção no detalhe do anúncio e no perfil público — R1, R2, R8 · CA2, CA4, CA6 · AB# a criar
  - Pronto quando: `ListingDetailPage.spec.tsx` e `PublicProfilePage.spec.tsx` mostram a seção para o cliente e escondem para o visitante; print em 1280 px igual ao frame da seção (L1) dentro de `1112-5772` e `1160-1396` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T6** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T2, T5 |
| R2 | T4, T5 |
| R3 | T1, T2, T3 |
| R4, R5 | T1, T2, T3, T4 |
| R6 | T1, T3, T4 |
| R7 | T4 |
| R8 | T4, T5 |
