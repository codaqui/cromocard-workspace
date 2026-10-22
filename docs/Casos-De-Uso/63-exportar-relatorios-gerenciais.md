| Nome do Caso de Uso | Exportar Relatórios Gerenciais |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador gere e exporte relatórios com informações gerenciais da plataforma. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado e possuir permissão para exportar relatórios. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa a opção "Exportar Relatórios". |  |
|  | 2. O sistema apresenta os relatórios disponíveis ("Novos cadastros" e "Catálogo"), os filtros e o histórico das exportações. |
| 3. O administrador seleciona o tipo de relatório e os filtros desejados. |  |
|  | 4. O sistema processa os filtros selecionados. |
|  | 5. O sistema apresenta os dados do relatório. |
| 6. O administrador seleciona a opção "Exportar" e escolhe o formato (CSV ou PDF). |  |
| 7. O administrador confirma a operação. |  |
|  | 8. O sistema gera o arquivo do relatório e registra a exportação no log de auditoria. |
|  | 9. O sistema disponibiliza o arquivo para o administrador. |
| 10. O administrador seleciona "Baixar" numa exportação do histórico. |  |
|  | 11. O sistema gera o arquivo de novo, com o mesmo tipo, filtros e formato. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador seleciona filtros que não possuem dados. |  |
|  | 2. O sistema informa que não foram encontrados dados para os filtros selecionados. |
| 3. O administrador altera os filtros. |  |
|  | 4. O sistema realiza uma nova consulta. |
| 5. O administrador cancela a exportação. |  |
|  | 6. O sistema cancela a operação sem gerar o arquivo. |
