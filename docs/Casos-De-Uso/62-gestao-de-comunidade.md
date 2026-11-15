| Nome do Caso de Uso | Gestão de Comunidade |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador suspenda, reative e exclua grupos da comunidade e modere as mensagens denunciadas. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado e possuir permissão para gerenciar grupos. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa a opção "Gestão de Comunidade". |  |
|  | 2. O sistema apresenta os indicadores (grupos ativos, mensagens dos últimos 7 dias e denúncias pendentes) e os grupos existentes, paginados, com nome, tipo de acesso (público ou privado), membros, criador, volume custodiado, status e as ações, com busca por nome ou criador e filtro de status. |
| 3. O administrador seleciona um grupo. |  |
|  | 4. O sistema apresenta os detalhes do grupo (descrição, tipo de acesso, criador, membros, data de criação, status e volume custodiado) e as opções disponíveis conforme o status: no grupo ativo, advertir, suspender e excluir; no advertido, reativar (tira o selo), suspender e excluir; no suspenso, reativar e excluir. |
| 5. O administrador escolhe a ação e informa o motivo. |  |
|  | 6. O sistema solicita a confirmação. |
| 7. O administrador confirma a operação. |  |
|  | 8. O sistema registra a alteração e o motivo no log de auditoria. O grupo suspenso some de Explorar e fica só para leitura dos membros; o grupo excluído some para todos. |
|  | 9. O sistema atualiza a lista de grupos e confirma a operação. |
| 10. O administrador abre a fila de mensagens denunciadas. |  |
|  | 11. O sistema apresenta cada denúncia pendente com o autor (idade da conta e advertências anteriores), o grupo, a mensagem, a categoria, a descrição da denúncia, quem denunciou e quando, e permite filtrar por gravidade. |
| 12. O administrador remove a mensagem, remove a mensagem e adverte o autor, ou dispensa a denúncia, informando o motivo; ou escolhe aplicar uma sanção ao autor (caso de uso 99). |  |
|  | 13. O sistema remove a mensagem (quando for o caso), marca a denúncia como resolvida ou dispensada com o moderador e a data, e registra a ação no log de auditoria. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador confirma uma ação sem informar o motivo. |  |
|  | 2. O sistema informa que o motivo é obrigatório. |
| 3. O administrador corrige as informações. |  |
|  | 4. O sistema realiza novamente a validação. |
| 5. O administrador cancela a operação. |  |
|  | 6. O sistema cancela a operação sem realizar alterações. |
