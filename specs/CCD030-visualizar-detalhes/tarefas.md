# Tarefas — CCD030 Visualizar Detalhes

- **Plano:** [plano.md](plano.md) · **User story:** AB#163
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende de `cards.status` (CCD106), `listings`/`card_conditions` (CCD084) e `price_history` (CCD075 ou CCD007).

## Backend — `apps/cromocard-backend`, branch `feature/163-visualizar-detalhes`

- [ ] **T1** · Criar validator, erro e repository do perfil público da carta — R3, R5, R13 · AB#1106
  - Pronto quando: `findPublicById` traz identificação e fotos e ignora excluída e rascunho.
- [ ] **T2** · Criar leitura dos anúncios ativos da carta — R7, R8 · CA2 · AB#1107
  - Pronto quando: `listings.service.spec.ts` cobre ordem por menor preço, pausado de fora, contagem e menor preço.
- [ ] **T3** · Criar service do perfil da carta — R3–R5, R13 · CA1 · AB#1108
  - Pronto quando: `cards.service.spec.ts` cobre o perfil completo, sem preço (`null`, depende da L2) e o `404`, com 90% de cobertura.
- [ ] **T4** · Criar endpoints GET /cards/:id e GET /cards/:cardId/listings — R1, R7, R13 · CA1, CA2, CA8 · AB#1109
  - Pronto quando: as rotas aparecem no `/docs` e `tests/integration/cards-profile.spec.ts` responde `200` sem token, `404` para rascunho e `400` para id inválido.

## Frontend — `apps/cromocard-frontend`, branch `feature/163-visualizar-detalhes`

- [ ] **T5** [P] · Criar tipos, api, queries e textos do perfil da carta — R3–R5, R10–R12 · AB#1110
  - Pronto quando: o typecheck passa e `card-profile.api.spec.ts` cobre as duas chamadas.
- [ ] **T6** · Criar galeria, preços e identificação do perfil da carta — R3–R5, R14 · CA1, CA9 · AB#1111
  - Pronto quando: `CardGallery.spec.tsx`, `CardMarketStats.spec.tsx` e `CardIdentification.spec.tsx` passam; print em 1280 px igual ao frame `1112-4615` e sem quebra em 375/768/1024 px.
- [ ] **T7** · Criar lista de anúncios disponíveis da carta — R7–R9, R12, R14 · CA2, CA3, CA7, CA9 · AB#1112
  - Pronto quando: `CardListingsList.spec.tsx` cobre a ordem, "Ver anúncio", vazia e o botão do vendedor; print em 1280 px igual ao frame `1112-4615` e sem quebra em 375/768/1024 px.
- [ ] **T8** · Criar modal Entre para continuar com retorno para a carta — R11, R14 · CA4, CA5, CA11 · AB#1113
  - Pronto quando: `LoginToContinueModal.spec.tsx` cobre as três saídas e o retorno; print em 1280 px igual ao frame `1112-5461` e sem quebra em 375/768/1024 px.
- [ ] **T9** · Criar página e rota /cartas/:id com o histórico de preços — R1, R2, R6, R10, R14 · CA1, CA4–CA6, CA9, CA10 · AB#1114
  - Pronto quando: `CardProfilePage.spec.tsx` cobre visitante, logado, carregando, erro e `404`; print em 1280 px igual aos frames `1112-4615` e `1112-5038` e sem quebra em 375/768/1024 px.
- [ ] **T10** · Ligar os cartões da busca, do marketplace e da Home ao perfil da carta — R2 · CA1 · AB#1115
  - Pronto quando: o clique nos cartões existentes leva a `/cartas/:id`, coberto nos testes de cada lista.

## Fechamento — workspace

- [ ] **T11** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1116
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T4, T9 |
| R2 | T9, T10 |
| R3, R5 | T1, T3, T5, T6 |
| R4 | T3, T5, T6 |
| R6 | T9 |
| R7, R8 | T2, T4, T7 |
| R9 | T7 |
| R10 | T5, T9 |
| R11 | T5, T8 |
| R12 | T5, T7 |
| R13 | T1, T3, T4 |
| R14 | T6, T7, T8, T9 |
