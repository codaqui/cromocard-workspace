# Tarefas — CCD019 Visualizar Progresso

- **Plano:** [plano.md](plano.md) · **User story:** AB#125
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende do domínio `collection` e das tabelas da CCD007; as páginas são da CCD007, CCD008 e CCD013.

## Backend — `apps/cromocard-backend`, branch `feature/125-visualizar-progresso`

- [ ] **T1** · Criar função de cálculo do progresso do álbum — R2, R3, R6, R7 · CA1, CA4, CA5 · AB#1050
  - Pronto quando: `collection-progress.spec.ts` cobre 44/54, 0/54, total 0 e o arredondamento da L3, com 100% de cobertura.
- [ ] **T2** · Criar validator, erro e repository do progresso — R1, R2 · AB#1051
  - Pronto quando: `countOwnedByAlbum` conta `OWNED` e `DUPLICATE` uma vez por carta, ignora excluídas, e `AlbumNotInCollectionError` responde `404 ALBUM_NOT_IN_COLLECTION`.
- [ ] **T3** · Criar service de leitura e recálculo do progresso — R1, R2, R8 · CA6 · AB#1052
  - Pronto quando: `collection-progress.service.spec.ts` cobre `getProgress`, o `404` e `recalculate` gravando `progress_percentage`, e o `collection.module.ts` exporta a service.
- [ ] **T4** · Criar endpoint GET /collections/me/albums/:albumId/progress — R1 · CA7 · AB#1053
  - Pronto quando: a rota aparece no `/docs` e `tests/integration/collection-progress.spec.ts` responde `200`, `401`, `403` (ADMIN) e `404`.
- [ ] **T5** · Acrescentar o progresso à lista de álbuns e ao álbum em destaque — R4, R5 · CA2, CA3 · AB#1054
  - Pronto quando: as respostas da CCD008 e da CCD007 trazem `progress` em cada álbum, com uma consulta só por página (teste de integração).

## Frontend — `apps/cromocard-frontend`, branch `feature/125-visualizar-progresso`

- [ ] **T6** [P] · Criar tipos, api, queries e textos do progresso — R1–R7 · AB#1055
  - Pronto quando: o typecheck passa e `collection.format.spec.ts` cobre os textos com plural e "Progresso indisponível".
- [ ] **T7** · Criar componente AlbumProgress com as três variantes — R3–R7, R9 · CA1, CA3–CA5 · AB#1056
  - Pronto quando: `AlbumProgress.spec.tsx` cobre as variantes e o indisponível; print em 1280 px igual aos frames `1160-23696`, `1160-23080` e `1122-17812` e sem quebra em 375/768/1024 px.
- [ ] **T8** · Mostrar o progresso no cabeçalho do detalhe do álbum — R3, R8, R9 · CA1, CA6, CA8 · AB#1057
  - Pronto quando: `AlbumDetailPage.spec.tsx` mostra 44 → 45 de 54 depois de marcar, sem recarregar; print em 1280 px igual ao frame `1160-23696` e sem quebra em 375/768/1024 px.
- [ ] **T9** · Mostrar o progresso nos cartões de Meus álbuns — R4, R9 · CA2, CA4, CA9 · AB#1058
  - Pronto quando: cada cartão mostra o progresso do próprio álbum; print em 1280 px igual ao frame `1160-23080` e sem quebra em 375/768/1024 px.
- [ ] **T10** · Mostrar o progresso no álbum em destaque do Início — R5, R9 · CA3, CA10 · AB#1059
  - Pronto quando: o bloco mostra "<x> de <total> cartas • <n>% completo"; print em 1280 px igual ao frame `1122-17812` e sem quebra em 375/768/1024 px.
- [ ] **T11** · Invalidar o progresso nas mutações de marcação — R8 · CA6 · AB#1060
  - Pronto quando: toda mutação de `collection.queries.ts` que muda marcação invalida `albumProgress(albumId)` e a lista de álbuns, coberto em teste.

## Fechamento — workspace

- [ ] **T12** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1061
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T2, T3, T4, T6 |
| R2 | T1, T2, T3, T6 |
| R3 | T1, T6, T7, T8 |
| R4 | T5, T6, T7, T9 |
| R5 | T5, T6, T7, T10 |
| R6, R7 | T1, T6, T7 |
| R8 | T3, T8, T11 |
| R9 | T7, T8, T9, T10 |
