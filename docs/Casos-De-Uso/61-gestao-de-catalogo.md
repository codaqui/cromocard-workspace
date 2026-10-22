| Nome do Caso de Uso | Gestão de Catálogo |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador cadastre, edite, remova e importe em lote as cartas, os álbuns e as categorias do catálogo global da plataforma. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado e possuir permissão para gerenciar o catálogo. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa a opção "Gestão de Catálogo". |  |
|  | 2. O sistema apresenta os itens cadastrados no catálogo, nas abas de cartas, álbuns e categorias. Raridades e idiomas vêm prontos e não são editados aqui. |
| 3. O administrador seleciona a opção de cadastrar, editar ou remover um item. |  |
|  | 4. O sistema apresenta o formulário ou as opções correspondentes. |
| 5. O administrador informa ou altera os dados do item. Na carta, envia a imagem da frente (obrigatória) e a do verso (opcional). |  |
|  | 6. O sistema valida os dados informados. |
| 7. O administrador confirma a operação. |  |
|  | 8. O sistema registra a operação realizada. O total de cartas do álbum é calculado pelas cartas dele. |
|  | 9. O sistema atualiza o catálogo e confirma a operação. |
| 10. O administrador escolhe importar cartas por um arquivo CSV, a partir do modelo para baixar. |  |
|  | 11. O sistema valida todas as linhas e só grava se todas estiverem corretas; havendo erro, informa as linhas com problema e não grava nenhuma. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador informa dados inválidos. |  |
|  | 2. O sistema informa os dados que precisam ser corrigidos. |
| 3. O administrador corrige os dados. |  |
|  | 4. O sistema realiza novamente a validação. |
| 5. O administrador tenta remover um item que possui vínculos que impedem sua exclusão: álbum com cartas; categoria com álbuns, cartas ou subcategorias; carta já usada em coleções. |  |
|  | 6. O sistema impede a exclusão e informa o motivo. |
