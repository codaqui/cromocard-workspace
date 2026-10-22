# Tarefas — CCD101 Segmentar Notificação Global

- **Plano:** [plano.md](plano.md) · **User story:** AB#605
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/605-segmentar-notificacao-global`

- [ ] **T1** · Criar migration de público e canais em global_notifications — R6 · AB#671
  - Pronto quando: as colunas existem e o `schema.prisma` bate com o DBML.
- [ ] **T2** · Criar destinatários por público, canais e envio de e-mail em lote — R2, R3, R5, R6, R8, R9 · CA2–CA4 · AB#672
  - Pronto quando: `global-notifications.service.spec.ts` cobre CA2–CA4.
- [ ] **T3** · Atualizar as rotas de disparo e de contagem com público e canais — R1, R3 · CA6 · AB#673
  - Pronto quando: o `/docs` mostra `audience` e `channels`.

## Frontend — `apps/cromocard-frontend`, branch `feature/605-segmentar-notificacao-global`

- [ ] **T4** [P] · Criar api e schema de público e canais — R2–R4 · AB#674
  - Pronto quando: o typecheck passa.
- [ ] **T5** · Acrescentar público com contagem e canais no formulário de notificação — R2–R4, R7–R9 · CA1 · AB#675
  - Pronto quando: a contagem muda ao trocar o público.
- [ ] **T6** · Mostrar público e canal no histórico de disparos — R10 · CA5 · AB#676
  - Pronto quando: `GlobalNotificationPage.spec.tsx` cobre CA5.

## Fechamento — workspace

- [ ] **T7** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#677
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3 |
| R2 | T2, T4, T5 |
| R3 | T2, T3, T4, T5 |
| R4 | T4, T5 |
| R5 | T2 |
| R6 | T1, T2 |
| R7 | T5 |
| R8, R9 | T2, T5 |
| R10 | T6 |
