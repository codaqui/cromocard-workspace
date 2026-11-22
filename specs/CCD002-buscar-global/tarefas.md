# Tarefas — CCD002 Buscar Global

- **Plano:** [plano.md](plano.md) · **User story:** AB#107
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- AB# de cada Task: a criar (as Tasks no Azure só serão criadas com o pedido do Daniel).
- As branches dos apps saem depois do merge da CCD078.

## Documentação — workspace

- [ ] **T1** · Registrar o ADR da busca textual sem acentos · docs · AB# a criar
  - Pronto quando: o ADR novo está em `docs/ADR/` como `Proposto`, no índice do `README.md`, e o PO decidiu.

## Backend — `apps/cromocard-backend`, branch `feature/107-buscar-global`

- [ ] **T2** · Criar migration da extensão unaccent e o seed da busca — R3, R16 · CA1, CA10 · AB# a criar
  - Pronto quando: a migration roda no banco de teste e o seed tem anúncios, usuários, grupos e álbuns com "charizard".
- [ ] **T3** · Criar validator da busca global — R4 · CA9 · AB# a criar
  - Pronto quando: `search.validator.spec.ts` cobre vazio, só espaços, 1 e 101 caracteres e `type` inválido.
- [ ] **T4** · Criar buscas públicas de usuários, grupos e álbuns nos domínios — R9–R11, R16 · CA4, CA11 · AB# a criar
  - Pronto quando: os services de `users`, `community` e `catalog` devolvem itens e contagens com as regras do plano, cobertos nos `.spec.ts`.
- [ ] **T5** · Criar service da busca global com abas e contagens — R5–R8, R15, R16 · CA1, CA2, CA7, CA10 · AB# a criar
  - Pronto quando: `search.service.spec.ts` cobre os limites de "Tudo", a aba só e o vazio, com 90% de cobertura.
- [ ] **T6** · Criar rota GET /search, swagger e module — R1 · CA1, CA7–CA10 · AB# a criar
  - Pronto quando: a rota aparece no `/docs` e `tests/integration/search.spec.ts` cobre os CAs sem token.
- [ ] **T7** · Criar endpoints públicos do álbum e das cartas do álbum — R12, R13 · CA5 · AB# a criar
  - Pronto quando: `GET /albums/:id` e `GET /albums/:id/cards` respondem sem token e `404 ALBUM_NOT_FOUND` para inativo ou excluído.

## Frontend — `apps/cromocard-frontend`, branch `feature/107-buscar-global`

- [ ] **T8** [P] · Criar types, api, queries e parâmetros de URL da busca — R5, R6 · AB# a criar
  - Pronto quando: o typecheck passa e `search.search-params.spec.ts` lê e grava `q` e `tipo`.
- [ ] **T9** · Ajustar a barra de busca do topo com validação do termo — R2–R4 · CA1, CA9 · AB# a criar
  - Pronto quando: `SearchBar.spec.tsx` cobre o envio e o aviso de termo inválido; print em 1280 px igual ao topo do frame `1112-2169` e sem quebra em 375/768/1024 px.
- [ ] **T10** · Criar cabeçalho, abas e cartões de usuário, grupo e álbum — R5, R6, R9–R11 · CA2, CA4, CA11 · AB# a criar
  - Pronto quando: `UserResultCard.spec.tsx` e `GroupResultCard.spec.tsx` cobrem CA4 e CA11; print em 1280 px igual ao frame `1112-3970` e sem quebra em 375/768/1024 px.
- [ ] **T11** · Criar página de resultados da busca com vazio e carregar mais — R1, R3, R5–R8, R15, R17 · CA1–CA3, CA7, CA8, CA12, CA13 · AB# a criar
  - Pronto quando: `SearchPage.spec.tsx` cobre CA1–CA3, CA7 e CA8; print em 1280 px igual aos frames `1112-3970` e `1112-4356` e sem quebra em 375/768/1024 px.
- [ ] **T12** · Criar modal Entre para continuar — R14, R17 · CA6, CA14 · AB# a criar
  - Pronto quando: `LoginRequiredDialog.spec.tsx` cobre os três botões e a volta depois do login; print em 1280 px igual ao frame `1160-2457` e sem quebra em 375/768/1024 px.
- [ ] **T13** · Criar página pública do álbum do catálogo — R12–R14, R17 · CA5, CA6, CA15, CA16 · AB# a criar
  - Pronto quando: `CatalogAlbumPage.spec.tsx` cobre CA5 e CA6 sem chamadas de escrita; print em 1280 px igual ao frame `1160-1845` e sem quebra em 375/768/1024 px.
- [ ] **T14** · Registrar as rotas /pesquisar e /catalogo/albuns/:id — R1, R3 · CA8 · AB# a criar
  - Pronto quando: as duas abrem sem login e, logado, com "Pesquisar" destacado no menu do cliente (`SiteShell.spec.tsx`).

## Fechamento — workspace

- [ ] **T15** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T6, T11, T14 |
| R2 | T9 |
| R3 | T2, T9, T11, T14 |
| R4 | T3, T9 |
| R5, R6 | T5, T8, T10, T11 |
| R7, R8 | T5, T11 |
| R9, R10, R11 | T4, T5, T10 |
| R12, R13 | T7, T13 |
| R14 | T12, T13 |
| R15 | T5, T11 |
| R16 | T2, T4, T5 |
| R17 | T9–T13 |
