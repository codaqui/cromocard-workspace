| Nome do Caso de Uso | Gestão de Catálogo |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador cadastre, edite, remova e importe em lote as cartas, os álbuns e as categorias do catálogo global da plataforma. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado e possuir permissão para gerenciar o catálogo. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa a opção "Gestão de Catálogo". |  |
|  | 2. O sistema apresenta os itens cadastrados no catálogo, nas abas de cartas, álbuns e categorias, com busca por nome ou código, filtros e paginação. A aba de cartas filtra por franquia, álbum, raridade, ano e status (publicadas ou rascunhos) e mostra os filtros ativos. Raridades e idiomas vêm prontos e não são editados aqui. |
| 3. O administrador seleciona a opção de cadastrar, editar ou remover um item, ou seleciona várias cartas para excluir de uma vez. |  |
|  | 4. O sistema apresenta o formulário ou as opções correspondentes. |
| 5. O administrador informa ou altera os dados do item. Na carta, informa o nome, a franquia, a raridade e o idioma (obrigatórios para publicar) e, se quiser, o álbum, a numeração, o código, as variantes, o ano de lançamento e a descrição; envia a imagem da frente (obrigatória) e a do verso (opcional; sem verso, a carta usa o verso padrão da franquia). No álbum, só o título é obrigatório. Na categoria, o nome e o tipo são obrigatórios e o slug é gerado a partir do nome. |  |
|  | 6. O sistema valida os dados informados. A numeração não pode se repetir no mesmo álbum, e o código não pode se repetir no catálogo. |
| 7. O administrador confirma a operação. |  |
|  | 8. O sistema registra a operação realizada. O total de cartas do álbum é calculado pelas cartas dele. |
|  | 9. O sistema atualiza o catálogo e confirma a operação. |
| 10. O administrador escolhe importar cartas por um arquivo CSV, a partir do modelo para baixar. |  |
|  | 11. O sistema valida todas as linhas e só grava se todas estiverem corretas, informando quantas cartas foram importadas; havendo erro, informa as linhas com problema e não grava nenhuma. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador informa dados inválidos. |  |
|  | 2. O sistema informa os dados que precisam ser corrigidos. |
| 3. O administrador corrige os dados. |  |
|  | 4. O sistema realiza novamente a validação. |
| 5. O administrador tenta remover um item que possui vínculos que impedem sua exclusão: álbum com cartas; categoria com álbuns, cartas ou subcategorias; carta já usada em coleções. |  |
|  | 6. O sistema impede a exclusão e informa o motivo. |
| 7. O administrador exclui um item sem vínculos, ou várias cartas selecionadas. |  |
|  | 8. O sistema pede a confirmação (na exclusão em lote, também o motivo), exclui os itens, registra a ação no log de auditoria e, no lote, informa as cartas que não foram excluídas por estarem em coleções. |
