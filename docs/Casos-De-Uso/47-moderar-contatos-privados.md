| Nome do Caso de Uso | Moderar Contatos Privados |
|---|---|
| Finalidade/Objetivo | Permitir que o usuário gerencie seus contatos e conversas privadas, podendo bloquear ou remover contatos conforme necessário. |
| Atores | Cliente |
| Pré Condições | O usuário deve estar autenticado e possuir pelo menos um contato ou conversa privada. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário acessa seus contatos ou conversas privadas. |  |
|  | 2. O sistema apresenta os contatos e as opções de gerenciamento disponíveis. |
| 3. O usuário seleciona um contato. |  |
|  | 4. O sistema exibe as opções de moderação disponíveis. |
| 5. O usuário seleciona uma ação, como bloquear ou remover o contato. |  |
|  | 6. O sistema solicita a confirmação da ação. |
| 7. O usuário confirma a ação. |  |
|  | 8. O sistema aplica a alteração e atualiza a lista de contatos. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário cancela a confirmação da ação. |  |
|  | 2. O sistema mantém o contato sem alterações. |
|  | 3. Caso o contato já esteja bloqueado, o sistema informa o status atual e disponibiliza a opção de desbloqueio. |
