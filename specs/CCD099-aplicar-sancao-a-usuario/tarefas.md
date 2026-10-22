# Tarefas — CCD099 Aplicar Sanção a Usuário

- **Plano:** [plano.md](plano.md) · **User story:** AB#603
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/603-aplicar-sancao-a-usuario`

- [ ] **T1** · Criar migrations das sanções (suspensão com prazo, BLOCKED, WARNED e user_warnings) — R4–R6, R12 · AB#653
  - Pronto quando: as migrations rodam e o `schema.prisma` bate com o DBML.
- [ ] **T2** · Criar service de advertir, suspender por prazo, banir e reativar com auditoria — R3–R7, R10 · CA1–CA4, CA7 · AB#654
  - Pronto quando: `user-sanctions.service.spec.ts` cobre CA1–CA4 e CA7.
- [ ] **T3** · Bloquear login e renovação de token de usuário banido — R11 · CA3 · AB#655
  - Pronto quando: `auth.service.spec.ts` cobre o `403` para `BLOCKED`.
- [ ] **T4** · Criar job que encerra as suspensões vencidas — R9 · CA6 · AB#656
  - Pronto quando: `lift-expired-suspensions.job.spec.ts` cobre CA6.
- [ ] **T5** · Criar remover e advertir, advertir grupo e filtro de gravidade na moderação — R8, R12–R14 · CA5, CA8, CA9 · AB#657
  - Pronto quando: os testes do `community` cobrem CA5, CA8 e CA9.
- [ ] **T6** · Criar rotas de sanções — R1 · CA10 · AB#658
  - Pronto quando: as rotas aparecem no `/docs` e respondem `403` para quem não é ADMIN.

## Frontend — `apps/cromocard-frontend`, branch `feature/603-aplicar-sancao-a-usuario`

- [ ] **T7** [P] · Criar api e queries das sanções — R4–R14 · AB#659
  - Pronto quando: o typecheck passa.
- [ ] **T8** · Criar diálogo de sanções com prazo e justificativa — R2, R3, R5, R6, R10 · CA2–CA4 · AB#660
  - Pronto quando: `SanctionDialog.spec.tsx` cobre suspender por prazo e confirmar sem justificativa.
- [ ] **T9** · Acrescentar remover e advertir, advertir grupo, gravidade e dados do autor na tela de Comunidades — R8, R12–R14 · CA5, CA8, CA9 · AB#661
  - Pronto quando: a fila filtra por gravidade com os dados do seed.

## Fechamento — workspace

- [ ] **T10** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#662
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T6 |
| R2 | T8 |
| R3 | T2, T8 |
| R4 | T1, T2, T7 |
| R5, R6 | T1, T2, T7, T8 |
| R7 | T2, T7 |
| R8, R13, R14 | T5, T7, T9 |
| R9 | T4, T7 |
| R10 | T2, T7, T8 |
| R11 | T3, T7 |
| R12 | T1, T5, T7, T9 |
