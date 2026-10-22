| Nome do Caso de Uso | Criar Conta |
|---|---|
| Finalidade/Objetivo | Permitir que o visitante se cadastre informando seus dados básicos, tipo de usuário e aceitando os termos, e confirme o e-mail. |
| Atores | Visitante |
| Pré Condições | O visitante deve estar na Home ou na tela de Login. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O visitante seleciona a opção de 'Cadastrar'. |  |
|  | 2. Solicitar nome, e-mail, senha, confirmação da senha e o tipo de usuário (Cliente ou Vendedor). |
| 3. Informar os campos solicitados e aceitar os termos de uso. |  |
|  | 4. O sistema valida os campos (senha com no mínimo 8 caracteres, com letra, número e símbolo) e a disponibilidade do e-mail (sem diferenciar maiúsculas). |
|  | 5. O sistema registra o usuário com o e-mail ainda não confirmado, envia o link de confirmação (válido por 24 horas) e mostra a tela 'Confirme seu e-mail', com a opção de reenviar. |
| 6. O visitante abre o link de confirmação recebido. |  |
|  | 7. O sistema confirma o e-mail e leva à tela de Login com a mensagem 'E-mail confirmado'. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
|  | 1. Caso algum campo seja inválido, ou os termos não tenham sido aceitos, indicar o campo e não registrar. |
|  | 2. Caso o e-mail já esteja cadastrado, informar 'E-mail já cadastrado' e, se a conta ainda não confirmou o e-mail, oferecer o reenvio da confirmação. |
|  | 3. Caso o e-mail pertença a uma conta excluída, informar e oferecer a reativação (CCD052). |
|  | 4. Caso o envio do e-mail falhe, manter o cadastro e permitir o reenvio. |
| 5. O visitante pede o reenvio da confirmação. |  |
|  | 6. O sistema envia um novo link, respeitando o limite de pedidos. |
|  | 7. Caso o link de confirmação esteja expirado ou inválido, informar e oferecer o reenvio. |
