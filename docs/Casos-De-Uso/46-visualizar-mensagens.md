| Nome do Caso de Uso | Visualizar Mensagens |
|---|---|
| Finalidade/Objetivo | Permitir que o usuário visualize suas conversas pessoais com outros colecionadores, leia e envie mensagens e comece uma conversa nova (inclui a user story "Conversar com Colecionador"). |
| Atores | Cliente, Vendedor |
| Pré Condições | O usuário deve estar autenticado como Cliente ou Vendedor. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário acessa "Mensagens" no menu. |  |
|  | 2. O sistema apresenta o topo "MENSAGENS • Chat pessoal com outros colecionadores" e a coluna "Conversas" com o total de conversas ativas ("N ativas"), o campo "Buscar conversa" e as abas "Todas" e "Não Lidas", cada uma com a sua quantidade. |
|  | 3. O sistema lista as conversas do usuário, da última mensagem mais recente para a mais antiga. Cada conversa mostra a foto (ou a inicial do nome), o nome, o @, o selo "Verificado" quando o outro participante é vendedor com a verificação aprovada, o ponto verde quando ele está online, a prévia da última mensagem (com "Você: " quando é do próprio usuário), a hora ou a data dela e a quantidade de mensagens não lidas. |
|  | 4. O sistema mostra no rodapé da lista "N de N conversas listadas". |
| 5. O usuário seleciona uma conversa. |  |
|  | 6. O sistema mostra no topo a foto, o nome, o @ e o selo do outro participante, o botão "Ver Perfil", que leva ao perfil público dele, e o escudo de bloquear ou denunciar (CCD047). |
|  | 7. O sistema mostra o quadro "Dica de segurança" com "Nunca pague por Pix ou link fora da CromoCard. Compre pelo anúncio no marketplace: o pagamento fica retido até a entrega." e as 30 mensagens mais recentes da conversa em ordem cronológica, separadas por dia ("Hoje, <dia> de <mês>"). As mensagens anteriores carregam quando o usuário rola para cima. |
|  | 8. O sistema destaca as mensagens recebidas que ainda não tinham sido lidas e as marca como lidas. |
|  | 9. O sistema mostra abaixo do campo de mensagem o aviso "Faça compras e pagamentos só pelo marketplace da CromoCard.". |
|  | 10. Quando chega uma mensagem nova, o sistema a mostra no fim da conversa aberta, já como lida, e atualiza na lista a prévia, a hora e as não lidas, sem recarregar a página. |
| 11. O usuário digita a mensagem no campo "Digite sua mensagem para @<usuário>..." e seleciona "Enviar" ou pressiona Enter. |  |
|  | 12. O sistema grava a mensagem, mostra-a no fim da conversa e a entrega em tempo real ao outro participante. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
|  | 1. Caso o usuário não possua nenhuma conversa, o sistema exibe "Nenhuma conversa ainda", a dica "Toque em "Nova conversa" para falar em particular com outro colecionador." e, no rodapé da lista, "Nenhuma conversa". |
|  | 2. Caso ocorra uma falha no carregamento, o sistema informa que não foi possível carregar as mensagens. Caso o envio falhe, o sistema mantém o texto no campo e informa que a mensagem não foi enviada. |
| 3. O usuário digita no campo "Buscar conversa". |  |
|  | 4. O sistema filtra a lista pelo nome ou pelo @ do outro participante e atualiza o rodapé com a quantidade listada. |
| 5. O usuário seleciona a aba "Não Lidas". |  |
|  | 6. O sistema lista só as conversas com mensagem não lida. |
| 7. O usuário seleciona "Nova conversa". |  |
|  | 8. O sistema abre o modal "Nova conversa" ("Envie uma mensagem privada para outro colecionador.") com o campo de busca, as abas "Todos", "Dos meus grupos", "Lojistas" e "Já negociei" e a seção "Conversas recentes". |
| 9. O usuário busca uma pessoa pelo nome ou pelo @ e escolhe uma aba. |  |
|  | 10. O sistema mostra em "Resultados" os usuários ativos que combinam com a busca, menos os bloqueados: todos, os que participam de um grupo com o usuário (com os grupos em comum), os vendedores ("Lojista") ou os com quem ele já teve pedido. |
| 11. O usuário seleciona "Conversar" num resultado ou numa conversa recente. |  |
|  | 12. O sistema abre a conversa com essa pessoa, criando-a se ainda não existir, e fecha o modal. |
| 13. O usuário seleciona "Cancelar". |  |
|  | 14. O sistema fecha o modal sem criar conversa. |
