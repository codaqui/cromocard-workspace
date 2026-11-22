# Tarefas — CCD036 Adicionar Carta ao Portfólio

- **Plano:** [plano.md](plano.md) · **User story:** AB#139
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende da CCD022 (rota de adicionar), da CCD021 (modal) e da CCD023 (solicitar).

## Backend — `apps/cromocard-backend`, branch `feature/139-adicionar-carta-ao-portfolio`

- [ ] **T1** · Acrescentar quantidade e erros ao adicionar carta — R5, R8 · AB#1139
  - Pronto quando: o validator aceita `quantity` e os erros `409 CARD_ALREADY_IN_COLLECTION`, `422 INVALID_QUANTITY` e `404 COLLECTION_CARD_NOT_FOUND` existem.
- [ ] **T2** · Aplicar a quantidade informada no service de adicionar carta — R5–R8, R10 · CA1, CA2, CA4, CA5 · AB#1140
  - Pronto quando: `collection-cards.service.spec.ts` cobre nova com 2, restaurada, já ativa (`409`), atualizar e quantidade inválida, com 90% de cobertura.
- [ ] **T3** · Criar endpoint PATCH /collections/me/cards/:cardId — R1, R8 · CA2, CA5, CA6 · AB#1141
  - Pronto quando: a rota aparece no `/docs` (ou a da CCD017 é reaproveitada) e `tests/integration/collection-cards.spec.ts` cobre `200`, `401`, `404`, `409` e `422`.

## Frontend — `apps/cromocard-frontend`, branch `feature/139-adicionar-carta-ao-portfolio`

- [ ] **T4** [P] · Criar mutações, schema e textos da quantidade — R5–R8 · AB#1142
  - Pronto quando: o typecheck passa e `collection-cards.schemas.spec.ts` recusa 0 e negativos.
- [ ] **T5** · Criar campo de quantidade ao adicionar carta — R5, R7, R11 · CA1, CA5, CA8 · AB#1143
  - Pronto quando: `AddQuantityForm.spec.tsx` cobre confirmar e recusar; print em 1280 px igual ao frame `1160-28449` e sem quebra em 375/768/1024 px.
- [ ] **T6** · Criar aviso de carta já no portfólio com atualizar quantidade — R8, R11 · CA2, CA8 · AB#1144
  - Pronto quando: `CardAlreadyInCollection.spec.tsx` cobre o aviso e a atualização; print em 1280 px igual ao frame `1160-28449` e sem quebra em 375/768/1024 px.
- [ ] **T7** · Ligar o modal ao detalhe do álbum com a oferta de solicitar cadastro — R2–R4, R7, R9, R11 · CA1, CA3, CA7 · AB#1145
  - Pronto quando: `AddCardModal.spec.tsx` e `AlbumDetailPage.spec.tsx` cobrem buscar, adicionar e o link sem resultado; print em 1280 px igual ao frame `1160-23696` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T8** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1146
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3 |
| R2, R3, R4, R9 | T7 |
| R5 | T1, T2, T4, T5 |
| R6, R10 | T2, T4 |
| R7 | T2, T4, T5, T7 |
| R8 | T1, T2, T3, T4, T6 |
| R11 | T5, T6, T7 |
