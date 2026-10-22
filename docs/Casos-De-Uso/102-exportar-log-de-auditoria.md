| Nome do Caso de Uso | Exportar Log de Auditoria |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador baixe em arquivo os registros do log de auditoria que estão na tela, com os filtros aplicados. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado com permissão de administrador. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa o Log de Auditoria e aplica os filtros desejados. |  |
|  | 2. O sistema apresenta os registros correspondentes. |
| 3. O administrador seleciona a opção "Extrair Logs". |  |
|  | 4. O sistema gera o arquivo com os registros filtrados: data e hora, responsável, ação, alvo e justificativa. |
|  | 5. O sistema disponibiliza o arquivo para download. |
|  | 6. O sistema registra a exportação no log de auditoria. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador seleciona "Extrair Logs" com filtros sem registros. |  |
|  | 2. O sistema informa que não há registros para exportar e não gera o arquivo. |
