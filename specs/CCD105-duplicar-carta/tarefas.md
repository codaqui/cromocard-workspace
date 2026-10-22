# Tarefas — CCD105 Duplicar Carta

- **Plano:** [plano.md](plano.md) · **User story:** AB#609
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/609-duplicar-carta`

- [ ] **T1** · Criar migration de código e variantes em cards — R8 · AB#702
  - Pronto quando: as colunas existem e o `schema.prisma` bate com o DBML.
- [ ] **T2** · Acrescentar código e variantes no validator e no service de cartas — R4, R5, R8 · CA3, CA5 · AB#703
  - Pronto quando: `catalog.service.spec.ts` cobre CA3 e CA5.
- [ ] **T3** · Criar resumo do catálogo, filtro por ano e exclusão em lote com auditoria — R7, R9, R10 · CA4, CA6, CA7 · AB#704
  - Pronto quando: `catalog.service.spec.ts` cobre CA4 e CA7.
- [ ] **T4** · Criar rotas de resumo e exclusão em lote do catálogo — R1 · CA8 · AB#705
  - Pronto quando: as rotas aparecem no `/docs` e respondem `403` para quem não é ADMIN.

## Frontend — `apps/cromocard-frontend`, branch `feature/609-duplicar-carta`

- [ ] **T5** [P] · Criar api, queries e schemas de código, variantes e resumo — R7–R10 · AB#706
  - Pronto quando: o typecheck passa.
- [ ] **T6** · Criar ação Duplicar com o formulário preenchido — R2–R6 · CA1, CA2 · AB#707
  - Pronto quando: `CardForm.spec.tsx` cobre CA1 e CA2.
- [ ] **T7** · Acrescentar indicadores, código, variantes, filtro por ano, chips e seleção em lote na lista — R7–R10 · CA4, CA6, CA7 · AB#708
  - Pronto quando: `CatalogPage.spec.tsx` cobre CA6 e a exclusão em lote.

## Fechamento — workspace

- [ ] **T8** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#709
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T4 |
| R2, R3, R6 | T6 |
| R4, R5 | T2, T6 |
| R7, R9, R10 | T3, T5, T7 |
| R8 | T1, T2, T5, T7 |
