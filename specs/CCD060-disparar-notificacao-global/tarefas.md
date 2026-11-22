# Tarefas — CCD060 Disparar Notificação Global (com CCD100 e CCD101)

- **Plano:** [plano.md](plano.md) · **User stories:** AB#335 (CCD060), AB#604 (CCD100), AB#605 (CCD101)
- Entrega conjunta (L9): uma branch e um PR por app, `feature/335-notificacao-global`. As tarefas da CCD100 e da CCD101
  ficam marcadas nos `tarefas.md` delas, com o mesmo commit.
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/335-notificacao-global`

- [x] **T1** · Criar validator e repository de notificações globais com entrega em transação — R3–R5, R8–R10, R14, R15 · AB#561
  - Pronto quando: o repository grava o disparo, as notificações e o total numa transação.
- [x] **T1a** · Criar as migrations de agendamento e de público e canais — CCD100 R5 · CCD101 R6 · AB#663 AB#671
  - Pronto quando: as colunas e o enum existem e o `schema.prisma` bate com o DBML.
- [x] **T2** · Criar service de disparo com público, canais, agendamento, cancelar, auditoria e e-mail — R8, R13, R14 · CA1, CA4 · CCD100 CA1, CA2, CA4 · CCD101 CA2–CA4 · AB#562 AB#664 AB#672
  - Pronto quando: `global-notifications.service.spec.ts` cobre esses critérios.
- [x] **T2a** · Criar job de envio das notificações agendadas — CCD100 R7 · CA3 · AB#665
  - Pronto quando: `send-scheduled-notifications.job.spec.ts` cobre CA3.
- [x] **T3** · Criar rotas de disparo, histórico, contagem e cancelar — R1, R12 · CA2, CA6 · AB#563 AB#666 AB#673
  - Pronto quando: as rotas aparecem no `/docs` e respondem como no contrato.

## Frontend — `apps/cromocard-frontend`, branch `feature/335-notificacao-global`

- [x] **T4** [P] · Criar api, queries e schema de notificação global — R3–R5, R15 · AB#564 AB#667 AB#674
  - Pronto quando: o schema espelha o validator e o typecheck passa.
- [x] **T5** · Criar tela de notificação global com público, canais, agendamento, pré-visualização, confirmação e histórico — R2, R6, R7, R11, R16–R18 · CA2, CA3, CA5, CA7–CA9 · CCD100 CA4, CA5, CA7 · CCD101 CA1, CA5 · AB#565 AB#668 AB#669 AB#675 AB#676
  - Pronto quando: `GlobalNotificationPage.spec.tsx` cobre envio, agendamento, erro, cancelar e histórico.

## Fechamento — workspace

- [ ] **T6** · Atualizar os ponteiros `apps/*` e marcar as specs CCD060, CCD100 e CCD101 como `Implementada` · AB#566 AB#670 AB#677
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3 |
| R2 | T5 |
| R3–R5 | T1, T4, T5 |
| R6, R7 | T5 |
| R8–R10 | T1, T2 |
| R11 | T5 |
| R12 | T3 |
| R13 | T2 |
| R14 | T1, T2 |
| R15 | T1, T4, T5 |
| R16 | T3, T5 |
| R17, R18 | T5 |
| CCD100 e CCD101 | T1a, T2, T2a, T3, T4, T5 (detalhe nos `tarefas.md` delas) |
