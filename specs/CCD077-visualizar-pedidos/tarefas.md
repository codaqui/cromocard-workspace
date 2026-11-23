# Tarefas — CCD077 Visualizar Pedidos

- **Plano:** [plano.md](plano.md) · **User story:** AB#1390
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Depende dos pedidos da CCD072 e das tabelas da CCD097 (ADR-054); o número do pedido depende da L1 (T1 da CCD072).

## Backend — `apps/cromocard-backend`, branch `feature/1390-visualizar-pedidos`

- [ ] **T1** · Criar service da lista e do detalhe dos pedidos do comprador — R1, R3–R11 · CA1–CA4, CA7 · AB#1391
  - Pronto quando: `orders.service.spec.ts` e `orders.release.spec.ts` cobrem filtro, contagens, linha do tempo, liberação, cancelado e reembolso; o seed tem pedidos em todos os status.
- [ ] **T2** · Criar endpoint GET /orders e estender GET /orders/:id — R1, R3–R11 · CA1–CA3, CA8 · AB#1392
  - Pronto quando: as rotas aparecem no `/docs` e `tests/integration/orders.spec.ts` cobre `200`, `400`, `401` e o `404` do pedido de outro.

## Frontend — `apps/cromocard-frontend`, branch `feature/1390-visualizar-pedidos`

- [ ] **T3** [P] · Criar tipos, api, queries e rótulos dos pedidos — R3–R11 · AB#1393
  - Pronto quando: o typecheck passa e `orders.api.spec.ts` e `orders.format.spec.ts` passam.
- [ ] **T4** · Criar página Meus pedidos com abas por status — R2–R5, R10, R12 · CA1, CA2, CA6, CA9, CA10 · AB#1394
  - Pronto quando: `MyOrdersPage.spec.tsx` cobre lista, abas, vazia, carregando e erro, e o item no menu lateral; print em 1280 px igual ao frame `1112-8445` e sem quebra em 375/768/1024 px.
- [ ] **T5** · Criar página de detalhe do pedido — R6–R9, R11, R12 · CA3–CA5, CA7, CA11 · AB#1395
  - Pronto quando: `OrderDetailPage.spec.tsx`, `OrderTimeline.spec.tsx` e `OrderTracking.spec.tsx` cobrem entregue, concluído, enviado e cancelado; print em 1280 px igual ao frame `1112-8820` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T6** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1396
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T1, T2 |
| R2, R10 | T4 |
| R3, R4, R5 | T1, T2, T3, T4 |
| R6–R9, R11 | T1, T2, T3, T5 |
| R12 | T4, T5 |
