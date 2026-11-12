| Nome do Caso de Uso | Exportar Relatórios Gerenciais |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador gere e exporte relatórios com informações gerenciais da plataforma. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado e possuir permissão para exportar relatórios. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa a opção "Exportar Relatórios". |  |
|  | 2. O sistema apresenta os relatórios disponíveis ("Novos cadastros" e "Catálogo" e, no escopo adicional, "Auditoria de Lojistas" e "Volume Transacionado & Custódia"), o filtro de período e o histórico das exportações. |
| 3. O administrador seleciona o tipo de relatório e o período: Hoje, 7 dias, 30 dias, 1 ano ou um intervalo de datas. |  |
|  | 4. O sistema processa os filtros selecionados. |
|  | 5. O sistema apresenta a prévia do relatório, com as primeiras linhas e o total de registros. |
| 6. O administrador escolhe o formato pelos botões "Exportar PDF" ou "Exportar CSV". |  |
| 7. O administrador confirma a operação no resumo com o tipo, o período, o formato e o total de registros. |  |
|  | 8. O sistema gera o arquivo do relatório, guarda no histórico por 90 dias e registra a exportação no log de auditoria. |
|  | 9. O sistema disponibiliza o arquivo para o administrador. |
| 10. O administrador seleciona "Baixar" numa exportação do histórico. |  |
|  | 11. O sistema entrega o mesmo arquivo gerado na exportação; depois de 90 dias, oferece gerar de novo com os mesmos filtros (caso de uso 107). |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador seleciona filtros que não possuem dados. |  |
|  | 2. O sistema informa que não foram encontrados dados para os filtros selecionados e não permite exportar. |
| 3. O administrador altera os filtros. |  |
|  | 4. O sistema realiza uma nova consulta. |
| 5. O administrador cancela a exportação. |  |
|  | 6. O sistema cancela a operação sem gerar o arquivo. |
