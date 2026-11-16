| Nome do Caso de Uso | Configurações Globais |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador configure parâmetros gerais que afetam o funcionamento da plataforma: o banner da Home, as categorias padrão (com o verso padrão de cada franquia), os templates de notificação e as metas. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado e possuir permissão para alterar as configurações globais. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa a opção "Configurações Globais". |  |
|  | 2. O sistema apresenta as configurações disponíveis, cada uma num módulo com os botões Salvar e Cancelar: banner da Home, categorias padrão (quais franquias são padrão, a ordem e o verso padrão de cada uma), templates de notificação (lista, novo, editar e excluir) e metas (meta mensal de novos cadastros e meta de votos das sugestões de categoria). No módulo de templates não há Salvar e Cancelar do módulo: cada template é salvo no próprio formulário e excluído pela lista. |
| 3. O administrador seleciona uma configuração. |  |
|  | 4. O sistema apresenta os valores atuais da configuração. |
| 5. O administrador altera os valores desejados. Os templates de notificação são modelos de título e conteúdo que a tela de Disparar Notificação Global oferece para preencher: o administrador usa {campo} para os trechos que a pessoa completa naquela tela. |  |
|  | 6. O sistema valida as informações inseridas: o link do botão do banner começa com https://, a imagem do banner é WEBP ou PNG de até 4 MB (tamanho recomendado 1920×600), o nome de um template não se repete, a meta mensal de novos cadastros pode ficar vazia (sem meta) e a meta de votos é obrigatória. |
| 7. O administrador confirma as alterações. |  |
|  | 8. O sistema salva as novas configurações e registra a alteração no log de auditoria, com os valores antes e depois. O banner salvo passa a ser lido pela Home pública, sem login, mesmo quando está desligado: a Home é que decide não exibi-lo. |
|  | 9. O sistema confirma que as configurações do módulo foram atualizadas. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador informa um valor inválido para uma configuração. |  |
|  | 2. O sistema identifica o valor inválido e informa o administrador. |
| 3. O administrador corrige o valor. |  |
|  | 4. O sistema realiza novamente a validação. |
| 5. O administrador cancela as alterações. |  |
|  | 6. O sistema descarta as alterações e mantém as configurações anteriores. |
| 7. O administrador exclui um template de notificação. |  |
|  | 8. O sistema pede confirmação, remove o template e registra a alteração no log de auditoria. |
