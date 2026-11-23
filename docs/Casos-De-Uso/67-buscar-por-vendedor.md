| Nome do Caso de Uso | Buscar por Vendedor |
|---|---|
| Finalidade/Objetivo | Como Cliente preciso buscar cartas por vendedor para localizar anúncios de um vendedor específico na plataforma. |
| Atores | Cliente |
| Pré Condições | O cliente deve estar acessando a listagem de cartas do marketplace. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O cliente acessa a seção de busca do marketplace. |  |
| 2. O cliente abre o filtro "Vendedor" na linha de filtros do Explorar marketplace (Figma, 22/11/2026). |  |
| 3. O cliente informa o nome do vendedor. |  |
|  | 4. O sistema lista os vendedores cujo nome de usuário corresponde ao nome informado, com a cidade e o número de anúncios ativos de cada um. |
|  | 5. Quando o cliente escolhe um vendedor da lista, o sistema localiza os anúncios ativos dele. |
|  | 6. O sistema exibe os anúncios encontrados, com o chip "Vendedor: <nome> ✕" nos filtros ativos para desfazer o filtro. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
|  | 1. Caso nenhum vendedor seja encontrado, o sistema exibe a mensagem: “Nenhum vendedor encontrado.” |
|  | 2. Caso o vendedor não possua anúncios ativos, o sistema exibe a mensagem: “Este vendedor não possui anúncios ativos.” |
