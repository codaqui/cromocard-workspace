| Nome do Caso de Uso | Visualizar Notificações |
|---|---|
| Finalidade/Objetivo | Permitir que o usuário visualize as notificações relacionadas às atividades e interações ocorridas na plataforma. |
| Atores | Cliente |
| Pré Condições | O usuário deve estar autenticado e possuir acesso à central de notificações. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário acessa a central de notificações. |  |
|  | 2. O sistema consulta as notificações vinculadas à conta do usuário. |
|  | 3. O sistema apresenta as notificações em ordem cronológica. |
| 4. O usuário seleciona uma notificação. |  |
|  | 5. O sistema direciona o usuário para o conteúdo relacionado à notificação, quando aplicável. |
|  | 6. O sistema atualiza o status da notificação para "lida". |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
|  | 1. Caso não existam notificações, o sistema exibe a mensagem "Nenhuma notificação encontrada". |
|  | 2. Caso o conteúdo relacionado não esteja mais disponível, o sistema informa que o conteúdo não pode ser acessado. |
