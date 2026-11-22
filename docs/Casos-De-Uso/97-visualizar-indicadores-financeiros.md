| Nome do Caso de Uso | Visualizar Indicadores Financeiros |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador acompanhe no Dashboard os valores movimentados no marketplace: valor em custódia, valor liquidado no dia, valor retido em garantia e indicadores de confiança dos vendedores. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado com permissão de administrador e o marketplace (compra, pedidos e pagamentos) deve estar em funcionamento. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa o Dashboard Gerencial. |  |
|  | 2. O sistema apresenta o valor total em custódia (pagamentos recebidos e ainda não liberados ao vendedor: pedidos Pagos, Enviados e Entregues). |
|  | 3. O sistema apresenta, sempre juntos, o valor liquidado no período (pedidos Concluídos, com o pagamento já transferido ao vendedor; no filtro Hoje, "liquidado hoje"), a quantidade de pedidos liberados e o valor retido em garantia (pedidos Entregues ainda sem repasse, no prazo de 7 dias antes da liberação automática). |
|  | 4. O sistema apresenta, na lista de vendedores, o volume anunciado de cada vendedor (a nota de reputação saiu em 22/11/2026 com as avaliações, ADR-068). |
| 5. O administrador seleciona o período: Hoje, 7 dias, 30 dias ou 1 ano. |  |
|  | 6. O sistema atualiza os indicadores financeiros conforme o período. |
| 7. O administrador seleciona a opção "Ver Livro Razão de Hoje". |  |
|  | 8. O sistema apresenta a lista dos pagamentos recebidos e das liberações aos vendedores do dia, com hora, pedido, comprador, vendedor, tipo (pagamento ou liberação) e valor, e os totais do dia: recebido, liberado e retido em garantia. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador seleciona um período sem movimentação. |  |
|  | 2. O sistema mostra os indicadores com valor zero e informa que não houve movimentação no período. |
