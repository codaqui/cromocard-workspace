# Tarefas — CCD014 Marcar Carta como Possuo (agrupa CCD015 e CCD016)

- **Plano:** [plano.md](plano.md) · **User story:** AB#120 (e AB#121, AB#122)
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure criadas em 22/11/2026 (Sprint 08), atribuídas a quem o plano final indica.

## Backend — `apps/cromocard-backend`, branch `feature/120-marcar-carta-como-possuo`

- [ ] **T1** · Criar regra de estado da carta na coleção — R3–R8 · CA3, CA5, CA6 · AB#1029
  - Pronto quando: `collection-card-state.spec.ts` cobre as 9 células da tabela de transições do plano.
- [ ] **T2** · Criar recálculo do progresso do álbum — R9 · CA1, CA3, CA6 · AB#1030
  - Pronto quando: `collection-progress.spec.ts` cobre 44 de 54 = 81,48, repetida contando uma vez e `total_cards = 0`.
- [ ] **T3** · Criar service da marcação com restauração da linha — R1–R9 · CA1–CA3, CA5, CA6, CA8 · AB#1031
  - Pronto quando: `collection-cards-marking.service.spec.ts` cobre CA1, CA2, os `404` da L11 e o `422
    CARD_STATUS_UNCHANGED`.
- [ ] **T4** · Criar endpoint PUT /collections/me/cards/:cardId/status — R1 · CA1–CA3, CA5, CA6, CA8 · AB#1032
  - Pronto quando: a rota aparece no `/docs` e `tests/integration/collection-card-marking.spec.ts` cobre CA1–CA3, CA5,
    CA6 e CA8.
- [ ] **T5** · Ligar a carta usada em coleções na exclusão do catálogo — R12 · CA9 · AB#1033
  - Entregue pela CCD007 (backend #48): o `catalog.module.ts` injeta o `collectionService` como `CardUsage`, e o
    `tests/integration/catalog-card-usage.spec.ts` cobre a exclusão bloqueada. A caixa é marcada no fechamento da CCD007.
  - Pronto quando: o `catalog.module.ts` injeta a `CardUsage` do domínio `collection` e o teste de integração cobre o
    CA9 (exclusão bloqueada com o erro da CCD061).

## Frontend — `apps/cromocard-frontend`, branch `feature/120-marcar-carta-como-possuo`

- [ ] **T6** [P] · Criar api, mutation otimista e previsão de estado da marcação — R10, R11 · CA7 · AB#1034
  - Pronto quando: `collection-marking.optimistic.spec.ts` cobre a tabela de transições e a mutation desfaz no erro.
- [ ] **T7** · Criar marcadores Possuo, Falta e Repetida nas cartas do álbum — R2, R5, R7, R10, R13 · CA1, CA4–CA6, CA10 · AB#1035
  - Pronto quando: `CardStatusMarkers.spec.tsx` cobre CA1, CA4, CA5 e CA6, e print em 1280 px igual ao frame
    `1160-23696` e sem quebra em 375/768/1024 px.
- [ ] **T8** · Mostrar o aviso de erro ao salvar a marcação — R11 · CA7 · AB#1036
  - Pronto quando: `AlbumDetailPage.spec.tsx` cobre CA7 (aviso e carta de volta ao status anterior), no estilo do aviso
    padrão da tela `1160-23696`.

## Fechamento — workspace

- [ ] **T9** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1037
  - Pronto quando: os PRs dos apps estão mergeados em `develop`, o índice de `specs/README.md` foi atualizado e a
    pendência da `CardUsage` no `plano.md` da CCD061 aponta para esta story.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3, T4 |
| R2 | T3, T7 |
| R3, R4 | T1, T3 |
| R5 | T1, T3, T7 |
| R6, R8 | T1, T3 |
| R7 | T1, T3, T7 |
| R9 | T2, T3 |
| R10 | T6, T7 |
| R11 | T6, T8 |
| R12 | T5 |
| R13 | T7 |
