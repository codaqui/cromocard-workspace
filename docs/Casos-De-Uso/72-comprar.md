| Nome do Caso de Uso | Comprar |
|---|---|
| Finalidade/Objetivo | Como Cliente preciso comprar uma carta para adquirir um item disponível no marketplace. |
| Atores | Cliente |
| Pré Condições | O cliente deve estar autenticado e a carta deve possuir quantidade disponível. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O cliente acessa os detalhes de uma carta. |  |
| 2. O cliente seleciona a opção “Comprar”. |  |
| 3. O cliente informa ou seleciona o endereço de entrega. |  |
| 4. O cliente seleciona a forma de envio. |  |
| 5. O cliente seleciona a forma de pagamento. |  |
| 6. O cliente confirma a compra. |  |
|  | 7. O sistema verifica a disponibilidade da carta. |
|  | 8. O sistema calcula as informações necessárias para a compra. |
|  | 9. O sistema processa o pedido. |
|  | 10. O sistema registra a compra. |
|  | 11. O sistema atualiza a quantidade disponível. |
|  | 12. O sistema notifica o vendedor sobre o novo pedido. |
|  | 13. O sistema confirma a compra ao cliente. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
|  | 1. Caso a carta não esteja mais disponível, o sistema informa que o item não possui estoque suficiente. |
|  | 2. Caso o pagamento não seja aprovado, o sistema informa que não foi possível concluir a compra. |
|  | 3. Caso ocorra algum erro durante a finalização, o sistema informa ao cliente que a compra não foi concluída. |
