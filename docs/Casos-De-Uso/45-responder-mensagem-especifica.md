| Nome do Caso de Uso | Responder Mensagem Específica |
|---|---|
| Finalidade/Objetivo | Permitir que o usuário responda diretamente a uma mensagem específica dentro de uma conversa, facilitando a identificação do contexto da resposta. |
| Atores | Cliente |
| Pré Condições | O usuário deve estar autenticado e possuir uma conversa ativa com outro usuário. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário acessa uma conversa e seleciona a mensagem que deseja responder. |  |
|  | 2. O sistema identifica a mensagem selecionada e habilita a opção de resposta. |
| 3. O usuário seleciona a opção "Responder". |  |
|  | 4. O sistema exibe a mensagem selecionada como referência no campo de resposta. |
| 5. O usuário digita a resposta e seleciona a opção "Enviar". |  |
|  | 6. O sistema envia a mensagem vinculada à mensagem original e atualiza a conversa. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário tenta enviar uma resposta sem inserir conteúdo. |  |
|  | 2. O sistema impede o envio e exibe a mensagem "Digite uma mensagem antes de enviar". |
| 3. O usuário tenta responder a uma mensagem que não está mais disponível. |  |
|  | 4. O sistema informa que a mensagem não está mais disponível e cancela a referência à mensagem original. |
