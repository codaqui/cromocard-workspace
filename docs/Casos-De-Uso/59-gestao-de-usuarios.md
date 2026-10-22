| Nome do Caso de Uso | Gestão de Usuários |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador gerencie os usuários da plataforma, incluindo cadastro, consulta, alteração e controle de status. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado e possuir permissão para realizar a gestão de usuários. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa a opção "Gestão de Usuários". |  |
|  | 2. O sistema apresenta a lista de usuários cadastrados, sem os excluídos, com nome, e-mail, papel, status e data de cadastro, e permite buscar por nome ou e-mail e filtrar por papel e por status. |
| 3. O administrador seleciona um usuário ou escolhe a opção de cadastrar um novo usuário. |  |
|  | 4. O sistema apresenta os dados e as opções disponíveis para gerenciamento: editar, alterar o papel, suspender, reativar e excluir. |
| 5. O administrador informa ou altera os dados do usuário (nome, e-mail e papel). |  |
|  | 6. O sistema valida os dados informados. |
|  | 7. O sistema registra as alterações realizadas. No cadastro, envia ao usuário um convite por e-mail com o link para definir a senha; a conta nasce com o e-mail confirmado e o aceite dos termos fica para o primeiro acesso. |
|  | 8. O sistema apresenta uma mensagem confirmando a operação. |
| 9. O administrador escolhe suspender ou excluir um usuário e informa o motivo. |  |
|  | 10. O sistema muda o status para suspenso ou exclui a conta (ela pode ser restaurada), encerra as sessões abertas do usuário e registra a ação e o motivo no log de auditoria. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador informa dados inválidos ou incompletos. |  |
|  | 2. O sistema identifica os dados inválidos e informa o administrador. |
| 3. O administrador corrige os dados. |  |
|  | 4. O sistema realiza novamente a validação. |
| 5. O administrador cancela a operação. |  |
|  | 6. O sistema cancela a operação e retorna para a lista de usuários. |
| 7. O administrador tenta suspender, excluir ou rebaixar a própria conta, ou o último administrador ativo. |  |
|  | 8. O sistema impede a operação e informa o motivo. |
