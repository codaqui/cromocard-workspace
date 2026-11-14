| Nome do Caso de Uso | Disparar Notificação Global |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador envie uma notificação para todos os usuários da plataforma. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado e possuir permissão para enviar notificações globais. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa a opção "Notificação Global". |  |
|  | 2. O sistema apresenta a tela para criação da notificação, com a pré-visualização de como ela aparece na central de notificações, e o histórico paginado dos disparos, dos mais recentes para os mais antigos, com data e horário, título, público, canal e status. |
| 3. O administrador informa o título (até 120 caracteres), o conteúdo (até 500 caracteres) e, opcionalmente, o link de destino da notificação. |  |
|  | 4. O sistema valida as informações preenchidas. |
| 5. O administrador confirma o envio da notificação. |  |
|  | 6. O sistema envia a notificação, dentro da plataforma (central de notificações), para todos os usuários não excluídos e não suspensos, menos o próprio administrador. |
|  | 7. O sistema registra o disparo da notificação. |
|  | 8. O sistema informa ao administrador que a notificação foi enviada com sucesso, com o título, o público, os canais e a quantidade de destinatários, e oferece "Ver histórico de disparos" e "Voltar à central". |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador tenta enviar uma notificação sem preencher os campos obrigatórios. |  |
|  | 2. O sistema informa quais campos precisam ser preenchidos. |
| 3. O administrador corrige as informações. |  |
|  | 4. O sistema permite o envio após a validação. |
| 5. O administrador seleciona "Cancelar", ao lado do envio. |  |
|  | 6. O sistema limpa o formulário sem enviar a notificação. |
