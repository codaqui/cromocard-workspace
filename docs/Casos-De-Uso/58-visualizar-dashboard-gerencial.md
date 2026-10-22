| Nome do Caso de Uso | Visualizar Dashboard Gerencial |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador visualize informações gerenciais na plataforma, facilitando o acompanhamento dos principais indicadores e dados do sistema |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado e possuir permissão para acessar o dashboard gerencial. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa a opção "Dashboard Gerencial". |  |
|  | 2. O sistema carrega os dados gerenciais disponíveis, considerando só registros não excluídos. |
|  | 3. O sistema apresenta os indicadores: total de usuários (todos os papéis, menos administradores), cartas do catálogo e novos cadastros no período; o gráfico da evolução dos novos cadastros; e a lista dos cadastros de vendedores recentes, com a opção "Ver informações", que abre o usuário na Gestão de Usuários. |
| 4. O administrador visualiza os indicadores apresentados. |  |
| 5. O administrador seleciona um período (Hoje, 7 dias, 30 dias ou 1 ano) ou um intervalo de datas. O padrão é 30 dias. |  |
|  | 6. O sistema processa o filtro selecionado, cortando os dias pelo horário de Brasília. |
|  | 7. O sistema atualiza os indicadores e informações conforme os filtros aplicados. |
| 8. O administrador consulta os dados apresentados no dashboard. |  |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa o dashboard e não existem dados disponíveis. |  |
|  | 2. O sistema informa que não existem dados para apresentação. |
| 3. O administrador seleciona um período ou filtro sem informações disponíveis. |  |
|  | 4. O sistema informa que não foram encontrados dados para os filtros selecionados. |
| 5. O administrador altera os filtros de consulta. |  |
|  | 6. O sistema atualiza o dashboard com os dados correspondentes aos novos filtros. |
