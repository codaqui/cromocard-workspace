# Tarefas — CCD066 Configurações Globais

- **Plano:** [plano.md](plano.md) · **User story:** AB#341
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/341-configuracoes-globais`

- [ ] **T1** · Criar schemas por chave, validator e repository das configurações — R3–R5, R7 · AB#592
  - Pronto quando: `home.banner` e `notification.templates` validam e o repository grava `updated_by_id`.
- [ ] **T2** · Criar service de configurações com auditoria e categorias padrão — R4–R7, R10, R13, R14 · CA2–CA4 · AB#593
  - Pronto quando: `settings.service.spec.ts` cobre CA2–CA4.
- [ ] **T3** · Criar rotas de admin e a leitura pública do banner — R1 · CA6 · AB#594
  - Pronto quando: as rotas aparecem no `/docs` e a pública só aceita `home.banner`.

## Frontend — `apps/cromocard-frontend`, branch `feature/341-configuracoes-globais`

- [ ] **T4** [P] · Criar api, queries e schemas das configurações — R4, R7 · AB#595
  - Pronto quando: os schemas espelham o backend e o typecheck passa.
- [ ] **T5** · Criar tela de configurações com banner, categorias padrão e templates — R2–R12 · CA1–CA5 · AB#596
  - Pronto quando: `SettingsPage.spec.tsx` cobre salvar, erro por campo e cancelar.

## Fechamento — workspace

- [ ] **T6** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#597
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3 |
| R2, R6, R8 | T5 |
| R3–R5, R7 | T1, T2, T4, T5 |
| R9, R11, R12 | T5 |
| R10, R13 | T2, T5 |
| R14 | T2 |
| R15 | T1, T3 |
