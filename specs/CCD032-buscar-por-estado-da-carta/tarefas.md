# Tarefas — CCD032 Buscar por Estado da Carta

- **Plano:** [plano.md](plano.md) · **User story:** AB#165
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure criadas em 22/11/2026 (Sprint 08), atribuídas a quem o plano final indica.
- **Fase MVP** desde 22/11/2026 (ADR-069).

## Backend — `apps/cromocard-backend`, branch `feature/165-buscar-por-estado-da-carta`

- [ ] **T1** · Cobrir o filtro de condição nos testes de integração — R1–R3, R5, R6 · CA1, CA3–CA5 · AB#1121
  - Pronto quando: `tests/integration/listings-public.spec.ts` cobre Near Mint, Regular vazio, a ordem das opções e o acesso decidido na L4.

## Frontend — `apps/cromocard-frontend`, branch `feature/165-buscar-por-estado-da-carta`

- [ ] **T2** [P] · Criar a lista aberta do filtro Condição — R2, R4, R6, R7 · CA1, CA2, CA5, CA6 · AB#1122
  - Pronto quando: `ListingFilters.spec.tsx` cobre as opções na ordem e a escolha; print em 1280 px igual ao frame `1112-3281` e sem quebra em 375/768/1024 px.
- [ ] **T3** · Ajustar a mensagem do vazio conforme a L5 — R5, R7 · CA3, CA7, CA8 · AB#1123
  - Pronto quando: `ExploreMarketplacePage.spec.tsx` cobre o texto decidido; print em 1280 px igual ao frame `1112-3674` e sem quebra em 375/768/1024 px.

## Documentação — workspace

- [ ] **T4** · Registrar as decisões L2–L5 no caso de uso 32 · docs · AB#1124
  - Pronto quando: `docs/Casos-De-Uso/32-buscar-por-estado-da-carta.md` cita o filtro do Explorar (ou o cancelamento) e a spec aponta para o passo novo.

## Fechamento — workspace

- [ ] **T5** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` (ou `Cancelada`) · AB#1125
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T1, T4 |
| R2 | T1, T2 |
| R3 | T1, T4 |
| R4 | T2 |
| R5 | T1, T3, T4 |
| R6 | T1, T2 |
| R7 | T2, T3 |
