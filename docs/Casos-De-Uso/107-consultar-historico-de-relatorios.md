| Nome do Caso de Uso | Consultar Histórico de Relatórios |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador veja os relatórios exportados recentemente pela equipe e baixe de novo um arquivo já gerado. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado com permissão de administrador. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa Exportar Relatórios. |  |
|  | 2. O sistema apresenta o histórico de relatórios exportados com o código, o tipo e o período do relatório, quem solicitou, a data e hora, o formato e o tamanho do arquivo. |
| 3. O administrador seleciona "Baixar" num relatório do histórico. |  |
|  | 4. O sistema disponibiliza o mesmo arquivo gerado na exportação. |
|  | 5. O sistema mantém cada arquivo disponível por 90 dias. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador tenta baixar um relatório com mais de 90 dias. |  |
|  | 2. O sistema informa que o arquivo expirou e oferece gerar o relatório de novo com os mesmos filtros. |
|  | 3. Ainda não há relatórios exportados. |
|  | 4. O sistema informa que o histórico está vazio. |
