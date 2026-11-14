| Nome do Caso de Uso | Favoritar Carta |
|---|---|
| Finalidade/Objetivo | Permitir que o usuário favorite uma carta para facilitar seu acesso e acompanhamento dentro da plataforma. |
| Atores | Cliente |
| Pré Condições | O usuário deve estar autenticado e a carta deve estar disponível para visualização. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário acessa a carta que deseja favoritar. |  |
|  | 2. O sistema apresenta a opção de favoritar a carta. |
| 3. O usuário seleciona a opção "Favoritar". |  |
|  | 4. O sistema registra a carta como favorita para o usuário. |
|  | 5. O sistema atualiza o indicador visual da carta e confirma a ação ao usuário. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O usuário seleciona novamente a opção de favorito em uma carta já favoritada. |  |
|  | 2. O sistema remove a carta da lista de favoritos e atualiza o indicador visual. |
| 3. O usuário tenta favoritar uma carta indisponível. |  |
|  | 4. O sistema impede a operação e informa que a carta não está disponível para ser favoritada. |
