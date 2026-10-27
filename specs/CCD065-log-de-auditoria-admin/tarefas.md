# Tarefas — CCD065 Log de Auditoria Admin

- **Plano:** [plano.md](plano.md) · **User story:** AB#340
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/340-log-de-auditoria`

- [ ] **T1** · Criar consultas de lista, detalhe e total do log de auditoria — R3–R6, R8 · CA1–CA3, CA5 · AB#587
  - Pronto quando: `audit-logs.service.spec.ts` cobre filtros, detalhe e admin excluído.
- [ ] **T2** · Criar rotas de leitura do log de auditoria — R1 · CA6 · AB#588
  - Pronto quando: as rotas aparecem no `/docs` e respondem `403` para quem não é ADMIN.

## Frontend — `apps/cromocard-frontend`, branch `feature/340-log-de-auditoria`

- [ ] **T3** [P] · Criar api, queries, types e rótulos das ações do log — R4 · AB#589
  - Pronto quando: cada `action` tem rótulo em pt-BR e o typecheck passa.
- [ ] **T4** · Criar tela de Logs com filtros, tabela e detalhe — R2–R7, R9 · CA1–CA4 · AB#590
  - Pronto quando: `AuditLogsPage.spec.tsx` cobre filtro vazio e abrir o detalhe.

## Fechamento — workspace

- [ ] **T5** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#591
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T2 |
| R2 | T4 |
| R3–R6 | T1, T3, T4 |
| R7, R9 | T4 |
| R8 | T1 |
| R10 | T1, T3 |
