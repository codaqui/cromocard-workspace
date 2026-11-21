| Nome do Caso de Uso | Conectar Conta de Recebimento |
|---|---|
| Finalidade/Objetivo | Permitir que o vendedor conecte uma conta Stripe para receber o valor das vendas, transferido pela plataforma depois da entrega. |
| Atores | Vendedor |
| Pré Condições | O usuário deve estar autenticado com perfil de Vendedor. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O vendedor acessa o Painel do vendedor sem a conta de recebimento pronta. |  |
|  | 2. O sistema mostra o aviso "Conecte sua conta de recebimento para vender" e o botão "Conectar conta Stripe". |
| 3. O vendedor seleciona "Conectar conta Stripe". |  |
|  | 4. O sistema cria a conta conectada do vendedor na Stripe, se ainda não existir, e o leva ao cadastro na página da Stripe. |
| 5. O vendedor preenche os dados na Stripe e volta para o CromoCard. |  |
|  | 6. O sistema mostra "Estamos verificando sua conta na Stripe" enquanto a Stripe analisa o cadastro. |
|  | 7. Quando a Stripe avisa que a conta pode receber transferências, o sistema marca a conta como pronta, tira o aviso e libera a criação de anúncios. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O vendedor sai do cadastro da Stripe sem terminar. |  |
|  | 2. O sistema mantém o aviso e permite continuar o cadastro de onde parou. |
|  | 3. Caso a Stripe peça mais informações ou recuse a conta, o sistema mostra o aviso com o botão para completar o cadastro, e os anúncios continuam bloqueados. |
