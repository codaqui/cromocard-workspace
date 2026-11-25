| Nome do Caso de Uso | Criar Anúncio |
|---|---|
| Finalidade/Objetivo | Como Vendedor preciso criar um anúncio para disponibilizar minhas cartas para venda no marketplace. |
| Atores | Vendedor |
| Pré Condições | O usuário deve estar autenticado com perfil de Vendedor, com a conta de recebimento pronta (Conectar Conta de Recebimento) e um endereço principal cadastrado, que é a origem do frete. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O vendedor seleciona "Criar anúncio" no Painel do vendedor, "Anunciar esta carta" no perfil da carta ou "Anunciar repetida" numa carta repetida da Início (só o vendedor vê esse botão). |  |
|  | 2. O sistema exibe o formulário de anúncio: a carta, escolhida por busca no catálogo (vindo do perfil da carta ou da Início, já escolhida), com a ajuda "Identificada no catálogo oficial <categoria> • <álbum>"; a condição, obrigatória (Mint, Near Mint, Ótimo, Bom ou Regular); o preço; a quantidade disponível, inteira de 1 a 99; a descrição, opcional, de até 2000 caracteres; e até 4 fotos, opcionais: dois espaços (frente e verso) e, preenchidos, mais espaços até 4. Enquanto o vendedor digita o preço, o sistema mostra a taxa de 5% e o valor líquido que ele recebe por unidade vendida. |
| 3. O vendedor preenche os dados e clica em "Publicar anúncio". |  |
|  | 4. O sistema valida as informações. |
|  | 5. O sistema cria o anúncio como ativo e o torna visível no marketplace. Sem fotos, o anúncio usa a imagem da carta no catálogo. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O vendedor informa um valor de venda zerado ou negativo |  |
|  | 2. O sistema exibe um alerta de validação 'Por favor, insira um valor válido maior que zero' |
| 3. O vendedor sem conta de recebimento pronta seleciona "Criar anúncio". |  |
|  | 4. O sistema avisa "Conecte sua conta de recebimento antes de anunciar" e oferece "Conectar conta Stripe" e "Agora não", que fecha o aviso. |
|  | 5. Caso o vendedor não tenha endereço principal, o sistema avisa "Cadastre seu endereço principal antes de anunciar. Ele é a origem do frete." e oferece "Cadastrar endereço", que leva ao Perfil. |
| 6. O vendedor publica sem escolher a condição ou com uma quantidade fora de 1 a 99. |  |
|  | 7. O sistema não publica e mostra o erro no campo. |
