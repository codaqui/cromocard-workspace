# CCD024 — Buscar por Nome

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #157 `CCD024 - Buscar por Nome`
- **Agrupa:** CCD025 Buscar por Número (#158), CCD026 Buscar por Coleção (#159), CCD027 Buscar por Categoria (#160), CCD028 Buscar por Raridade (#161), CCD029 Buscar por Idioma (#162)
- **Caso de uso:** [24-buscar-por-nome.md](../../docs/Casos-De-Uso/24-buscar-por-nome.md), [25-buscar-por-numero.md](../../docs/Casos-De-Uso/25-buscar-por-numero.md), [26-buscar-por-colecao.md](../../docs/Casos-De-Uso/26-buscar-por-colecao.md), [27-buscar-por-categoria.md](../../docs/Casos-De-Uso/27-buscar-por-categoria.md), [28-buscar-por-raridade.md](../../docs/Casos-De-Uso/28-buscar-por-raridade.md), [29-buscar-por-idioma.md](../../docs/Casos-De-Uso/29-buscar-por-idioma.md)
- **Atores:** Cliente · **Pré-condições:** autenticado e na tela de pesquisa de cartas (L1, L2)
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso buscar cartas por nome para localizar um item específico.
> Como Cliente preciso buscar cartas por número para encontrar uma carta específica dentro de uma coleção.
> Como Cliente preciso buscar cartas por coleção para visualizar itens pertencentes a uma coleção específica.
> Como Cliente preciso filtrar cartas por categoria para encontrar itens de um determinado tipo.
> Como Cliente preciso filtrar cartas por raridade para encontrar itens com características específicas.
> Como Cliente preciso filtrar cartas por idioma para encontrar cartas na língua desejada.

## Fidelidade ao Figma (obrigatória)

> ⚠️ **A tela implementada tem que ficar IGUAL ao Figma.** Os frames listados em **Telas (Figma)** são o contrato visual
> desta user story: não são referência, sugestão nem inspiração. Layout, ordem dos blocos, medidas, espaçamentos,
> alinhamentos, cores, tipografia (fonte, peso, tamanho e altura de linha), raios, bordas, sombras, ícones, imagens, textos
> (letra por letra) e estados (vazio, erro, carregando, hover, foco, desabilitado) seguem o frame. Medidas e cores saem do
> Figma, nunca "a olho".
>
> - Nada é inventado, trocado ou "melhorado" fora do frame. Diferença entre o Figma e a documentação vira lacuna em
>   **Lacunas e decisões** e é decidida antes do código (ADR-060). Até a decisão, vale a documentação.
> - O que o Figma não desenha (R marcado em "O que falta no Figma") segue o estilo da própria tela: os mesmos componentes,
>   tokens e espaçamentos.
> - A tela só está pronta quando o print dela em 1280 px, lado a lado com o print do frame, não mostra diferença. Em
>   celular (375 px), tablet (768 px) e laptop (1024 px), mantém o mesmo design adaptado, sem quebra, corte nem rolagem
>   horizontal.
> - A revisão (`/cromocard-revisor`) reprova o PR que não estiver igual ao Figma.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | A pesquisa de cartas exige login: sem token, a API responde `401` | Permissão | `24`–`29`, Pré-condições (L2) |
| R2 | Tela de pesquisa de cartas com o campo de busca e os filtros de coleção, categoria, raridade e idioma (qual tela: L1) | Tela | `24`–`29`, Pré-condições e FP 1 (L1) |
| R3 | O cliente digita o nome da carta no campo de busca, e o sistema pesquisa as cartas cujo nome corresponde ao termo | Ação | `24`, FP 1–2 (L7) |
| R4 | O cliente informa o número da carta no campo de busca, e o sistema pesquisa as cartas cujo número corresponde ao valor | Ação | `25`, FP 1–2 (L6, L7) |
| R5 | Filtro de coleção: o cliente escolhe a coleção, e o sistema mostra só as cartas dela | Campo | `26`, FP 1–2 (L4) |
| R6 | Filtro de categoria com as categorias padrão na ordem de Ordenar Categorias Padrão (a fixada primeiro, depois `display_order`); o sistema mostra só as cartas da categoria escolhida | Campo | `27`, FP 1–2; `104`, FP 9 (CCD104, R6 e L12) (L5) |
| R7 | Filtro de raridade: o sistema mostra só as cartas da raridade escolhida | Campo | `28`, FP 1–2 |
| R8 | Filtro de idioma: o sistema mostra só as cartas do idioma escolhido | Campo | `29`, FP 1–2 |
| R9 | O sistema exibe a lista de cartas encontradas (campos da lista: L8) | Tela | `24`–`29`, FP 3 (L8) |
| R10 | Selecionar uma carta da lista abre a carta escolhida (destino: L8) | Ação | `24`–`29`, FP 4 (L8) |
| R11 | Sem nenhuma carta encontrada, a tela mostra "Nenhuma carta encontrada com os termos informados" | Mensagem | `24`–`29`, FA 1 (L9) |
| R12 | Só entram cartas do catálogo com `status = ACTIVE` e sem `deleted_at` | Regra | ADR-053, item 5; ADR-015 |
| R13 | A API recebe o termo em `q` e os filtros pelo nome do campo (ex.: `rarityId`, `languageId`), com paginação por `page` e `pageSize` | Regra | ADR-011, "Paginação, filtros e ordenação" |
| R14 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados. Os filtros ainda não têm frame (L1): o requisito vale para o frame que for desenhado | Fidelidade | Figma (frames da seção Telas); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2, R3, R9) — **Dado** um cliente logado na tela de pesquisa de cartas e as cartas "Lionel Messi" e "Lionel
  Scaloni" no catálogo, **quando** ele digita "lionel", **então** a lista mostra as duas cartas.
- **CA2** (R4) — **Dado** a carta Nº 10 do álbum "Copa do Mundo 2026", **quando** o cliente informa "10" no campo de busca,
  **então** a carta Nº 10 aparece na lista.
- **CA3** (R5) — **Dado** a coleção "Copa do Mundo 2026" escolhida no filtro, **quando** a lista atualiza, **então** só
  aparecem cartas dessa coleção.
- **CA4** (R6) — **Dado** Pokémon fixada e a ordem salva Futebol, Magic: The Gathering, **quando** o cliente abre o filtro de
  categoria, **então** vê Pokémon, Futebol e Magic: The Gathering, nessa ordem; **quando** escolhe Futebol, **então** só
  aparecem cartas de Futebol (com as subcategorias, conforme a L5).
- **CA5** (R7) — **Dado** a raridade "Lendária" escolhida, **quando** a lista atualiza, **então** só aparecem cartas
  lendárias.
- **CA6** (R8) — **Dado** o idioma "Português - Brasil" escolhido, **quando** a lista atualiza, **então** só aparecem cartas
  nesse idioma.
- **CA7** (R10) — **Dado** a lista de resultados, **quando** o cliente seleciona uma carta, **então** abre a carta escolhida
  (destino da L8).
- **CA8** (R11) — **Dado** um nome, número ou filtro sem correspondência, **quando** a pesquisa termina, **então** a tela
  mostra "Nenhuma carta encontrada com os termos informados".
- **CA9** (R1) — **Dado** uma requisição sem token, **quando** chama a pesquisa de cartas, **então** a API responde `401`.
- **CA10** (R12) — **Dado** uma carta em rascunho (`DRAFT`) e uma excluída com o termo no nome, **quando** o cliente pesquisa,
  **então** nenhuma das duas aparece.
- **CA11** (R14 de Fidelidade) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o
  print dela é comparado lado a lado com o print do frame `1112-3970`, **então** não há diferença de layout, medida,
  espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem
  rolagem horizontal (vale se a L1 escolher a página Pesquisar).
- **CA12** (R14 de Fidelidade) — Idem ao CA11, com o estado sem resultados e o frame `1112-4356`.
- **CA13** (R14 de Fidelidade) — Idem ao CA11, com o frame dos filtros que for desenhado (L1), em cada estado desenhado.

- **CA14** (R14) — **Dado** cada tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame correspondente (`1112-4356`), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `cards` | `name`, `number`, `album_id`, `category_id`, `rarity_id`, `language_id`, `front_image_url`, `status` (`card_status.ACTIVE`), `deleted_at` | `number` varchar(20), único por álbum (`album_id`, `number`) |
| `albums` | `id`, `title`, `category_id`, `status` (`album_status`), `deleted_at` | a "coleção" (L4) |
| `categories` | `name`, `parent_category_id`, `is_default`, `is_pinned`, `display_order`, `deleted_at` | filtro de categoria (L5) |
| `rarities` | `id`, `name`, `sort_order` | `name` único |
| `languages` | `id`, `name`, `code` | `code` único |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Público - Busca (a página "Pesquisar" do cliente, pelo frame `1122-18396`) | [1112-3970](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-3970) | R2, R3, R9 | ❌ Não bate: só o termo, sem número nem filtros (L1) |
| Público - Busca - sem resultados | [1112-4356](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-4356) | R11 | ❌ Não bate: outro texto (L9) |

- **Não há frame da "tela de pesquisa de cartas" com os filtros dos seis casos de uso** (L1). Filtros parecidos aparecem em
  telas de outras stories: no detalhe do álbum do cliente (`1160-23696`, CCD013) há "Buscar carta pelo nome ou número",
  "Nº (#01 a #54)", "Todos os idiomas" e "Todas as Raridades"; no Explorar marketplace (`1112-3281`, CCD078) há "Buscar por
  carta ou coleção" e "Categoria". O perfil da carta (`1112-4615`) mostra os mesmos campos: Número, Coleção, Categoria,
  Raridade e Idioma.
- **Diferenças com o Figma** (decisão em Lacunas e decisões): Busca — o resultado "Cartas" mostra anúncios, e o `24`, FP 2,
  pesquisa cartas do catálogo (L3); o vazio diz "Nenhum resultado encontrado para o termo pesquisado", e os casos de uso
  pedem "Nenhuma carta encontrada com os termos informados" (L9).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R4–R8 os filtros de número, coleção, categoria,
  raridade e idioma (L1).

## Fora do escopo

- Busca global de usuários, grupos e álbuns — CCD002.
- Pesquisar carta para adicionar à coleção e filtros dentro do álbum do cliente — CCD021, CCD013 e CCD037 (L10).
- Filtro por estado de conservação — CCD032; por vendedor — CCD067.
- Perfil da carta — CCD030.
- Gravar a ordem das categorias padrão — CCD104.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Qual é a "tela de pesquisa de cartas" dos casos de uso 24–29? O Figma não tem uma tela com os seis filtros: a página "Pesquisar" (`1112-3970`) só tem o termo; nome, número, idioma e raridade aparecem no detalhe do álbum (`1160-23696`, CCD013); coleção e categoria, no Explorar (`1112-3281`, CCD078). Falta o desenho da tela no Figma. (proposta: filtros na aba "Cartas" da página Pesquisar; o Gabriel desenha) | pendente | — |
| L2 | Os casos de uso exigem cliente autenticado, mas a página Pesquisar é pública (CCD002) e o Explorar também (CCD078). A pesquisa de cartas exige login? (proposta: não, aberta como a busca global) | pendente | — |
| L3 | A pesquisa é sobre as cartas do catálogo (`cards`, como diz o FP 2) ou sobre anúncios (como o grupo "Cartas" da busca global)? (proposta: catálogo) | pendente | — |
| L4 | "Coleção" é o álbum do catálogo (`albums`, como no perfil da carta: "Coleção: Copa do Mundo 2026") ou a coleção do cliente (`collections`)? (proposta: o álbum do catálogo) | pendente | — |
| L5 | Qual categoria conta: a da carta (`cards.category_id`) ou a do álbum (`albums.category_id`)? Escolher uma categoria padrão (raiz) traz as cartas das subcategorias? (proposta: sim, pela carta ou pelo álbum; decidir junto com CCD001 L7 e CCD078) | pendente | — |
| L6 | Nome e número usam o mesmo campo (como "Buscar carta pelo nome ou número" no `1160-23696`) ou campos separados? Os filtros se combinam (todos ao mesmo tempo)? (proposta: um campo para nome ou número; filtros combinados) | pendente | — |
| L7 | Como o termo corresponde? (proposta: nome por trecho, sem diferenciar maiúsculas e acentos; número exato, ignorando zeros à esquerda) | pendente | — |
| L8 | Que campos cada carta mostra na lista, quantas por página e o que abre ao selecionar (FP 4)? (proposta: imagem, nome, Nº, coleção e raridade; 8 por vez com "Carregar mais"; abre o perfil da carta, CCD030) | pendente | — |
| L9 | A mensagem dos casos de uso é "Nenhuma carta encontrada com os termos informados"; o vazio da página Pesquisar diz "Nenhum resultado encontrado para o termo pesquisado" (CCD002). Qual vale? | pendente | — |
| L10 | A CCD021 (Pesquisar Carta: nome, número ou característica, mesma mensagem) e a CCD037 (Buscar Categoria do Card) se sobrepõem a este grupo. São a mesma tela? | pendente | — |
| L11 | Em que ordem aparecem as opções de raridade e de idioma nos filtros? (proposta: raridade por `sort_order`; idioma por `name`) | pendente | — |
| L12 | Estados de carregando e de erro não estão na documentação nem no Figma. (proposta: o padrão da Área do Cliente) | pendente | — |
