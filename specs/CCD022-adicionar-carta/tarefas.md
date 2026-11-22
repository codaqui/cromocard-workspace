# Tarefas — CCD022 Adicionar Carta

- **Plano:** [plano.md](plano.md) · **User story:** AB#128
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende da CCD007, CCD019, CCD021, CCD030 e CCD106.

## Backend — `apps/cromocard-backend`, branch `feature/128-adicionar-carta`

- [ ] **T1** · Criar validator, erro e repository das cartas da coleção — R3, R5–R7 · AB#1079
  - Pronto quando: o repository acha a marcação mesmo excluída e tem `create`, `increment`, `restore` e `ensureUserAlbum`.
- [ ] **T2** · Criar service de adicionar carta à coleção — R3–R7 · CA1, CA3, CA4 · AB#1080
  - Pronto quando: `collection-cards.service.spec.ts` cobre nova, já ativa, `MISSING` (depende da L4), excluída, rascunho e o recálculo, com 90% de cobertura.
- [ ] **T3** · Criar endpoint POST /collections/me/cards — R1, R7 · CA1, CA3–CA6 · AB#1081
  - Pronto quando: a rota aparece no `/docs` e `tests/integration/collection-cards.spec.ts` cobre `201`, `200`, `400`, `401`, `403` e `404`.
- [ ] **T4** · Acrescentar o estado na coleção à busca e ao perfil da carta — R2, R5 · AB#1082
  - Pronto quando: `GET /cards/search` e `GET /cards/:id` com token trazem `inCollection`, coberto em integração.

## Frontend — `apps/cromocard-frontend`, branch `feature/128-adicionar-carta`

- [ ] **T5** [P] · Criar tipos, api, mutação e textos de adicionar carta — R3–R5 · AB#1083
  - Pronto quando: o typecheck passa e a mutação invalida busca, carta, grade e progresso.
- [ ] **T6** · Ligar o Adicionar dos resultados do modal à coleção — R2, R4, R5, R8 · CA1, CA7, CA9 · AB#1084
  - Pronto quando: `CardSearchResult.spec.tsx` cobre adicionar, o selo e o aviso; print em 1280 px igual aos frames `1160-28449` e `1160-23696` e sem quebra em 375/768/1024 px.
- [ ] **T7** · Criar botão Adicionar à coleção do perfil da carta — R2, R5, R8 · CA2, CA3, CA8 · AB#1085
  - Pronto quando: `AddToCollectionButton.spec.tsx` cobre adicionar e adicionar de novo; print em 1280 px igual ao frame `1112-4615` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T8** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1086
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3 |
| R2 | T4, T6, T7 |
| R3 | T1, T2, T5 |
| R4 | T2, T5, T6 |
| R5 | T1, T2, T4, T5, T6, T7 |
| R6 | T1, T2 |
| R7 | T1, T2, T3 |
| R8 | T6, T7 |
