# Tarefas — CCD094 Validar Cadastro de Vendedor

- **Plano:** [plano.md](plano.md) · **User story:** AB#598
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/598-validar-cadastro-de-vendedor`

- [ ] **T1** · Criar migrations e seed do credenciamento de vendedor — R5–R7 · AB#612
  - Pronto quando: as 3 tabelas existem, uma migration por tabela, e o seed cria cadastros em cada status.
- [ ] **T2** · Criar validator, errors e repository do credenciamento — R2, R3, R5, R14, R15 · AB#613
  - Pronto quando: o repository filtra por status e só muda cadastro em análise ou pendente.
- [ ] **T3** · Criar service de validar documento, notas, aprovar e rejeitar com auditoria — R6–R11, R14 · CA3–CA7 · AB#614
  - Pronto quando: `seller-verifications.service.spec.ts` cobre CA3–CA7.
- [ ] **T4** · Criar rotas do credenciamento e o resumo do card — R1, R4 · CA8, CA10 · AB#615
  - Pronto quando: as rotas aparecem no `/docs` e respondem `403` para quem não é ADMIN.
- [ ] **T5** · Acrescentar o status da análise na lista de usuários e o relatório Auditoria de Lojistas — R12, R13 · CA9 · AB#616
  - Pronto quando: a lista de usuários traz `sellerVerificationStatus` e o relatório exporta em CSV e PDF.

## Frontend — `apps/cromocard-frontend`, branch `feature/598-validar-cadastro-de-vendedor`

- [ ] **T6** [P] · Criar api, queries e types do credenciamento — R2–R9 · AB#617
  - Pronto quando: o typecheck passa.
- [ ] **T7** · Criar lista de cadastros de vendedores e card de credenciamento no Dashboard — R2–R4, R12 · CA1, CA8 · AB#618
  - Pronto quando: `SellerRegistrationsTable.spec.tsx` cobre o filtro e o card.
- [ ] **T8** · Criar painel Validar Cadastro com documentos, notas, aprovar e rejeitar — R5–R10 · CA2–CA6 · AB#619
  - Pronto quando: `SellerVerificationPanel.spec.tsx` cobre validar documento, aprovar e rejeitar sem motivo.

## Fechamento — workspace

- [ ] **T9** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#620
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T4 |
| R2, R3 | T2, T6, T7 |
| R4 | T4, T6, T7 |
| R5 | T1, T2, T6, T8 |
| R6, R7 | T1, T3, T6, T8 |
| R8, R9 | T3, T6, T8 |
| R10 | T3, T8 |
| R11 | T3 |
| R12 | T5, T7 |
| R13 | T5 |
| R14 | T2, T3 |
| R15 | T2 |
