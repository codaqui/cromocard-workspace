# Tarefas — CCD008 Listar Álbum

- **Plano:** [plano.md](plano.md) · **User story:** AB#114
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure criadas em 22/11/2026 (Sprint 08), atribuídas a quem o plano final indica.

## Backend — `apps/cromocard-backend`, branch `feature/114-listar-album`

- [ ] **T1** · Criar repository dos álbuns da coleção com contadores e ordem — R1, R3, R4 · AB#983
  - Pronto quando: a consulta filtra `deleted_at` de `user_albums` e `albums` e ordena por `recent`, `progress` e `name`.
- [ ] **T2** · Criar service da lista de álbuns com valor estimado — R3–R5 · CA1–CA3 · AB#984
  - Pronto quando: `collection-albums.service.spec.ts` cobre CA1, CA2 e CA3.
- [ ] **T3** · Acrescentar as cartas possuídas na semana ao resumo da coleção — R3 · AB#985
  - Pronto quando: `collection.service.spec.ts` cobre `ownedLast7Days` com marcações de 3 e de 10 dias atrás (depende da L5).
- [ ] **T4** · Criar endpoint GET /collections/me/albums — R1 · CA1–CA3, CA6 · AB#986
  - Pronto quando: a rota aparece no `/docs` e `tests/integration/collection-albums.spec.ts` cobre CA1–CA3 e CA6.

## Frontend — `apps/cromocard-frontend`, branch `feature/114-listar-album`

- [ ] **T5** [P] · Criar types, api e queries da lista de álbuns — R3–R5 · AB#987
  - Pronto quando: o typecheck passa e `collection.api.spec.ts` cobre `listMyAlbums`.
- [ ] **T6** · Criar indicadores e cartão do álbum de Meus álbuns — R4–R6, R9 · CA1, CA3, CA4, CA8 · AB#988
  - Pronto quando: `CollectionAlbumCard.spec.tsx` cobre os campos e "Abrir álbum", e print em 1280 px igual ao frame
    `1160-23080` e sem quebra em 375/768/1024 px.
- [ ] **T7** · Criar página Meus álbuns com vazio, carregando e erro — R2, R3, R7–R9 · CA1, CA4, CA5, CA7–CA9 · AB#989
  - Pronto quando: `/albuns` abre pelo menu, `MyAlbumsPage.spec.tsx` cobre CA1, CA4, CA5 e CA7, e print em 1280 px igual
    aos frames `1160-23080` e `1160-29088` e sem quebra em 375/768/1024 px.

## Docs — workspace

- [ ] **T8** · Tirar do caso de uso 08 o formulário copiado do Solicitar Álbum — R2 · AB#990
  - Pronto quando: `docs/Casos-De-Uso/08-listar-album.md` não tem mais o FP 2 do formulário (depende da L2, com a
    confirmação do PO).

## Fechamento — workspace

- [ ] **T9** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#991
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T1, T4 |
| R2 | T7, T8 |
| R3 | T1, T2, T3, T5, T7 |
| R4 | T1, T2, T5, T6 |
| R5 | T2, T5, T6 |
| R6 | T6 |
| R7, R8 | T7 |
| R9 | T6, T7 |
