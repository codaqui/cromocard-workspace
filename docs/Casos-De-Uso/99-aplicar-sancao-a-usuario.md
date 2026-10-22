| Nome do Caso de Uso | Aplicar Sanção a Usuário |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador advirta, suspenda por um prazo ou bane definitivamente um usuário que descumpriu as regras, a partir da Gestão de Usuários ou da fila de moderação das comunidades. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado com permissão de administrador. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador abre uma denúncia na Fila de Moderação ou seleciona um usuário na Gestão de Usuários. |  |
|  | 2. O sistema apresenta o usuário com o número de advertências anteriores e as sanções disponíveis: advertir, suspender temporariamente e banir definitivamente. |
| 3. O administrador escolhe a sanção. |  |
|  | 4. O sistema solicita a justificativa e, na suspensão, o prazo: 3, 7, 15 ou 30 dias. |
| 5. O administrador informa a justificativa e, se for o caso, o prazo, e confirma. |  |
|  | 6. Na advertência, o sistema soma uma advertência ao usuário e o avisa por notificação; advertências acumuladas não suspendem sozinhas. |
|  | 7. Na suspensão, o sistema muda o status para Suspenso até o fim do prazo, encerra as sessões do usuário e mostra o prazo na lista (ex.: "Suspenso (7d)"). |
|  | 8. No banimento, o sistema muda o status para Bloqueado, encerra as sessões e impede novos logins. |
|  | 9. O sistema registra a sanção e a justificativa no log de auditoria. |
|  | 10. O sistema confirma a sanção aplicada. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador escolhe "Remover Mensagem & Advertir Usuário" numa denúncia. |  |
|  | 2. O sistema remove a mensagem denunciada, aplica a advertência e resolve a denúncia. |
|  | 3. O prazo de uma suspensão termina. |
|  | 4. O sistema volta o status do usuário para Ativo. |
| 5. O administrador seleciona "Reativar" num usuário suspenso ou bloqueado. |  |
|  | 6. O sistema volta o status para Ativo e registra a ação no log de auditoria. |
| 7. O administrador confirma sem informar a justificativa. |  |
|  | 8. O sistema informa que a justificativa é obrigatória. |
