# Tarefas — CCD009 Buscar Álbum

- **Plano:** [plano.md](plano.md) · **User story:** AB#115
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure criadas em 22/11/2026 (Sprint 08), atribuídas a quem o plano final indica.

## Backend — `apps/cromocard-backend`, branch `feature/115-buscar-album`

- [ ] **T1** · Cobrir o isolamento da lista de álbuns entre clientes — R1 · CA6 · AB#992
  - Pronto quando: `tests/integration/collection-albums.spec.ts` mostra que o álbum da coleção de outro cliente não volta
    e que sem token a resposta é `401`.

## Frontend — `apps/cromocard-frontend`, branch `feature/115-buscar-album`

- [ ] **T2** [P] · Criar filtro de álbuns por nome e ano — R3, R4 · CA1–CA3 · AB#993
  - Pronto quando: `collection.search.spec.ts` cobre trecho sem acento e maiúscula, ano exato e texto vazio.
- [ ] **T3** · Criar campo de busca e resultado vazio em Meus álbuns — R2, R4–R7 · CA1, CA3–CA5, CA7, CA8 · AB#994
  - Pronto quando: `MyAlbumsPage.spec.tsx` cobre CA1, CA3, CA4 e CA5, e print em 1280 px igual ao frame `1160-23080`
    (com o campo desenhado, L2) e ao `1160-29088`, e sem quebra em 375/768/1024 px.

## Docs — workspace

- [ ] **T4** · Acrescentar ao caso de uso 09 o resultado vazio da busca — R4 · AB#995
  - Pronto quando: `docs/Casos-De-Uso/09-buscar-album.md` tem o FA 2 do resultado vazio (depende da L3 e da L5, com a
    confirmação do PO).

## Fechamento — workspace

- [ ] **T5** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#996
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T1 |
| R2 | T3 |
| R3 | T2 |
| R4 | T2, T3, T4 |
| R5, R6, R7 | T3 |
