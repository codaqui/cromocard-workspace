# Tarefas — CCD098 Gerenciar Dados Complementares do Usuário

- **Plano:** [plano.md](plano.md) · **User story:** AB#602
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/602-dados-complementares-do-usuario`

- [ ] **T1** · Criar migration dos dados complementares de users — R2, R4, R8 · AB#642
  - Pronto quando: as colunas existem e o `schema.prisma` bate com o DBML.
- [ ] **T2** · Estender validators e repository de usuários com @, CPF, telefone e busca — R3, R4, R6, R7, R14 · CA2, CA4, CA5 · AB#643
  - Pronto quando: o repository busca por @, CPF, CNPJ e ID e o validator recusa CPF inválido.
- [ ] **T3** · Estender service de usuários com link de ativação opcional, reenvio e auditoria — R5, R9, R15 · CA3, CA8 · AB#644
  - Pronto quando: `admin-users.service.spec.ts` cobre CA3 e CA8.
- [ ] **T4** · Gravar último acesso e aceitar login por nome de usuário no auth — R8, R10 · CA6 · AB#645
  - Pronto quando: `auth.service.spec.ts` cobre CA6.
- [ ] **T5** · Criar rotas de detalhe e reenvio e atualizar o Swagger de usuários — R1, R13, R15 · CA9 · AB#646
  - Pronto quando: as rotas aparecem no `/docs` e respondem `403` para quem não é ADMIN.

## Frontend — `apps/cromocard-frontend`, branch `feature/602-dados-complementares-do-usuario`

- [ ] **T6** [P] · Criar api, queries e schemas dos dados complementares — R3–R7, R15 · AB#647
  - Pronto quando: o typecheck passa.
- [ ] **T7** · Acrescentar colunas, busca e total na lista de usuários — R2, R3, R12 · CA1, CA2 · AB#648
  - Pronto quando: `UsersPage.spec.tsx` cobre a busca por CPF.
- [ ] **T8** · Acrescentar @, CPF, telefone e o link de ativação no modal de usuário — R4–R7 · CA3–CA5 · AB#649
  - Pronto quando: o modal mostra os erros por campo vindos da API.
- [ ] **T9** · Criar detalhe do usuário e a confirmação reforçada da exclusão — R11, R13 · CA7 · AB#650
  - Pronto quando: `DeleteUserDialog.spec.tsx` cobre CA7.
- [ ] **T10** · Aceitar e-mail ou nome de usuário na tela de login — R10 · CA6 · AB#651
  - Pronto quando: o login funciona com o @ do seed.

## Fechamento — workspace

- [ ] **T11** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#652
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T5 |
| R2 | T1, T7 |
| R3 | T2, T6, T7 |
| R4 | T1, T2, T6, T8 |
| R5 | T3, T6, T8 |
| R6, R7 | T2, T6, T8 |
| R8 | T1, T4 |
| R9 | T3 |
| R10 | T4, T10 |
| R11 | T9 |
| R12 | T7 |
| R13 | T5, T9 |
| R14 | T2 |
| R15 | T3, T5, T6 |
