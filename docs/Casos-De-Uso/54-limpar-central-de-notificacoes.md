| Nome do Caso de Uso | Limpar Central de Notificações |
|---|---|
| Finalidade/Objetivo | Permitir que o usuário remova as notificações apresentadas em sua central de notificações. |
| Atores | Cliente |
| Pré Condições | O usuário deve estar autenticado e possuir notificações na central. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário acessa a central de notificações. |  |
|  | 2. O sistema apresenta as notificações disponíveis. |
| 3. O usuário seleciona a opção "Limpar notificações". |  |
|  | 4. O sistema solicita a confirmação da ação. |
| 5. O usuário confirma a limpeza. |  |
|  | 6. O sistema remove as notificações da central. |
|  | 7. O sistema atualiza a interface e informa que a central foi limpa. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário cancela a operação. |  |
|  | 2. O sistema mantém as notificações sem alterações. |
|  | 3. Caso não existam notificações, o sistema informa que a central já está vazia. |
