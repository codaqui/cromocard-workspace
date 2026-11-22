# Tarefas — CCD021 Pesquisar Carta

- **Plano:** [plano.md](plano.md) · **User story:** AB#127
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende de `cards.status` (CCD106) e do detalhe do álbum (CCD013).

## Backend — `apps/cromocard-backend`, branch `feature/127-pesquisar-carta`

- [ ] **T1** · Criar validator e repository da busca de cartas — R3, R4 · AB#1072
  - Pronto quando: `searchActive` procura no nome e no número, filtra `ACTIVE` e não excluídas e põe o álbum aberto primeiro.
- [ ] **T2** · Criar service da busca de cartas — R3–R5 · CA1, CA2 · AB#1073
  - Pronto quando: `cards.service.spec.ts` cobre nome, número, lista vazia e o mapeamento da linha, com 90% de cobertura.
- [ ] **T3** · Criar endpoint GET /cards/search — R1 · CA1–CA3, CA7 · AB#1074
  - Pronto quando: a rota aparece no `/docs` e `tests/integration/cards-search.spec.ts` cobre `200`, rascunho e excluída de fora, `400`, `401` e `403` (ADMIN).

## Frontend — `apps/cromocard-frontend`, branch `feature/127-pesquisar-carta`

- [ ] **T4** [P] · Criar tipos, api, queries e textos da busca de cartas — R2, R3, R7 · AB#1075
  - Pronto quando: o typecheck passa e a query só dispara com 2 caracteres ou mais.
- [ ] **T5** · Criar modal Adicionar carta com a busca e os resultados — R2, R5–R9 · CA1, CA4–CA6, CA8 · AB#1076
  - Pronto quando: `AddCardModal.spec.tsx` e `CardSearchResult.spec.tsx` cobrem resultados, sem resultado, carregando e fechar; print em 1280 px igual ao frame `1160-28449` e sem quebra em 375/768/1024 px.
- [ ] **T6** · Abrir o modal pelo + Adicionar carta do detalhe do álbum — R2 · AB#1077
  - Pronto quando: o botão abre o modal com o `albumId` do álbum aberto, coberto em `AlbumDetailPage.spec.tsx`.

## Fechamento — workspace

- [ ] **T7** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1078
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T3 |
| R2 | T4, T5, T6 |
| R3 | T1, T2, T4 |
| R4 | T1 |
| R5 | T2, T5 |
| R6, R8, R9 | T5 |
| R7 | T4, T5 |
