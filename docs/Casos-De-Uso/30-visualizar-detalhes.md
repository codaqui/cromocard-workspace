| Nome do Caso de Uso | Visualizar Detalhes |
|---|---|
| Finalidade/Objetivo | Permitir que o visitante ou o cliente visualize os detalhes de uma carta para conhecer suas características antes de realizar uma compra. |
| Atores | Visitante, Cliente |
| Pré Condições | Nenhuma: o visitante vê a página inteira. Comprar, favoritar e adicionar à coleção pedem login. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O ator seleciona a carta na busca, no marketplace ou na Home. |  |
|  | 2. O sistema apresenta o perfil da carta: o caminho (Início / Marketplace / categoria / álbum / carta), os selos de raridade, álbum e categoria, o nome, o subtítulo "Nº <número> • <álbum>", as imagens (a principal e uma miniatura para cada imagem: frente, verso e fotos de detalhe), o preço médio de mercado (média das vendas concluídas nos últimos 30 dias; sem vendas, "—"), o menor anúncio, a quantidade de anúncios ativos com estoque, o botão "Ver anúncios (<n>)", que leva à lista, os dados de identificação (Visualizar Informações da Carta), o histórico de preços (Visualizar Histórico de Preços) e a lista "Anúncios disponíveis (<n>)", com a nota "Pagamento retido pela CromoCard até você receber a carta", vendedor, condição ("—" quando o anúncio não tem condição) e preço, ordenada pelo menor preço e carregada de 20 em 20 ("Carregar mais"). Anúncio pausado, encerrado, excluído ou sem estoque não entra na lista, na contagem nem no menor anúncio. |
| 3. O ator navega pelas informações apresentadas. |  |
| 4. O ator seleciona "Ver anúncio" em um dos anúncios. |  |
|  | 5. O sistema abre o detalhe do anúncio, de onde parte a compra (Comprar). |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O visitante seleciona "Favoritar" ou "Adicionar à coleção". |  |
|  | 2. O sistema mostra "Entre para continuar", com "Continuar com Google", "Entrar com e-mail e senha" e "Criar conta grátis"; depois do login ou do cadastro, o usuário volta para a carta (o login pelo Google é da CCD004 e, até ela existir, leva a uma página em construção). O visitante vê ainda o aviso "Ainda não tem conta? Você pode ver tudo nesta página; para comprar, favoritar ou adicionar à coleção, basta entrar."; o usuário logado não vê o aviso. |
|  | 3. Caso a carta não tenha anúncios ativos, a lista informa que não há anúncios, e o vendedor logado vê a opção "Anunciar esta carta" (o visitante não vê o botão); o botão leva a Criar Anúncio. |
|  | 4. Caso a carta não exista, tenha sido excluída ou seja um rascunho, o sistema mostra "Carta não encontrada", com o link "Voltar para o marketplace", que leva à página inicial enquanto o marketplace não tem tela própria. |
