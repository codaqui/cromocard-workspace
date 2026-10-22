| Nome do Caso de Uso | Configurações Globais |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador configure parâmetros gerais que afetam o funcionamento da plataforma: o banner da Home, as categorias padrão e os templates de notificação. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado e possuir permissão para alterar as configurações globais. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa a opção "Configurações Globais". |  |
|  | 2. O sistema apresenta as configurações disponíveis: banner da Home, categorias padrão e templates de notificação. |
| 3. O administrador seleciona uma configuração. |  |
|  | 4. O sistema apresenta os valores atuais da configuração. |
| 5. O administrador altera os valores desejados. Os templates de notificação são modelos de título e conteúdo que a tela de Disparar Notificação Global oferece para preencher. |  |
|  | 6. O sistema valida as informações inseridas. |
| 7. O administrador confirma as alterações. |  |
|  | 8. O sistema salva as novas configurações e registra a alteração no log de auditoria. O banner salvo passa a ser lido pela Home pública, sem login. |
|  | 9. O sistema confirma que as configurações foram atualizadas. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador informa um valor inválido para uma configuração. |  |
|  | 2. O sistema identifica o valor inválido e informa o administrador. |
| 3. O administrador corrige o valor. |  |
|  | 4. O sistema realiza novamente a validação. |
| 5. O administrador cancela as alterações. |  |
|  | 6. O sistema descarta as alterações e mantém as configurações anteriores. |
