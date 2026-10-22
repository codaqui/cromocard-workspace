# CCD096 — Acompanhar Evolução de Cadastros

- **Status:** Planejada
- **Fase:** Escopo Adicional
- **User story:** #600 `CCD096-Acompanhar Evolução de Cadastros` · responsável Lucca Rocha · Sprint 06
- **Caso de uso:** [96-acompanhar-evolucao-de-cadastros.md](../../docs/Casos-De-Uso/96-acompanhar-evolucao-de-cadastros.md) · índice: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO)

## Objetivo

> Como Administrador eu quero ver no Dashboard um gráfico dos novos cadastros de colecionadores e de lojistas certificados por período, comparado com a meta mensal, para acompanhar o crescimento da plataforma.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401` sem token, `403` para outro papel | Permissão | `96`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | Gráfico com uma linha de colecionadores (`CUSTOMER` cadastrados) e outra de lojistas certificados (`seller_verifications` aprovados), e o total de cada um no período | Tela | `96`, FP 2; ADR-052, item 5 |
| R3 | Indicador de novos cadastros do mês com o percentual da meta e a meta projetada | Campo | `96`, FP 3 |
| R4 | Pontos agrupados por hora (Hoje), por dia (7 e 30 dias) ou por mês (1 ano) | Regra | `96`, FP 4–5 |
| R5 | Passar o cursor mostra o valor do ponto | Tela | `96`, FP 6–7 |
| R6 | Período sem cadastros mostra a mensagem em vez do gráfico vazio | Estado | `96`, FA 1–2 |
| R7 | Sem meta configurada, mostra o total sem o percentual | Estado | `96`, FA 3–4 |
| R8 | A meta mensal é lida de `global_settings` (`dashboard.monthly_signup_goal`) | Regra | `96`, FP 3; ADR-051, item 1 |
| R9 | Cada indicador mostra a variação em relação ao período anterior | Campo | EA-058-02 |
| R10 | Total de usuários separado em colecionadores e lojistas | Campo | EA-058-03 |
| R11 | Novas cartas cadastradas na semana, no card do acervo | Campo | EA-058-04 |

## Critérios de aceite

- **CA1** (R2, R4) — **Dado** cadastros nos últimos 7 dias, **quando** o admin seleciona 7 dias, **então** o gráfico mostra um ponto por dia para colecionadores e para lojistas certificados.
- **CA2** (R4) — **Dado** o período Hoje, **quando** o admin seleciona Hoje, **então** os pontos são por hora.
- **CA3** (R3) — **Dado** meta de 4.000 e 4.218 cadastros no mês, **quando** o admin abre o Dashboard, **então** o indicador mostra 105% da meta.
- **CA4** (R7) — **Dado** nenhuma meta configurada, **quando** o admin abre o Dashboard, **então** o indicador mostra o total sem percentual.
- **CA5** (R6) — **Dado** nenhum cadastro no período, **quando** o admin seleciona o período, **então** a tela mostra a mensagem de sem cadastros.
- **CA6** (R9–R11) — **Dado** 100 usuários no período atual e 80 no anterior, **quando** o admin abre o Dashboard, **então** o total mostra +25% e a divisão entre colecionadores e lojistas.
- **CA7** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama uma das rotas, **então** recebe `403`.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `users` | `role`, `created_at` | MVP |
| `seller_verifications` | `status`, `reviewed_at` | da CCD094 |
| `cards` | `created_at` | MVP |
| `global_settings` | `dashboard.monthly_signup_goal` | chave nova, criada pelo seed |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Dashboard geral | [208-1240](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=208-1240) | R2, R3, R9–R11 | ⚠️ Divergente |
| Dashboard — filtro Hoje | [247-3539](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=247-3539) | R4 | ✅ Bate |
| Dashboard — filtro 7 dias | [247-2499](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=247-2499) | R4 | ✅ Bate |

- Os rótulos de eventos no eixo (ex.: "Feira BGC") não têm origem de dado e não entram.

## Fora do escopo

- Indicadores financeiros — CCD097.
- Card de credenciamento — CCD094.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Onde a meta é definida? (proposta: um campo a mais na tela de Configurações da CCD066) | Um campo a mais na tela de Configurações da CCD066 | `96`, FA 5–6 |
| L2 | Variação quando o período anterior é zero (proposta: mostrar "novo" em vez do percentual) | Mostrar "novo" em vez do percentual | `96`, FP 3 |
