# CCD007 — Visualizar Resumo da Coleção

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #113 `CCD007-Visualizar Resumo da Coleção`
- **Caso de uso:** [07-visualizar-resumo-da-colecao.md](../../docs/Casos-De-Uso/07-visualizar-resumo-da-colecao.md) · complemento EA-007-01 em [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md)
- **Atores:** Cliente · **Pré-condições:** autenticado e na tela inicial do Painel Cliente (Dashboard)
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso visualizar um resumo da minha coleção para acompanhar de forma rápida a quantidade e os principais itens cadastrados.

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
| R1 | Ver o resumo exige login: sem token, a API responde `401`. Cada cliente vê só a própria coleção | Permissão | `07`, Pré-condições; ADR-005, item 4; ADR-011 (papel `ADMIN`: L1) |
| R2 | A tela inicial do Painel Cliente (Dashboard, item "Início" do menu) mostra o resumo da coleção assim que o cliente a abre | Tela | `07`, FP 1 |
| R3 | O resumo mostra o total de álbuns ativos: os álbuns da coleção do cliente (`user_albums` sem `deleted_at`, de álbuns sem `deleted_at`) | Regra | `07`, FP 2 |
| R4 | O resumo mostra o total de cartas registradas na coleção (o que conta: L3) | Regra | `07`, FP 2 |
| R5 | O resumo mostra o percentual médio de completude: a média de `user_albums.progress_percentage` dos álbuns ativos (onde aparece: L4) | Regra | `07`, FP 2 |
| R6 | Os indicadores aparecem em cards visuais | Tela | `07`, FP 3 |
| R7 | O resumo mostra o valor estimado da coleção, a soma do preço médio das cartas marcadas como possuo, com a variação em 30 dias. Preço médio = média de `price_history` nos últimos 30 dias (detalhes da conta: L5) | Campo | EA-007-01; EA-061-05 |
| R8 | O resumo mostra os principais itens cadastrados na coleção (quais e como: L6) | Tela | `user-stories.md`, narrativa da CCD007 |
| R9 | Sem nenhum álbum nem carta na coleção, os contadores aparecem zerados, com o botão de atalho "Adicionar Primeiro Álbum" (destino: L8) | Estado | `07`, FA 1 |
| R10 | Enquanto os dados carregam, a tela mostra o estado de carregando; se a API falha, mostra o estado de erro com a mensagem da API | Estado | ADR-041, Erros e Consequências (`LoadingState`, `ErrorState`) |
| R11 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas: `1122-17812`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2, R3, R4, R5, R6) — **Dado** um cliente com 4 álbuns na coleção e cartas marcadas, **quando** ele abre o Início, **então** vê, em cards, o total de 4 álbuns ativos, o total de cartas registradas e o percentual médio de completude, igual à média do progresso dos 4 álbuns.
- **CA2** (R3) — **Dado** um cliente que removeu um dos seus 4 álbuns (CCD011), **quando** abre o Início, **então** o total de álbuns ativos é 3.
- **CA3** (R7) — **Dado** um cliente com cartas marcadas como possuo que têm preço em `price_history` nos últimos 30 dias, **quando** abre o Início, **então** o card "Valor estimado" mostra a soma dos preços médios dessas cartas e a variação em 30 dias.
- **CA4** (R8) — **Dado** um cliente com cartas na coleção, **quando** abre o Início, **então** vê a lista dos principais itens, com o nome e o status de cada carta.
- **CA5** (R9) — **Dado** um cliente sem nenhum álbum nem carta, **quando** abre o Início, **então** vê todos os contadores em 0 e o botão "Adicionar Primeiro Álbum".
- **CA6** (R1) — **Dado** um visitante sem login, **quando** chama a API do resumo, **então** recebe `401`; **dado** dois clientes, **quando** o primeiro abre o Início, **então** os números não incluem nada da coleção do segundo.
- **CA7** (R10) — **Dado** a API do resumo fora do ar, **quando** o cliente abre o Início, **então** vê o estado de erro com a mensagem da API, e enquanto a resposta não chega vê o estado de carregando.
- **CA8** (R11) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1122-17812`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `collections` | `id`, `user_id` | 1:1 com o usuário (`user_id` único); quando nasce: L2 |
| `user_albums` | `collection_id`, `album_id`, `progress_percentage`, `deleted_at` | `progress_percentage` `decimal(5,2)`, default 0; único por (`collection_id`, `album_id`) |
| `albums` | `title`, `total_cards`, `deleted_at` | `total_cards` default 0 |
| `collection_cards` | `collection_id`, `card_id`, `status` (`collection_card_status`: `OWNED`, `MISSING`, `DUPLICATE`), `quantity`, `deleted_at` | `quantity` default 1; único por (`collection_id`, `card_id`) |
| `cards` | `album_id`, `name`, `deleted_at` | itens da lista (R8) |
| `price_history` | `card_id`, `price`, `reference_date` | só leitura (R7) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Cliente - Início (minha coleção) | [1122-17812](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1122-17812) | R2–R8, R11 | ❌ Não bate: indicadores diferentes do caso de uso (L3, L4) e blocos só no Figma (L6, L7, L9, L10) |

- **Diferenças com o Figma** (decisão em Lacunas e decisões):
  - Início — os cards são "Valor estimado", "Total de cartas", "Possuo", "Faltantes" e "Repetidas"; o caso de uso pede álbuns ativos, cartas registradas e percentual médio de completude (L3, L4). O total de álbuns aparece só no subtítulo "Colecionador desde out. de 2026 • 4 álbuns ativos".
  - Início — o percentual médio de completude não aparece em lugar nenhum (L4).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões):
  - Início — cards "Possuo", "Faltantes" e "Repetidas" (L3).
  - Início — "Álbum em destaque: <álbum>", com a barra de progresso, "<n> de <total> cartas • <n>% completo" e o botão "Abrir álbum" (L7).
  - Início — grade de cartas com as abas "Todas (n)", "Possuo (n)", "Faltantes (n)", "Repetidas (n)", a busca "Buscar carta na coleção", "Ordenar: Maior valor" e os filtros por categoria ("Todas", "Pokémon", "Magic", "Futebol", "One Piece", "Yu-Gi-Oh!"); cada cartão com "<categoria> • <álbum>", nome, selo de status ("Possuo", "Repetida (x2)", "Faltante"), "Preço médio" ou "Menor anúncio" e o valor (L6).
  - Início — botões dos cartões "Ver carta", "Anunciar repetida" e "Comprar no marketplace" (L10).
  - Início — saudação "Olá, <nome>" e "Colecionador desde <mês> de <ano>" (L9).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela):
  - R5 percentual médio de completude (L4).
  - R9 Início vazio, com os contadores zerados e o botão "Adicionar Primeiro Álbum" (L8).
  - R10 estados de carregando e de erro.
- O sobretítulo "Minha coleção", o menu lateral, o sino e o avatar do topo são o layout comum da Área do Cliente.

## Fora do escopo

- "Compartilhar coleção" — CCD012.
- "Editar perfil" — CCD048.
- Abrir a carta ("Ver carta") — CCD030 e CCD031.
- "Anunciar repetida" — CCD084.
- "Comprar no marketplace" — marketplace (CCD078 e CCD072).
- Progresso de cada álbum e a barra do álbum em destaque — o cálculo é da CCD019; esta story só lê `progress_percentage`.
- Sino de notificações do topo — CCD053.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O `ADMIN` acessa o Painel Cliente? O caso de uso só diz "Cliente". (proposta: não; `CUSTOMER` e `SELLER` acessam, o `ADMIN` recebe `403` na API e o frontend o leva ao BackOffice, como no ADR-043) | pendente | — |
| L2 | Quando nasce a coleção (`collections`) do cliente? A CCD003 (L7) e a CCD004 (L6) deixaram para "as stories deles". (proposta: a API cria a coleção na primeira leitura ou escrita, com `is_public = false`; sem coleção, o resumo vem zerado) | pendente | — |
| L3 | O caso de uso pede "cartas registradas"; o Figma mostra "Total de cartas" (264 = soma do total de cartas dos 4 álbuns da coleção) dividido em "Possuo" (184), "Faltantes" (80) e "Repetidas" (28). Qual vale? Os cards Possuo, Faltantes e Repetidas, que só existem no Figma, fazem sentido? (proposta: como no Figma: total = soma de `albums.total_cards` dos álbuns ativos; possuo = cartas desses álbuns com status `OWNED` ou `DUPLICATE`; faltantes = total − possuo; repetidas = soma das unidades além da primeira) | pendente | — |
| L4 | O caso de uso pede o percentual médio de completude e o Figma não o mostra (só o percentual do álbum em destaque). Onde ele aparece? (proposta: o Gabriel acrescenta um card ou o percentual ao lado de "4 álbuns ativos") | pendente | — |
| L5 | Valor estimado (EA-007-01): conta uma vez por carta ou cada unidade (repetidas entram)? Carta sem preço nos últimos 30 dias conta como zero? A variação "+14,2% em 30 dias" compara com quê? (proposta: uma vez por carta possuída, sem as repetidas; sem preço, zero; variação = valor de hoje contra o valor calculado com os preços de 30 a 60 dias atrás) | pendente | — |
| L6 | "Principais itens" (user story): o Figma mostra uma grade de cartas da coleção com abas por status, busca, ordenação "Maior valor" e filtros por categoria, que nenhum caso de uso descreve. Faz sentido implementar? Quantas cartas aparecem e com paginação? O cartão faltante mostra "Menor anúncio" (do marketplace) e os outros "Preço médio": vale? (proposta: sim, como no Figma, com 8 cartas por página ordenadas por maior valor e "Menor anúncio" = menor `listings.price` ativo da carta) | pendente | — |
| L7 | "Álbum em destaque" com "Abrir álbum" só existe no Figma. Faz sentido? Qual álbum é o destaque? (proposta: sim; o favorito, `user_albums.is_favorite`, ou, sem favorito, o último álbum em que o cliente marcou carta) | pendente | — |
| L8 | Para onde leva "Adicionar Primeiro Álbum" e qual o desenho do Início vazio, que o Figma não tem? O "sem álbuns" de Álbuns (`1160-29088`) usa outro texto e o botão "Solicitar álbum". (proposta: leva ao catálogo em Pesquisar, onde a CCD022 adiciona; o Gabriel desenha o Início vazio no estilo de `1160-29088`) | pendente | — |
| L9 | Saudação "Olá, <nome>" e "Colecionador desde <mês> de <ano>" só existem no Figma. Fazem sentido? De onde vem a data? (proposta: sim; primeiro nome de `users.name` e mês e ano de `users.created_at`) | pendente | — |
| L10 | Os botões dos cartões ("Ver carta", "Anunciar repetida", "Comprar no marketplace") levam a outras stories. Fazem sentido nesta tela? "Anunciar repetida" aparece para quem não é vendedor? (proposta: sim, como links para as telas da CCD030, CCD084 e do marketplace; "Anunciar repetida" só para `SELLER`, e para o `CUSTOMER` a repetida mostra "Ver carta") | pendente | — |
| L11 | O EA-007-01 cita o frame `1160-5395`, que não está mais no Figma (índice de 21/11/2026); o valor do álbum aparece hoje em `1160-23080` e `1160-23696`. Atualizar a referência no `escopo-adicional.md`? (proposta: sim) | pendente | — |
