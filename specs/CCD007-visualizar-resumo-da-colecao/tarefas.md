# Tarefas — CCD007 Visualizar Resumo da Coleção

- **Plano:** [plano.md](plano.md) · **User story:** AB#113
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure criadas em 22/11/2026 (Sprint 08), atribuídas a quem o plano final indica.
- Revisadas em 23/11/2026 com as decisões do PO. Ordem de entrega: T1 e T3–T8 primeiro, sem preços; o valor estimado e o "Menor
  anúncio" ficam zerados ou com "—" até a T2 entrar. A T2 (preços) vem por último no backend.
- Em 25/11/2026, `price_history` e `listings` já estão no `develop` (backend #41 e #44): a T2 fica sem migration, e o CA3 e
  o valor do CA8 podem ser verificados nesta story.
- Em 26/11/2026, o backend (codaqui/cromocard-backend#48) entregou a T1–T8 com os preços já ligados, sem implementação
  nula. A revisão de código acrescentou a trava da exclusão de carta em coleções (T4) e a restauração da coleção
  excluída (ADR-015). As caixas só são marcadas no PR de fechamento, depois do merge.

## Backend — `apps/cromocard-backend`, branch `feature/113-visualizar-resumo-da-colecao`

- [ ] **T1** · Criar migrations de collections, user_albums e collection_cards — R3, R4 · AB#971
  - Pronto quando: as 3 migrations (`create_<tabela>_table`) criam as tabelas e o enum `collection_card_status` iguais
    ao DBML, com os índices únicos, e o `prisma migrate dev` não acusa diferença.
- [ ] **T2** · Ligar os preços de price_history ao resumo da coleção — R7 · CA3 · AB#972
  - A migration saiu: a CCD097 (backend #41) já criou `price_history`.
  - Pronto quando: a implementação Prisma de `CollectionPrices` está ligada no
    `collection.module.ts`, o seed tem o histórico de preços dos últimos 60 dias e os anúncios ativos, e o teste de
    integração cobre o CA3.
- [ ] **T3** · Criar seed da coleção de exemplo com histórico de preços — R3–R8 · CA1, CA3, CA8 · AB#973
  - Pronto quando: o cliente do seed tem 4 álbuns e cartas `OWNED`, `MISSING` e `DUPLICATE`, com os números do frame
    `1122-17812`, o histórico de preços e os anúncios do "Menor anúncio".
- [ ] **T4** · Criar repositories da coleção e das cartas e a interface de preços — R1, R3–R5, R7, R8 · AB#974
  - Pronto quando: `findOrCreateByUserId` cria a coleção uma vez só (L2) e restaura a excluída (ADR-015), e as
    consultas filtram `deleted_at` nos álbuns, nas cartas e nas marcações.
  - Inclui `findCardIdsInCollections`, que o catálogo usa pela `collectionService` para não excluir carta marcada
    (CCD061 FA 5). Antecipa a T5 da CCD014 (AB#1033).
- [ ] **T5** · Criar service do resumo da coleção — R3–R7, R9, R12, R13 · CA1–CA3, CA5, CA9 · AB#975
  - Pronto quando: `collection.service.spec.ts` cobre CA1, CA2, CA3, CA5 e CA9, com a variação `null` sem preço anterior
    e valor zerado sem preço.
- [ ] **T6** · Criar consulta dos principais itens com abas, busca e ordenação por valor — R8 · CA4 · AB#976
  - Pronto quando: `collection.service.spec.ts` cobre CA4, a carta sem marcação vem como `MISSING` e a ordem é por maior
    valor (L6); sem anúncio ativo, o "Menor anúncio" vem `null`.
- [ ] **T7** · Criar rotas GET /collections/me/summary e /collections/me/cards — R1 · CA6 · AB#977
  - Pronto quando: as rotas aparecem no `/docs`, o módulo está em `src/routes.ts`, sem token respondem `401` e como
    `ADMIN` `403` (L1).
- [ ] **T8** · Criar teste de integração do resumo da coleção — R1, R3–R9 · CA1–CA6 · AB#978
  - Pronto quando: `tests/integration/collection-summary.spec.ts` e `catalog-card-usage.spec.ts` passam e a cobertura
    dos arquivos alterados é de 90% ou mais.

## Frontend — `apps/cromocard-frontend`, branch `feature/113-visualizar-resumo-da-colecao`

- [ ] **T9** [P] · Criar types, api, queries, labels e format da coleção — R3–R8 · AB#979
  - Pronto quando: o typecheck passa e `collection.api.spec.ts` e `collection.format.spec.ts` cobrem as chamadas e os
    formatos de dinheiro e percentual.
- [ ] **T10** · Criar indicadores, álbum em destaque e grade de cartas do Início — R4, R6–R8, R12, R14 · CA1, CA3, CA4, CA9 · AB#980
  - Pronto quando: `CollectionCardsGrid.spec.tsx` cobre abas, busca, filtro e os links "Ver carta" e "Anunciar
    repetida" (só `SELLER`) e "Comprar no marketplace" para rotas de `underConstructionRoute`, e print em 1280 px igual ao frame
    `1122-17812` e sem quebra em 375/768/1024 px.
- [ ] **T11** · Criar página Início do cliente com estados vazio, carregando e erro — R2, R3, R5, R9–R11, R13 · CA1, CA5, CA7, CA8 · AB#981
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
| R12 | T4, T5, T9, T10 |
| R13 | T5, T9, T11 |
| R14 | T10 |
