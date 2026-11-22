# Tarefas — CCD041 Silenciar Notificações de Grupo

- **Plano:** [plano.md](plano.md) · **User story:** AB#144
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure criadas em 22/11/2026 (Sprint 08), atribuídas a quem o plano final indica.

## Docs — workspace, branch `docs/144-silenciar-ate-reativar`

- [ ] **T1** · Registrar ADR do silêncio até reativar com data distante — R4 · AB#1176
  - Pronto quando: o ADR `Proposto` está em `docs/ADR/` e o `41` cita o período (depende da L2).

## Backend — `apps/cromocard-backend`, branch `feature/144-silenciar-notificacoes-de-grupo`

- [ ] **T2** · Criar silenciar e reativar notificações do grupo — R1, R3, R4, R6–R8 · CA1–CA5 · AB#1177
  - Pronto quando: as rotas aparecem no `/docs` e os testes cobrem os períodos, o prazo vencido, reativar, `401` e `403`.
- [ ] **T3** · Filtrar membros silenciados no aviso de mensagem nova — R5, R6 · CA1, CA3, CA4 · AB#1178
  - Pronto quando: `notifications.service.spec.ts` cobre silenciado sem aviso e prazo vencido com aviso.

## Frontend — `apps/cromocard-frontend`, branch `feature/144-silenciar-notificacoes-de-grupo`

- [ ] **T4** [P] · Criar api e queries de silenciar e reativar — R3, R4, R8 · AB#1179
  - Pronto quando: o typecheck passa.
- [ ] **T5** · Criar modal Silenciar grupo e o de reativar — R2–R4, R8, R9 · CA1, CA2, CA4, CA6 · AB#1180
  - Pronto quando: `MuteGroupDialog.spec.tsx` e `UnmuteGroupDialog.spec.tsx` cobrem os períodos e reativar; print em
    1280 px igual ao frame `675-15445` e sem quebra em 375/768/1024 px.
- [ ] **T6** · Mostrar o sino silenciado no topo do chat e no cartão do grupo — R7, R9 · CA3, CA7, CA8 · AB#1181
  - Pronto quando: o sino muda com `mutedUntil`; print em 1280 px igual aos frames `675-14037` e `417-2915` e sem quebra
    em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T7** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1182
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T2 |
| R2 | T5 |
| R3 | T2, T4, T5 |
| R4 | T1, T2, T4, T5 |
| R5 | T3 |
| R6 | T2, T3 |
| R7 | T2, T6 |
| R8 | T2, T4, T5 |
| R9 | T5, T6 |
