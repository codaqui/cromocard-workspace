# Plano — CCD097 Visualizar Indicadores Financeiros

- **Spec:** [spec.md](spec.md) — feito sobre a spec em Rascunho (pedido do PO em 2026-10-22), com as propostas das lacunas
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade

## Solução

Consultas de leitura sobre as tabelas do marketplace, criadas nesta story a partir do DBML e povoadas pelo seed, num serviço `admin/finance`. O Dashboard, o Catálogo, a Comunidade e os Relatórios mostram os números.

## Dependências

- CCD058, CCD061, CCD062 e CCD063 (telas onde os números aparecem).

## Dados e migrations

Cada coluna entra com esta story, numa migration própria (ADR-053, item 10).

| Tabela | Migration | O que muda | Requisitos |
|---|---|---|---|
| `listings` | `create_listings_table` | tabela do DBML | R5, R10 |
| `orders` | `create_orders_table` | tabela do DBML | R2, R3 |
| `payments` | `create_payments_table` | tabela do DBML | R2–R4 |
| `reviews` | `create_reviews_table` | tabela do DBML | R5 |
| `price_history` | `create_price_history_table` | tabela do DBML | R9 |

## Contrato da API

| Método e caminho | Entrada | Sucesso | Erros | Requisitos |
|---|---|---|---|---|
| `GET /api/v1/admin/finance/summary` | `period` | `200` `{ custody, settledToday, settledOrders, retained }` | `400` | R2–R4, R6, R8 |
| `GET /api/v1/admin/finance/ledger` | `date` | `200` lista de pagamentos e liberações | — | R7 |
| `GET /api/v1/admin/finance/sellers` | `ids` | `200` volume e reputação por vendedor | — | R5 |
| `GET /api/v1/admin/finance/cards` · `/groups` | `ids` | `200` população e preço médio; volume por grupo | — | R9, R10 |

## Backend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `database/schema.prisma` + 5 migrations · `database/seeds/marketplace.seed.ts` | tabelas do DBML e movimentação de teste | R2–R5, R9, R10 |
| `src/domains/admin/finance/` (repository, service + `.spec.ts`) | custódia, liquidado, retido, livro razão, volume, reputação, população e preço médio | R2–R10 |
| controller · routes · swagger · `reports` (tipo `FINANCE`) | rotas e relatório | R1, R11 |

## Frontend

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/admin/finance/` (api, queries, types) | chamadas | R2–R10 |
| `components/FinanceCards/` · `LedgerModal/` | cards e livro razão no Dashboard | R2–R4, R6–R8 |
| colunas em `SellerRegistrationsTable`, lista do catálogo e lista de grupos | volume, reputação, população, preço médio e volume por grupo | R5, R9, R10 |

## Testes

| Critério | Onde |
|---|---|
| CA1–CA6 | `finance.service.spec.ts` |
| CA7, CA8 | integração |

## Decisões técnicas

- Valores trafegam em centavos inteiros (`amountCents`) e o frontend formata em reais.
