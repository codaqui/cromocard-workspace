# Tarefas — CCD060 Disparar Notificação Global

- **Plano:** [plano.md](plano.md) · **User story:** AB#335
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/335-notificacao-global`

- [ ] **T1** · Criar validator e repository de notificações globais com entrega em transação — R3–R5, R8–R10 · AB#561
  - Pronto quando: o repository grava o disparo, as notificações e o total numa transação.
- [ ] **T2** · Criar service de disparo com destinatários e auditoria — R8, R13 · CA1, CA4 · AB#562
  - Pronto quando: `global-notifications.service.spec.ts` cobre CA1 e CA4.
- [ ] **T3** · Criar rotas de disparo, histórico e contagem de destinatários — R1, R12 · CA2, CA6 · AB#563
  - Pronto quando: as rotas aparecem no `/docs` e respondem como no contrato.

## Frontend — `apps/cromocard-frontend`, branch `feature/335-notificacao-global`

- [ ] **T4** [P] · Criar api, queries e schema de notificação global — R3–R5 · AB#564
  - Pronto quando: o schema espelha o validator e o typecheck passa.
- [ ] **T5** · Criar tela de notificação global com pré-visualização, confirmação e histórico — R2, R6, R7, R11 · CA2, CA3, CA5 · AB#565
  - Pronto quando: `GlobalNotificationPage.spec.tsx` cobre envio, erro e cancelar.

## Fechamento — workspace

- [ ] **T6** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#566
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3 |
| R2 | T5 |
| R3–R5 | T1, T4 |
| R6, R7 | T5 |
| R8–R10 | T1, T2 |
| R11 | T5 |
| R12 | T3 |
| R13 | T2 |
| R14 | T2 |
| R15 | T1, T4, T5 |
| R16 | T3, T5 |
