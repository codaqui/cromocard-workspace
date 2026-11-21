# CCD096 — Acompanhar Evolução de Cadastros

- **Status:** Em implementação
- **Fase:** Escopo Adicional
- **User story:** #600 `CCD096-Acompanhar Evolução de Cadastros` · responsável Lucca Rocha · Sprint 06
- **Caso de uso:** [96-acompanhar-evolucao-de-cadastros.md](../../docs/Casos-De-Uso/96-acompanhar-evolucao-de-cadastros.md) · índice: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO); reaprovada em 2026-11-12, depois da revisão do Figma do painel admin; decisões L4–L6 propostas em 2026-11-17 por Lucca Rocha e validadas em 2026-11-20 por Felipe Consulim (PO)

## Objetivo

> Como Administrador eu quero ver no Dashboard um gráfico dos novos cadastros de colecionadores e de lojistas certificados por período, comparado com a meta mensal, para acompanhar o crescimento da plataforma.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401` sem token, `403` para outro papel | Permissão | `96`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | Gráfico com uma linha de colecionadores (`CUSTOMER` cadastrados) e outra de lojistas certificados (`seller_verifications` aprovados), e o total de cada um no período | Tela | `96`, FP 2; ADR-052, item 5 |
| R3 | Indicador de novos cadastros do período; no filtro de 30 dias, também o percentual da meta mensal e a meta projetada | Campo | `96`, FP 3 (L3) |
| R4 | Pontos agrupados por hora (Hoje), por dia (7 e 30 dias) ou por mês (1 ano) | Regra | `96`, FP 4–5 |
| R5 | Passar o cursor mostra o valor do ponto | Tela | `96`, FP 6–7 |
| R6 | Período sem cadastros mostra a mensagem em vez do gráfico vazio | Estado | `96`, FA 1–2 |
| R7 | Sem meta configurada, mostra o total sem o percentual | Estado | `96`, FA 3–4 |
| R8 | A meta mensal é lida de `global_settings` (`dashboard.monthly_signup_goal`) | Regra | `96`, FP 3; ADR-051, item 1 |
| R9 | O indicador de usuários mostra a variação dos cadastros em relação ao período anterior (L4) | Campo | `96`, FP 3; EA-058-02 |
| R10 | Total de usuários separado em colecionadores e lojistas | Campo | EA-058-03 |
| R11 | Novas cartas cadastradas na semana, no card do acervo | Campo | EA-058-04 |

## Critérios de aceite

- **CA1** (R2, R4) — **Dado** cadastros nos últimos 7 dias, **quando** o admin seleciona 7 dias, **então** o gráfico mostra um ponto por dia para colecionadores e para lojistas certificados.
- **CA2** (R4) — **Dado** o período Hoje, **quando** o admin seleciona Hoje, **então** os pontos são por hora.
- **CA3** (R3) — **Dado** meta de 4.000 e 4.218 cadastros nos últimos 30 dias, **quando** o admin abre o Dashboard, **então** o indicador mostra +4.218 e 105% da meta.
- **CA8** (R3) — **Dado** 1.120 cadastros nos últimos 7 dias, **quando** o admin seleciona 7 dias, **então** o indicador mostra +1.120, sem o percentual da meta.
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

Conferidas em 11/11/2026, depois do ajuste do Figma à documentação. Links: `https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=<frame>`.

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Dashboard geral (30 dias) | `208-1240` | R2, R3, R4, R9–R11 | ✅ Bate |
| Dashboard - filtro de 7 dias | `247-2499` | R3, R4, R5 | ✅ Bate |
| Dashboard - filtro Hoje | `247-3539` | R3, R4, R5 | ✅ Bate |
| Dashboard - meta não configurada | `795-2234` | R7 | ✅ Bate |
| Dashboard - filtro sem dados | `795-1704` | R6 | ✅ Bate |

- Os balões do gráfico mostram a quantidade de cadastros do ponto (R5), por exemplo "212 novos cadastros".

Conferidas de novo em 17/11/2026 (Playwright, 1440 px), antes da implementação:

- **Total de usuários** — "usuários", descrição "Clientes e vendedores, sem administradores e sem contas excluídas.",
  selo de variação (ex.: "+12.4%"; "0%" quando os dois períodos são zero) e rodapé Colecionadores | Lojistas (L5).
- **Cartas no catálogo** — "cartas" e "+3.120 novas cartas esta semana", sem rodapé (L5).
- **Novos cadastros** — "+4.218" com a minilinha; texto por período: "Meta mensal de 4.000 cadastros superada." (30
  dias, com o selo "105% da Meta"), "Meta mensal não configurada." (30 dias, sem meta), "Novos cadastros hoje.",
  "Novos cadastros nos últimos 7 dias." e "Nenhum cadastro no período." (L3, L5).
- **Gráfico** — subtítulo por período ("Novos cadastros por hora hoje.", "… por dia nos últimos 7 dias.", "… por dia
  nos últimos 30 dias.", "… por dia no período selecionado."), legenda com o total de cada linha ("Colecionadores
  (+4.070)", "Lojistas (+148)"), colecionadores em linha cheia com área e lojistas em linha tracejada; eixo com
  "00h … Agora (23h)" (Hoje), "Qui (05/11) … Qua (Hoje)" (7 dias) e "13/10 … 11/11 (HOJE)" (30 dias).
- **Sem dados** — o card do gráfico continua na tela, com a legenda "+0" e "Não há cadastros no período." no lugar
  das linhas (R6).
- Fora desta story: o card "Lojistas & Credenciamento" e a tabela de vendedores com CNPJ e status (CCD094) e o card
  "Valor em custódia" (CCD097). Até lá, o 4º card (Novos vendedores) e o painel "Composição dos cadastros" da CCD058
  continuam.

## Fora do escopo

- Indicadores financeiros — CCD097.
- Card de credenciamento — CCD094.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Onde a meta é definida? (proposta: um campo a mais na tela de Configurações da CCD066) | Um campo a mais na tela de Configurações da CCD066; desenhado no módulo 4 "Metas" de `228-3048` em 12/11/2026 | `96`, FA 5–6 |
| L2 | Variação quando o período anterior é zero (proposta: mostrar "novo" em vez do percentual) | Mostrar "novo" em vez do percentual | `96`, FP 3 |
| L3 | "Novos cadastros (mês)" ou "no período"? | O número segue o período; o percentual da meta mensal aparece só no filtro de 30 dias. Decisão do PO (Daniel, 11/11/2026), na revisão do Figma | `96`, FP 3 |
| L4 | O R9 diz "cada indicador", mas o Figma só tem o selo de variação no Total de usuários | Só o Total de usuários mostra a variação, com a regra do CA6 (cadastros do período contra os do período anterior, de mesmo tamanho); "0%" quando os dois são zero. Validada pelo PO (Felipe Consulim, 20/11/2026) | `96`, FP 3; `escopo-adicional.md`, EA-058-02 |
| L5 | Os cards da CCD058 mudam de texto e de rodapé no Figma | Total de usuários, Cartas no catálogo e Novos cadastros seguem o Figma (textos e rodapés acima); o 4º card só muda com a CCD094. Validada pelo PO (Felipe Consulim, 20/11/2026) | `96`, FP 3; Telas desta spec |
| L6 | O seed não tem cadastro de vendedor aprovado, e a linha de lojistas fica zerada no ambiente local | Usa o seed de `seller_verifications` da [CCD094](../CCD094-validar-cadastro-de-vendedor/spec.md), já mesclado, que traz um cadastro aprovado; esta story não cria seed próprio, para não duplicar o cadastro do mesmo vendedor. Validada pelo PO (Felipe Consulim, 20/11/2026) | plano |
