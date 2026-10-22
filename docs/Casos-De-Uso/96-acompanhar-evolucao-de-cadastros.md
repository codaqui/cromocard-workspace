| Nome do Caso de Uso | Acompanhar Evolução de Cadastros |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador acompanhe no Dashboard a evolução dos novos cadastros de colecionadores e de lojistas certificados ao longo do tempo e compare com a meta mensal. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado com permissão de administrador. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa o Dashboard Gerencial. |  |
|  | 2. O sistema apresenta o gráfico "Evolução: Novos Cadastros vs Lojistas Certificados", com uma linha para colecionadores e outra para lojistas certificados, e o total de cada um no período. |
|  | 3. O sistema apresenta o indicador de novos cadastros do mês com o percentual atingido da meta mensal e a meta projetada; cada indicador mostra a variação em relação ao período anterior ("novo" quando o anterior é zero). |
| 4. O administrador seleciona o período: Hoje, 7 dias, 30 dias ou 1 ano. |  |
|  | 5. O sistema atualiza o gráfico, agrupando os pontos por hora (Hoje), por dia (7 dias e 30 dias) ou por mês (1 ano). |
| 6. O administrador passa o cursor sobre um ponto do gráfico. |  |
|  | 7. O sistema mostra o valor daquele ponto. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador seleciona um período sem cadastros. |  |
|  | 2. O sistema informa que não há cadastros no período, em vez de mostrar o gráfico vazio. |
|  | 3. Nenhuma meta mensal está configurada. |
|  | 4. O sistema mostra o total de novos cadastros sem o percentual da meta. |
| 5. O administrador altera a meta mensal em Configurações Globais. |  |
|  | 6. O sistema passa a calcular o percentual com a meta nova. |
