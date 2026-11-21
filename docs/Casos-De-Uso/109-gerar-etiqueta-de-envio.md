| Nome do Caso de Uso | Gerar Etiqueta de Envio |
|---|---|
| Finalidade/Objetivo | Permitir que o vendedor gere a etiqueta de envio de um pedido pago, para postar a carta com rastreio. |
| Atores | Vendedor |
| Pré Condições | O vendedor deve estar autenticado e ter um pedido Pago, ainda não enviado. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O vendedor acessa "Pedidos e envios" no Painel do vendedor. |  |
|  | 2. O sistema lista as vendas por status (Aguardando envio, Em trânsito, Entregues e Cancelados), com o prazo de 2 dias para enviar. |
| 3. O vendedor seleciona "Gerar etiqueta" em um pedido aguardando envio. |  |
|  | 4. O sistema mostra a carta, o comprador, o endereço de entrega, o frete escolhido pelo comprador, o pacote padrão (envelope de 16 × 11 × 2 cm, 100 g, com o valor declarado igual ao preço da carta) e o remetente (o endereço principal do vendedor). |
| 5. O vendedor confirma "Gerar etiqueta". |  |
|  | 6. O sistema compra a etiqueta no Melhor Envio, como envio não comercial com declaração de conteúdo, marca o pedido como Enviado com o código de rastreio e avisa o comprador por e-mail. |
|  | 7. O sistema mostra "Etiqueta gerada", com o código de rastreio e o botão "Imprimir etiqueta". |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
|  | 1. Caso o Melhor Envio recuse a etiqueta, o sistema informa o motivo e mantém o pedido como Pago, para tentar de novo. |
|  | 2. Caso o vendedor passe do prazo de 2 dias, o pedido ganha o selo "atrasado" para o administrador. |
