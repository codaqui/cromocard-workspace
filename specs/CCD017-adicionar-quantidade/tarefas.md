# Tarefas — CCD017 Adicionar Quantidade

- **Plano:** [plano.md](plano.md) · **User story:** AB#123
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure criadas em 22/11/2026 (Sprint 08), atribuídas a quem o plano final indica.

## Backend — `apps/cromocard-backend`, branch `feature/123-adicionar-quantidade`

- [ ] **T1** · Acrescentar a quantidade à regra de estado e ao service da marcação — R1, R3 · CA1, CA3 · AB#1038
  - Pronto quando: `collection-card-state.spec.ts` e `collection-cards-marking.service.spec.ts` cobrem 1 → `OWNED`, 2 →
    `DUPLICATE`, carta faltante (`422 CARD_NOT_OWNED`, depende da L3) e carta fora da coleção (`404`).
- [ ] **T2** · Criar endpoint PATCH /collections/me/cards/:cardId/quantity — R1, R5 · CA1–CA3 · AB#1039
  - Pronto quando: a rota aparece no `/docs` e `tests/integration/collection-card-quantity.spec.ts` cobre CA1, CA2
    (`400`) e CA3.

## Frontend — `apps/cromocard-frontend`, branch `feature/123-adicionar-quantidade`

- [ ] **T3** [P] · Criar api, mutation e schema do valor manual da quantidade — R3–R6 · CA2 · AB#1040
  - Pronto quando: `collection-quantity.schema.spec.ts` cobre negativo, zero, decimal, texto e 1000.
- [ ] **T4** · Criar controle de quantidade com o mais e o valor manual nas cartas — R2, R4–R7 · CA1, CA2, CA4, CA5 · AB#1041
  - Pronto quando: `CardQuantityControl.spec.tsx` cobre CA1, CA2 e CA4, e print em 1280 px igual ao frame `1160-23696` e
    sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T5** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1042
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T1, T2 |
| R2 | T4 |
| R3 | T1, T3 |
| R4, R6 | T3, T4 |
| R5 | T2, T3, T4 |
| R7 | T4 |
