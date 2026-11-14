| Nome do Caso de Uso | Denunciar Perfil |
|---|---|
| Finalidade/Objetivo | Permitir que o usuário denuncie um perfil que esteja violando as regras da plataforma ou apresentando comportamento inadequado. |
| Atores | Cliente |
| Pré Condições | O usuário deve estar autenticado e ter acesso ao perfil que deseja denunciar. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário acessa o perfil que deseja denunciar. |  |
|  | 2. O sistema apresenta a opção "Denunciar perfil". |
| 3. O usuário seleciona a opção de denúncia. |  |
|  | 4. O sistema apresenta as categorias disponíveis para a denúncia. |
| 5. O usuário seleciona o motivo da denúncia e, se necessário, adiciona uma descrição. |  |
|  | 6. O sistema valida as informações fornecidas. |
| 7. O usuário confirma a denúncia. |  |
|  | 8. O sistema registra a denúncia e informa que ela foi enviada para análise. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário tenta enviar uma denúncia sem selecionar um motivo. |  |
|  | 2. O sistema impede o envio e solicita a seleção de um motivo. |
| 3. O usuário cancela a denúncia. |  |
|  | 4. O sistema encerra o processo sem registrar a denúncia. |
