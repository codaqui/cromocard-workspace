# Tarefas — CCD011 Remover Álbum

- **Plano:** [plano.md](plano.md) · **User story:** AB#117
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure criadas em 22/11/2026 (Sprint 08), atribuídas a quem o plano final indica.

## Backend — `apps/cromocard-backend`, branch `feature/117-remover-album`

- [ ] **T1** · Criar remoção do álbum da coleção com as marcações — R1, R4 · CA2, CA3, CA5 · AB#1008
  - Pronto quando: `collection-albums.service.spec.ts` cobre CA2, CA3 e o `404` do CA5, com as duas exclusões lógicas na
    mesma transação.
- [ ] **T2** · Criar endpoint DELETE /collections/me/albums/:albumId — R1 · CA2, CA3, CA5 · AB#1009
  - Pronto quando: a rota aparece no `/docs` e `tests/integration/collection-remove-album.spec.ts` cobre CA2, CA3 e CA5.

## Frontend — `apps/cromocard-frontend`, branch `feature/117-remover-album`

- [ ] **T3** [P] · Criar api e mutation da remoção do álbum — R4, R5 · AB#1010
  - Pronto quando: `collection.api.spec.ts` cobre `removeAlbum` e a mutation invalida lista, resumo e detalhe.
- [ ] **T4** · Criar menu de opções e modal de remoção do álbum — R2, R3, R6, R7, R8 · CA1, CA4, CA6–CA8 · AB#1011
  - Pronto quando: `RemoveAlbumDialog.spec.tsx` cobre CA1, CA4 e CA6, e print em 1280 px igual aos frames `1160-26090` e
    `1160-27915` e sem quebra em 375/768/1024 px.
- [ ] **T5** · Ligar a remoção em Meus álbuns e no detalhe do álbum — R2, R5 · CA2 · AB#1012
  - Pronto quando: `MyAlbumsPage.spec.tsx` cobre CA2 (lista sem o álbum e o aviso) e, do detalhe, o cliente volta para
    `/albuns`; print em 1280 px igual ao frame `1160-26090` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T6** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1013
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T1, T2 |
| R2 | T4, T5 |
| R3 | T4 |
| R4 | T1, T3 |
| R5 | T3, T5 |
| R6, R7, R8 | T4 |
