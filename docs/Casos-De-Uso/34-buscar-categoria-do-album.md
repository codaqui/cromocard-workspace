| Nome do Caso de Uso | Buscar Categoria do Álbum |
|---|---|
| Finalidade/Objetivo | Como Cliente preciso selecionar a categoria por seleções e times do álbum para filtrar figurinhas exatos dentro da minha coleção. |
| Atores | Cliente |
| Pré Condições | O cliente deve estar autenticado e no detalhe de um álbum da sua coleção. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O cliente abre o filtro "Seleção" na linha de filtros do detalhe do álbum e escolhe uma seleção ou time da lista (cada opção mostra quantas figurinhas dele o cliente tem); "Todas as seleções" desfaz o filtro (Figma, 22/11/2026) |  |
|  | 2. O sistema processa a seleção e aplica o filtro na coleção do cliente |
|  | 3. O sistema exibe apenas as figurinhas correspondentes à seleção/time escolhido e atualiza a contagem "Exibindo N de M itens" |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
|  | 1. Caso o cliente não possua figurinhas na categoria selecionada, o sistema exibe a mensagem 'Nenhuma figurinha encontrada para esta categoria' |
