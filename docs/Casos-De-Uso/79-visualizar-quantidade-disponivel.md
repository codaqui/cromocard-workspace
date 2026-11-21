| Nome do Caso de Uso | Visualizar Quantidade Disponível |
|---|---|
| Finalidade/Objetivo | Como Cliente preciso visualizar a quantidade disponível de uma carta para verificar se existe estoque suficiente antes de realizar uma compra. |
| Atores | Visitante, Cliente |
| Pré Condições | O ator deve estar visualizando o detalhe de um anúncio. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O ator acessa o detalhe do anúncio. |  |
|  | 2. O sistema busca a quantidade disponível da carta no anúncio. |
|  | 3. O sistema exibe a quantidade disponível, ao lado do preço e da condição. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
|  | 1. Caso a quantidade seja zero ou o anúncio esteja pausado, o sistema mostra "Indisponível" no lugar de "Comprar" e os outros anúncios da carta. |
