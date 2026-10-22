| Nome do Caso de Uso | Agendar Notificação Global |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador programe uma notificação global para ser enviada numa data e hora futuras, em vez de enviá-la na hora. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado com permissão de administrador. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador preenche a notificação na Central de Notificações (Disparar Notificação Global). |  |
| 2. O administrador escolhe a opção "Agendar Horário" em vez de "Disparo Imediato". |  |
|  | 3. O sistema apresenta o calendário e o horário de liberação, com o fuso horário de Brasília (UTC-3). |
| 4. O administrador seleciona o dia e o horário do envio. |  |
| 5. O administrador confirma o agendamento. |  |
|  | 6. O sistema valida que a data e o horário são futuros. |
|  | 7. O sistema grava a notificação com o status "Na fila" e registra a ação no log de auditoria. |
|  | 8. O sistema informa que a notificação foi agendada, com o título, o público e o horário programado. |
|  | 9. No horário programado, o sistema envia a notificação aos usuários e muda o status para "Entregue". |
| 10. O administrador consulta o histórico de disparos. |  |
|  | 11. O sistema apresenta os disparos com data e horário, título, público, canal e status. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador seleciona uma data ou horário já passados. |  |
|  | 2. O sistema informa que o horário precisa ser futuro. |
| 3. O administrador cancela um agendamento que ainda está na fila. |  |
|  | 4. O sistema cancela o envio e registra a ação no log de auditoria. |
