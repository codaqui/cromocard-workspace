# CCD092 — Visualizar Total de Vendas

- **Status:** Rascunho
- **Fase:** MVP (sem marca nas user stories do Painel Vendedor)
- **User story:** #351 `CCD092-Visualizar Total de Vendas`
- **Caso de uso:** [92-visualizar-total-de-vendas.md](../../docs/Casos-De-Uso/92-visualizar-total-de-vendas.md)
- **Atores:** Vendedor · **Pré-condições:** autenticado como `SELLER`, no painel de métricas da conta (Visão geral do Painel do vendedor)
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Vendedor preciso visualizar o total de vendas para acompanhar a quantidade de negociações realizadas.

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
| R1 | Só `SELLER` vê o painel, e só as próprias vendas: `401` sem token, `403` para outro papel | Permissão | `92`, Atores e Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | A Visão geral do Painel do vendedor ("Visão geral" no grupo "Vendedor" do menu) é o painel de métricas | Tela | `92`, FP 1; `escopo-adicional.md`, menu lateral único (20/11/2026) |
| R3 | O sistema soma as vendas concluídas com sucesso do vendedor (L1) | Regra | `92`, FP 2; DBML `orders.seller_id`, `orders.status`, `orders.items_amount` |
| R4 | Cartão "Total de Vendas" com o total financeiro e a quantidade de vendas concluídas | Tela | `92`, FP 3 |
| R5 | Gráfico "Vendas e faturamento por dia" com o faturamento e o volume de vendas | Tela | `92`, FP 3 |
| R6 | Vendedor sem vendas vê as métricas zeradas, com um incentivo para fazer a primeira venda | Estado | `92`, FA 1 |
| R7 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames `492-2007`, `1112-9866`, `1112-10347`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2–R5) — **Dado** um vendedor com 3 vendas concluídas no período (R$ 100, R$ 200 e R$ 300) e uma venda de outro vendedor, **quando** abre a Visão geral, **então** o cartão "Total de Vendas" mostra R$ 600,00 e "3 vendas concluídas", e o gráfico mostra o faturamento e as unidades por dia dessas 3 vendas.
- **CA2** (R3) — **Dado** um pedido do vendedor `CANCELED` e um `AWAITING_PAYMENT`, **quando** ele abre a Visão geral, **então** nenhum dos dois entra no total (os demais status seguem a L1).
- **CA3** (R6) — **Dado** um vendedor com a conta pronta e sem vendas, **quando** abre a Visão geral, **então** vê "R$ 0,00", "0 vendas concluídas", o gráfico vazio e o incentivo à primeira venda (L5).
- **CA4** (R5) — **Dado** o gráfico, **quando** o vendedor alterna entre "Faturamento (R$)" e "Unidades Vendidas", **então** o gráfico troca de valor sem recarregar a página.
- **CA5** (R1) — **Dado** um visitante sem login, **quando** chama as métricas, **então** recebe `401`; **dado** um `CUSTOMER` ou `ADMIN`, recebe `403`.
- **CA6** (R4, R5) — **Dado** as métricas carregando, **quando** a Visão geral abre, **então** cartões e gráfico mostram o carregamento; se a API falhar, mostram o erro com a opção de tentar de novo.
- **CA7** (R7) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `492-2007` (Painel Vendedor), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA8** (R7) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1112-9866` (métricas zeradas, sem conta de recebimento), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA9** (R7) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1112-10347` (métricas zeradas, conta em verificação), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `orders` | `seller_id`, `status` (`order_status`), `items_amount`, `quantity`, `platform_fee`, `paid_at`, `delivered_at`, `released_at`, `created_at` | só leitura; status concluído conforme a L1; a data de referência do período conforme a L2 |
| `listings` | `seller_id`, `status`, `available_quantity` | só para o cartão "Anúncios Ativos", se a L3 decidir implementar |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Painel Vendedor (Visão geral) | [492-2007](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=492-2007) | R2–R5 | ❌ Não bate (L2–L4) |
| Painel Vendedor - conectar conta de recebimento (métricas zeradas) | [1112-9866](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-9866) | R6 | ❌ Não bate (L5) |
| Painel Vendedor - conta de recebimento em verificação (métricas zeradas) | [1112-10347](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-10347) | R6 | ❌ Não bate (L5) |
| Painel Vendedor - financeiro e extrato | [675-8493](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-8493) | — | Sem caso de uso (L6) |

- Visão geral: "Visão geral", "Suas vendas, seus anúncios e o valor a receber.", período "Hoje | Últimos 7 dias | Este Mês
  (Ativo) | 1 Ano | Personalizado" com "Intervalo: 01 Nov, 2026 - Hoje"; cartões "VOLUME FINANCEIRO / Total de Vendas" (com
  "+18.4%" e "38 vendas concluídas"), "LIQUIDAÇÃO / Liberado no mês" ("A liberar: …"), "INVENTÁRIO / Anúncios Ativos"
  ("14 pausados • 3 esgotados") e "TRÁFEGO DA LOJA / Visualizações" ("+24% no mês", "1.840 cliques"); gráfico "Vendas e
  faturamento por dia", "Vendas concluídas no período.", alternador "Faturamento (R$)" / "Unidades Vendidas", destaques
  "Melhor Dia do Mês", "Vendas Realizadas Hoje" e "Taxa de Liquidez" e o balão "Melhor dia".
- Métricas zeradas: "R$ 0,00", "0 vendas concluídas", "—" nos destaques, "0 unidades (R$ 0,00)" e as mensagens do gráfico
  "Nenhuma venda no período. Conecte sua conta Stripe para começar a vender." (`1112-9866`) e "Nenhuma venda no período. Os
  anúncios liberam assim que a Stripe confirmar a conta." (`1112-10347`).
- **Diferenças com o Figma** (decisão em Lacunas e decisões): o incentivo à primeira venda (`92`, FA 1) só existe para quem
  ainda não tem a conta pronta; o vendedor pronto e sem vendas não tem frame (L5).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): filtro de período e "Intervalo" (L2); variação
  "+18.4%", "Melhor Dia do Mês", "Vendas Realizadas Hoje", "Taxa de Liquidez" e o balão "Melhor dia" (L4); cartões
  "Liberado no mês", "Anúncios Ativos" e "Visualizações" (L3); "Sincronizado há 2 min", "Exportar Fiscal/CSV" e "Ver Loja
  Pública" (L7); a tela "Financeiro e extrato" (L6).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R6 a Visão geral zerada do vendedor com conta pronta
  e o incentivo à primeira venda.

## Fora do escopo

- Ranking "Cartas mais vendidas" da mesma tela — CCD093.
- Avisos de conta de recebimento ("Conecte sua conta…", "Estamos verificando…") — CCD108.
- "Criar Novo Anúncio" — CCD084; menu do vendedor (Meus anúncios, Pedidos e envios) — CCD085 e CCD109.
- Indicadores financeiros da plataforma no BackOffice — CCD097 e CCD111.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O que é "transação concluída com sucesso" e qual valor somar? Só `COMPLETED` (pagamento liberado) ou também `PAID`, `SHIPPED` e `DELIVERED`? Valor da carta (`items_amount`) ou líquido? (proposta: pedidos pagos e não cancelados — `PAID`, `SHIPPED`, `DELIVERED`, `COMPLETED` —, somando `items_amount`; "vendas concluídas" conta esses pedidos) | pendente | — |
| L2 | O filtro de período (Hoje, Últimos 7 dias, Este Mês, 1 Ano, Personalizado) só existe no Figma. Faz sentido implementar? E por qual data filtrar? (proposta: sim, com "Este Mês" como padrão e a data `paid_at`); o rótulo "Este Mês (Ativo)" leva mesmo "(Ativo)"? (proposta: não, é anotação do estado selecionado) | pendente | — |
| L3 | Cartões "Liberado no mês"/"A liberar", "Anúncios Ativos" ("pausados • esgotados") e "Visualizações"/"cliques" só existem no Figma; visualizações e cliques não têm dado no DBML. Faz sentido implementar? (proposta: sim para "Liberado no mês" e "Anúncios Ativos"; "Visualizações" sai do frame) | pendente | — |
| L4 | Variação "+18.4%", "Melhor Dia do Mês", "Vendas Realizadas Hoje", "Taxa de Liquidez" ("91.4% em < 5 dias") e o balão "Melhor dia" só existem no Figma. Faz sentido implementar? O que é a taxa de liquidez? (proposta: sim para a variação contra o período anterior, melhor dia e vendas de hoje; a taxa de liquidez sai) | pendente | — |
| L5 | Texto do incentivo à primeira venda para o vendedor com conta pronta e sem vendas (proposta: "Nenhuma venda no período. Crie seu primeiro anúncio para começar a vender." com "Criar Novo Anúncio"; o Gabriel desenha o estado) | pendente | — |
| L6 | A tela "Financeiro e extrato" (`675-8493`: "Liberado no mês", "Em custódia", "Vendas no mês", "Taxas da plataforma" e o "Extrato de movimentações" com Tudo, Vendas, Repasses e Taxas) não tem caso de uso. Entra nesta user story, vira caso de uso novo ou fica fora? (proposta: caso de uso novo, fora desta spec) | pendente | — |
| L7 | "Sincronizado há 2 min", "Exportar Fiscal/CSV" e "Ver Loja Pública" só existem no Figma. Faz sentido implementar? (proposta: "Ver Loja Pública" leva ao perfil público `1160-1396`; os outros dois saem do frame) | pendente | — |
