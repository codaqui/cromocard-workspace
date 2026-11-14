| Nome do Caso de Uso | Editar Dados do Perfil |
|---|---|
| Finalidade/Objetivo | Permitir que o usuário altere e atualize seus dados pessoais e informações apresentadas em seu perfil. |
| Atores | Cliente |
| Pré Condições | O usuário deve estar autenticado e possuir um perfil cadastrado. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário acessa seu perfil e seleciona a opção "Editar perfil". |  |
|  | 2. O sistema apresenta os dados atuais do perfil em modo de edição. |
| 3. O usuário altera as informações desejadas. |  |
|  | 4. O sistema valida os dados informados. |
| 5. O usuário seleciona a opção "Salvar". |  |
|  | 6. O sistema atualiza os dados do perfil. |
|  | 7. O sistema exibe uma mensagem confirmando a atualização. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário informa dados inválidos ou incompletos. |  |
|  | 2. O sistema impede o salvamento e informa quais campos precisam ser corrigidos. |
| 3. O usuário cancela a edição. |  |
|  | 4. O sistema descarta as alterações e mantém os dados anteriores. |
