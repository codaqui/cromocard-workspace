| Nome do Caso de Uso | Visualizar Resumo da Coleção |
|---|---|
| Finalidade/Objetivo | Permitir que o usuário visualize dados quantitativos e consolidados de sua coleção geral na Dashboard. |
| Atores | Cliente |
| Pré Condições | O usuário deve estar autenticado ('logado') no sistema e na tela de Dashboard. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário acessa o Painel Cliente (Dashboard). |  |
|  | 2. O sistema consulta o banco de dados e calcula o total de álbuns ativos, o percentual médio de completude e os contadores de cartas: total de cartas dos álbuns ativos, cartas que possui, cartas faltantes e cartas repetidas. |
|  | 3. O sistema apresenta os indicadores consolidados em formato de cards visuais na tela. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
|  | 1. Caso o usuário não possua nenhum item cadastrado, o sistema exibe os contadores zerados com um botão de atalho para 'Adicionar Primeiro Álbum'. |
