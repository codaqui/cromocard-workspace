| Nome do Caso de Uso | Configurar Privacidade e Senha |
|---|---|
| Finalidade/Objetivo | Permitir que o usuário configure suas preferências de privacidade e altere a senha de acesso à conta. |
| Atores | Cliente |
| Pré Condições | O usuário deve estar autenticado e possuir uma conta ativa. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário acessa as configurações da conta. |  |
|  | 2. O sistema apresenta as opções de privacidade e segurança disponíveis. |
| 3. O usuário altera suas configurações de privacidade. |  |
|  | 4. O sistema valida e registra as novas preferências. |
| 5. O usuário acessa a opção de alteração de senha e informa a senha atual e a nova senha. |  |
|  | 6. O sistema valida a senha atual e os requisitos da nova senha. |
| 7. O usuário confirma a alteração. |  |
|  | 8. O sistema atualiza a senha e confirma a alteração ao usuário. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário informa uma senha atual incorreta. |  |
|  | 2. O sistema impede a alteração e informa que a senha atual é inválida. |
| 3. O usuário informa uma nova senha que não atende aos requisitos de segurança. |  |
|  | 4. O sistema informa os requisitos necessários para a nova senha. |
| 5. O usuário cancela a alteração. |  |
|  | 6. O sistema mantém as configurações anteriores. |
