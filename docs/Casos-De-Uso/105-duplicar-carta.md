| Nome do Caso de Uso | Duplicar Carta |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador crie uma carta nova no catálogo a partir de uma carta existente, aproveitando os dados em comum (franquia, álbum, raridade e idioma). |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado com permissão para gerenciar o catálogo. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador seleciona a ação "Duplicar" numa carta da lista de Gestão de Catálogo. |  |
|  | 2. O sistema abre o formulário de cadastro de carta preenchido com os dados da carta de origem, sem a numeração e sem as imagens. |
| 3. O administrador informa a numeração, as imagens e ajusta os demais dados. |  |
| 4. O administrador confirma o cadastro. |  |
|  | 5. O sistema valida os dados como num cadastro novo. |
|  | 6. O sistema grava a nova carta, registra a ação no log de auditoria e confirma a operação. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador confirma com a mesma numeração da carta de origem no mesmo álbum. |  |
|  | 2. O sistema informa que a numeração já existe no álbum. |
| 3. O administrador cancela. |  |
|  | 4. O sistema fecha o formulário sem criar a carta. |
