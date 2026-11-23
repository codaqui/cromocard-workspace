# Tarefas — CCD110 Confirmar Entrega e Liberar Pagamento

- **Plano:** [plano.md](plano.md) · **User story:** AB#922
- Ordem de execução de cima para baixo. `[P]` = pode ser feita em paralelo com a anterior.
- Tasks no Azure criadas em 22/11/2026 (Sprint 08), atribuídas a quem o plano final indica.

## Backend — `apps/cromocard-backend`, branch `feature/922-confirmar-entrega-e-liberar-pagamento`

- [ ] **T1** · Acrescentar a transferência por pedido ao PaymentProvider — R6, R7, R10 · AB#1528
  - Pronto quando: Stripe e provider falso têm `createTransfer` com `source_transaction`, `transfer_group` e
    `idempotencyKey`, e o falso simula a recusa.
- [ ] **T2** · Criar variáveis do prazo de liberação e do segredo do webhook e as regras de prazo — R3, R8, R10 · CA1, CA7 · AB#1529
  - Pronto quando: `env.ts` valida `PAYMENT_RELEASE_DAYS` e `MELHOR_ENVIO_WEBHOOK_SECRET` e `order-deadlines.spec.ts`
    cobre `releaseAt` e `isReleasePending`.
- [ ] **T3** · Criar service de entrega do pedido com e-mail ao comprador — R1–R3 · CA1–CA3 · AB#1530
  - Pronto quando: `order-delivery.service.spec.ts` cobre a entrega, o aviso repetido e a consulta do rastreio.
- [ ] **T4** · Criar webhook POST /webhooks/melhor-envio com conferência da assinatura — R1 · CA1, CA2 · AB#1531
  - Pronto quando: a assinatura inválida responde `400`, a válida responde `200` e o corpo bruto só vale nessa rota.
- [ ] **T5** · Criar service de liberação do pagamento ao vendedor — R6–R11 · CA4, CA5, CA7–CA10 · AB#1532
  - Pronto quando: `payment-release.service.spec.ts` cobre o valor, a taxa, a falha, a conta não pronta, o cancelado e a
    liberação única.
- [ ] **T6** · Criar endpoint POST /me/orders/:id/confirm-receipt e os campos de liberação no detalhe — R3, R4, R11, R12 · CA10, CA11 · AB#1533
  - Pronto quando: a rota aparece no `/docs` e o detalhe da CCD077 traz `releaseAt` e `canConfirmReceipt`.
- [ ] **T7** · Criar jobs de consulta do rastreio e de liberação automática — R2, R8, R10 · CA3, CA7, CA9 · AB#1534
  - Pronto quando: os dois jobs estão em `src/jobs/index.ts`, rodam de hora em hora (L6) e os `.spec.ts` passam.
- [ ] **T8** · Criar testes de integração da entrega e da liberação — R1, R4–R12 · CA1, CA2, CA4, CA8, CA10, CA11 · AB#1535
  - Pronto quando: a integração do webhook e da confirmação passa, com 90% de cobertura nos arquivos alterados.

## Frontend — `apps/cromocard-frontend`, branch `feature/922-confirmar-entrega-e-liberar-pagamento`

- [ ] **T9** [P] · Acrescentar a confirmação de recebimento à api e às queries de pedidos — R3–R6 · AB#1536
  - Pronto quando: o typecheck passa e o `.api.spec.ts` cobre a ação.
- [ ] **T10** · Criar diálogo Confirmar recebimento — R5, R6, R13 · CA6, CA12, CA14 · AB#1537
  - Pronto quando: `ConfirmReceiptDialog.spec.tsx` cobre CA6 e CA12; print em 1280 px igual ao frame `1112-9136` e sem
    quebra em 375/768/1024 px.
- [ ] **T11** · Acrescentar liberação e Confirmar recebimento ao detalhe do pedido — R3, R4, R13 · CA1, CA4, CA13 · AB#1538
  - Pronto quando: `OrderDetailPage.spec.tsx` cobre a data da liberação, o botão e o estado concluído (L2); print em 1280 px
    igual ao frame `1112-8820` e sem quebra em 375/768/1024 px.

## Fechamento — workspace

- [ ] **T12** · Atualizar os ponteiros `apps/*` e marcar a spec como `Implementada` · AB#1539
  - Pronto quando: os PRs dos apps estão mergeados em `develop` e o índice de `specs/README.md` foi atualizado.

## Cobertura

| Requisito | Tarefas |
|---|---|
| R1 | T2, T3, T4, T8 |
| R2 | T3, T7 |
| R3 | T2, T3, T6, T9, T11 |
| R4 | T6, T9, T11 |
| R5 | T9, T10 |
| R6, R7 | T1, T5, T8, T10 |
| R8 | T2, T5, T7 |
| R9 | T5, T8 |
| R10 | T1, T2, T5, T7 |
| R11 | T5, T6, T8 |
| R12 | T6, T8 |
| R13 | T10, T11 |
