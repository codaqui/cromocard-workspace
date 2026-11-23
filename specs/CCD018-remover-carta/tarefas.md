# Tarefas — CCD018 Remover Carta

- **Plano:** [plano.md](plano.md) · **User story:** AB#124
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure criadas em 22/11/2026 (Sprint 08), atribuídas a quem o plano final indica.

## Docs — workspace

- [ ] **T1** · Registrar ADR da remoção de carta da coleção sem exclusão lógica — R4 · AB#1043
  - Pronto quando: o ADR novo nasce `Proposto` em `docs/ADR/`, revê a citação da CCD018 no ADR-015 e o índice do
    `README.md` dos ADRs o lista (depende da L6).

## Backend — `apps/cromocard-backend`, branch `feature/124-remover-carta`

- [ ] **T2** · Acrescentar diminuir e remover à regra de estado e ao service da marcação — R1, R3–R6 · CA1–CA4 · AB#1044
  - Pronto quando: `collection-card-state.spec.ts` cobre as 6 células das ações `DECREMENT` e `REMOVE` e
    `collection-cards-marking.service.spec.ts` cobre CA2 (progresso 79,63) e o `422 QUANTITY_ALREADY_ZERO`.
- [ ] **T3** · Criar endpoints POST /collections/me/cards/:cardId/decrement e /remove — R1, R6 · CA1–CA5 · AB#1045
  - Pronto quando: as rotas aparecem no `/docs` e `tests/integration/collection-card-remove.spec.ts` cobre CA1–CA5.

## Frontend — `apps/cromocard-frontend`, branch `feature/124-remover-carta`

- [ ] **T4** [P] · Criar api e mutations de diminuir e remover a carta — R3–R5, R7 · AB#1046
  - Pronto quando: `collection.api.spec.ts` cobre as duas chamadas e as mutations atualizam a carta e as contagens.
- [ ] **T5** · Ligar o menos do controle de quantidade — R2, R5–R8 · CA1, CA2, CA4, CA6, CA7 · AB#1047
  - Pronto quando: `CardQuantityControl.spec.tsx` cobre CA1, CA4 e CA6, e print em 1280 px igual ao frame `1160-23696` e
    sem quebra em 375/768/1024 px.
- [ ] **T6** · Criar lixeira e modal de remover a carta da coleção — R2, R6–R8 · CA3, CA7 · AB#1048
  - Pronto quando: `RemoveCardDialog.spec.tsx` cobre CA3 e o cancelar, a lixeira fica desabilitada com 0, e print em
    1280 px igual ao frame `1160-23696` (o modal no layout do `1160-27915`, L4) e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T7** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1049
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T2, T3 |
| R2 | T5, T6 |
| R3 | T2, T4 |
| R4 | T1, T2, T4 |
| R5 | T2, T4, T5 |
| R6 | T2, T3, T5, T6 |
| R7 | T4, T5, T6 |
| R8 | T5, T6 |
