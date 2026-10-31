| Nome do Caso de Uso | Visualizar Mensagens |
|---|---|
| Finalidade/Objetivo | Permitir que o usuário visualize suas conversas e mensagens recebidas e enviadas na plataforma. |
| Atores | Cliente |
| Pré Condições | O usuário deve estar autenticado e possuir acesso à área de mensagens. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário acessa a área de mensagens. |  |
|  | 2. O sistema apresenta a lista de conversas disponíveis para o usuário. |
| 3. O usuário seleciona uma conversa. |  |
|  | 4. O sistema carrega e exibe as mensagens da conversa selecionada, organizadas cronologicamente. |
|  | 5. O sistema identifica visualmente as mensagens ainda não lidas. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
|  | 1. Caso o usuário não possua nenhuma conversa, o sistema exibe a mensagem "Nenhuma conversa encontrada". |
|  | 2. Caso ocorra uma falha no carregamento, o sistema informa que não foi possível carregar as mensagens. |
