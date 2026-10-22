| Nome do Caso de Uso | Log de Auditoria Admin |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador consulte o histórico das ações administrativas realizadas na plataforma. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado e possuir permissão para consultar os registros de auditoria. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa a opção "Log de Auditoria". |  |
|  | 2. O sistema apresenta os registros de ações administrativas, dos mais recentes para os mais antigos. |
| 3. O administrador aplica filtros de pesquisa, quando necessário: administrador responsável, tipo de ação, tipo de entidade, período e o ID do alvo. |  |
|  | 4. O sistema processa os filtros informados. |
|  | 5. O sistema apresenta os registros correspondentes, com a ação descrita em português. |
| 6. O administrador seleciona um registro. |  |
|  | 7. O sistema apresenta os detalhes da ação registrada, inclusive o motivo. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador realiza uma pesquisa sem resultados. |  |
|  | 2. O sistema informa que nenhum registro foi encontrado. |
| 3. O administrador altera os filtros. |  |
|  | 4. O sistema realiza uma nova pesquisa e apresenta os registros encontrados. |
