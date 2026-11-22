# Tarefas — CCD109 Gerar Etiqueta de Envio

- **Plano:** [plano.md](plano.md) · **User story:** AB#921
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure: a criar (só com o pedido do Daniel). Depende da CCD072 (orders, payments e `ShippingProvider`) e da
  CCD108 (Painel do vendedor) no `develop`.

## Backend — `apps/cromocard-backend`, branch `feature/921-gerar-etiqueta-de-envio`

- [ ] **T1** · Acrescentar compra de etiqueta, impressão e rastreio ao ShippingProvider — R5, R8, R9, R12 · AB# a criar
  - Pronto quando: Melhor Envio e provider falso têm `purchaseLabel`, `getLabelPrintUrl` e `getTracking`, e o `.spec.ts` do
    falso cobre compra e recusa.
- [ ] **T2** · Criar prazo de envio, atraso e número do pedido — R3, R10 · CA1, CA6 · AB# a criar
  - Pronto quando: `order-deadlines.spec.ts` cobre 47 h restantes e o atraso com 3 dias.
- [ ] **T3** · Acrescentar ao seed as vendas do vendedor em todos os status — R2, R3, R10 · AB# a criar
  - Pronto quando: o vendedor do seed tem 2 `PAID` (uma há 3 dias), 1 `SHIPPED`, 1 `DELIVERED` e 1 `CANCELED`.
- [ ] **T4** · Criar service da lista de vendas e do detalhe do pedido — R2–R4 · CA1, CA2 · AB# a criar
  - Pronto quando: `seller-sales.service.spec.ts` cobre abas, contagem, período e o detalhe com pacote e remetente.
- [ ] **T5** · Criar compra da etiqueta com e-mail ao comprador — R5–R9, R11 · CA3, CA5, CA7, CA10 · AB# a criar
  - Pronto quando: o service cobre compra, recusa, status inválido e dados do remetente faltando, e o e-mail
    `order-shipped.mail.ts` sai só depois do commit.
- [ ] **T6** · Criar rotas GET /me/sales, GET /me/sales/:id, POST /shipping-label e GET /shipping-label/print — R1, R8 · CA4, CA8 · AB# a criar
  - Pronto quando: as rotas aparecem no `/docs` e estão em `src/routes.ts`.
- [ ] **T7** · Criar testes de integração de pedidos e envios — R1–R11 · CA3, CA4, CA7, CA8, CA10 · AB# a criar
  - Pronto quando: `tests/integration/marketplace/seller-sales.spec.ts` passa, inclusive as duas compras simultâneas, com
    90% de cobertura nos arquivos alterados.

## Frontend — `apps/cromocard-frontend`, branch `feature/921-gerar-etiqueta-de-envio`

- [ ] **T8** [P] · Criar api, queries e formatação de pedidos e envios — R2–R9 · AB# a criar
  - Pronto quando: o typecheck passa e o `.format.spec.ts` cobre o prazo em horas e o número do pedido.
- [ ] **T9** · Criar página Pedidos e envios — R2, R3, R13 · CA1, CA9, CA11 · AB# a criar
  - Pronto quando: `SalesPage.spec.tsx` cobre CA1 e CA9; print em 1280 px igual ao frame `675-7139` e sem quebra em
    375/768/1024 px.
- [ ] **T10** · Criar modal Gerar etiqueta — R4, R5, R9, R13 · CA2, CA3, CA5, CA10, CA12 · AB# a criar
  - Pronto quando: `GenerateLabelModal.spec.tsx` cobre CA2, CA3, CA5 e CA10; print em 1280 px igual ao frame `675-7788` e
    sem quebra em 375/768/1024 px.
- [ ] **T11** · Criar estado Etiqueta gerada com impressão — R6, R8, R13 · CA3, CA4, CA13 · AB# a criar
  - Pronto quando: `LabelGeneratedView.spec.tsx` cobre CA4; print em 1280 px igual ao frame `1112-9466` e sem quebra em
    375/768/1024 px.

## Fechamento — workspace

- [ ] **T12** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB# a criar
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T6, T7 |
| R2 | T3, T4, T8, T9 |
| R3 | T2, T3, T4, T9 |
| R4 | T4, T10 |
| R5 | T1, T5, T10 |
| R6, R7 | T5, T7, T11 |
| R8 | T1, T6, T11 |
| R9 | T1, T5, T10 |
| R10 | T2, T3 |
| R11 | T5, T7 |
| R12 | T1 |
| R13 | T9, T10, T11 |
