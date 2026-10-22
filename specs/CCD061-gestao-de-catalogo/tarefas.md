# Tarefas — CCD061 Gestão de Catálogo

- **Plano:** [plano.md](plano.md) · **User story:** AB#336
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior. A importação CSV (T5, T10)
  pode ir num segundo PR.

## Backend — `apps/cromocard-backend`, branch `feature/336-gestao-de-catalogo`

- [ ] **T1** · Criar validators e errors do catálogo — R5–R8, R11 · AB#550
  - Pronto quando: os schemas de álbum, carta e categoria recusam dados inválidos.
- [ ] **T2** · Criar repositories de álbuns, cartas e categorias — R3, R7, R10, R11 · AB#551
  - Pronto quando: os repositories filtram excluídos, restauram carta pelo número e checam vínculos.
- [ ] **T3** · Criar catalogService com total_cards calculado e auditoria — R4–R11, R14 · CA2–CA4 · AB#552
  - Pronto quando: `catalog.service.spec.ts` cobre CA2–CA4 e o service é exportado pelo module.
- [ ] **T4** · Criar rotas de admin do catálogo — R1 · CA7 · AB#553
  - Pronto quando: as rotas aparecem no `/docs` e respondem `403` para quem não é ADMIN.
- [ ] **T5** · Criar importação CSV de cartas com modelo para baixar — R13 · CA5, CA6 · AB#554
  - Pronto quando: `catalog-import.service.spec.ts` cobre arquivo válido e inválido.
- [ ] **T6** · Criar testes de integração do catálogo — CA2–CA7 · AB#555
  - Pronto quando: `npm run test:integration` passa.

## Frontend — `apps/cromocard-frontend`, branch `feature/336-gestao-de-catalogo`

- [ ] **T7** [P] · Criar api, queries, schemas e types do catálogo — R4–R8 · AB#556
  - Pronto quando: o typecheck passa.
- [ ] **T8** · Criar página do catálogo com abas, busca e filtros — R2, R3 · CA1 · AB#557
  - Pronto quando: as três abas listam e filtram, como no Figma 208-2895.
- [ ] **T9** · Criar formulários de carta, álbum e categoria e a exclusão — R4–R12 · CA2–CA4 · AB#558
  - Pronto quando: os specs dos modais cobrem salvar, erro de número repetido e bloqueio de exclusão.
- [ ] **T10** · Criar modal de importação CSV — R13 · CA5, CA6 · AB#559
  - Pronto quando: a tela mostra o resumo ou a lista de linhas com erro.

## Fechamento — workspace

- [ ] **T11** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#560
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T4 |
| R2, R3 | T2, T8 |
| R4–R9 | T1, T3, T7, T9 |
| R10, R11 | T2, T3, T9 |
| R12 | T9 |
| R13 | T5, T10 |
| R14 | T3 |
| R15 | T1–T4, T7, T9 |
