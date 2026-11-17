# Tarefas — CCD103 Votar em Solicitação de Catálogo

- **Plano:** [plano.md](plano.md) · **User story:** AB#607
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- As branches dos apps saem de `feature/339-aprovar-solicitacoes` (CCD064) e entram depois dela.

## Backend — `apps/cromocard-backend`, branch `feature/607-votar-em-solicitacao-de-catalogo`

- [ ] **T1** · Criar migration de catalog_request_votes e o seed da meta — R3, R9 · AB#685
  - Pronto quando: a tabela existe com a PK composta, a meta está no seed e as sugestões do seed têm os campos extras e votos.
- [ ] **T2** · Criar service de voto com troca e votação encerrada — R1, R3, R4, R6–R8 · CA1–CA3, CA8 · AB#686
  - Pronto quando: `catalog-request-votes.service.spec.ts` cobre CA1–CA3 e CA8.
- [ ] **T3** · Acrescentar quórum, resumo do checklist e subcategorias na fila do admin — R5, R9–R13 · CA4, CA5, CA11 · AB#687
  - Pronto quando: `catalog-requests.service.spec.ts` cobre CA4, CA5 e CA11.
- [ ] **T4** · Criar exportação do checklist do álbum sugerido — R11 · CA6 · AB#688
  - Pronto quando: o CSV traz uma linha por carta do checklist.
- [ ] **T5** · Criar rotas de votação do cliente e do checklist — R1 · CA7, CA8 · AB#689
  - Pronto quando: as rotas aparecem no `/docs`, votar sem login responde `401` e como admin `403`.

## Frontend — `apps/cromocard-frontend`, branch `feature/607-votar-em-solicitacao-de-catalogo`

- [ ] **T6** [P] · Criar api e queries da votação — R2–R4, R7, R8 · AB#690
  - Pronto quando: o typecheck passa.
- [ ] **T7** · Criar página de sugestões em votação no Painel Cliente — R2–R4, R7, R8 · CA1–CA3, CA9, CA10 · AB#691
  - Pronto quando: `CommunitySuggestionsPage.spec.tsx` cobre votar, trocar o voto, vazio e votação encerrada, igual aos frames `1038-1750`, `1038-2242` e `1038-2740`.
- [ ] **T8** · Acrescentar quórum, campos da sugestão, checklist, capa, logo e subcategorias nos cartões da fila — R5, R10–R13 · CA4–CA6, CA11 · AB#692
  - Pronto quando: os cartões mostram o quórum e os campos com os dados do seed, como no frame `228-1804`.

## Fechamento — workspace

- [ ] **T9** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#693
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T2, T5, T7 |
| R2 | T6, T7 |
| R3 | T1, T2, T6, T7 |
| R4, R7, R8 | T2, T6, T7 |
| R5, R12 | T3, T8 |
| R6 | T2 |
| R9 | T1, T3 |
| R10, R13 | T3, T8 |
| R11 | T3, T4, T8 |
