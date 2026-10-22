| Nome do Caso de Uso | Salvar Rascunho de Carta |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador salve o cadastro de uma carta incompleto, como rascunho que não aparece no catálogo, para terminar depois. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado com permissão para gerenciar o catálogo. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador preenche parte do formulário "Cadastrar Nova Carta no Catálogo". |  |
| 2. O administrador seleciona "Salvar como Rascunho". |  |
|  | 3. O sistema grava a carta como rascunho exigindo só o nome. |
|  | 4. O sistema não exibe a carta no catálogo, nas buscas nem nas coleções. |
| 5. O administrador abre o rascunho mais tarde pelo filtro "Rascunhos" da Gestão de Catálogo. |  |
|  | 6. O sistema apresenta o formulário com os dados salvos. |
| 7. O administrador completa os dados e seleciona "Cadastrar Carta no Catálogo". |  |
|  | 8. O sistema valida todos os campos obrigatórios, publica a carta no catálogo e registra a ação no log de auditoria. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador tenta publicar o rascunho com campos obrigatórios vazios. |  |
|  | 2. O sistema indica os campos que faltam e mantém a carta como rascunho. |
| 3. O administrador exclui o rascunho. |  |
|  | 4. O sistema remove o rascunho. |
