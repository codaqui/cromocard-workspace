| Nome do Caso de Uso | Visualizar Notificações |
|---|---|
| Finalidade/Objetivo | Permitir que o usuário visualize as notificações relacionadas às atividades e interações ocorridas na plataforma. |
| Atores | Cliente, Vendedor |
| Pré Condições | O usuário deve estar autenticado como cliente ou vendedor e possuir acesso à central de notificações. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário acessa a central de notificações pelo menu, pelo sino do topo ou por "Ver todas as notificações". |  |
|  | 2. O sistema consulta as notificações vinculadas à conta do usuário, sem as excluídas. |
|  | 3. O sistema apresenta as notificações da mais recente para a mais antiga, agrupadas em "Hoje" e "Anteriores", 50 por vez, com "Carregar mais" no fim. Mostra o total de não lidas e os filtros "Todas", "Novas Mensagens", "Convites de Grupos" e "Avisos da Plataforma", cada um com a contagem. Cada notificação mostra o rótulo do tipo, quando chegou, o título, a mensagem e, se tiver destino, um botão de ação; a não lida aparece destacada. |
| 4. O usuário seleciona uma notificação ou o botão de ação dela. |  |
|  | 5. O sistema direciona o usuário para o conteúdo relacionado à notificação, quando aplicável. |
|  | 6. O sistema atualiza o status da notificação para "lida" e diminui o contador de não lidas. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
|  | 1. Caso não existam notificações, o sistema exibe a mensagem "Nenhuma notificação encontrada". |
|  | 2. Caso o conteúdo relacionado não esteja mais disponível, a página de destino mostra "Este conteúdo não está mais disponível." e a notificação fica lida. |
|  | 3. Caso não existam notificações não lidas, o sistema mostra "Tudo em dia!", com "Você não tem notificações não lidas. Avisaremos quando chegar algo novo." e "Configurar alertas", e as notificações lidas continuam abaixo, em "Anteriores". |
| 4. O usuário escolhe um filtro. |  |
|  | 5. O sistema mostra só as notificações daquela categoria. |
| 6. O usuário seleciona "✓" ou "Marcar como lida" no menu "⋮" de uma notificação. |  |
|  | 7. O sistema marca a notificação como lida, sem sair da central. "Configurar este tipo de alerta", no mesmo menu, leva às preferências de aviso em Configurações. |
|  | 8. Caso chegue uma notificação nova com o usuário em qualquer tela, o sistema mostra um aviso flutuante, com o botão de ação e "Marcar como lida", e soma 1 ao contador do sino. |
| 9. O usuário seleciona o sino do topo. |  |
|  | 10. O sistema mostra as últimas notificações, com os filtros "Todas", "Não lidas", "Pedidos" e "Grupos", "Ver todas as notificações" e "Configurar alertas". |
