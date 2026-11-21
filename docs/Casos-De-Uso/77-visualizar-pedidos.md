| Nome do Caso de Uso | Visualizar Pedidos |
|---|---|
| Finalidade/Objetivo | Como Cliente preciso visualizar meus pedidos para acompanhar o pagamento, o envio e a entrega das compras realizadas na plataforma. |
| Atores | Cliente |
| Pré Condições | O cliente deve estar autenticado. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O cliente acessa "Meus pedidos" no menu lateral ou em Perfil e configurações. |  |
|  | 2. O sistema busca os pedidos do cliente e exibe a lista com número do pedido, carta, vendedor, data, total e status (Aguardando pagamento, Pago, Enviado, Entregue, Concluído ou Cancelado), com abas por status e a quantidade de cada uma. |
| 3. O cliente seleciona "Ver pedido". |  |
|  | 4. O sistema exibe o detalhe do pedido: a linha do tempo (pago, enviado, entregue e concluído, com data e hora), a transportadora, o código e o link de rastreio, o endereço de entrega, o vendedor e os valores (carta, frete e total). |
|  | 5. Com o pedido entregue e ainda não concluído, o sistema mostra a data em que o valor será liberado ao vendedor e o botão "Confirmar recebimento" (Confirmar Entrega e Liberar Pagamento). |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
|  | 1. Caso o cliente ainda não possua pedidos, o sistema exibe a mensagem: “Você ainda não possui pedidos.” |
|  | 2. Caso o pedido tenha sido cancelado, o detalhe mostra o motivo ("pagamento não concluído" ou o motivo informado pelo administrador) e, se houve pagamento, que o valor foi reembolsado no cartão. |
