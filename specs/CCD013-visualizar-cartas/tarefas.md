# Tarefas — CCD013 Visualizar Cartas

- **Plano:** [plano.md](plano.md) · **User story:** AB#119
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure: a criar (só com o pedido do Daniel). As branches saem de `develop` depois do merge da CCD008 e das
  migrations de `cards` da CCD106 e da CCD105.

## Backend — `apps/cromocard-backend`, branch `feature/119-visualizar-cartas`

- [ ] **T1** · Criar consulta das cartas do álbum com o status da coleção — R3–R5 · CA1, CA2, CA4 · AB# a criar
  - Pronto quando: a consulta traz só cartas `ACTIVE` e não excluídas, a carta sem marcação vem `MISSING` com 0 e a ordem
    é a natural do número.
- [ ] **T2** · Criar service do detalhe do álbum da coleção — R1–R6 · CA1, CA2, CA5 · AB# a criar
  - Pronto quando: `collection-album-detail.service.spec.ts` cobre CA1, CA2, CA5 e o `404` fora da coleção.
- [ ] **T3** · Criar endpoints GET /collections/me/albums/:albumId e /:albumId/cards — R1 · CA1, CA2, CA4–CA6 · AB# a criar
  - Pronto quando: as rotas aparecem no `/docs`, o seed tem o álbum de 54 cartas e
    `tests/integration/collection-album-detail.spec.ts` cobre CA1, CA2, CA4, CA5 e CA6.

## Frontend — `apps/cromocard-frontend`, branch `feature/119-visualizar-cartas`

- [ ] **T4** [P] · Criar types, api, queries e labels do detalhe do álbum — R3–R5 · AB# a criar
  - Pronto quando: o typecheck passa e `collection-album.api.spec.ts` cobre as duas chamadas.
- [ ] **T5** · Criar cabeçalho, barra de abas, cartão em grade e linha em lista das cartas — R2, R4, R5, R8 · CA1, CA3, CA8 · AB# a criar
  - Pronto quando: `AlbumCardTile.spec.tsx` cobre os campos e os selos, e print em 1280 px igual ao frame `1160-23696` e
    sem quebra em 375/768/1024 px.
- [ ] **T6** · Criar página do detalhe do álbum com vazio, carregando e erro — R2, R4, R6–R8 · CA1, CA3, CA5, CA7, CA8 · AB# a criar
  - Pronto quando: `/albuns/:albumId` abre por "Abrir álbum", `AlbumDetailPage.spec.tsx` cobre CA1, CA3, CA5 e CA7, e
    print em 1280 px igual ao frame `1160-23696` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T7** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T2, T3 |
| R2 | T2, T5, T6 |
| R3 | T1, T2, T4 |
| R4 | T1, T4, T5, T6 |
| R5 | T1, T2, T4, T5 |
| R6 | T2, T6 |
| R7 | T6 |
| R8 | T5, T6 |
