| Nome do Caso de Uso | Comprar |
|---|---|
| Finalidade/Objetivo | Como Cliente preciso comprar uma carta anunciada no marketplace, com o pagamento retido pela plataforma até a carta ser entregue. |
| Atores | Cliente |
| Pré Condições | O cliente deve estar autenticado, com a conta ativa, e o anúncio deve estar ativo, com quantidade disponível, e não ser do próprio cliente. Vendedores também compram, como clientes. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O cliente seleciona "Comprar" no detalhe do anúncio. |  |
|  | 2. O sistema apresenta o checkout com a carta, a condição, o vendedor, o endereço de entrega e as opções de frete. Cada pedido tem uma unidade de um anúncio. |
| 3. O cliente escolhe ou cadastra o endereço de entrega e informa o CPF, se o cadastro ainda não tiver. |  |
|  | 4. O sistema calcula as opções de frete (Correios e Jadlog) a partir do CEP do endereço principal do vendedor, do CEP de entrega e do pacote padrão de uma carta, com o preço e o prazo de cada uma. |
| 5. O cliente escolhe o frete e seleciona "Ir para o pagamento". |  |
|  | 6. O sistema confere de novo a disponibilidade, cria o pedido como "Aguardando pagamento", com o total (carta + frete) em reais, reserva a carta por 30 minutos e leva o cliente à página de pagamento da Stripe. |
| 7. O cliente paga com cartão na página da Stripe. |  |
|  | 8. O sistema recebe a confirmação da Stripe, marca o pedido como "Pago", mantém o valor retido na plataforma e avisa o vendedor por e-mail que há uma venda paga para enviar. |
|  | 9. O sistema mostra ao cliente "Pagamento confirmado", com o número do pedido e o prazo de 2 dias para o vendedor enviar. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O visitante seleciona "Comprar". |  |
|  | 2. O sistema mostra "Entre para continuar"; depois do login, o usuário volta para o anúncio. |
|  | 3. Caso o anúncio esteja esgotado ou pausado, o sistema mostra "Indisponível" no lugar de "Comprar" e os outros anúncios da carta. No próprio anúncio, o botão "Comprar" não aparece. |
|  | 4. Caso a carta esgote antes do pagamento (passo 6), o sistema informa que ela não está mais disponível e volta ao anúncio. |
|  | 5. Caso não haja frete para o CEP de entrega, o sistema informa e pede outro endereço. |
| 6. O cliente cancela na página da Stripe ou não paga em 30 minutos. |  |
|  | 7. O sistema marca o pedido como "Cancelado", com o motivo "pagamento não concluído", devolve a carta ao estoque e mostra "Pagamento não concluído", com "Tentar de novo". O pedido continua em Meus pedidos. |
|  | 8. Caso o cartão seja recusado, a própria página da Stripe informa e permite usar outro cartão. |
