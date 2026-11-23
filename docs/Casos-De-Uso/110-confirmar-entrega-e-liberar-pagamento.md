| Nome do Caso de Uso | Confirmar Entrega e Liberar Pagamento |
|---|---|
| Finalidade/Objetivo | Liberar ao vendedor o valor retido de um pedido depois que a carta é entregue, para que o comprador compre com segurança. |
| Atores | Cliente (comprador), Sistema |
| Pré Condições | O pedido deve estar Enviado, com etiqueta gerada pelo Melhor Envio. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
|  | 1. O sistema recebe do Melhor Envio o aviso de que a encomenda foi entregue (ou o encontra na consulta periódica do rastreio) e marca o pedido como Entregue. |
|  | 2. O sistema avisa o comprador por e-mail e mostra no pedido a data da liberação: 7 dias depois da entrega (0 dias em homologação). |
| 3. O comprador confere a carta e seleciona "Confirmar recebimento" no detalhe do pedido. |  |
|  | 4. O sistema pede a confirmação e avisa que, depois dela, o valor é liberado ao vendedor. |
| 5. O comprador confirma. |  |
|  | 6. O sistema transfere ao vendedor, pela Stripe, o valor da carta menos a taxa de 5% (arredondada para baixo, a favor do vendedor), marca o pedido como Concluído e avisa o vendedor por e-mail. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
|  | 1. Caso o comprador não confirme nem relate um problema, o sistema libera o pagamento automaticamente quando passam os 7 dias depois da entrega. |
|  | 2. Caso o administrador cancele e reembolse o pedido antes da liberação (Gerenciar Pedidos e Pagamentos), o pedido fica Cancelado e nada é transferido. |
|  | 3. Caso a transferência falhe na Stripe, o pedido continua Entregue, o sistema tenta de novo na próxima execução e o administrador vê o pedido como pendente. |
| 4. O comprador seleciona "Relatar problema" no detalhe de um pedido Enviado ou Entregue, antes da liberação, porque a carta chegou errada, danificada ou não chegou. |  |
|  | 5. O sistema pede a descrição do problema (obrigatória). |
| 6. O comprador descreve o problema e confirma. |  |
|  | 7. O sistema suspende a liberação automática, marca o pedido com "Problema relatado" para o administrador resolver (Gerenciar Pedidos e Pagamentos) e informa ao comprador que o pagamento fica retido até lá. |
