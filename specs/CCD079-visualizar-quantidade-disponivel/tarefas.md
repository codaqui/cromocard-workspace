# Tarefas — CCD079 Visualizar Quantidade Disponível

- **Plano:** [plano.md](plano.md) · **User story:** não encontrada no board (AB# a criar)
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende de `listings` e `card_conditions` (CCD084/CCD097) já no `schema.prisma`.

## Backend — `apps/cromocard-backend`, branch `feature/<id>-visualizar-quantidade-disponivel`

- [ ] **T1** · Criar validator e erros do detalhe do anúncio — R1, R2 · AB# a criar
  - Pronto quando: `listingIdParams` e `cardListingsQuery` validam com Zod e `ListingNotFoundError` responde `404 LISTING_NOT_FOUND`.
- [ ] **T2** · Criar repository de leitura de anúncios — R2, R6 · AB# a criar
  - Pronto quando: `findPublicById` traz a condição e ignora excluídos; `findActiveByCard` filtra `ACTIVE` com quantidade > 0, exclui o atual e ordena por menor preço (depende da L3).
- [ ] **T3** · Criar service do detalhe com a disponibilidade — R2–R6 · CA1, CA3, CA4 · AB# a criar
  - Pronto quando: `listings.service.spec.ts` e `listings.availability.spec.ts` cobrem quantidade 0, `PAUSED`, `CLOSED` (depende da L1), `isOwner` (depende da L5) e outros anúncios, com 90% de cobertura.
- [ ] **T4** · Criar endpoints GET /listings/:id e GET /cards/:cardId/listings — R1, R2, R6 · CA1, CA3, CA4 · AB# a criar
  - Pronto quando: as rotas aparecem no `/docs`, `tests/integration/listings.spec.ts` responde `200` sem token, `404` para excluído e `400` para id inválido.

## Frontend — `apps/cromocard-frontend`, branch `feature/<id>-visualizar-quantidade-disponivel`

- [ ] **T5** [P] · Criar tipos, api e queries do detalhe do anúncio — R2–R6 · AB# a criar
  - Pronto quando: o typecheck passa e `listings.api.spec.ts` cobre as duas chamadas.
- [ ] **T6** · Criar bloco de compra com quantidade disponível e estado indisponível — R3–R5, R8 · CA1, CA3, CA4, CA6, CA7 · AB# a criar
  - Pronto quando: `ListingPurchasePanel.spec.tsx` cobre disponível e indisponível; print em 1280 px igual aos frames `1112-5772` e `1112-6152` e sem quebra em 375/768/1024 px.
- [ ] **T7** · Criar tabela de outros anúncios da carta — R6, R8 · CA3, CA7 · AB# a criar
  - Pronto quando: `OtherListingsTable.spec.tsx` cobre a lista e a seção vazia (depende da L3); print em 1280 px igual ao frame `1112-6152` e sem quebra em 375/768/1024 px.
- [ ] **T8** · Criar página do detalhe do anúncio e a rota /anuncios/:id — R1, R7, R8 · CA1, CA2, CA5, CA6 · AB# a criar
  - Pronto quando: `ListingDetailPage.spec.tsx` cobre visitante, cliente logado, carregando, erro e `404`; print em 1280 px igual ao frame `1112-5772` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T9** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T1, T4, T8 |
| R2 | T1, T2, T3, T4, T5 |
| R3 | T3, T5, T6 |
| R4, R5 | T3, T5, T6 |
| R6 | T2, T3, T4, T5, T7 |
| R7 | T8 |
| R8 | T6, T7, T8 |
