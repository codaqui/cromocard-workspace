| Nome do Caso de Uso | Notificar Pendência Cadastral |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador avise um vendedor sobre uma pendência no cadastro, com o prazo para regularizar, sem aprovar nem reprovar o credenciamento. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado com permissão de administrador e o cadastro do vendedor deve estar em análise ou pendente. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador seleciona a opção "Notificar Lojista" na lista de cadastros ou "Notificar Pendência" no dossiê do vendedor. |  |
|  | 2. O sistema apresenta o formulário de pendência com o destinatário (nome e e-mail do vendedor) e os canais de envio: notificação no site e e-mail. |
| 3. O administrador escolhe um modelo de mensagem pronto, quando houver um adequado. |  |
|  | 4. O sistema preenche o corpo da mensagem com o texto do modelo e os dados do vendedor. |
| 5. O administrador revisa ou escreve o corpo da mensagem. |  |
| 6. O administrador escolhe o prazo para regularização. |  |
| 7. O administrador confirma o envio. |  |
|  | 8. O sistema valida as informações preenchidas. |
|  | 9. O sistema envia a notificação no site e o e-mail ao vendedor. |
|  | 10. O sistema muda o status do cadastro para Pendente e registra a ação no log de auditoria. |
|  | 11. O sistema apresenta a confirmação com o destinatário, o assunto, os canais, o horário de envio e a prévia do conteúdo, e as opções "Voltar ao Dashboard" e "Ver perfil do lojista". |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador tenta enviar com o corpo da mensagem vazio. |  |
|  | 2. O sistema informa que o corpo da mensagem é obrigatório. |
| 3. O administrador cancela o envio. |  |
|  | 4. O sistema fecha o formulário sem enviar a notificação. |
|  | 5. O envio do e-mail falha. |
|  | 6. O sistema mantém a notificação no site e informa ao administrador que o e-mail não foi entregue. |
