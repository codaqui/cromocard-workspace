| Nome do Caso de Uso | Criar Anúncio |
|---|---|
| Finalidade/Objetivo | Como Vendedor preciso criar um anúncio para disponibilizar minhas cartas para venda no marketplace. |
| Atores | Vendedor |
| Pré Condições | O usuário deve estar autenticado com perfil de Vendedor, com a conta de recebimento pronta (Conectar Conta de Recebimento) e um endereço principal cadastrado, que é a origem do frete. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O vendedor seleciona "Criar anúncio" no Painel do vendedor ou "Anunciar esta carta" no perfil da carta. |  |
|  | 2. O sistema exibe o formulário de anúncio: a carta, escolhida por busca no catálogo; a condição (Mint, Near Mint, Ótimo, Bom ou Regular); o preço; a quantidade disponível; a descrição; e até 4 fotos, opcionais. |
| 3. O vendedor preenche os dados e clica em "Publicar anúncio". |  |
|  | 4. O sistema valida as informações e mostra a taxa de 5% e o valor líquido que o vendedor recebe por unidade vendida. |
|  | 5. O sistema cria o anúncio como ativo e o torna visível no marketplace. Sem fotos, o anúncio usa a imagem da carta no catálogo. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O vendedor informa um valor de venda zerado ou negativo |  |
|  | 2. O sistema exibe um alerta de validação 'Por favor, insira um valor válido maior que zero' |
|  | 3. Sem a conta de recebimento pronta, o sistema mostra "Criar anúncio" desabilitado e o aviso da conta de recebimento no Painel do vendedor (CCD108). |
|  | 4. Se a criação chegar ao sistema mesmo assim, ele recusa com o aviso "Conecte sua conta de recebimento antes de anunciar" e oferece "Conectar conta Stripe". |
|  | 5. Caso o vendedor não tenha endereço principal, o sistema pede o cadastro do endereço antes de publicar. |
