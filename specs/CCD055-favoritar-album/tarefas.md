# Tarefas — CCD055 Favoritar Álbum

- **Plano:** [plano.md](plano.md) · **User story:** não encontrada no board (AB# a criar)
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Cria a base de favoritos que a CCD056 e a CCD057 reaproveitam.

## Docs — workspace

- [ ] **T1** · Registrar no DBML e em ADR o índice único parcial de favorites — R6 · AB# a criar
  - Pronto quando: a L2 está decidida e os três `.dbml` têm os índices parciais (PR de docs mergeado, ADR `Proposto`).

## Backend — `apps/cromocard-backend`, branch `feature/<id>-favoritar-album`

- [ ] **T2** · Criar migration create_favorites_table — R3, R6 · AB# a criar
  - Pronto quando: a tabela, o enum, as FKs, o `CHECK` de um alvo e os índices parciais existem, e o seed tem favoritos de exemplo.
- [ ] **T3** · Criar service de favoritos com o alvo álbum — R3–R8 · CA1–CA4, CA6 · AB# a criar
  - Pronto quando: `favorites.service.spec.ts` cobre favoritar, repetir, remover, `INACTIVE`, excluído e a lista.
- [ ] **T4** · Criar endpoints GET, PUT e DELETE /favorites/:type/:targetId e GET /favorites — R1, R3, R5–R8 · CA1–CA5 · AB# a criar
  - Pronto quando: as rotas aparecem no `/docs` e `tests/integration/favorites.spec.ts` cobre `200`, `204`, `401`, `404`, `422` e a corrida do CA3.

## Frontend — `apps/cromocard-frontend`, branch `feature/<id>-favoritar-album`

- [ ] **T5** [P] · Criar tipos, api e queries de favoritos — R3–R8 · AB# a criar
  - Pronto quando: o typecheck passa e `favorites.api.spec.ts` cobre as quatro chamadas.
- [ ] **T6** · Criar ou reaproveitar o modal Entre para continuar da CCD030 — R1 · CA5 · AB# a criar
  - Pronto quando: `LoginToContinueModal.spec.tsx` cobre as três opções e a volta à página de origem; igual ao frame `1112-5461` em 1280 px e sem quebra em 375/768/1024 px.
- [ ] **T7** · Criar botão Favoritar na página do álbum — R1, R2, R4, R5, R7, R9 · CA1, CA2, CA4, CA5, CA8 · AB# a criar
  - Pronto quando: `FavoriteButton.spec.tsx` cobre favoritar, remover, indisponível e visitante; print em 1280 px igual ao frame `1160-1845` e sem quebra em 375/768/1024 px.
- [ ] **T8** · Criar aba Álbuns de Meus Favoritos — R5, R8, R9 · CA2, CA6, CA7, CA9 · AB# a criar
  - Pronto quando: `FavoriteAlbumsList.spec.tsx` cobre lista, abrir, remover, vazia, carregando e erro; print em 1280 px igual ao frame `675-10770` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T9** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T4, T6, T7 |
| R2 | T7 |
| R3 | T2, T3, T4, T5 |
| R4 | T3, T5, T7 |
| R5 | T3, T4, T5, T7, T8 |
| R6 | T1, T2, T3, T4 |
| R7 | T3, T4, T7 |
| R8 | T3, T4, T5, T8 |
| R9 | T7, T8 |
