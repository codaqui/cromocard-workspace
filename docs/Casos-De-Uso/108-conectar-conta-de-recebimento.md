| Nome do Caso de Uso | Conectar Conta de Recebimento |
|---|---|
| Finalidade/Objetivo | Permitir que o vendedor conecte uma conta Stripe para receber o valor das vendas, transferido pela plataforma depois da entrega. |
| Atores | Vendedor |
| Pré Condições | O usuário deve estar autenticado com perfil de Vendedor. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O vendedor acessa o Painel do vendedor sem a conta de recebimento pronta. |  |
|  | 2. O sistema mostra o aviso "Conecte sua conta de recebimento para vender", com a ajuda "O cadastro é feito na própria Stripe e leva poucos minutos. Sem a conta pronta, não é possível publicar anúncios.", e o botão "Conectar conta Stripe". "Criar Novo Anúncio" e "Criar Anúncio" ficam desabilitados. |
| 3. O vendedor seleciona "Conectar conta Stripe". |  |
|  | 4. O sistema cria a conta conectada do vendedor na Stripe, se ainda não existir, e o leva ao cadastro na página da Stripe. |
| 5. O vendedor preenche os dados na Stripe e volta para o CromoCard. |  |
|  | 6. Na volta, o sistema consulta a conta na Stripe e, enquanto ela analisa o cadastro, mostra "Estamos verificando sua conta na Stripe", com o selo "Verificando" e a ajuda "Você poderá publicar anúncios assim que a Stripe liberar a conta. Isso costuma levar poucos minutos." |
|  | 7. Quando a Stripe avisa que a conta pode receber transferências, o sistema marca a conta como pronta, tira o aviso e libera a criação de anúncios. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O vendedor sai do cadastro da Stripe sem terminar. |  |
|  | 2. O sistema mostra o aviso "Termine seu cadastro na Stripe para vender" com o botão "Continuar cadastro", que retoma o cadastro de onde parou, na mesma conta. |
|  | 3. Caso a Stripe peça mais informações ou recuse a conta, o sistema mostra o aviso "A Stripe precisa de mais informações" com o botão "Completar cadastro", e os anúncios continuam bloqueados. |
|  | 4. Caso a Stripe suspenda as transferências de uma conta que já estava pronta, o sistema volta a mostrar o aviso e bloqueia criar e reativar anúncios; os anúncios ativos continuam ativos. |
