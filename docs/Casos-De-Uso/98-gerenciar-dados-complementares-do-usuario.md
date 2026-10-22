| Nome do Caso de Uso | Gerenciar Dados Complementares do Usuário |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador consulte e mantenha os dados complementares de um usuário (nome de usuário, telefone, CPF e último acesso) e o encontre por eles na Gestão de Usuários. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado com permissão de administrador. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa a Gestão de Usuários. |  |
|  | 2. O sistema apresenta a lista com nome, nome de usuário (@) e ID, e-mail e telefone, papel, status, data e IP do último acesso. |
| 3. O administrador busca por nome, nome de usuário, e-mail, CPF ou CNPJ ou ID do usuário. |  |
|  | 4. O sistema apresenta os usuários encontrados. |
| 5. O administrador seleciona "+ Novo Usuário" ou edita um usuário. |  |
|  | 6. O sistema apresenta o formulário com nome completo, nome de usuário, e-mail, CPF, telefone com DDD e papel de acesso. |
| 7. O administrador preenche ou altera os dados complementares. |  |
| 8. O administrador marca "Enviar link de ativação de conta por e-mail", ao cadastrar um usuário novo. |  |
| 9. O administrador confirma a operação. |  |
|  | 10. O sistema valida que o nome de usuário e o CPF não pertencem a outra conta. |
|  | 11. O sistema grava os dados e, se marcado, envia ao usuário o link de ativação com validade de 24 horas. |
|  | 12. O sistema registra a ação no log de auditoria e confirma a operação. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador informa um nome de usuário ou CPF que já pertence a outra conta. |  |
|  | 2. O sistema informa qual dado já está em uso. |
| 3. O administrador informa um CPF ou telefone em formato inválido. |  |
|  | 4. O sistema indica o campo inválido. |
| 5. O administrador cadastra o usuário sem marcar o envio do link de ativação. |  |
|  | 6. O sistema cria a conta sem enviar o e-mail; o administrador pode reenviar o link depois. |
