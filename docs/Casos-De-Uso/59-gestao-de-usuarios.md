| Nome do Caso de Uso | Gestão de Usuários |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador gerencie os usuários da plataforma, incluindo cadastro, consulta, alteração e controle de status. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado e possuir permissão para realizar a gestão de usuários. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa a opção "Gestão de Usuários". |  |
|  | 2. O sistema apresenta a lista de usuários cadastrados. |
| 3. O administrador seleciona um usuário ou escolhe a opção de cadastrar um novo usuário. |  |
|  | 4. O sistema apresenta os dados e as opções disponíveis para gerenciamento. |
| 5. O administrador informa ou altera os dados do usuário. |  |
|  | 6. O sistema valida os dados informados. |
|  | 7. O sistema registra as alterações realizadas. |
|  | 8. O sistema apresenta uma mensagem confirmando a operação. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador informa dados inválidos ou incompletos. |  |
|  | 2. O sistema identifica os dados inválidos e informa o administrador. |
| 3. O administrador corrige os dados. |  |
|  | 4. O sistema realiza novamente a validação. |
| 5. O administrador cancela a operação. |  |
|  | 6. O sistema cancela a operação e retorna para a lista de usuários. |

### Regras de Negócio

| Código | Regra |
|---|---|
| RN01 | E-mail é obrigatório e único. Nome de usuário (`username`) é opcional e único. |
| RN02 | No cadastro feito pelo administrador não se informa senha: o sistema envia ao usuário um link para definir a senha, válido por 24 horas. |
| RN03 | Excluir um usuário é soft delete (ADR-015): a conta some das listagens e pode ser restaurada por um administrador. |
| RN04 | Suspender muda o `status` para `SUSPENDED`; o usuário suspenso não consegue fazer login. Reativar volta para `ACTIVE`. |
| RN05 | O administrador não pode suspender, excluir ou rebaixar a própria conta, nem remover o último administrador ativo. |
| RN06 | Toda criação, alteração de dados, mudança de papel, suspensão, reativação, exclusão e restauração gera um registro em `audit_logs` (ADR-034). |

### Critérios de Aceite (MVP)

- [ ] Lista paginada com nome, @, e-mail, telefone, papel, status e último acesso (`last_login_at`).
- [ ] Busca por nome, e-mail ou @, e filtros por Papel e por Status.
- [ ] Cadastrar usuário com nome, @, e-mail, telefone e papel; o sistema envia o link de definição de senha (RN02).
- [ ] Editar os dados e alterar o papel de um usuário.
- [ ] Suspender e reativar um usuário (RN04).
- [ ] Excluir com confirmação: o modal informa que a conta pode ser restaurada (RN03).
- [ ] Restaurar um usuário excluído.
- [ ] As regras RN05 retornam `422` com mensagem clara.
- [ ] Cada operação aparece no Log de Auditoria (CCD065).

### Fora do Escopo do MVP

CPF, IP do último acesso, sessões ativas, KYC e "custódia". Decisão no ADR-038.

### Referências

- Figma: `administração - Gestão de usuarios`, `administração - adicionar novo usuario`, `administração - remover usuario`
- DER: `users.phone`, `users.username`, `users.last_login_at` (ADR-038)
