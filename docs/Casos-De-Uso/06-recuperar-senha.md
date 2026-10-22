| Nome do Caso de Uso | Recuperar Senha |
|---|---|
| Finalidade/Objetivo | Permitir que o visitante solicite a recuperação da senha esquecida através do e-mail e defina uma senha nova. |
| Atores | Visitante |
| Pré Condições | O visitante deve estar na tela de Login e selecionar a opção de recuperação. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O visitante seleciona a opção 'Esqueci minha senha'. |  |
|  | 2. Solicitar o preenchimento do e-mail cadastrado. |
| 3. Informar o e-mail solicitado. |  |
|  | 4. O sistema verifica se o e-mail pertence a uma conta ativa. |
|  | 5. O sistema envia um link de redefinição (válido por 1 hora, uso único; invalida os links anteriores) e exibe uma confirmação genérica de envio. |
| 6. O visitante abre o link e informa a senha nova e a confirmação. |  |
|  | 7. O sistema valida o link e a senha (mesma regra do cadastro), grava a senha nova, encerra todas as sessões abertas, confirma o e-mail se ainda não estava confirmado e envia um e-mail avisando da troca. |
|  | 8. O sistema leva à tela de Login com a mensagem 'Senha alterada'. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
|  | 1. Caso o e-mail não possua formato válido, emitir mensagem de erro. |
|  | 2. Caso o e-mail não exista, ou a conta esteja suspensa ou excluída, não enviar nada e exibir a mesma confirmação genérica (por segurança, não informar se o e-mail existe). |
|  | 3. Caso o link esteja expirado, inválido ou já usado, informar e oferecer pedir um novo link. |
|  | 4. Caso a conta só entre pelo Google, o link permite criar uma senha, e a conta passa a entrar dos dois jeitos. |
