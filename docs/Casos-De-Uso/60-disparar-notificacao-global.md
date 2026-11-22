| Nome do Caso de Uso | Disparar Notificação Global |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador envie uma notificação para todos os usuários da plataforma. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado e possuir permissão para enviar notificações globais. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa a opção "Notificação Global". |  |
|  | 2. O sistema apresenta a tela para criação da notificação, com a pré-visualização de como ela aparece na central de notificações (com o ícone do CromoCard no lugar da imagem), e o histórico paginado dos disparos, dos mais recentes para os mais antigos, com data e horário, título, público, canal e status. |
| 3. O administrador informa o título (até 120 caracteres), o conteúdo (até 500 caracteres) e, opcionalmente, o link de destino da notificação: um caminho do site começando com "/" ou um endereço http(s), com até 255 caracteres. |  |
|  | 4. O sistema valida as informações preenchidas. |
|  | 5. O sistema mostra o aviso "Antes de enviar" com a quantidade de destinatários e que o envio não pode ser desfeito; o botão de envio também mostra a quantidade. |
| 6. O administrador confirma o envio no botão "Enviar notificação para N usuários". |  |
|  | 7. O sistema envia a notificação, dentro da plataforma (central de notificações), para todos os usuários ativos (não excluídos, não suspensos e não bloqueados), menos o próprio administrador. |
|  | 8. O sistema registra o disparo da notificação. |
|  | 9. O sistema informa ao administrador que a notificação foi enviada com sucesso, com o título, o público, os canais e a quantidade de destinatários, e oferece "Ver histórico de disparos" e "Voltar à central". |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador tenta enviar uma notificação sem preencher os campos obrigatórios. |  |
|  | 2. O sistema informa, ao lado de cada campo, o que precisa ser corrigido (título ou mensagem vazios, título acima de 120 ou mensagem acima de 500 caracteres, link em formato inválido) e pede para corrigir os campos destacados. |
| 3. O administrador corrige as informações. |  |
|  | 4. O sistema permite o envio após a validação. |
| 5. O administrador seleciona "Cancelar", ao lado do envio. |  |
|  | 6. O sistema limpa o formulário sem enviar a notificação. |
