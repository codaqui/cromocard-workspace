# Plano — CCD109 Gerar Etiqueta de Envio

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L12 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

"Pedidos e envios" (`/vendedor/pedidos`) lista as vendas do vendedor por aba (`GET /api/v1/me/sales`), com o prazo de 48 h
dos pedidos pagos. "Gerar etiqueta" abre o modal com os dados de `GET /api/v1/me/sales/:id`; confirmar chama
`POST /api/v1/me/sales/:id/shipping-label`, que compra a etiqueta no `ShippingProvider` (Melhor Envio), grava etiqueta,
rastreio e `shipped_at`, muda o pedido para `SHIPPED` e manda o e-mail ao comprador. "Imprimir etiqueta" pede o link de
impressão na hora (`GET …/shipping-label/print`).

## Dependências

- **CCD072 (Comprar):** cria `orders` e `payments` (`create_orders_table`, `create_payments_table`), o `ShippingProvider`
  (interface, fábrica, `MelhorEnvioShippingProvider` com OAuth2 e `FakeShippingProvider` com frete fixo) e grava
  `orders.shipping_service` no checkout. Esta story acrescenta ao provider a compra da etiqueta, o link de impressão e a
  consulta do rastreio (usada pela CCD110). Conferir os nomes com o plano da CCD072 quando ele sair.
- **Número do pedido** (depende da L6): se a CCD072 já tiver criado `order-number.ts`, esta story reaproveita; senão, cria.
- **CCD108:** o Painel do vendedor e o grupo "Vendedor" do menu.
- **CCD110:** usa `shipping_label_id` e o `getTracking` daqui; **CCD111:** usa `isShipmentLate` daqui para o selo "Atrasado"
  (R10).
- **ADR-059:** `MailProvider` e os modelos em `src/providers/mail/templates/`.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `orders` | não | — (CCD072) | `PAID` → `SHIPPED`; grava `shipping_label_id`, `tracking_code`, `tracking_url`, `shipped_at` |
| `addresses` · `users` | sim | — | destino (`shipping_address_id`), remetente (principal do vendedor), CPF e telefone dos dois |
| `listings` · `cards` · `card_conditions` | não / sim | — (CCD084) | carta, miniatura e condição |

Nenhuma coluna nova: o prazo do frete não é guardado (depende da L5) e o link de impressão é pedido na hora (depende da L12).

## Regras

- **Prazo** (R3, depende da L4): `shipBy = paid_at + 48 h`; a lista mostra as horas que faltam ("Envie em até 47h").
- **Atrasado** (R10): `isShipmentLate(order, now)` = `PAID`, sem `shipping_label_id` e `now > shipBy`. Função pura em
  `order-deadlines.ts`, exportada para a CCD111.
- **Abas** (R2, depende da L3): "Aguardando envio" = `PAID`; "Em trânsito" = `SHIPPED`; "Entregues" = `DELIVERED` e
  `COMPLETED` (com "Pagamento liberado" no concluído); "Cancelados" = `CANCELED`; `AWAITING_PAYMENT` não aparece. A lista
  filtra pela aba e pelo período, padrão 30 dias por `created_at` (depende da L1).
- **Pacote padrão** (R4): envelope 16 × 11 × 2 cm, 100 g, valor declarado = `items_amount`; remetente = endereço principal
  do vendedor.
- **Compra** (R5, R6): só `PAID` (`422 INVALID_ORDER_STATUS`, R11); serviço = `orders.shipping_service`; envio não comercial
  com declaração de conteúdo, CPF do vendedor e do comprador. Vendedor sem CPF ou telefone → `422 SENDER_DATA_REQUIRED` com
  os campos que faltam (depende da L11). A compra roda com um lock do pedido (`pg_advisory_xact_lock`), para dois cliques
  não comprarem duas etiquetas (CA10).
- **Recusa** (R9): o provider devolve o motivo; o pedido continua `PAID`, nada é gravado e nenhum e-mail sai.
- **Enviado** (R6, depende da L10): o pedido fica `SHIPPED` na compra; o `order.posted` não entra nesta story.
- **E-mail** (R7): depois do commit, `order-shipped.mail.ts` ao comprador com o código e o link de rastreio.
- **Valor líquido no modal** (depende da L7): `items_amount − platformFee` (`platform-fee.ts` da CCD084).

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }` / `{ data, meta }`, JSON camelCase, dinheiro como string decimal, erros
`{ error, message, details? }`. Todas as rotas: `authenticate` + `authorize('SELLER')`, com `401 UNAUTHORIZED` e
`403 FORBIDDEN` (R1); pedido de outro vendedor ou inexistente responde `404 ORDER_NOT_FOUND`.

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `GET /api/v1/me/sales` | `tab` (`AWAITING_SHIPMENT` \| `IN_TRANSIT` \| `DELIVERED` \| `CANCELED`, padrão o primeiro), `period` (`7d` \| `30d` \| `90d`, padrão `30d`), `page`, `pageSize` | `200` `{ data: SellerSale[], meta: { page, pageSize, total, counts: { awaitingShipment, inTransit, delivered, canceled }, summary: { deliveredThisMonth, retainedAmount } } }` | `400 VALIDATION_ERROR` | R2, R3 |
| `GET /api/v1/me/sales/:id` | — | `200` `{ data: SellerSaleDetail }` | `404 ORDER_NOT_FOUND` | R1, R4 |
| `POST /api/v1/me/sales/:id/shipping-label` | sem corpo | `200` `{ data: { trackingCode, trackingUrl, shippingService, shippedAt, postBy } }` | `404 ORDER_NOT_FOUND`, `422 INVALID_ORDER_STATUS`, `422 PRIMARY_ADDRESS_REQUIRED`, `422 SENDER_DATA_REQUIRED`, `422 SHIPPING_LABEL_REJECTED` (`details.reason` = motivo do Melhor Envio), `502 SHIPPING_PROVIDER_UNAVAILABLE` | R5–R9, R11 |
| `GET /api/v1/me/sales/:id/shipping-label/print` | — | `200` `{ data: { url } }` | `404 ORDER_NOT_FOUND`, `404 SHIPPING_LABEL_NOT_FOUND`, `502 SHIPPING_PROVIDER_UNAVAILABLE` | R8 |

```ts
SellerSale = { id, number, createdAt, status, card: { name, frontImageUrl }, buyer: { name, username },
  itemsAmount, shipBy | null, hoursLeft | null, released: boolean }
SellerSaleDetail = SellerSale & { condition: { name }, shippingAddress: Address, shipping: { service, amount },
  package: { lengthCm: 16, widthCm: 11, heightCm: 2, weightG: 100, declaredValue }, sender: Address,
  platformFee, netAmount, trackingCode | null, trackingUrl | null }
```

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/providers/shipping/shipping.provider.ts` | `purchaseLabel(input)` → `{ labelId, trackingCode, trackingUrl }`, `getLabelPrintUrl(labelId)`, `getTracking(labelId)` → `{ status, deliveredAt }`; erro `ShippingLabelRejectedError(reason)` | R5, R8, R9, R12 |
| `src/providers/shipping/melhor-envio.shipping-provider.ts` | carrinho e compra no mesmo passo (`/me/cart`, `/me/shipment/checkout`, `/me/shipment/generate`), declaração de conteúdo, `/me/shipment/print` e `/me/shipment/tracking` | R5, R8, R12 |
| `src/providers/shipping/fake.shipping-provider.ts` (+ `.spec.ts`) | etiqueta e código falsos, recusa e entrega simuladas pelo teste | R9, R12 |
| `src/domains/marketplace/orders/order-deadlines.ts` (+ `.spec.ts`) · `order-number.ts` (L6) | prazo, atraso e número legível | R3, R10 |
| `src/domains/marketplace/orders/seller-sales.{validator,repository,service,controller,routes,swagger,errors}.ts` + `seller-sales.module.ts` (`basePath: '/me/sales'`) | lista, detalhe, compra com lock, impressão | R1–R9, R11 |
| `src/providers/mail/templates/order-shipped.mail.ts` | e-mail do envio ao comprador | R7 |
| `database/seeds/data/orders.json` (CCD072/CCD097) | vendas do vendedor do seed em todos os status, uma `PAID` há 3 dias | R2, R3, R10 |
| `src/routes.ts` | registra o módulo | R1 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/routes/paths.ts` · `siteMenu.ts` | `/vendedor/pedidos` e o item "Pedidos e envios" no grupo "Vendedor" | R2 |
| `src/features/marketplace/sales/sales.{types,api,queries,format,labels}.ts` | vendas, prazo em horas, número do pedido e textos (L9) | R2–R9 |
| `pages/SalesPage/` | página do frame `675-7139`: "Pedidos & Envios", subtítulo, selo "<n> aguardando envio", cartões (L1), abas com contagem, filtro "Últimos 30 dias", tabela (Pedido, Carta, Comprador, Valor, Status, Ações) com "Gerar etiqueta", "Acompanhar" (abre `trackingUrl`) e "Ver detalhes" (modal só leitura) (L2); sem "Imprimir etiquetas" e "Exportar Fiscal/CSV" | R2, R3, R13 |
| `components/GenerateLabelModal/` | modal do frame `675-7788`: pedido e prazo, comprador e valor, "🔒 Pagamento retido" e o aviso do líquido (L7), endereço, frete escolhido sem o prazo de entrega (L5), "PACOTE PADRÃO", remetente, "Cancelar" e "Gerar etiqueta" em carregamento e bloqueado no segundo clique (CA10); recusa com o motivo; pedido de CPF ou telefone (L11) | R4, R5, R9, R13 |
| `components/LabelGeneratedView/` | estado do frame `1112-9466`: "Etiqueta gerada", "CÓDIGO DE RASTREIO", "poste até <data>" (L8), "Fechar" e "Imprimir etiqueta", que abre o link em nova aba | R6, R8, R13 |

- **Estados:** `LoadingState`, `ErrorState` com "Tentar de novo" e `EmptyState` "Nenhuma venda por aqui ainda" (L9, CA9).
- **Componentes reaproveitados:** `DataTable`, `Tabs`, `Select`, `Pagination`, `KpiCard`, `Badge`, `Modal`, `Button`,
  `Toast`, `EmptyState`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | contagem das abas e "Envie em até 47h" | `seller-sales.service.spec.ts` · `order-deadlines.spec.ts` · `SalesPage.spec.tsx` |
| CA2 | o modal mostra carta, comprador, endereço, frete, pacote e remetente | `seller-sales.service.spec.ts` · `GenerateLabelModal.spec.tsx` |
| CA3 | compra no provider falso, pedido `SHIPPED` com os 4 campos, e-mail com o código, "Etiqueta gerada" | `seller-sales.service.spec.ts` · `tests/integration/marketplace/seller-sales.spec.ts` · `GenerateLabelModal.spec.tsx` |
| CA4 | "Imprimir etiqueta" abre o link | `LabelGeneratedView.spec.tsx` · integração da impressão |
| CA5 | recusa mostra o motivo, pedido continua `PAID`, sem e-mail | `seller-sales.service.spec.ts` · `GenerateLabelModal.spec.tsx` |
| CA6 | `PAID` há 3 dias sem etiqueta é atrasado (a tela é da CCD111) | `order-deadlines.spec.ts` |
| CA7 | pedido `SHIPPED` responde `422` sem nova compra | `seller-sales.service.spec.ts` · integração |
| CA8 | `401`, `403` para `CUSTOMER`, `404` para outro vendedor | integração |
| CA9 | vazio, carregamento e erro | `SalesPage.spec.tsx` |
| CA10 | duas chamadas simultâneas compram uma etiqueta só; botão bloqueado | integração · `GenerateLabelModal.spec.tsx` |
| CA11–CA13 | print em 1280 px igual aos frames `675-7139`, `675-7788` e `1112-9466`, sem quebra em 375/768/1024 px | revisão visual (`/cromocard-revisor`) |

## Decisões técnicas

- A compra da etiqueta roda num lock do pedido no Postgres (`pg_advisory_xact_lock` pelo id), checando o status dentro do
  lock; assim, dois pedidos simultâneos não compram duas etiquetas, sem coluna nova.
- O e-mail sai depois do commit, para o comprador não receber código de um pedido que não ficou `SHIPPED`.
- O link de impressão do Melhor Envio é temporário, por isso é pedido a cada "Imprimir etiqueta", sem guardar URL.
