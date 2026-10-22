# Tarefas — CCD100 Agendar Notificação Global

- **Plano:** [plano.md](plano.md) · **User story:** AB#604
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/604-agendar-notificacao-global`

- [ ] **T1** · Criar migration de agendamento em global_notifications — R5 · AB#663
  - Pronto quando: as colunas e o enum existem e o `schema.prisma` bate com o DBML.
- [ ] **T2** · Criar agendar e cancelar no service de notificação global com auditoria — R4, R5, R9 · CA1, CA2, CA4 · AB#664
  - Pronto quando: `global-notifications.service.spec.ts` cobre CA1, CA2 e CA4.
- [ ] **T3** · Criar job de envio das notificações agendadas — R7 · CA3 · AB#665
  - Pronto quando: `send-scheduled-notifications.job.spec.ts` cobre CA3.
- [ ] **T4** · Criar rota de cancelar e atualizar o contrato do disparo — R1 · CA6 · AB#666
  - Pronto quando: as rotas aparecem no `/docs` com `scheduledAt` e `status`.

## Frontend — `apps/cromocard-frontend`, branch `feature/604-agendar-notificacao-global`

- [ ] **T5** [P] · Criar api e schema do agendamento — R2–R5, R9 · AB#667
  - Pronto quando: o typecheck passa.
- [ ] **T6** · Acrescentar agendamento com calendário e horário na tela de notificação — R2–R4, R6 · CA1, CA2 · AB#668
  - Pronto quando: a tela agenda e mostra a confirmação com o horário.
- [ ] **T7** · Acrescentar status e cancelar no histórico de disparos — R8, R9 · CA4, CA5 · AB#669
  - Pronto quando: `GlobalNotificationPage.spec.tsx` cobre CA5.

## Fechamento — workspace

- [ ] **T8** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#670
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T4 |
| R2, R3 | T5, T6 |
| R4 | T2, T5, T6 |
| R5 | T1, T2, T5 |
| R6 | T6 |
| R7 | T3 |
| R8 | T7 |
| R9 | T2, T5, T7 |
