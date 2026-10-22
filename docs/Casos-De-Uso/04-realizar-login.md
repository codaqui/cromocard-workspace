| Nome do Caso de Uso | Realizar Login |
|---|---|
| Finalidade/Objetivo | Permitir que o visitante faça login com e-mail/senha ou com a conta Google para acessar sua conta. |
| Atores | Visitante |
| Pré Condições | O visitante deve possuir um cadastro ativo, com o e-mail confirmado, e estar na tela de Login. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O visitante acessa a tela de Login. |  |
|  | 2. Apresentar os campos de e-mail e senha, a opção "Lembrar de mim" (desmarcada) e o login com Google. |
| 3. O visitante informa e-mail e senha, marca ou não "Lembrar de mim" e clica em entrar. |  |
|  | 4. O sistema valida os campos preenchidos e confere o e-mail (sem diferenciar maiúsculas) e a senha. |
|  | 5. O sistema inicia a sessão do usuário (por 30 dias com "Lembrar de mim"; sem ela, até fechar o navegador) e o redireciona para a página inicial da sua área: Cliente e Vendedor para o Painel Cliente, Administrador para o BackOffice. Se o visitante tentou abrir uma página protegida antes, volta para ela. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
|  | 1. Caso as credenciais não coincidam com a base de dados (inclusive numa conta que só entra pelo Google), emitir mensagem de erro 'E-mail ou senha incorretos'. |
|  | 2. Caso o e-mail ainda não tenha sido confirmado, informar 'Confirme seu e-mail para entrar' e oferecer o reenvio da confirmação. |
|  | 3. Caso a conta esteja suspensa, informar 'Sua conta está suspensa. Entre em contato com o suporte.' |
|  | 4. Caso a conta tenha sido excluída, informar que a conta foi excluída e oferecer a reativação (CCD052). |
| 5. O visitante escolhe entrar com o Google. |  |
|  | 6. O sistema valida a conta Google. Se o e-mail já tem conta, vincula e entra; se não tem, cria uma conta de Cliente com o e-mail confirmado e os termos aceitos (o aviso "Ao continuar, você aceita os Termos de Uso" fica junto do botão) e entra. |
| 7. O usuário logado clica em "Sair" no cabeçalho. |  |
|  | 8. O sistema encerra a sessão e volta para a área pública. |
