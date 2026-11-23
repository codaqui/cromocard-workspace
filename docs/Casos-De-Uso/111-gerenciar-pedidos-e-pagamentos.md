| Nome do Caso de Uso | Gerenciar Pedidos e Pagamentos |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador acompanhe os pedidos do marketplace (pagamento, envio e repasse ao vendedor) e resolva as exceções: cancelar com reembolso antes da liberação ou liberar o pagamento na hora. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado com permissão de administrador. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador seleciona "Pedidos e pagamentos" no menu do BackOffice. |  |
|  | 2. O sistema apresenta os totais (em custódia, a liberar nos próximos 7 dias, liberado no mês e repasses pendentes) e a lista de pedidos, do mais recente para o mais antigo, com número, data, carta, comprador, vendedor, valor, status (Aguardando pagamento, Pago, Enviado, Entregue, Concluído ou Cancelado) e os selos "Atrasado", quando o pedido está Pago há mais de 2 dias sem etiqueta, e "Problema relatado", quando o comprador relatou um problema (Confirmar Entrega e Liberar Pagamento). |
| 3. O administrador filtra por status (ou pelos pedidos com problema relatado) ou busca pelo número do pedido, pelo comprador ou pelo vendedor. |  |
|  | 4. O sistema atualiza a lista. |
| 5. O administrador seleciona um pedido. |  |
|  | 6. O sistema apresenta o detalhe do pedido: a linha do tempo (pago, enviado, entregue e concluído, com as datas), o pagamento (valor da carta, frete, taxa de 5%, valor líquido do vendedor e os identificadores do pagamento e da transferência na Stripe) e o envio (serviço, código de rastreio e link do rastreio). Se o comprador relatou um problema, mostra a descrição e a data do relato. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador seleciona "Cancelar e reembolsar" num pedido Pago, Enviado ou Entregue. |  |
|  | 2. O sistema pede o motivo do cancelamento e avisa que o comprador recebe de volta o valor total (carta e frete). |
| 3. O administrador informa o motivo e confirma. |  |
|  | 4. O sistema faz o reembolso pela Stripe, marca o pedido como Cancelado com o motivo, avisa o comprador e o vendedor por e-mail e registra a ação no log de auditoria. |
| 5. O administrador confirma sem informar o motivo. |  |
|  | 6. O sistema informa que o motivo é obrigatório. |
| 7. O administrador seleciona "Liberar agora" num pedido Entregue (inclusive quando o repasse automático falhou ou quando o problema relatado foi resolvido a favor do vendedor). |  |
|  | 8. O sistema pede a confirmação, transfere ao vendedor como na liberação normal (Confirmar Entrega e Liberar Pagamento), marca o pedido como Concluído e registra a ação no log de auditoria. |
|  | 9. Num pedido Concluído ou Cancelado, o sistema não oferece as ações e informa que o pedido já foi encerrado. |
| 10. O administrador busca ou filtra e nenhum pedido corresponde. |  |
|  | 11. O sistema informa que nenhum pedido foi encontrado e oferece limpar os filtros. |
