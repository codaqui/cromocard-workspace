| Nome do Caso de Uso | Votar em Solicitação de Catálogo |
|---|---|
| Finalidade/Objetivo | Permitir que os colecionadores votem a favor, neutro ou contra uma sugestão de nova categoria (franquia) e que o administrador use o resultado da votação para decidir. |
| Atores | Cliente, Administrador |
| Pré Condições | O cliente deve estar autenticado e existir uma solicitação de categoria pendente aberta para votação. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O cliente acessa a página "Sugestões da comunidade", com as sugestões de categoria em votação. |  |
|  | 2. O sistema apresenta as sugestões pendentes com a descrição e a contagem atual de votos. |
| 3. O cliente vota a favor, neutro ou contra uma sugestão. |  |
|  | 4. O sistema registra o voto, um por cliente em cada sugestão. |
|  | 5. O sistema atualiza a contagem de votos da sugestão. |
| 6. O administrador abre a solicitação na Fila de Solicitações. |  |
|  | 7. O sistema apresenta o quórum: total de votos, meta de votos (200 por padrão, configurável), percentual da meta e a divisão entre a favor, neutros e contra. |
| 8. O administrador aprova ou recusa a solicitação considerando o resultado. |  |
|  | 9. O sistema encerra a votação da sugestão. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O cliente vota de novo na mesma sugestão. |  |
|  | 2. O sistema troca o voto anterior pelo novo, sem contar dois votos. |
| 3. O cliente tenta votar numa sugestão já aprovada ou recusada. |  |
|  | 4. O sistema informa que a votação foi encerrada. |
