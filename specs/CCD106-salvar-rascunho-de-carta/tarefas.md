# Tarefas — CCD106 Salvar Rascunho de Carta

- **Plano:** [plano.md](plano.md) · **User story:** AB#610
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/610-salvar-rascunho-de-carta`

- [ ] **T1** · Criar migration de status e ano em cards e o seed do verso padrão — R2, R8, R9 · AB#710
  - Pronto quando: as colunas e o enum existem e a chave está no seed.
- [ ] **T2** · Criar rascunho e publicação de carta com auditoria — R2, R5, R6 · CA1, CA3, CA4 · AB#711
  - Pronto quando: `catalog.service.spec.ts` cobre CA1, CA3 e CA4.
- [ ] **T3** · Esconder rascunhos das consultas públicas do catálogo — R3 · CA1 · AB#712
  - Pronto quando: as consultas públicas só devolvem cartas `ACTIVE`.
- [ ] **T4** · Criar verso padrão, aviso de duplicata e tamanho mínimo da imagem — R9–R11 · CA5–CA7 · AB#713
  - Pronto quando: os testes cobrem CA5 e CA7 e a rota de duplicatas responde.
- [ ] **T5** · Criar rotas de publicar e de duplicatas — R1 · CA8 · AB#714
  - Pronto quando: as rotas aparecem no `/docs` e respondem `403` para quem não é ADMIN.

## Frontend — `apps/cromocard-frontend`, branch `feature/610-salvar-rascunho-de-carta`

- [ ] **T6** [P] · Criar api, queries e schemas do rascunho — R2–R6, R10 · AB#715
  - Pronto quando: o typecheck passa.
- [ ] **T7** · Acrescentar Salvar como Rascunho, publicar, ano e verso padrão no formulário de carta — R2, R5, R6, R8, R9, R11 · CA1, CA4, CA5 · AB#716
  - Pronto quando: `CardForm.spec.tsx` cobre salvar rascunho e publicar com campo vazio.
- [ ] **T8** · Acrescentar filtro de rascunhos, excluir rascunho e aviso de duplicata na lista — R4, R7, R10 · CA2, CA6 · AB#717
  - Pronto quando: `CatalogPage.spec.tsx` cobre CA2 e CA6.

## Fechamento — workspace

- [ ] **T9** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#718
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T5 |
| R2 | T1, T2, T6, T7 |
| R3 | T3, T6 |
| R4 | T6, T8 |
| R5, R6 | T2, T6, T7 |
| R7 | T8 |
| R8 | T1, T7 |
| R9 | T1, T4, T7 |
| R10 | T4, T6, T8 |
| R11 | T4, T7 |
