| Nome do Caso de Uso | Segmentar Notificação Global |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador envie uma notificação global só para um público (por exemplo, só vendedores ou só colecionadores ativos) e escolha os canais de envio. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado com permissão de administrador. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador preenche a notificação na Central de Notificações (Disparar Notificação Global). |  |
| 2. O administrador escolhe o público: toda a base, colecionadores ativos (clientes que entraram nos últimos 30 dias) ou vendedores. |  |
|  | 3. O sistema calcula e mostra quantos usuários fazem parte do público escolhido. |
| 4. O administrador escolhe os canais: notificação no app ou e-mail. |  |
| 5. O administrador confirma o envio. |  |
|  | 6. O sistema envia a notificação só aos usuários do público, pelos canais escolhidos. |
|  | 7. O sistema registra o público, os canais e a quantidade de destinatários no histórico de disparos e no log de auditoria. |
|  | 8. O sistema informa que a notificação foi enviada, com o público selecionado. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador escolhe um público sem usuários. |  |
|  | 2. O sistema informa que o público está vazio e não permite o envio. |
| 3. O administrador não escolhe nenhum canal. |  |
|  | 4. O sistema informa que pelo menos um canal é obrigatório. |
