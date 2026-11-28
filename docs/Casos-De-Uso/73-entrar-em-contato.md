| Nome do Caso de Uso | Entrar em Contato |
|---|---|
| Finalidade/Objetivo | Como Cliente preciso entrar em contato com o vendedor para esclarecer dúvidas ou negociar informações sobre uma carta anunciada. |
| Atores | Cliente |
| Pré Condições | O cliente deve estar autenticado e visualizando um anúncio ativo de outro usuário. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O cliente acessa os detalhes do anúncio. |  |
| 2. O cliente seleciona a opção “Entrar em contato”, no quadro do vendedor. |  |
|  | 3. O sistema identifica o vendedor responsável pelo anúncio. |
|  | 4. O sistema abre a conversa entre o cliente e o vendedor em Mensagens, criando-a se ainda não existir. Há uma conversa só por par de usuários: uma conversa que já existe é reaproveitada, mesmo que tenha começado por outro anúncio ou pela Nova conversa. |
|  | 5. O sistema preenche o campo de mensagem com o texto sugerido “Olá! Tenho interesse no anúncio <carta> (<preço>).”. |
| 6. O cliente edita, se quiser, e envia a mensagem ao vendedor. |  |
|  | 7. O sistema envia a mensagem, e o vendedor a recebe em tempo real na conversa. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
|  | 1. Caso o vendedor não esteja disponível para contato (conta suspensa, bloqueada ou excluída) ou tenha bloqueado o cliente, o sistema informa no anúncio “Não foi possível iniciar a conversa com este vendedor.” e não abre a conversa. |
|  | 2. Caso o cliente tenha bloqueado o vendedor, o sistema informa no anúncio “Você bloqueou @<vendedor>. Para conversar de novo, desbloqueie em Configurações › Privacidade.” e não abre a conversa. |
| 3. O visitante sem login seleciona “Entrar em contato”. | 4. O sistema mostra o aviso “Entre para continuar”, como em Comprar e Favoritar. |
|  | 5. No anúncio do próprio cliente, a opção “Entrar em contato” não aparece. |
