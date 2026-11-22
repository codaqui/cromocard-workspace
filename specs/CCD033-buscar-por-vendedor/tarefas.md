# Tarefas — CCD033 Buscar por Vendedor

- **Plano:** [plano.md](plano.md) · **User story:** AB#166
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- AB# de cada Task: a criar (as Tasks no Azure só serão criadas com o pedido do Daniel).
- Fase Futuro Marketplace. Pela proposta da L2 só a T1 é feita; T2–T4 valem se a L2 mantiver a CCD033, depois da CCD067.

## Documentação — workspace

- [ ] **T1** · Registrar a decisão da duplicidade nos casos de uso 33 e 67 · docs · AB# a criar
  - Pronto quando: `docs/Casos-De-Uso/33-buscar-por-vendedor.md` aponta para o `67` (ou as diferenças ficam resolvidas) e a spec tem o status decidido.

## Backend — `apps/cromocard-backend`, branch `feature/166-buscar-por-vendedor`

- [ ] **T2** · Exigir login na busca por vendedor — R1 · CA4 · AB# a criar
  - Pronto quando: `tests/integration/sellers.spec.ts` responde `401` sem token e cobre CA1 e CA3 com token.

## Frontend — `apps/cromocard-frontend`, branch `feature/166-buscar-por-vendedor`

- [ ] **T3** [P] · Pedir login ao visitante no escopo Vendedores — R1, R2, R7 · CA4, CA5, CA6 · AB# a criar
  - Pronto quando: o visitante vê "Entre para continuar" ao escolher "Vendedores"; print em 1280 px igual ao frame `1112-3281` e sem quebra em 375/768/1024 px.
- [ ] **T4** · Ajustar a mensagem sem vendedor — R3–R6, R7 · CA1–CA3, CA7, CA8 · AB# a criar
  - Pronto quando: `SellerResultList.spec.tsx` cobre o texto da L2; prints em 1280 px iguais aos frames `1112-3970` e `1160-1396` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T5** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` (ou `Cancelada`) · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` (ou a T1 está mergeada) e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T1, T2, T3 |
| R2 | T3 |
| R3, R4, R5 | T1, T4 |
| R6 | T1, T4 |
| R7 | T3, T4 |
