# Tarefas — CCD102 Exportar Log de Auditoria

- **Plano:** [plano.md](plano.md) · **User story:** AB#606
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/606-exportar-log-de-auditoria`

- [ ] **T1** · Criar migration de ip_address e gravar o IP no AuditLogService — R9 · AB#678
  - Pronto quando: toda ação nova grava o IP de quem fez.
- [ ] **T2** · Criar exportação CSV dos registros filtrados com auditoria — R2–R5 · CA1, CA2 · AB#679
  - Pronto quando: `audit-logs.service.spec.ts` cobre CA1 e CA2.
- [ ] **T3** · Criar resumo de 30 dias, filtros rápidos e busca por IP — R7–R9 · CA3–CA5 · AB#680
  - Pronto quando: `audit-logs.service.spec.ts` cobre CA3–CA5.
- [ ] **T4** · Criar rotas de exportação e resumo do log — R1 · CA6 · AB#681
  - Pronto quando: as rotas aparecem no `/docs` e respondem `403` para quem não é ADMIN.

## Frontend — `apps/cromocard-frontend`, branch `feature/606-exportar-log-de-auditoria`

- [ ] **T5** [P] · Criar api e queries da exportação e do resumo do log — R2, R7 · AB#682
  - Pronto quando: o typecheck passa.
- [ ] **T6** · Acrescentar Extrair Logs, resumo, filtros rápidos, justificativa e busca por IP na tela de Logs — R2, R3, R5–R9 · CA1–CA5 · AB#683
  - Pronto quando: `AuditLogsPage.spec.tsx` cobre exportar sem registros e o filtro rápido.

## Fechamento — workspace

- [ ] **T7** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#684
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T4 |
| R2 | T2, T5, T6 |
| R3, R5 | T2, T6 |
| R4 | T2 |
| R6 | T6 |
| R7 | T3, T5, T6 |
| R8 | T3, T6 |
| R9 | T1, T3, T6 |
