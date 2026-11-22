# Tarefas — CCD057 Favoritar Grupo

- **Plano:** [plano.md](plano.md) · **User story:** AB#1330
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende da base de favoritos da CCD055 e da página do grupo (CCD039/CCD044, tela depende da L1).

## Backend — `apps/cromocard-backend`, branch `feature/1330-favoritar-grupo`

- [ ] **T1** · Criar alvo grupo nos favoritos — R1, R3, R5–R8 · CA1–CA5 · AB#1331
  - Pronto quando: `favorites.service.spec.ts` e `tests/integration/favorites.spec.ts` cobrem favoritar, repetir, remover, `SUSPENDED` (`422`), `WARNED` disponível (depende da L2), excluído (`404`), `401` e a corrida.

## Frontend — `apps/cromocard-frontend`, branch `feature/1330-favoritar-grupo`

- [ ] **T2** [P] · Montar botão Favoritar na página do grupo — R2, R4, R5, R7 · CA1, CA2, CA4 · AB#1332
  - Pronto quando: `FavoriteButton.spec.tsx` cobre o grupo; o botão segue o estilo da tela escolhida na L1, sem quebra em 375/768/1024 px.
- [ ] **T3** · Criar aba Grupos de Meus Favoritos — R5, R8, R9 · CA2, CA6–CA8 · AB#1333
  - Pronto quando: `FavoriteGroupsList.spec.tsx` cobre lista, abrir, remover, vazia, carregando e erro; print em 1280 px igual ao frame `675-11250` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T4** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1334
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1, R3, R6 | T1 |
| R2, R4 | T2 |
| R5, R7 | T1, T2 |
| R8 | T1, T3 |
| R9 | T3 |
