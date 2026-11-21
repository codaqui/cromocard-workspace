| Nome do Caso de Uso | Visualizar Destaques |
|---|---|
| Finalidade/Objetivo | Permitir que o visitante visualize na Home os destaques, as cartas mais procuradas, os anúncios recentes e as categorias padrão |
| Atores | Visitante |
| Pré Condições | O Usuário (Visistante) deve acessar a URL base da Aplicação. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O Visitante tera acesso a tela home da aplicação. |  |
|  | 2. O sistema apresenta o destaque principal, com os atalhos "Criar conta grátis" e "Explorar o marketplace"; a seção "Mais procuradas nos últimos 30 dias", com as 4 cartas com mais vendas concluídas nos últimos 30 dias; e a seção "Cartas recém-anunciadas", com os anúncios ativos mais recentes e um filtro pelas categorias padrão, na ordem definida em Ordenar Categorias Padrão, com a fixada no topo. |
| 3. O visitante navega pelas categorias e itens em destaque. |  |
|  | 4. O sistema abre o Explorar marketplace filtrado na categoria escolhida, o perfil da carta escolhida ou o anúncio escolhido. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
|  | 1. Caso não haja vendas concluídas nos últimos 30 dias, o sistema não mostra a seção "Mais procuradas". |
|  | 2. Caso não haja anúncios ativos, a seção "Cartas recém-anunciadas" informa que ainda não há anúncios. |
