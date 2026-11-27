# CCD007 — Visualizar Resumo da Coleção

- **Status:** Em implementação (Planejada em 23/11/2026, com o plano e as tarefas revisados)
- **Fase:** MVP
- **User story:** #113 `CCD007-Visualizar Resumo da Coleção`
- **Caso de uso:** [07-visualizar-resumo-da-colecao.md](../../docs/Casos-De-Uso/07-visualizar-resumo-da-colecao.md) · complemento EA-007-01 em [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md)
- **Atores:** Cliente · **Pré-condições:** autenticado e na tela inicial do Painel Cliente (Dashboard)
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** Felipe Consulim (PO), 23/11/2026

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
| R1 | Ver o resumo exige login: sem token, a API responde `401`; o `ADMIN` recebe `403` e vai ao BackOffice. Cada cliente (`CUSTOMER` ou `SELLER`) vê só a própria coleção | Permissão | `07`, Pré-condições; ADR-005, item 4; ADR-011; ADR-043 (L1) |
| R2 | A tela inicial do Painel Cliente (Dashboard, item "Início" do menu) mostra o resumo da coleção assim que o cliente a abre | Tela | `07`, FP 1 |
| R3 | O resumo mostra o total de álbuns ativos: os álbuns da coleção do cliente (`user_albums` sem `deleted_at`, de álbuns sem `deleted_at`) | Regra | `07`, FP 2 |
| R4 | O resumo mostra, em cards, o total de cartas (soma de `albums.total_cards` dos álbuns ativos), "Possuo" (cartas desses álbuns com `OWNED` ou `DUPLICATE`), "Faltantes" (total − possuo) e "Repetidas" (unidades além da primeira) | Regra | `07`, FP 2 (L3) |
| R5 | O resumo mostra o percentual médio de completude, a média de `user_albums.progress_percentage` dos álbuns ativos, ao lado de "<n> álbuns ativos" no subtítulo | Regra | `07`, FP 2 (L4) |
| R6 | Os indicadores aparecem em cards visuais | Tela | `07`, FP 3 |
| R7 | O resumo mostra o valor estimado da coleção, a soma do preço médio de cada carta possuída (uma vez por carta, sem as repetidas), com a variação em 30 dias (hoje contra os preços de 30 a 60 dias atrás). Preço médio = média de `price_history` nos últimos 30 dias; sem preço, a carta conta zero. Até `price_history` existir, valor e variação ficam zerados | Campo | EA-007-01; EA-061-05 (L5) |
| R8 | O resumo mostra a grade de cartas da coleção, como no Figma: abas por status com contagem, busca, ordenação "Maior valor", filtros por categoria e 8 cartas por página. Cada cartão mostra "Preço médio" ou, na faltante, "Menor anúncio" (menor `listings.price` ativo; sem anúncio, "—") | Tela | `user-stories.md`, narrativa da CCD007 (L6) |
| R9 | Sem nenhum álbum nem carta na coleção, os contadores aparecem zerados, com o botão de atalho "Adicionar Primeiro Álbum", que leva à CCD022. O Início vazio segue o estilo de `1160-29088` | Estado | `07`, FA 1 (L8) |
| R10 | Enquanto os dados carregam, a tela mostra o estado de carregando; se a API falha, mostra o estado de erro com a mensagem da API | Estado | ADR-041, Erros e Consequências (`LoadingState`, `ErrorState`) |
| R11 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas: `1122-17812`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |
| R12 | O Início mostra o "Álbum em destaque": o álbum favorito (`user_albums.is_favorite`) ou, sem favorito, o último em que o cliente marcou carta, com a barra de progresso, "<n> de <total> cartas • <n>% completo" e "Abrir álbum" | Tela | Figma `1122-17812` (L7) |
| R13 | O Início mostra a saudação "Olá, <primeiro nome>" (de `users.name`) e "Colecionador desde <mês> de <ano>" (de `users.created_at`) | Tela | Figma `1122-17812` (L9) |
| R14 | Os cartões têm "Ver carta" (CCD030), "Anunciar repetida" (CCD084, só para `SELLER`; o `CUSTOMER` vê "Ver carta") e "Comprar no marketplace"; "Ver carta", "Anunciar repetida" e "Comprar no marketplace" (CCD078 e CCD072) usam `underConstructionRoute` até essas stories entrarem | Ação | Figma `1122-17812` (L10) |

## Critérios de aceite

- **CA1** (R2, R3, R4, R5, R6) — **Dado** um cliente com 4 álbuns na coleção (264 cartas no total) e cartas marcadas, **quando** ele abre o Início, **então** vê "4 álbuns ativos" com o percentual médio de completude ao lado e os cards "Total de cartas" (264), "Possuo", "Faltantes" (264 − possuo) e "Repetidas".
- **CA2** (R3) — **Dado** um cliente que removeu um dos seus 4 álbuns (CCD011), **quando** abre o Início, **então** o total de álbuns ativos é 3.
- **CA3** (R7; verificável só depois que `price_history` entrar no `develop`) — **Dado** um cliente com cartas marcadas como possuo que têm preço em `price_history` nos últimos 30 dias, **quando** abre o Início, **então** o card "Valor estimado" mostra a soma dos preços médios dessas cartas e a variação em 30 dias.
- **CA4** (R8) — **Dado** um cliente com 10 cartas na coleção, **quando** abre o Início, **então** vê as 8 de maior valor na primeira página, com o selo de status; a faltante sem anúncio mostra "Menor anúncio" "—".
- **CA5** (R9) — **Dado** um cliente sem nenhum álbum nem carta, **quando** abre o Início, **então** vê todos os contadores em 0 e o botão "Adicionar Primeiro Álbum".
- **CA6** (R1) — **Dado** um visitante sem login, **quando** chama a API do resumo, **então** recebe `401`; **dado** dois clientes, **quando** o primeiro abre o Início, **então** os números não incluem nada da coleção do segundo.
- **CA7** (R10) — **Dado** a API do resumo fora do ar, **quando** o cliente abre o Início, **então** vê o estado de erro com a mensagem da API, e enquanto a resposta não chega vê o estado de carregando.
- **CA8** (R11; o card "Valor estimado" só fica igual ao frame depois que `price_history` entrar no `develop`) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1122-17812`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA9** (R12) — **Dado** um cliente sem álbum favorito, **quando** abre o Início, **então** o álbum em destaque é o último em que ele marcou carta.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `collections` | `id`, `user_id` | 1:1 com o usuário (`user_id` único); quando nasce: L2 |
| `user_albums` | `collection_id`, `album_id`, `progress_percentage`, `deleted_at` | `progress_percentage` `decimal(5,2)`, default 0; único por (`collection_id`, `album_id`) |
| `albums` | `title`, `total_cards`, `deleted_at` | `total_cards` default 0 |
| `collection_cards` | `collection_id`, `card_id`, `status` (`collection_card_status`: `OWNED`, `MISSING`, `DUPLICATE`), `quantity`, `deleted_at` | `quantity` default 1; único por (`collection_id`, `card_id`) |
| `cards` | `album_id`, `name`, `deleted_at` | itens da lista (R8) |
| `price_history` | `card_id`, `price`, `reference_date` | só leitura (R7); tabela da base do marketplace, ainda fora do `develop`, criada pela "Onda 0" do Felipe ou pela CCD097 (PR backend #41), o que entrar primeiro |
| `listings` | `card_id`, `price`, `status`, `deleted_at` | só leitura, "Menor anúncio" (R8); mesma situação de `price_history` |
| `users` | `name`, `created_at` | saudação (R13) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Cliente - Início (minha coleção) | [1122-17812](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1122-17812) | R2–R14 | ✅ Bate, com duas inclusões decididas que o frame não desenha: o percentual médio no subtítulo (R5) e o Início vazio (R9), no estilo da tela (L4, L8, 23/11/2026) |

- **Diferenças com o Figma** (decisão em Lacunas e decisões):
  - Início — os cards são "Valor estimado", "Total de cartas", "Possuo", "Faltantes" e "Repetidas"; o caso de uso pede álbuns ativos, cartas registradas e percentual médio de completude (L3, L4). O total de álbuns aparece só no subtítulo "Colecionador desde out. de 2026 • 4 álbuns ativos".
  - Início — o percentual médio de completude não aparece em lugar nenhum (L4).
  - Início — o frame diz "4 álbuns ativos", mas os 8 cartões da grade são de 8 álbuns; e "44 de 54 cartas" dá 81%, não 82%. O seed segue os números dos cards em 4 álbuns, e o percentual sai da regra (L12).
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

## Ordem de entrega (orientação do PO, 23/11/2026)

Primeiro o domínio `collection` e os contadores (R1–R6, R9–R13), que não dependem do marketplace. O valor estimado (R7) e o "Menor anúncio" (R8) ligam quando `price_history` e `listings` entrarem no `develop`; até lá, aparecem zerados ou com "—".

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
| L1 | O `ADMIN` acessa o Painel Cliente? O caso de uso só diz "Cliente". (proposta: não; `CUSTOMER` e `SELLER` acessam, o `ADMIN` recebe `403` na API e o frontend o leva ao BackOffice, como no ADR-043) | Não: `CUSTOMER` e `SELLER` acessam; o `ADMIN` recebe `403` e o frontend o leva ao BackOffice (ADR-043). Felipe Consulim (PO), 23/11/2026 | R1 |
| L2 | Quando nasce a coleção (`collections`) do cliente? A CCD003 (L7) e a CCD004 (L6) deixaram para "as stories deles". (proposta: a API cria a coleção na primeira leitura ou escrita, com `is_public = false`; sem coleção, o resumo vem zerado) | A API cria a coleção na primeira leitura ou escrita, com `is_public = false`; sem coleção, o resumo vem zerado. Felipe Consulim (PO), 23/11/2026 | Dados, R9 |
| L3 | O caso de uso pede "cartas registradas"; o Figma mostra "Total de cartas" (264 = soma do total de cartas dos 4 álbuns da coleção) dividido em "Possuo" (184), "Faltantes" (80) e "Repetidas" (28). Qual vale? Os cards Possuo, Faltantes e Repetidas, que só existem no Figma, fazem sentido? (proposta: como no Figma: total = soma de `albums.total_cards` dos álbuns ativos; possuo = cartas desses álbuns com status `OWNED` ou `DUPLICATE`; faltantes = total − possuo; repetidas = soma das unidades além da primeira) | Como no Figma: total = soma de `albums.total_cards` dos álbuns ativos; possuo = cartas desses álbuns com `OWNED` ou `DUPLICATE`; faltantes = total − possuo; repetidas = unidades além da primeira. O caso de uso 07 passa a citar os quatro contadores. Felipe Consulim (PO), 23/11/2026 | R4, CA1; `07`, FP 2 |
| L4 | O caso de uso pede o percentual médio de completude e o Figma não o mostra (só o percentual do álbum em destaque). Onde ele aparece? (proposta: o Gabriel acrescenta um card ou o percentual ao lado de "4 álbuns ativos") | Ao lado de "<n> álbuns ativos", no subtítulo, sem card novo (não depende de desenho novo no Figma). Felipe Consulim (PO), 23/11/2026 | R5; `07`, FP 2 |
| L5 | Valor estimado (EA-007-01): conta uma vez por carta ou cada unidade (repetidas entram)? Carta sem preço nos últimos 30 dias conta como zero? A variação "+14,2% em 30 dias" compara com quê? (proposta: uma vez por carta possuída, sem as repetidas; sem preço, zero; variação = valor de hoje contra o valor calculado com os preços de 30 a 60 dias atrás) | Uma vez por carta possuída, sem as repetidas; sem preço nos últimos 30 dias, conta zero; variação = hoje contra os preços de 30 a 60 dias atrás. O preço vem de `price_history`, da base do marketplace; até a tabela existir, o valor estimado e a variação ficam zerados. Felipe Consulim (PO), 23/11/2026 | R7, CA3 |
| L6 | "Principais itens" (user story): o Figma mostra uma grade de cartas da coleção com abas por status, busca, ordenação "Maior valor" e filtros por categoria, que nenhum caso de uso descreve. Faz sentido implementar? Quantas cartas aparecem e com paginação? O cartão faltante mostra "Menor anúncio" (do marketplace) e os outros "Preço médio": vale? (proposta: sim, como no Figma, com 8 cartas por página ordenadas por maior valor e "Menor anúncio" = menor `listings.price` ativo da carta) | Sim, como no Figma: 8 cartas por página, ordenadas pelo maior valor. O "Menor anúncio" da faltante é o menor `listings.price` ativo; sem anúncio (ou antes de `listings` existir), mostra "—". Felipe Consulim (PO), 23/11/2026 | R8, CA4 |
| L7 | "Álbum em destaque" com "Abrir álbum" só existe no Figma. Faz sentido? Qual álbum é o destaque? (proposta: sim; o favorito, `user_albums.is_favorite`, ou, sem favorito, o último álbum em que o cliente marcou carta) | Sim: o álbum com `user_albums.is_favorite` ou, sem favorito, o último em que o cliente marcou carta. O DER já cobre: `user_albums.is_favorite` (favorito da coleção) e `favorites` com `type = ALBUM` (favorito do catálogo), sem tabela nova. Felipe Consulim (PO), 23/11/2026 | R12, CA9 |
| L8 | Para onde leva "Adicionar Primeiro Álbum" e qual o desenho do Início vazio, que o Figma não tem? O "sem álbuns" de Álbuns (`1160-29088`) usa outro texto e o botão "Solicitar álbum". (proposta: leva ao catálogo em Pesquisar, onde a CCD022 adiciona; o Gabriel desenha o Início vazio no estilo de `1160-29088`) | Leva à CCD022 (adicionar carta, a partir do catálogo). Enquanto o Gabriel não desenha o Início vazio, ele usa o estilo de `1160-29088`. Felipe Consulim (PO), 23/11/2026 | R9, CA5 |
| L9 | Saudação "Olá, <nome>" e "Colecionador desde <mês> de <ano>" só existem no Figma. Fazem sentido? De onde vem a data? (proposta: sim; primeiro nome de `users.name` e mês e ano de `users.created_at`) | Sim: primeiro nome de `users.name` e mês e ano de `users.created_at`. Felipe Consulim (PO), 23/11/2026 | R13 |
| L10 | Os botões dos cartões ("Ver carta", "Anunciar repetida", "Comprar no marketplace") levam a outras stories. Fazem sentido nesta tela? "Anunciar repetida" aparece para quem não é vendedor? (proposta: sim, como links para as telas da CCD030, CCD084 e do marketplace; "Anunciar repetida" só para `SELLER`, e para o `CUSTOMER` a repetida mostra "Ver carta") | Sim, como links. "Ver carta" (CCD030) e "Anunciar repetida" (CCD084) usam `underConstructionRoute` até essas stories entrarem; "Anunciar repetida" só para `SELLER`, e o `CUSTOMER` vê "Ver carta". Felipe Consulim (PO), 23/11/2026 | R14 |
| L11 | O EA-007-01 cita o frame `1160-5395`, que não está mais no Figma (índice de 21/11/2026); o valor do álbum aparece hoje em `1160-23080` e `1160-23696`. Atualizar a referência no `escopo-adicional.md`? (proposta: sim) | Sim: a referência do EA-007-01 passa a ser `1160-23080` / `1160-23696`. Felipe Consulim (PO), 23/11/2026 | `escopo-adicional.md`, EA-007-01 |
| L12 | Os dados de exemplo do frame `1122-17812` não fecham: "4 álbuns ativos" com cartões de 8 álbuns na grade, e "44 de 54 cartas" (81%) mostrado como 82%. Qual número o seed e a tela seguem? (proposta: os cards, com 4 álbuns, e o percentual calculado pela regra) | O seed segue os cards (4 álbuns ativos) e o percentual sai da regra (81%); a tela difere do frame só nesses números de exemplo, sem mudar regra. Lucas Oliveira Lima, 27/11/2026 | Dados, CA1, CA8; Telas |
