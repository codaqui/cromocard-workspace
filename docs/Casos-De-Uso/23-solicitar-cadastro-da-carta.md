| Nome do Caso de Uso | Solicitar Cadastro da Carta |
|---|---|
| Finalidade/Objetivo | Permitir que o cliente solicite o cadastro de uma carta que ainda não está disponível na base de dados da plataforma. |
| Atores | Cliente |
| Pré Condições | O cliente deve estar autenticado e ter pesquisado a carta sem encontrar o resultado desejado. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O cliente seleciona a opção 'Solicitar Cadastro de Carta' na tela de busca. |  |
|  | 2. O sistema apresenta um formulário para o cliente informar os dados da carta: nome, álbum, número, franquia, raridade e idioma, a imagem da frente (obrigatória) e a do verso (opcional), para que a carta possa entrar publicada no catálogo quando aprovada. |
| 3. O cliente preenche os dados solicitados e confirma o envio. |  |
|  | 4. O sistema registra a solicitação, encaminha para análise do administrador e exibe uma mensagem de confirmação ao cliente. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O cliente tenta enviar o formulário sem preencher os campos obrigatórios. |  |
|  | 2. O sistema exibe mensagem de erro indicando os campos pendentes e mantém o formulário aberto. |
