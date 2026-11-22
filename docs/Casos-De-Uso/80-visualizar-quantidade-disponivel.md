| Nome do Caso de Uso | Visualizar Quantidade Disponível |
|---|---|
| Finalidade/Objetivo | Como Cliente preciso visualizar os dados do vendedor para conhecer suas informações e avaliar sua confiabilidade antes de realizar uma compra. |
| Atores | Visitante, Cliente |
| Pré Condições | O ator deve estar visualizando o detalhe de um anúncio ou a lista de anúncios do perfil da carta. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O ator acessa o detalhe de um anúncio. |  |
|  | 2. O sistema busca os dados públicos do vendedor. |
|  | 3. O sistema exibe o nome de usuário do vendedor, a cidade e o estado (sem nota de avaliação: as avaliações saíram do projeto em 22/11/2026, ADR-068). |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
|  | 1. Caso algumas informações não estejam disponíveis, o sistema exibe apenas os dados públicos cadastrados pelo vendedor. |
