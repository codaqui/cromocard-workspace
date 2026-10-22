| Nome do Caso de Uso | Ordenar Categorias Padrão |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador defina a ordem em que as categorias padrão (franquias) aparecem no menu principal, nos filtros e na vitrine, e fixe uma categoria no topo. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado com permissão de administrador e existir pelo menos uma categoria padrão. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa Configurações Globais, no módulo "Ordenação e Gestão de Categorias Padrão". |  |
|  | 2. O sistema apresenta as categorias padrão na ordem atual, cada uma com a posição, o nome, o slug, a quantidade de cartas e o selo de exibição. |
| 3. O administrador move uma categoria para cima ou para baixo, pelas setas ou arrastando. |  |
|  | 4. O sistema atualiza as posições na tela. |
| 5. O administrador marca uma categoria como "Fixado no topo", quando necessário. |  |
|  | 6. O sistema coloca a categoria fixada na primeira posição. |
| 7. O administrador seleciona "Salvar Ordem". |  |
|  | 8. O sistema grava a nova ordem e registra a ação no log de auditoria. |
|  | 9. O sistema passa a exibir as categorias nessa ordem no menu, nos filtros e na vitrine e confirma a operação. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador sai da tela sem salvar a ordem. |  |
|  | 2. O sistema descarta as mudanças e mantém a ordem anterior. |
| 3. O administrador tenta mover para cima a primeira categoria ou para baixo a última. |  |
|  | 4. O sistema mantém a posição, com a seta desabilitada. |
