| Nome do Caso de Uso | Buscar por Categoria |
|---|---|
| Finalidade/Objetivo | Permitir que o cliente filtre cartas ou figurinhas por categoria para encontrar itens de um determinado tipo. |
| Atores | Cliente |
| Pré Condições | O cliente deve estar autenticado e estar na tela de pesquisa de cartas. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O cliente seleciona a categoria desejada no filtro de busca, que lista as categorias padrão na ordem definida em Ordenar Categorias Padrão, com a fixada no topo. |  |
|  | 2. O sistema filtra as cartas que pertencem à categoria selecionada. |
|  | 3. O sistema exibe a lista de cartas encontradas. |
| 4. O cliente seleciona a carta desejada na lista de resultados. |  |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
|  | 1. Se o sistema não encontrar cartas para a categoria selecionada, exibe a mensagem 'Nenhuma carta encontrada com os termos informados'. |
