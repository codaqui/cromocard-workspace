| Nome do Caso de Uso | Visualizar Indicadores Financeiros |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador acompanhe no Dashboard os valores movimentados no marketplace: valor em custódia, valor liquidado no dia, valor retido em garantia e indicadores de confiança dos vendedores. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado com permissão de administrador e o marketplace (compra, pedidos e pagamentos) deve estar em funcionamento. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa o Dashboard Gerencial. |  |
|  | 2. O sistema apresenta o valor total em custódia (pagamentos recebidos e ainda não liberados ao vendedor). |
|  | 3. O sistema apresenta o valor liquidado no dia, a quantidade de pedidos liberados e o valor retido em garantia. |
|  | 4. O sistema apresenta, na lista de vendedores, o volume anunciado e a nota de reputação de cada vendedor. |
| 5. O administrador seleciona o período: Hoje, 7 dias, 30 dias ou 1 ano. |  |
|  | 6. O sistema atualiza os indicadores financeiros conforme o período. |
| 7. O administrador seleciona a opção "Ver Livro Razão de Hoje". |  |
|  | 8. O sistema apresenta a lista dos pagamentos e liberações do dia. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador seleciona um período sem movimentação. |  |
|  | 2. O sistema mostra os indicadores com valor zero e informa que não houve movimentação no período. |
