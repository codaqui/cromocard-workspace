| Nome do Caso de Uso | Ordenar Categorias Padrão |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador defina a ordem em que as categorias padrão (franquias) aparecem no menu principal, nos filtros e na vitrine, e fixe uma categoria no topo. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado com permissão de administrador e existir pelo menos uma categoria padrão. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa Configurações Globais, no "Módulo 2: Categorias padrão". |  |
|  | 2. O sistema apresenta as categorias padrão na ordem atual, cada uma com a posição, o nome, o slug, a quantidade de cartas e o selo de exibição. A quantidade soma as cartas não excluídas ligadas à categoria ou às subcategorias dela, direto ou pelos álbuns delas. |
| 3. O administrador move uma categoria para cima ou para baixo, pelas setas ou arrastando. |  |
|  | 4. O sistema atualiza as posições na tela. |
| 5. O administrador marca uma categoria como "Fixado no topo" pelo botão de alfinete da linha, quando necessário (só uma por vez). |  |
|  | 6. O sistema coloca a categoria fixada na primeira posição, com o selo "Fixado no topo", e retira o fixado da categoria que estava fixada antes, se houver. |
| 7. O administrador seleciona "Salvar Ordem". |  |
|  | 8. O sistema grava a nova ordem e a categoria fixada junto com as demais alterações do módulo (categorias padrão e versos, da Configurações Globais) e registra a ação no log de auditoria. |
|  | 9. O sistema confirma a operação. A ordem gravada aqui é a que o menu, os filtros e a vitrine seguem, nos casos Visualizar Destaques e Buscar por Categoria. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador sai da tela sem salvar a ordem. |  |
|  | 2. O sistema descarta as mudanças e mantém a ordem anterior. |
| 3. O administrador tenta mover para cima a primeira categoria ou para baixo a última. |  |
|  | 4. O sistema mantém a posição, com a seta desabilitada. |
| 5. O administrador seleciona o alfinete da categoria fixada. |  |
|  | 6. O sistema retira o "Fixado no topo" da categoria, que continua na posição em que está até o administrador movê-la. |
| 7. O administrador tenta mover para baixo a categoria fixada ou passar outra categoria por cima dela. |  |
|  | 8. O sistema mantém a posição, com a seta desabilitada: a categoria fixada fica sempre no topo até ser desafixada. |
