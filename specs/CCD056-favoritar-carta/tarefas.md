# Tarefas — CCD056 Favoritar Carta

- **Plano:** [plano.md](plano.md) · **User story:** não encontrada no board (AB# a criar)
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende da base de favoritos da CCD055, de `cards.status` (CCD106) e do perfil da carta (CCD030).

## Backend — `apps/cromocard-backend`, branch `feature/<id>-favoritar-carta`

- [ ] **T1** · Criar alvo carta nos favoritos — R1, R4, R6–R9 · CA1–CA5 · AB# a criar
  - Pronto quando: `favorites.service.spec.ts` e `tests/integration/favorites.spec.ts` cobrem favoritar, repetir, remover, `DRAFT`, excluída (`404`), `401` e a corrida; o seed tem cartas favoritas.

## Frontend — `apps/cromocard-frontend`, branch `feature/<id>-favoritar-carta`

- [ ] **T2** [P] · Montar botão Favoritar no perfil da carta — R1–R3, R5, R6, R8, R10 · CA1, CA2, CA4, CA5, CA8, CA9 · AB# a criar
  - Pronto quando: `FavoriteButton.spec.tsx` cobre a carta e a volta depois do login; print em 1280 px igual aos frames `1112-4615` e `1112-5461` e sem quebra em 375/768/1024 px.
- [ ] **T3** · Criar aba Cartas de Meus Favoritos — R6, R9, R10 · CA2, CA6, CA7, CA10 · AB# a criar
  - Pronto quando: `FavoriteCardsList.spec.tsx` cobre lista, abrir, remover, vazia, carregando e erro; print em 1280 px igual ao frame `675-10296` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T4** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1, R6, R8 | T1, T2 |
| R2, R3, R5 | T2 |
| R4, R7 | T1 |
| R9 | T1, T3 |
| R10 | T2, T3 |
