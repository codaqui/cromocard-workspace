# CCD075 — Visualizar Histórico de Preços

- **Status:** Rascunho
- **Fase:** MVP (fatia mínima do marketplace, ADR-027)
- **User story:** não encontrada no board
- **Caso de uso:** [75-visualizar-historico-de-precos.md](../../docs/Casos-De-Uso/75-visualizar-historico-de-precos.md)
- **Atores:** Visitante, Cliente · **Pré-condições:** no perfil da carta (Visualizar Detalhes, CCD030)
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso visualizar o histórico de preços para acompanhar a variação do valor da carta.

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
| R1 | O histórico de preços é público: visitante e cliente veem sem login | Permissão | `75`, Atores e Pré-condições; `30`, Pré-condições |
| R2 | O perfil da carta mostra o gráfico do histórico de preços, com os últimos 7 dias ao abrir | Tela | `75`, FP 1–2 |
| R3 | O histórico é calculado a partir das vendas concluídas na CromoCard (`price_history` com `source = SALE`); preços de anúncio não entram | Regra | `75`, FP 2; DBML `price_history`, `price_source` (L1) |
| R4 | Junto do gráfico, o mínimo, o máximo, a média e a variação do período | Campo | `75`, FP 2 (L3) |
| R5 | O ator escolhe o período: 7 dias, 30 dias, 90 dias ou 1 ano | Ação | `75`, FP 3 |
| R6 | Trocar o período atualiza o gráfico e os quatro valores | Regra | `75`, FP 4 |
| R7 | Sem dados suficientes, o bloco mostra "Não há histórico de preços disponível para esta carta." | Mensagem | `75`, FA 1 (L4) |
| R8 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R1–R4) — **Dado** uma carta com vendas concluídas nos últimos 7 dias e um visitante sem login, **quando** ele abre o perfil da carta, **então** vê o gráfico dos últimos 7 dias com "7 dias" selecionado e o mínimo, o máximo, a média e a variação calculados só dessas vendas.
- **CA2** (R5, R6) — **Dado** o perfil aberto em 7 dias, **quando** o ator seleciona "1 ano", **então** "1 ano" fica selecionado e o gráfico e os quatro valores passam a ser os do último ano.
- **CA3** (R3) — **Dado** uma carta com registros `source = LISTING` e `source = SALE`, **quando** o histórico é calculado, **então** só os de `SALE` entram.
- **CA4** (R7) — **Dado** uma carta sem vendas concluídas, **quando** o perfil abre, **então** o bloco mostra "Não há histórico de preços disponível para esta carta." no lugar do gráfico e dos valores.
- **CA5** (R6) — **Dado** a troca de período, **quando** a resposta ainda não chegou ou falhou, **então** o bloco mostra o carregamento ou um aviso de erro no estilo da tela, sem apagar o período anterior por engano.
- **CA6** (R8) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1112-4615`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA7** (R8) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1112-5038`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `price_history` | `card_id`, `price`, `reference_date`, `source` (`price_source`: `SALE`, `LISTING`) | todas obrigatórias; tabela de histórico, nunca excluída (ADR-015, item 4); já existe no banco, com seed (ADR-054) |
| `orders` | `listing_id`, `status`, `items_amount` | só se o histórico for calculado direto das vendas (L1) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Público — Perfil da carta (7 dias) | [1112-4615](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-4615) | R2–R5 | ⚠️ Bate; "Baseado em N vendas…" só no Figma (L2) |
| Público — Perfil da carta — 1 ano | [1112-5038](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-5038) | R5, R6 | ⚠️ Igual ao anterior |

- Textos: "Histórico de preços", "7 dias", "30 dias", "90 dias", "1 ano", "Baseado em 9 vendas concluídas na CromoCard no período", "Mínimo", "Máximo", "Média", "Variação".
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): a linha "Baseado em N vendas concluídas na CromoCard no período" (L2).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R7 o bloco sem histórico; o carregamento ao trocar de período (CA5).

## Fora do escopo

- Preço médio de mercado, menor anúncio, quantidade de anúncios e o restante do perfil da carta — CCD030 e CCD031.
- Lista "Anúncios disponíveis" — CCD030 (ordenação: CCD068 e CCD069).
- Alerta de preço — fase Futuro.
- Gravar o histórico quando uma venda é concluída — depende da L1 (CCD110, se for gravado na conclusão).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Como `price_history` é alimentado: uma linha por venda concluída (gravada quando o pedido é concluído, CCD110) ou um snapshot diário (ADR-010, "Snapshot diário de price_history")? E "venda concluída" é o pedido `COMPLETED` ou também `DELIVERED`? | pendente | — |
| L2 | "Baseado em 9 vendas concluídas na CromoCard no período" (só no Figma). Faz sentido implementar? Com snapshot diário (L1) não dá para contar as vendas | pendente | — |
| L3 | Fórmulas: a variação compara o primeiro e o último preço do período, em %? A média é das vendas ou dos pontos do gráfico? Em 1 ano, o gráfico mostra um ponto por dia ou por semana? | pendente | — |
| L4 | O que é "dados insuficientes" (quantas vendas no mínimo)? A mensagem vale por período (sem vendas em 7 dias, mas com vendas em 1 ano) ou só quando a carta nunca teve venda? | pendente | — |
