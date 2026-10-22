# Tarefas — CCD104 Ordenar Categorias Padrão

- **Plano:** [plano.md](plano.md) · **User story:** AB#608
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/608-ordenar-categorias-padrao`

- [ ] **T1** · Criar migration de exibição em categories com o slug das existentes — R9 · AB#694
  - Pronto quando: as colunas existem e as categorias do seed têm slug.
- [ ] **T2** · Criar leitura e gravação da ordem das categorias padrão com auditoria — R4, R5 · CA2–CA4 · AB#695
  - Pronto quando: `settings.service.spec.ts` cobre CA2–CA4.
- [ ] **T3** · Ordenar o catálogo por fixada e ordem e gerar slug e selo no cadastro de categoria — R6, R9, R10 · CA5, CA6 · AB#696
  - Pronto quando: `catalog.service.spec.ts` cobre CA6 e a lista pública vem ordenada.
- [ ] **T4** · Criar rotas da ordem das categorias padrão — R1 · CA7 · AB#697
  - Pronto quando: as rotas aparecem no `/docs` e respondem `403` para quem não é ADMIN.

## Frontend — `apps/cromocard-frontend`, branch `feature/608-ordenar-categorias-padrao`

- [ ] **T5** [P] · Criar api e queries da ordem das categorias — R2–R5 · AB#698
  - Pronto quando: o typecheck passa.
- [ ] **T6** · Criar módulo de ordenação das categorias padrão com setas, arrastar, fixar e salvar — R2–R4, R7, R8 · CA1, CA2, CA4 · AB#699
  - Pronto quando: `DefaultCategoriesOrder.spec.tsx` cobre mover, fixar e sair sem salvar.
- [ ] **T7** · Acrescentar o selo no formulário de categoria — R10 · AB#700
  - Pronto quando: o selo salvo aparece no módulo de ordenação.

## Fechamento — workspace

- [ ] **T8** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#701
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T4 |
| R2, R3 | T5, T6 |
| R4 | T2, T5, T6 |
| R5 | T2, T5 |
| R6 | T3 |
| R7, R8 | T6 |
| R9 | T1, T3 |
| R10 | T3, T7 |
