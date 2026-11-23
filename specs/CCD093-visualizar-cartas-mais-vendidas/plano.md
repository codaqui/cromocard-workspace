# Plano — CCD093 Visualizar Cartas Mais Vendidas

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L5 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

O bloco "Cartas mais vendidas" entra na Visão geral do vendedor (L1), abaixo do gráfico da CCD092, e usa o mesmo filtro de
período. Ele chama `GET /api/v1/me/top-cards`, que agrupa as vendas do vendedor no período por carta, ordena por unidades
ou por faturamento ("Ordenar por:") e devolve as 5 primeiras, com a condição mais vendida, o preço médio e o faturamento.

## Dependências

- **CCD092:** o domínio `marketplace/seller-metrics/` (validator e período), a regra de "venda" (L1 da CCD092) e o filtro de
  período da página.
- **CCD108:** a página `SellerOverviewPage`.
- **CCD084 e CCD072/CCD097:** `listings`, `card_conditions` e `orders`, só leitura.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `orders` · `listings` · `card_conditions` | não | — (CCD072/CCD097, CCD084) | `seller_id`, `status`, `quantity`, `items_amount`, `paid_at`; `card_id`, `condition_id`; `name` |
| `cards` · `albums` | sim | — | `name`, `number`, `front_image_url`; `title` |

Nenhuma coluna nova.

## Regras

- **Vendas que contam** (R3): as mesmas da CCD092 (L1 de lá), do vendedor do token, no período (R5).
- **Agrupamento** (R3, depende da L4): por `listings.card_id`; `unitsSold` = soma de `quantity`; `revenue` = soma de
  `items_amount`; `averagePrice` = `revenue / unitsSold`, arredondado em centavos; a condição do selo é a de mais unidades
  (empate: a de maior `sort_order`).
- **Ordem** (R3, depende da L2): `sort=units` (padrão) ou `sort=revenue`; empate pelo nome da carta.
- **Limite** (depende da L5): 5 linhas.
- **Vazio** (R6, depende da L3): `hasSalesEver = false` → "Nenhuma carta vendida ainda."; vendas só fora do período → "Não
  há dados suficientes para formar o ranking no período escolhido".

## Contrato da API

Convenções do ADR-011: `/api/v1`, `{ data, meta }`, JSON camelCase, dinheiro como string decimal, erros `{ error, message,
details? }`.

### `GET /api/v1/me/top-cards` — R1–R6

- **Acesso:** `authenticate` + `authorize('SELLER')`
- **Entrada:** `period` / `from` / `to` (os mesmos da CCD092), `sort` (`units` \| `revenue`, padrão `units`).
- **Sucesso:** `200`

  ```json
  { "data": [{ "position": 1, "unitsSold": 15, "averagePrice": "1750.00", "revenue": "26250.00",
    "card": { "id": "uuid", "name": "Suicune", "number": "SV-49", "frontImageUrl": "https://…", "album": { "title": "Shining Fates" } },
    "condition": { "name": "Mint" } }],
    "meta": { "limit": 5, "sort": "units", "hasSalesEver": true } }
  ```

- **Erros:** `400 VALIDATION_ERROR` (período ou ordenação inválida) — R5; `401 UNAUTHORIZED`, `403 FORBIDDEN` — R1.

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/marketplace/seller-metrics/seller-metrics.validator.ts` | query do ranking (`sort`) | R3, R5 |
| `seller-metrics.repository.ts` | `groupBy` por carta e por condição, e se o vendedor já vendeu alguma vez | R3, R4, R6 |
| `seller-metrics.service.ts` (+ `.spec.ts`) | ordem, posição, preço médio, condição do selo e limite | R3–R6 |
| `seller-metrics.controller.ts` · `.routes.ts` · `.swagger.ts` | rota `/me/top-cards` | R1 |
| `database/seeds/data/orders.json` | vendas de Suicune, Charizard (só no mês passado) e Messi do vendedor do seed | R3, R5 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/marketplace/seller-dashboard/seller-dashboard.{types,api,queries,labels}.ts` | ranking e os dois textos do vazio | R3–R6 |
| `components/TopCardsTable/` | bloco do frame `492-2007`: troféu, "Cartas mais vendidas", "As cartas que mais venderam no período.", "Ordenar por:", colunas "CLASSIFICAÇÃO & CARTA", "CONDIÇÃO", "VENDAS REALIZADAS", "PREÇO MÉDIO" e "FATURAMENTO TOTAL"; vazio do frame `1112-9866` | R2, R4, R6, R7 |
| `pages/SellerOverviewPage/` | bloco abaixo do gráfico, com o período da página | R2, R5 |

- **Estados:** `LoadingState` na tabela e `ErrorState` com "Tentar de novo" (CA6).
- **Componentes reaproveitados:** `DataTable`, `Select`, `Badge`, `EmptyState`, `LoadingState`, `ErrorState`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | Suicune 15, Charizard 8, Messi 6, nessa ordem, com "<n> vendidas" | `seller-metrics.service.spec.ts` · `tests/integration/marketplace/seller-metrics.spec.ts` · `TopCardsTable.spec.tsx` |
| CA2 | vendas de outro vendedor e pedidos cancelados ficam fora | `seller-metrics.service.spec.ts` · integração |
| CA3 | Charizard só no mês passado some com "Este Mês" e aparece com "1 Ano" | `seller-metrics.service.spec.ts` · integração |
| CA4 | período sem vendas mostra o texto da L3 | `TopCardsTable.spec.tsx` |
| CA5 | `401` sem token; `403` para `CUSTOMER` e `ADMIN` | integração |
| CA6 | carregamento e erro com nova tentativa | `TopCardsTable.spec.tsx` |
| CA7, CA8 | print em 1280 px igual aos frames `492-2007` (bloco) e `1112-9866` (vazio), sem quebra em 375/768/1024 px | revisão visual (`/cromocard-revisor`) |

## Decisões técnicas

- O ranking fica no mesmo domínio e no mesmo validator de período da CCD092, para os dois blocos usarem exatamente o mesmo
  recorte.
