| Nome do Caso de Uso | Favoritar Grupo |
|---|---|
| Finalidade/Objetivo | Permitir que o usuário favorite um grupo para facilitar seu acesso e acompanhamento dentro da plataforma. |
| Atores | Cliente |
| Pré Condições | O usuário deve estar autenticado e o grupo deve estar disponível para visualização. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário acessa o grupo que deseja favoritar. |  |
|  | 2. O sistema apresenta a opção de favoritar o grupo. |
| 3. O usuário seleciona a opção "Favoritar". |  |
|  | 4. O sistema registra o grupo como favorito para o usuário. |
|  | 5. O sistema atualiza o indicador visual do grupo e confirma a ação ao usuário. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário seleciona novamente a opção de favorito em um grupo já favoritado. |  |
|  | 2. O sistema remove o grupo da lista de favoritos e atualiza o indicador visual. |
| 3. O usuário tenta favoritar um grupo indisponível. |  |
|  | 4. O sistema impede a operação e informa que o grupo não está disponível para ser favoritado. |
