| Nome do Caso de Uso | Buscar Global |
|---|---|
| Finalidade/Objetivo | Permitir que o visitante busque cartas, usuários e grupos diretamente no painel público. |
| Atores | Visitante |
| Pré Condições | O visitante deve estar na tela Home ou ter a barra de busca visível. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O visitante seleciona a barra de busca global. |  |
|  | 2. O sistema habilita o campo para digitação. |
| 3. O visitante informa o termo desejado (ex: nome da carta) e submete a busca. |  |
|  | 4. O sistema valida o termo e realiza a consulta no banco de dados. |
|  | 5. O sistema apresenta os resultados agrupados em Cartas (anúncios ativos), Usuários, Grupos e Álbuns, com abas para ver só um grupo; cada carta leva ao perfil da carta. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
|  | 1. Caso a busca não retorne nenhum resultado, exibir a mensagem 'Nenhum resultado encontrado para o termo pesquisado'. |
