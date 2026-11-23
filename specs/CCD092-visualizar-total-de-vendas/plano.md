# Plano — CCD092 Visualizar Total de Vendas

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L7 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

A Visão geral do vendedor (`/vendedor`, criada pela CCD108) ganha o filtro de período, os cartões de métricas, o gráfico
"Vendas e faturamento por dia" e os destaques, todos de `GET /api/v1/me/sales-summary`. O backend soma os pedidos vendidos
do vendedor no período (status da L1, data `paid_at` da L2) e devolve os totais e a série por dia. Sem vendas, a tela mostra
as métricas zeradas com a mensagem do gráfico conforme o estado da conta Stripe (CCD108).

## Dependências

- **CCD108:** a página `SellerOverviewPage`, o grupo "Vendedor" do menu e `GET /api/v1/me/stripe-account`, que escolhe a
  mensagem das métricas zeradas (`1112-9866`, `1112-10347` ou a da L5).
- **CCD072 (ou CCD097, a que entrar primeiro):** a migration `create_orders_table`; aqui só se lê. O seed de pedidos vem do
  seed do marketplace da CCD097 e ganha pedidos do vendedor do seed.
- **CCD084:** `listings`, para o cartão "Anúncios Ativos" (depende da L3).
- **CCD093:** usa o mesmo período e o mesmo domínio; entra depois desta.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `orders` | não | — (CCD072/CCD097) | só leitura: `seller_id`, `status`, `items_amount`, `quantity`, `platform_fee`, `paid_at`, `released_at` |
| `listings` | não | — (CCD084) | só leitura: `status`, `available_quantity` (depende da L3) |

Nenhuma coluna nova.

## Regras

- **Venda** (R3, depende da L1): pedido do vendedor com status `PAID`, `SHIPPED`, `DELIVERED` ou `COMPLETED`, não excluído;
  soma `items_amount` e conta pedidos ("vendas concluídas"); unidades = soma de `quantity`.
- **Período** (depende da L2): `today`, `7d`, `month` (padrão, do dia 1 do mês até agora), `1y` ou `from`/`to`, por
  `paid_at`, no fuso de Brasília, como o `dashboard.period.ts` do BackOffice.
- **Série por dia** (R5): um ponto por dia do período, com zero nos dias sem venda.
- **Cartões extras** (depende da L3): "Liberado no mês" = líquido (`items_amount − platform_fee`) dos `COMPLETED` com
  `released_at` no mês; "A liberar" = líquido dos `PAID`, `SHIPPED` e `DELIVERED`; "Anúncios Ativos" com pausados e
  esgotados. "Visualizações" sai.
- **Destaques** (depende da L4): variação contra o período anterior de mesma duração, melhor dia e vendas de hoje; "Taxa de
  Liquidez" sai.
- **Zerado** (R6, depende da L5): conta não conectada ou `PENDING` → mensagem de `1112-9866`; `VERIFYING` → `1112-10347`;
  `READY` e sem vendas → "Nenhuma venda no período. Crie seu primeiro anúncio para começar a vender." com "Criar Novo
  Anúncio".

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data }`, JSON camelCase, dinheiro como string decimal, erros `{ error, message,
details? }`.

### `GET /api/v1/me/sales-summary` — R1–R6

- **Acesso:** `authenticate` + `authorize('SELLER')`; só os pedidos com `seller_id` do token.
- **Entrada:** `period` (`today` \| `7d` \| `month` \| `1y`, padrão `month`) ou `from` e `to` (datas ISO, `to` ≥ `from`).
- **Sucesso:** `200`

  ```json
  { "data": {
    "range": { "from": "2026-11-01T03:00:00Z", "to": "2026-11-22T15:00:00Z" },
    "totalSales": "600.00", "completedSales": 3, "unitsSold": 3, "variation": 0.184,
    "released": "1540.00", "toRelease": "380.00",
    "listings": { "active": 14, "paused": 2, "soldOut": 3 },
    "bestDay": { "date": "2026-11-12", "revenue": "300.00", "units": 1 },
    "today": { "sales": 0, "revenue": "0.00" },
    "daily": [{ "date": "2026-11-01", "revenue": "0.00", "units": 0 }]
  } }
  ```

  `variation` é `null` quando o período anterior não tem vendas; `bestDay` é `null` sem vendas.

- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | período inválido ou `to` antes de `from` | R3 |
  | 401 / 403 | `UNAUTHORIZED` / `FORBIDDEN` | sem token / papel diferente de `SELLER` | R1 |

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/marketplace/seller-metrics/seller-metrics.{validator,period,repository,service,controller,routes,swagger}.ts` + `seller-metrics.module.ts` (`basePath: '/me'`) | período, somas, série por dia, cartões e destaques | R1, R3–R6 |
| `src/shared/utils/time-zone.ts` | início do mês no fuso de Brasília, se ainda não houver | R3 |
| `database/seeds/data/orders.json` (CCD097) | pedidos do vendedor do seed em todos os status, em dias diferentes do mês, e de outro vendedor | R3 |
| `src/routes.ts` | registra o módulo | R1 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/components/PeriodFilter/` | opção "Este Mês" (`month`) ao lado das que já existem, sem mudar as telas do BackOffice | R3 |
| `src/features/marketplace/seller-dashboard/seller-dashboard.{types,api,queries,format,labels}.ts` | resumo de vendas, moeda, datas e as mensagens do zerado | R3–R6 |
| `components/SalesKpiCards/` | "VOLUME FINANCEIRO / Total de Vendas" com a variação e "<n> vendas concluídas", "LIQUIDAÇÃO / Liberado no mês" e "INVENTÁRIO / Anúncios Ativos" (L3) | R4, R7 |
| `components/SalesChart/` | "Vendas e faturamento por dia" com o alternador "Faturamento (R$)" / "Unidades Vendidas" sem recarregar (CA4), o balão "Melhor dia" e a mensagem do zerado | R5, R6, R7 |
| `components/SalesHighlights/` | "Melhor Dia do Mês" e "Vendas Realizadas Hoje" (L4) | R5, R7 |
| `pages/SellerOverviewPage/` (CCD108) | título "Visão geral", subtítulo, filtro de período com "Intervalo: …", cartões, gráfico e destaques; "Ver Loja Pública" leva ao perfil público (L7) | R2, R6, R7 |

- **Estados:** `LoadingState` nos cartões e no gráfico e `ErrorState` com "Tentar de novo" (CA6); zerado como nos frames
  `1112-9866` e `1112-10347`.
- **Componentes reaproveitados:** `KpiCard`, `PeriodFilter`, `Tabs`, `Badge`, `LoadingState`, `ErrorState`, `Button`; o
  gráfico segue o do Dashboard do BackOffice (`features/admin/dashboard/components`).

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | 3 vendas de R$ 100, 200 e 300 somam R$ 600,00, "3 vendas concluídas", e a série tem as 3; venda de outro vendedor fica fora | `seller-metrics.service.spec.ts` · `tests/integration/marketplace/seller-metrics.spec.ts` · `SellerOverviewPage.spec.tsx` |
| CA2 | `CANCELED` e `AWAITING_PAYMENT` não entram | `seller-metrics.service.spec.ts` · integração |
| CA3 | conta pronta e sem vendas: R$ 0,00, 0 vendas, gráfico vazio e o incentivo | `SellerOverviewPage.spec.tsx` |
| CA4 | o alternador troca faturamento e unidades sem nova chamada | `SalesChart.spec.tsx` |
| CA5 | `401` sem token; `403` para `CUSTOMER` e `ADMIN` | integração |
| CA6 | carregamento e erro com nova tentativa | `SellerOverviewPage.spec.tsx` |
| CA7–CA9 | print em 1280 px igual aos frames `492-2007`, `1112-9866` e `1112-10347`, sem quebra em 375/768/1024 px | revisão visual (`/cromocard-revisor`) |
| CA10 | frame `675-8493` (Financeiro e extrato): depende da L6; com a proposta, a tela vira caso de uso novo e o CA10 sai desta spec | — |

## Decisões técnicas

- As métricas vêm num endpoint só, porque cartões, gráfico e destaques usam o mesmo período e a mesma consulta; o ranking
  da CCD093 fica em endpoint próprio, porque tem ordenação e limite.
- As somas são feitas no banco (`groupBy` por dia em `paid_at`, no fuso de Brasília) e o backend completa os dias sem venda.
