# Plano — CCD075 Visualizar Histórico de Preços

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L4 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

O perfil público da carta (CCD030) ganha o bloco "Histórico de preços": ele chama
`GET /api/v1/cards/:id/price-history?period=7d` ao abrir e de novo a cada troca de período (7 dias, 30 dias, 90 dias,
1 ano). O backend lê `price_history` com `source = SALE`, monta os pontos do gráfico e calcula mínimo, máximo, média e
variação do período. Sem vendas no período, o bloco mostra a mensagem de histórico indisponível.

## Dependências

- **CCD030**: a página `CardProfilePage` (frames `1112-4615` e `1112-5038`), que encaixa este bloco.
- **CCD097 / CCD007** (ADR-054): a tabela `price_history`, criada pela que entrar primeiro, com o seed das vendas.
- Gravar uma linha de `price_history` a cada venda concluída não é desta story (depende da L1; CCD110 se for na conclusão).

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `price_history` | da CCD097 / CCD007 | — | só leitura de `card_id`, `price`, `reference_date`, `source = SALE`, `deleted_at` (R2–R6) |
| `cards` | sim | — | carta existe e não está excluída (`404`) |

## Regras

- **Período** (R2, R5): `7d` (padrão), `30d`, `90d`, `1y`; de `hoje − período` até hoje, pelo `reference_date`, no fuso de
  `America/Sao_Paulo` (`src/shared/utils/time-zone.ts`).
- **Fonte** (R3): só `source = SALE`; `LISTING` não entra (depende da L1).
- **Pontos** (R2): um ponto por dia com a média das vendas do dia; em `1y`, um ponto por semana (depende da L3).
- **Valores** (R4): mínimo e máximo das vendas; média das vendas (não dos pontos); variação = (último ponto − primeiro
  ponto) / primeiro ponto, em %, com uma casa (depende da L3).
- **Sem dados** (R7): nenhuma venda no período → `stats: null` e `points: []`; a tela mostra a mensagem. O mínimo de vendas
  e se a regra vale por período dependem da L4 (aqui: por período, com pelo menos 1 venda).
- "Baseado em N vendas concluídas…" só entra com a L2.

## Contrato da API

### `GET /api/v1/cards/:id/price-history` — R1–R7

- **Acesso:** público
- **Entrada:** `period` = `7d` | `30d` | `90d` | `1y` (padrão `7d`)
- **Sucesso:** `200`

  ```json
  { "data": { "period": "7d", "points": [{ "date": "2026-11-16", "price": "1740.00" }],
    "stats": { "min": "1690.00", "max": "1810.00", "average": "1752.30", "variationPercent": "-3.1" } } }
  ```

- **Erros:**

  | Status | `error` | Quando | Requisito |
  |---|---|---|---|
  | 400 | `VALIDATION_ERROR` | `period` fora da lista ou id que não é uuid | R5 |
  | 404 | `CARD_NOT_FOUND` | carta inexistente ou excluída | R2 |

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/catalog/cards/price-history.validator.ts` | `period` e o id | R5 |
| `price-history.repository.ts` | vendas da carta no intervalo (`source = SALE`, `deleted_at` nulo) | R3 |
| `price-history.stats.ts` + `.spec.ts` | funções puras: agrupar em pontos, mínimo, máximo, média, variação | R2, R4, R6 |
| `price-history.service.ts` + `.spec.ts` | intervalo do período, `404`, resposta vazia | R2–R7 |
| `price-history.controller.ts` · `.routes.ts` · `.swagger.ts` | rota pública no módulo de catálogo | R1 |
| `database/seeds/` | vendas de exemplo em 7 dias e em 1 ano, registros `LISTING` e uma carta sem vendas | R3, R7 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/catalog/price-history.{types,api,queries,format,labels}.ts` | contrato, query por período (mantém o dado anterior enquanto carrega), formato de moeda e %, textos | R2, R4–R7 |
| `components/PriceHistory/` | título "Histórico de preços", seletor de períodos, gráfico e os quatro valores, frames `1112-4615` e `1112-5038`; sem dados, "Não há histórico de preços disponível para esta carta."; carregando e erro no estilo do bloco | R2, R4–R8 |
| `components/PriceHistory/PriceLineChart.tsx` | gráfico de linha em SVG, com os tokens de cor da tela | R2 |
| `pages/CardProfilePage/` (CCD030) | encaixa o bloco | R1 |

- **Componentes reaproveitados:** `PeriodFilter` (se o visual bater com o frame; senão `Tabs`), `LoadingState`,
  `ErrorState`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | sem login, 7 dias, valores só das vendas | `price-history.service.spec.ts` · `tests/integration/price-history.spec.ts` · `PriceHistory.spec.tsx` |
| CA2 | troca para 1 ano: período selecionado, pontos e valores do ano | `PriceHistory.spec.tsx` · integração |
| CA3 | `LISTING` não entra | `price-history.stats.spec.ts` · integração |
| CA4 | sem vendas: mensagem no lugar do gráfico e dos valores | service · `PriceHistory.spec.tsx` |
| CA5 | carregando e erro sem trocar o período por engano | `PriceHistory.spec.tsx` |
| CA6, CA7 | print em 1280 px igual aos frames `1112-4615` e `1112-5038`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Decisões técnicas

- O gráfico é um SVG feito na própria feature, sem biblioteca de gráficos: é uma linha só e evita uma dependência nova.
  Se o time preferir uma biblioteca, isso vira um ADR novo `Proposto`.
- Os cálculos ficam em funções puras (`price-history.stats.ts`), testadas sem banco.
