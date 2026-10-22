# Tarefas — CCD059 Gestão de Usuários

- **Plano:** [plano.md](plano.md) · **User story:** AB#334
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/334-gestao-de-usuarios`

- [ ] **T1** · Criar validators e errors da gestão de usuários — R5–R11 · AB#540
  - Pronto quando: os schemas recusam dados inválidos e a busca usa `q`.
- [ ] **T2** · Estender o repository de users com filtros, detalhe, criação, status e soft delete — R3–R9 · AB#541
  - Pronto quando: o repository filtra excluídos e por papel e status.
- [ ] **T3** · Criar service de gestão com convite, limites, revogação de sessões e auditoria — R5–R10, R14 · CA2–CA7 · AB#542
  - Pronto quando: `admin-users.service.spec.ts` cobre CA2–CA7.
- [ ] **T4** · Criar rotas de detalhe, criar, editar, suspender, reativar e excluir — R1 · CA9 · AB#543
  - Pronto quando: as rotas aparecem no `/docs` e respondem `403` para quem não é ADMIN.
- [ ] **T5** · Criar teste de integração da gestão de usuários — CA1–CA9 · AB#544
  - Pronto quando: `npm run test:integration` passa.

## Frontend — `apps/cromocard-frontend`, branch `feature/334-gestao-de-usuarios`

- [ ] **T6** [P] · Criar api, queries, schemas e labels da gestão de usuários — R5–R9 · AB#545
  - Pronto quando: o typecheck passa e as query keys invalidam a lista após cada ação.
- [ ] **T7** · Adicionar filtros e ações à lista de usuários — R2–R4 · CA1 · AB#546
  - Pronto quando: a lista filtra por busca, papel e status, como no Figma 208-1793.
- [ ] **T8** · Criar modal de criar e editar usuário — R5–R7, R11–R13 · CA2, CA3, CA8 · AB#547
  - Pronto quando: `UserFormModal.spec.tsx` cobre criar, editar, erro por campo e cancelar.
- [ ] **T9** · Criar diálogos de suspender, reativar e excluir com motivo — R8, R9, R14 · CA4–CA6 · AB#548
  - Pronto quando: a exclusão exige digitar o nome e o motivo, com o texto de soft delete.

## Fechamento — workspace

- [ ] **T10** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#549
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T4 |
| R2 | T7 |
| R3, R4 | T2, T7 |
| R5–R7 | T1–T3, T6, T8 |
| R8, R9 | T2, T3, T6, T9 |
| R10, R11 | T1, T3, T8 |
| R12, R13 | T8 |
| R14 | T3, T9 |
| R15 | CCD004 (T5, T7 de lá) |
| R16 | T2, T7 |
| R17–R19 | T3, T8, T9 |
