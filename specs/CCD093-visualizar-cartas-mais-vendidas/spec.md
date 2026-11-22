# CCD093 — Visualizar Cartas Mais Vendidas

- **Status:** Rascunho
- **Fase:** MVP (sem marca nas user stories do Painel Vendedor)
- **User story:** #352 `CCD093-Visualizar Cartas Mais Vendidas`
- **Caso de uso:** [93-visualizar-cartas-mais-vendidas.md](../../docs/Casos-De-Uso/93-visualizar-cartas-mais-vendidas.md)
- **Atores:** Vendedor · **Pré-condições:** autenticado como `SELLER`, no painel de métricas da conta (Visão geral do Painel do vendedor)
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Vendedor preciso visualizar as cartas mais vendidas para identificar quais produtos possuem maior procura.

## Fidelidade ao Figma (obrigatória)

> ⚠️ **A tela implementada tem que ficar IGUAL ao Figma.** Os frames listados em **Telas (Figma)** são o contrato visual
> desta user story: não são referência, sugestão nem inspiração. Layout, ordem dos blocos, medidas, espaçamentos,
> alinhamentos, cores, tipografia (fonte, peso, tamanho e altura de linha), raios, bordas, sombras, ícones, imagens, textos
> (letra por letra) e estados (vazio, erro, carregando, hover, foco, desabilitado) seguem o frame. Medidas e cores saem do
> Figma, nunca "a olho".
>
> - Nada é inventado, trocado ou "melhorado" fora do frame. Diferença entre o Figma e a documentação vira lacuna em
>   **Lacunas e decisões** e é decidida antes do código (ADR-060). Até a decisão, vale a documentação.
> - O que o Figma não desenha (R marcado em "O que falta no Figma") segue o estilo da própria tela: os mesmos componentes,
>   tokens e espaçamentos.
> - A tela só está pronta quando o print dela em 1280 px, lado a lado com o print do frame, não mostra diferença. Em
>   celular (375 px), tablet (768 px) e laptop (1024 px), mantém o mesmo design adaptado, sem quebra, corte nem rolagem
>   horizontal.
> - A revisão (`/cromocard-revisor`) reprova o PR que não estiver igual ao Figma.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `SELLER` vê o ranking, e só das próprias vendas: `401` sem token, `403` para outro papel | Permissão | `93`, Atores e Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | O ranking "Cartas mais vendidas" fica no painel de métricas do vendedor (Visão geral) | Tela | `93`, FP 1; Figma `492-2007` (L1) |
| R3 | O sistema agrupa o histórico de vendas do vendedor por carta e ordena das cartas de maior saída para as de menor | Regra | `93`, FP 2; DBML `orders`, `listings.card_id` |
| R4 | O ranking é uma lista com a posição, a carta e o volume vendido de cada uma | Tela | `93`, FP 3 |
| R5 | O ranking respeita o período selecionado | Regra | `93`, FA 1 |
| R6 | Sem dados no período, o sistema mostra "Não há dados suficientes para formar o ranking no período escolhido" | Estado | `93`, FA 1 |
| R7 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames `492-2007`, `1112-9866`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2–R4) — **Dado** um vendedor com 15 unidades vendidas de Suicune, 8 de Charizard e 6 de Messi no período, **quando** abre a Visão geral, **então** "Cartas mais vendidas" lista Suicune em 1º, Charizard em 2º e Messi em 3º, com "15 vendidas", "8 vendidas" e "6 vendidas" (ordem conforme a L2).
- **CA2** (R3) — **Dado** vendas de outro vendedor e pedidos cancelados, **quando** o vendedor abre o ranking, **então** nenhum deles entra na contagem.
- **CA3** (R5) — **Dado** vendas de Charizard só no mês passado, **quando** o vendedor seleciona "Este Mês", **então** Charizard não aparece no ranking; com "1 Ano", aparece.
- **CA4** (R6) — **Dado** um período sem vendas, **quando** o vendedor abre o ranking, **então** vê "Não há dados suficientes para formar o ranking no período escolhido" (texto conforme a L3).
- **CA5** (R1) — **Dado** um visitante sem login, **quando** chama o ranking, **então** recebe `401`; **dado** um `CUSTOMER` ou `ADMIN`, recebe `403`.
- **CA6** (R4) — **Dado** o ranking carregando, **quando** a Visão geral abre, **então** a tabela mostra o carregamento; se a API falhar, mostra o erro com a opção de tentar de novo.
- **CA7** (R7) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `492-2007` (bloco "Cartas mais vendidas"), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA8** (R7) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1112-9866` (ranking vazio), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `orders` | `seller_id`, `listing_id`, `status` (`order_status`), `quantity`, `items_amount`, `paid_at` | só leitura; quais status contam, como na CCD092 (L1 de lá) |
| `listings` | `card_id`, `condition_id` | carta e condição da venda |
| `cards` | `name`, `number`, `album_id`, `front_image_url` | nome, número e miniatura |
| `albums` | `name` | subtítulo da carta (coleção) |
| `card_conditions` | `name` | coluna "Condição" (L4) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Painel Vendedor (bloco "Cartas mais vendidas") | [492-2007](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=492-2007) | R2–R5 | ❌ Não bate (L1, L2, L4, L5) |
| Painel Vendedor - ranking vazio (sem conta de recebimento) | [1112-9866](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-9866) | R6 | ❌ Não bate (L3) |

- Bloco: "Cartas mais vendidas" com troféu, "As cartas que mais venderam no período.", "Ordenar por:" "Volume Total (R$)",
  colunas "CLASSIFICAÇÃO & CARTA", "CONDIÇÃO", "VENDAS REALIZADAS", "PREÇO MÉDIO" e "FATURAMENTO TOTAL"; cada linha tem a
  posição, a miniatura, o nome e o número da carta, a coleção, o selo de condição, "<n> vendidas", o preço médio e o
  faturamento. O frame mostra 3 linhas. Vazio: "Nenhuma carta vendida ainda." (o mesmo texto aparece em `1112-10347`).
- **Diferenças com o Figma** (decisão em Lacunas e decisões): o caso de uso fala em "relatório de 'Cartas Mais Vendidas'";
  o Figma é um bloco da Visão geral (L1). Ordem: o caso de uso ordena por maior saída (volume); o Figma ordena por "Volume
  Total (R$)", o faturamento (L2). Vazio: o caso de uso pede "Não há dados suficientes para formar o ranking no período
  escolhido"; o Figma mostra "Nenhuma carta vendida ainda." (L3).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): colunas "Condição", "Preço médio" e
  "Faturamento total" (L4); seletor "Ordenar por:" (L2); limite de 3 linhas (L5).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R6 o ranking vazio de um vendedor com conta pronta
  num período sem vendas.

## Fora do escopo

- Cartão "Total de Vendas", gráfico, filtro de período e demais métricas da Visão geral — CCD092 (o ranking usa o período
  escolhido lá).
- Avisos de conta de recebimento — CCD108.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O ranking é um relatório próprio (`93`, FP 1) ou o bloco da Visão geral (Figma)? (proposta: o bloco da Visão geral; ajustar o FP 1) | pendente | — |
| L2 | Ordem padrão: unidades vendidas (`93`, FP 2) ou "Volume Total (R$)" (Figma)? Que opções o "Ordenar por:" tem? (proposta: duas opções, "Unidades vendidas" e "Volume Total (R$)", começando por unidades, como no caso de uso) | pendente | — |
| L3 | Texto do vazio: "Não há dados suficientes para formar o ranking no período escolhido" (caso de uso) ou "Nenhuma carta vendida ainda." (Figma)? (proposta: o do caso de uso quando há vendas fora do período; o do Figma quando o vendedor nunca vendeu) | pendente | — |
| L4 | Colunas "Condição", "Preço médio" e "Faturamento total" só existem no Figma, e a condição na linha faz o ranking agrupar por carta e condição. Faz sentido implementar? (proposta: sim; agrupar por carta, com a condição mais vendida no selo) | pendente | — |
| L5 | Quantas cartas o ranking mostra? O frame mostra 3 (proposta: as 5 primeiras) | pendente | — |
