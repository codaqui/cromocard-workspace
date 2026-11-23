# Plano — CCD077 Visualizar Pedidos

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L11 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

"Meus pedidos" (`/pedidos`) lista as compras do usuário por `GET /api/v1/orders`, com abas por status e a contagem de cada
uma em `meta.counts`. "Ver pedido" abre `/pedidos/:id`, que usa o `GET /api/v1/orders/:id` criado pela CCD072, agora com a
linha do tempo, o rastreio, o endereço, o vendedor, os valores, a data de liberação e o motivo do cancelamento.

## Dependências

- **CCD072**: grava os pedidos e cria o `GET /orders/:id` (resumo), que esta story estende.
- **CCD097** (ADR-054): `orders`, `payments` e `listings` no banco, com o seed do marketplace.
- **CCD109 / CCD110 / CCD111**: preenchem `shipped_at`, `tracking_*`, `delivered_at`, `released_at`, o reembolso e o
  botão "Confirmar recebimento" (o modal `1112-9136` é da CCD110). Esta story só lê e mostra o botão.
- **PR de docs no DBML** para o número do pedido (L1, o mesmo da CCD072).

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `orders` | da CCD097 | — | leitura das colunas da spec (R3, R6–R9, R11) |
| `payments` | da CCD097 | — | `status = REFUNDED` e `refunded_at` (R11) |
| `listings` · `cards` · `card_conditions` · `users` · `addresses` | sim / da CCD097 e CCD084 | — | carta, vendedor e endereço, mesmo excluído depois (R3, R8) |
| número do pedido | não (o DBML não tem) | depende da L1 | R3 |

## Regras

- **Escopo** (R1): sempre `buyer_id = usuário do token`; pedido de outra pessoa → `404 ORDER_NOT_FOUND`.
- **Abas** (R4): uma por `order_status`, com a contagem (`groupBy` por status); "Todos" é a aba inicial, como no frame e no
  CA1 (depende da L2). Ordem: mais recentes primeiro, 20 por página (depende da L8).
- **Linha do tempo** (R6): Pago (`paid_at`), Enviado (`shipped_at`), Entregue (`delivered_at`), Concluído (`released_at`);
  etapa sem data fica pendente.
- **Transportadora** (R7): `shipping_method` (depende da L9 e da L3 da CCD072); link = `tracking_url`, com o texto
  "Acompanhar entrega nos <transportadora> →".
- **Liberação** (R9): só em `DELIVERED`: `releaseDate = delivered_at + ORDER_RELEASE_DAYS` (7; 0 em homologação), o mesmo
  parâmetro da CCD110 (se ainda não existir, esta story cria a variável no `env.ts`); `canConfirmReceipt = true`.
- **Cancelado** (R11): `cancel_reason`; `refunded = payments.status = REFUNDED`, com `refunded_at`.
- Subtítulo por status: só o de `DELIVERED` tem texto (depende da L10). "cartão final 4242" (L3) e "Falar com o suporte"
  (L4) ficam fora até a decisão.

## Contrato da API

```ts
OrderListItem = { id, code, createdAt, status, totalAmount, card: { name, number, frontImageUrl }, seller: { id, username } }
OrderDetail = OrderListItem & { itemsAmount, shippingAmount, condition: { name },
  timeline: { paidAt, shippedAt, deliveredAt, releasedAt }, carrier, trackingCode, trackingUrl,
  shippingAddress: { street, number, complement, neighborhood, city, state, zipCode },
  releaseDate: string | null, canConfirmReceipt: boolean,
  cancelReason: string | null, refunded: boolean, refundedAt: string | null }   // code depende da L1
```

| Método e caminho | Acesso | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|---|
| `GET /api/v1/orders` | `authenticate` | `status?` (`order_status`), `page`, `pageSize` | `200` `{ data: OrderListItem[], meta: { page, pageSize, total, counts: { ALL, AWAITING_PAYMENT, PAID, SHIPPED, DELIVERED, COMPLETED, CANCELED } } }` | `400 VALIDATION_ERROR`, `401` | R1, R3, R4, R10 |
| `GET /api/v1/orders/:id` (da CCD072, estendido) | `authenticate` | — | `200` `{ data: OrderDetail }` | `400`, `401`, `404 ORDER_NOT_FOUND` | R1, R5–R9, R11 |

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/marketplace/orders/orders.validator.ts` | filtro de status e paginação | R4 |
| `orders.repository.ts` | `listByBuyer`, `countByStatus`, `findDetailForBuyer` (inclui excluídos de endereço e anúncio) | R1, R3, R4, R8 |
| `orders.release.ts` + `.spec.ts` | data de liberação e `canConfirmReceipt` | R9 |
| `orders.service.ts` + `.spec.ts` | lista, contagens, detalhe, cancelado com reembolso | R1, R3–R11 |
| `orders.controller.ts` · `.routes.ts` · `.swagger.ts` | `GET /orders` e o detalhe completo | R1 |
| `database/seeds/` | pedidos do cliente do seed em todos os status, um cancelado por expiração e um reembolsado | R3, R4, R11 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/marketplace/orders/` (da CCD072).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `orders.types.ts` · `.api.ts` · `.queries.ts` · `.labels.ts` · `.format.ts` | contrato, rótulos dos status, data e moeda | R3–R11 |
| `pages/MyOrdersPage/` | "COMPRAS", "Meus pedidos", abas com contagem e a tabela Pedido · Carta · Vendedor · Data · Total · Status · "Ver pedido", frame `1112-8445`; `EmptyState` "Você ainda não possui pedidos.", `LoadingState`, `ErrorState` | R2–R5, R10, R12 |
| `pages/OrderDetailPage/` | breadcrumb, subtítulo, "Acompanhamento", rastreio, endereço, resumo e "Confirmar recebimento", frame `1112-8820`; cancelado com motivo e reembolso no estilo da tela | R6–R9, R11, R12 |
| `components/OrderTimeline/` · `OrderTracking/` · `OrderSummaryCard/` | blocos do detalhe | R6–R8 |
| `src/app/layouts/SiteShell/siteMenu.ts` | item "Meus pedidos" no menu lateral do cliente (acesso por Perfil depende da L6) | R2 |
| `orders.routes.ts` · `src/routes/paths.ts` | `/pedidos` e `/pedidos/:id` no `CustomerLayout` com `RequireAuth` | R1, R2, R5 |

- **Componentes reaproveitados:** `Tabs`, `DataTable`, `Badge`, `Pagination`, `Button`, `EmptyState`, `LoadingState`,
  `ErrorState`, `NotFoundPage` (para o `404`).

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | 5 pedidos com número, carta, vendedor, data, total e status | `orders.service.spec.ts` · `tests/integration/orders.spec.ts` · `MyOrdersPage.spec.tsx` |
| CA2 | aba "Enviado" filtra e as contagens batem | service · `MyOrdersPage.spec.tsx` |
| CA3 | detalhe `DELIVERED` com linha do tempo, rastreio, endereço, vendedor e valores | integração · `OrderDetailPage.spec.tsx` |
| CA4 | entregue em 20/11 → liberação em 27/11 e botão; `COMPLETED` sem botão e com a data | `orders.release.spec.ts` · `OrderDetailPage.spec.tsx` |
| CA5 | link de rastreio abre a transportadora | `OrderTracking.spec.tsx` |
| CA6 | lista vazia | `MyOrdersPage.spec.tsx` |
| CA7 | cancelado por expiração sem reembolso; cancelado pelo admin com reembolso | service · `OrderDetailPage.spec.tsx` |
| CA8 | `401`; pedido de outro → `404` | integração |
| CA9 | carregando e erro sem a mensagem de vazio | `MyOrdersPage.spec.tsx` |
| CA10, CA11 | print em 1280 px igual aos frames `1112-8445` e `1112-8820`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Decisões técnicas

- As contagens das abas vêm no `meta` da lista, numa consulta `groupBy`, para a tela não fazer uma chamada por aba.
- O detalhe estende o `GET /orders/:id` da CCD072, sem rota paralela; a data de liberação é calculada no backend, no mesmo
  lugar que a CCD110 usa para liberar.
