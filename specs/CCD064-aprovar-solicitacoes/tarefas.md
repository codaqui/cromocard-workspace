# Tarefas — CCD064 Aprovar Solicitações

- **Plano:** [plano.md](plano.md) · **User story:** AB#339
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/339-aprovar-solicitacoes`

- [ ] **T1** · Criar validator, errors e repository das solicitações — R3, R5, R7, R11 · AB#581
  - Pronto quando: o repository lista por tipo e status e só muda solicitação `PENDING`.
- [ ] **T2** · Criar service de aprovar e recusar com catálogo, auditoria e notificação — R6–R13 · CA2–CA6 · AB#582
  - Pronto quando: `catalog-requests.service.spec.ts` cobre CA2–CA6.
- [ ] **T3** · Criar rotas de lista, detalhe, aprovar e recusar — R1 · CA7 · AB#583
  - Pronto quando: as rotas aparecem no `/docs` e respondem como no contrato.

## Frontend — `apps/cromocard-frontend`, branch `feature/339-aprovar-solicitacoes`

- [ ] **T4** [P] · Criar api, queries e types das solicitações — R3–R7 · AB#584
  - Pronto quando: o typecheck passa.
- [ ] **T5** · Criar tela de solicitações com abas e cartões de aprovar e recusar — R2–R12 · CA1, CA4 · AB#585
  - Pronto quando: `CatalogRequestsPage.spec.tsx` cobre aprovar, recusar com motivo e solicitação já processada.

## Fechamento — workspace

- [ ] **T6** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#586
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3 |
| R2–R5 | T1, T4, T5 |
| R6–R10 | T2, T5 |
| R11 | T1, T2, T5 |
| R12 | T5 |
| R13 | T2 |
| R14, R15 | T2, T3, T5 |
