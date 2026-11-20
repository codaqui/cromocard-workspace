| Nome do Caso de Uso | Aprovar Solicitações |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador analise e aprove ou recuse as solicitações de novas cartas, álbuns e categorias realizadas pelos usuários da plataforma. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado e existir pelo menos uma solicitação pendente. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa a opção "Solicitações". |  |
|  | 2. O sistema apresenta as solicitações pendentes, paginadas, com abas por tipo (todas, cartas, álbuns e categorias) e a quantidade de pendentes em cada uma. Cada solicitação aparece aberta, com o código, o tipo, o solicitante e os dados sugeridos. |
| 3. O administrador seleciona uma solicitação. |  |
|  | 4. O sistema apresenta os detalhes da solicitação. Na carta: nome, álbum, número, franquia, raridade, idioma e as imagens; no álbum: título, franquia, editora e ano; na categoria: nome e tipo. |
| 5. O administrador analisa as informações. |  |
| 6. O administrador seleciona a opção "Aprovar". |  |
| 7. O administrador confirma a operação no resumo do que será criado. |  |
|  | 8. O sistema registra a aprovação e cria o item no catálogo como foi sugerido (ajustes depois, pela Gestão de Catálogo). A carta entra publicada. O álbum entra sem cartas: elas são cadastradas depois, na Gestão de Catálogo, e vinculadas a ele. |
|  | 9. O sistema atualiza o status da solicitação, avisa o solicitante por notificação ("Sua sugestão foi aprovada": "<nome do item> entrou no catálogo do CromoCard.") e registra a ação no log de auditoria. |
|  | 10. O sistema informa ao administrador que a solicitação foi aprovada. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador seleciona uma solicitação que já foi processada. |  |
|  | 2. O sistema informa que a solicitação não está mais disponível para aprovação, com quem a processou e quando. |
| 3. O administrador cancela a operação. |  |
|  | 4. O sistema retorna para a lista de solicitações. |
| 5. O administrador seleciona a opção "Recusar" e informa o motivo, obrigatório. |  |
|  | 6. O sistema muda o status da solicitação para recusada, guarda o motivo, avisa o solicitante por notificação ("Sua sugestão foi recusada": "<nome do item> não foi aprovada. Motivo: <motivo>") e registra a ação no log de auditoria. Sem motivo, informa que ele é obrigatório. |
| 7. O administrador aprova uma sugestão que conflita com o catálogo (ex.: número que já existe no álbum) ou à qual falta um dado obrigatório para publicar (franquia, raridade, idioma ou imagem da frente). |  |
|  | 8. O sistema informa o conflito e mantém a solicitação pendente. |
