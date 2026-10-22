# Tarefas — CCD103 Votar em Solicitação de Catálogo

- **Plano:** [plano.md](plano.md) · **User story:** AB#607
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.

## Backend — `apps/cromocard-backend`, branch `feature/607-votar-em-solicitacao-de-catalogo`

- [ ] **T1** · Criar migration de catalog_request_votes e o seed da meta — R3, R9 · AB#685
  - Pronto quando: a tabela existe com a PK composta e a meta está no seed.
- [ ] **T2** · Criar service de voto com troca e votação encerrada — R3, R4, R6–R8 · CA1–CA3 · AB#686
  - Pronto quando: `catalog-request-votes.service.spec.ts` cobre CA1–CA3.
- [ ] **T3** · Acrescentar quórum no detalhe e subcategorias na aprovação de categoria — R5, R9, R12 · CA4, CA5 · AB#687
  - Pronto quando: `catalog-requests.service.spec.ts` cobre CA4 e CA5.
- [ ] **T4** · Criar exportação do checklist do álbum sugerido — R11 · CA6 · AB#688
  - Pronto quando: o CSV traz uma linha por carta do checklist.
- [ ] **T5** · Criar rotas de votação do cliente e do checklist — R1 · CA7 · AB#689
  - Pronto quando: as rotas aparecem no `/docs` e votar sem login responde `401`.

## Frontend — `apps/cromocard-frontend`, branch `feature/607-votar-em-solicitacao-de-catalogo`

- [ ] **T6** [P] · Criar api e queries da votação — R2–R4, R7, R8 · AB#690
  - Pronto quando: o typecheck passa.
- [ ] **T7** · Criar página de sugestões em votação no Painel Cliente — R2–R4, R7, R8 · CA1–CA3 · AB#691
  - Pronto quando: `CommunitySuggestionsPage.spec.tsx` cobre votar e trocar o voto.
- [ ] **T8** · Acrescentar quórum, campos da sugestão, checklist e subcategorias nos cartões da fila — R5, R10–R12 · CA4–CA6 · AB#692
  - Pronto quando: os cartões mostram o quórum e os campos com os dados do seed.

## Fechamento — workspace

- [ ] **T9** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#693
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T5 |
| R2 | T6, T7 |
| R3 | T1, T2, T6, T7 |
| R4, R7, R8 | T2, T6, T7 |
| R5, R12 | T3, T8 |
| R6 | T2 |
| R9 | T1, T3 |
| R10 | T8 |
| R11 | T4, T8 |
