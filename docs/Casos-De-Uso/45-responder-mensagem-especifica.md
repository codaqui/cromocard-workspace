| Nome do Caso de Uso | Responder Mensagem Específica |
|---|---|
| Finalidade/Objetivo | Permitir que o usuário responda diretamente a uma mensagem específica dentro de uma conversa, facilitando a identificação do contexto da resposta. |
| Atores | Cliente, Vendedor |
| Pré Condições | O usuário deve estar autenticado e possuir uma conversa ativa com outro usuário. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário acessa uma conversa e seleciona a mensagem que deseja responder. |  |
|  | 2. O sistema identifica a mensagem selecionada e abre o menu da mensagem com a opção "Responder". |
| 3. O usuário seleciona a opção "Responder". |  |
|  | 4. O sistema exibe acima do campo de digitação o bloco "Respondendo a @<nome de usuário do autor>:" com o começo da mensagem selecionada entre aspas, cortado com "..." quando não cabe em uma linha. |
| 5. O usuário digita a resposta e seleciona a opção "Enviar". |  |
|  | 6. O sistema envia a mensagem vinculada à mensagem original e atualiza a conversa, mostrando acima do texto da resposta o bloco "Respondendo a @<autor>" com o começo da mensagem original. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário tenta enviar uma resposta sem inserir conteúdo. |  |
|  | 2. O sistema impede o envio e exibe a mensagem "Digite uma mensagem antes de enviar". |
| 3. O usuário tenta responder a uma mensagem que não está mais disponível. |  |
|  | 4. O sistema exibe a mensagem "A mensagem que você está respondendo não está mais disponível.", cancela a referência à mensagem original e mantém o texto digitado no campo, para ser enviado sem citação. |
| 5. O usuário seleciona o "×" do bloco "Respondendo a" ou pressiona Esc. |  |
|  | 6. O sistema cancela a referência à mensagem original e mantém o texto digitado no campo. |
|  | 7. Quando a mensagem original de uma resposta já enviada deixa de estar disponível, o sistema mostra "Mensagem indisponível" no lugar do trecho citado. |
