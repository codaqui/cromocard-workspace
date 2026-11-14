| Nome do Caso de Uso | Exclusão da Conta |
|---|---|
| Finalidade/Objetivo | Permitir que o usuário solicite a exclusão de sua conta e dos dados associados, conforme as regras da plataforma. |
| Atores | Cliente |
| Pré Condições | O usuário deve estar autenticado e possuir uma conta ativa. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário acessa as configurações da conta. |  |
|  | 2. O sistema apresenta a opção de exclusão da conta. |
| 3. O usuário seleciona "Excluir conta". |  |
|  | 4. O sistema apresenta uma mensagem de confirmação informando as consequências da exclusão. |
| 5. O usuário confirma a exclusão da conta. |  |
|  | 6. O sistema solicita a autenticação ou confirmação de segurança necessária. |
| 7. O usuário realiza a confirmação. |  |
|  | 8. O sistema exclui ou desativa a conta conforme as regras definidas e encerra a sessão. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário cancela a exclusão. |  |
|  | 2. O sistema cancela a operação e mantém a conta ativa. |
| 3. O usuário não consegue realizar a confirmação de segurança. |  |
|  | 4. O sistema impede a exclusão da conta e informa que a confirmação é necessária. |
