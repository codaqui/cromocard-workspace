# Tarefas — CCD007 Visualizar Resumo da Coleção

- **Plano:** [plano.md](plano.md) · **User story:** AB#113
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure criadas em 22/11/2026 (Sprint 08), atribuídas a quem o plano final indica.

## Backend — `apps/cromocard-backend`, branch `feature/113-visualizar-resumo-da-colecao`

- [ ] **T1** · Criar migrations de collections, user_albums e collection_cards — R3, R4 · AB#971
  - Pronto quando: as 3 migrations (`create_<tabela>_table`) criam as tabelas e o enum `collection_card_status` iguais
    ao DBML, com os índices únicos, e o `prisma migrate dev` não acusa diferença.
- [ ] **T2** · Criar migration de price_history — R7 · AB#972
  - Pronto quando: `create_price_history_table` cria a tabela e o enum `price_source` do DBML (ou a tarefa é removida,
    se a CCD097 já tiver criado a tabela).
- [ ] **T3** · Criar seed da coleção de exemplo com histórico de preços — R3–R8 · CA1, CA3, CA8 · AB#973
  - Pronto quando: o cliente do seed tem 4 álbuns, cartas `OWNED`, `MISSING` e `DUPLICATE` e preços nos últimos 60 dias,
    com os números do frame `1122-17812`.
- [ ] **T4** · Criar repositories da coleção, das cartas e dos preços — R1, R3–R5, R7, R8 · AB#974
  - Pronto quando: `findOrCreateByUserId` cria a coleção uma vez só (depende da L2) e as consultas filtram `deleted_at`
    nos álbuns, nas cartas e nas marcações.
- [ ] **T5** · Criar service do resumo da coleção — R3–R7, R9 · CA1–CA3, CA5 · AB#975
  - Pronto quando: `collection.service.spec.ts` cobre CA1, CA2, CA3 e CA5, com a variação `null` sem preço anterior.
- [ ] **T6** · Criar consulta dos principais itens com abas, busca e ordenação por valor — R8 · CA4 · AB#976
  - Pronto quando: `collection.service.spec.ts` cobre CA4, a carta sem marcação vem como `MISSING` e a ordem é por maior
    valor (depende da L6).
- [ ] **T7** · Criar rotas GET /collections/me/summary e /collections/me/cards — R1 · CA6 · AB#977
  - Pronto quando: as rotas aparecem no `/docs`, o módulo está em `src/routes.ts`, sem token respondem `401` e como
    `ADMIN` `403` (depende da L1).
- [ ] **T8** · Criar teste de integração do resumo da coleção — R1, R3–R9 · CA1–CA6 · AB#978
  - Pronto quando: `tests/integration/collection-summary.spec.ts` passa e a cobertura dos arquivos alterados é de 90% ou
    mais.

## Frontend — `apps/cromocard-frontend`, branch `feature/113-visualizar-resumo-da-colecao`

- [ ] **T9** [P] · Criar types, api, queries, labels e format da coleção — R3–R8 · AB#979
  - Pronto quando: o typecheck passa e `collection.api.spec.ts` e `collection.format.spec.ts` cobrem as chamadas e os
    formatos de dinheiro e percentual.
- [ ] **T10** · Criar indicadores, álbum em destaque e grade de cartas do Início — R6–R8 · CA1, CA3, CA4 · AB#980
  - Pronto quando: `CollectionCardsGrid.spec.tsx` cobre abas, busca e filtro, e print em 1280 px igual ao frame
    `1122-17812` e sem quebra em 375/768/1024 px.
- [ ] **T11** · Criar página Início do cliente com estados vazio, carregando e erro — R2, R9–R11 · CA1, CA5, CA7, CA8 · AB#981
  - Pronto quando: `/inicio` abre pelo item "Início" do menu e pelo login do cliente, `CollectionHomePage.spec.tsx`
    cobre CA1, CA5 e CA7, e print em 1280 px igual ao frame `1122-17812` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T12** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#982
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T4, T7, T8 |
| R2 | T11 |
| R3, R4, R5 | T1, T3, T4, T5, T9, T10 |
| R6 | T10, T11 |
| R7 | T2, T3, T4, T5, T9, T10 |
| R8 | T3, T4, T6, T9, T10 |
| R9 | T5, T11 |
| R10 | T11 |
| R11 | T10, T11 |
