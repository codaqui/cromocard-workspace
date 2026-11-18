| Nome do Caso de Uso | Visualizar Histórico de Preços |
|---|---|
| Finalidade/Objetivo | Como Cliente preciso visualizar o histórico de preços de uma carta para acompanhar sua variação de valor ao longo do tempo. |
| Atores | Visitante, Cliente |
| Pré Condições | O ator deve estar no perfil da carta (Visualizar Detalhes). |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O ator acessa o perfil da carta. |  |
|  | 2. O sistema exibe o gráfico do histórico de preços dos últimos 7 dias, calculado a partir das vendas concluídas na CromoCard, com o mínimo, o máximo, a média e a variação do período. |
| 3. O ator escolhe outro período: 7 dias, 30 dias, 90 dias ou 1 ano. |  |
|  | 4. O sistema atualiza o gráfico e os valores para o período escolhido. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
|  | 1. Caso não existam dados históricos suficientes, o sistema informa: “Não há histórico de preços disponível para esta carta.” |
