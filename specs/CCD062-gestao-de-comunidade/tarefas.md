# Tarefas — CCD062 Gestão de Comunidade

- **Plano:** [plano.md](plano.md) · **User story:** AB#337
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/337-gestao-de-comunidade`

- [ ] **T1** · Criar validator, errors e repository de administração de grupos e denúncias — R3–R9 · AB#567
  - Pronto quando: o repository lista grupos com membros, muda status, exclui e resolve denúncia em transação.
- [ ] **T2** · Criar service de suspender, reativar, excluir e moderar com auditoria — R5–R9, R12 · CA2–CA7 · AB#568
  - Pronto quando: `community-admin.service.spec.ts` cobre CA2–CA7.
- [ ] **T3** · Criar rotas de admin de grupos e da fila de denúncias — R1 · CA8 · AB#569
  - Pronto quando: as rotas aparecem no `/docs` e respondem `403` para quem não é ADMIN.

## Frontend — `apps/cromocard-frontend`, branch `feature/337-gestao-de-comunidade`

- [ ] **T4** [P] · Criar api, queries e types da administração de comunidade — R3–R9 · AB#570
  - Pronto quando: o typecheck passa.
- [ ] **T5** · Criar tela de comunidades com indicadores, grupos e fila de moderação — R2–R4, R7 · CA1, CA5 · AB#571
  - Pronto quando: a tela segue o Figma 220-3524 e trata carregando, vazio e erro.
- [ ] **T6** · Criar diálogos de ação sobre grupos e denúncias com motivo — R5, R6, R8–R11 · CA2–CA4, CA6, CA7 · AB#572
  - Pronto quando: os specs dos diálogos cobrem confirmar e cancelar.

## Fechamento — workspace

- [ ] **T7** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#573
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3 |
| R2 | T5 |
| R3, R4, R7 | T1, T4, T5 |
| R5, R6, R8, R9 | T1, T2, T6 |
| R10, R11 | T6 |
| R12 | T2 |
| R13 | T1, T2, T6 |
| R14 | T1, T4, T5 |
