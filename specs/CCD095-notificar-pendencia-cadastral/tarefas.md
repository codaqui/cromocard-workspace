# Tarefas — CCD095 Notificar Pendência Cadastral

- **Plano:** [plano.md](plano.md) · **User story:** AB#599
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/599-notificar-pendencia-cadastral`

- [ ] **T1** · Criar seed dos modelos de pendência e o schema da chave — R4, R12 · AB#621
  - Pronto quando: a chave existe depois do seed e o schema Zod valida a lista de modelos.
- [ ] **T2** · Criar service de pendência com notificação, e-mail, prazo e auditoria — R5–R8, R11 · CA3, CA5, CA6 · AB#622
  - Pronto quando: `pending-notice.service.spec.ts` cobre CA3, CA5 e CA6.
- [ ] **T3** · Criar rotas de modelos e de envio da pendência — R1 · CA7 · AB#623
  - Pronto quando: as rotas aparecem no `/docs` e respondem `403` para quem não é ADMIN.

## Frontend — `apps/cromocard-frontend`, branch `feature/599-notificar-pendencia-cadastral`

- [ ] **T4** [P] · Criar api e queries da notificação de pendência — R4–R8 · AB#624
  - Pronto quando: o typecheck passa.
- [ ] **T5** · Criar modal Notificar Lojista com modelos, prazo e confirmação — R2–R6, R9, R10 · CA1, CA2, CA4 · AB#625
  - Pronto quando: `PendingNoticeModal.spec.tsx` cobre escolher modelo, enviar e cancelar.

## Fechamento — workspace

- [ ] **T6** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#626
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3 |
| R2, R3, R9, R10 | T5 |
| R4 | T1, T4, T5 |
| R5, R6 | T2, T4, T5 |
| R7, R8 | T2, T4 |
| R11 | T2 |
| R12 | T1 |
