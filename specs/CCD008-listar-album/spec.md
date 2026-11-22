# CCD008 — Listar Álbum

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #114 `CCD008-Listar Álbum`
- **Caso de uso:** [08-listar-album.md](../../docs/Casos-De-Uso/08-listar-album.md) · complemento EA-007-01 em [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md)
- **Atores:** Cliente · **Pré-condições:** autenticado e com a opção "Meus Álbuns" selecionada no menu
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso listar meus álbuns para visualizar as coleções cadastradas em minha conta.

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
| R1 | Listar os álbuns exige login: sem token, a API responde `401`. Cada cliente vê só os álbuns da própria coleção | Permissão | `08`, Pré-condições; ADR-005, item 4; ADR-011 (papel `ADMIN`: L1) |
| R2 | A opção "Meus Álbuns" do menu principal abre a lista de álbuns do cliente (rótulo: L11) | Ação | `08`, FP 1 |
| R3 | A lista mostra os álbuns ativos da biblioteca do cliente (`user_albums` sem `deleted_at`), iniciados ou favoritados (o que entra: L3) | Regra | `08`, Finalidade e FP 3 |
| R4 | Cada álbum mostra a capa, o título e a barra de progresso individual (`user_albums.progress_percentage`) | Tela | `08`, FP 3 |
| R5 | Cada álbum mostra o valor estimado do álbum: a soma do preço médio das cartas dele marcadas como possuo (preço médio = média de `price_history` nos últimos 30 dias) | Campo | EA-007-01; EA-061-05 |
| R6 | Cada álbum tem a ação de abrir o álbum, que leva ao detalhe com as cartas (CCD013) | Ação | `13`, FP 1 |
| R7 | Sem álbuns na coleção, a tela mostra uma mensagem informativa e um botão que leva ao Catálogo Global (texto e botão: L4) | Estado | `08`, FA 1 |
| R8 | Enquanto a lista carrega, a tela mostra o estado de carregando; se a API falha, mostra o estado de erro com a mensagem da API | Estado | ADR-041, Erros e Consequências (`LoadingState`, `ErrorState`) |
| R9 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas: `1160-23080`, `1160-29088`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2, R3, R4) — **Dado** um cliente com 4 álbuns na coleção, **quando** ele seleciona o item de álbuns no menu, **então** vê os 4 álbuns, cada um com a capa, o título e a barra de progresso com o percentual do álbum.
- **CA2** (R3) — **Dado** um cliente que removeu um álbum (CCD011), **quando** abre a lista, **então** o álbum removido não aparece.
- **CA3** (R5) — **Dado** um álbum com 2 cartas marcadas como possuo, com preço médio de R$ 100,00 e R$ 50,00 nos últimos 30 dias, **quando** o cliente abre a lista, **então** o álbum mostra o valor estimado de R$ 150,00.
- **CA4** (R6) — **Dado** a lista aberta, **quando** o cliente seleciona a ação de abrir um álbum, **então** vai para o detalhe desse álbum.
- **CA5** (R7) — **Dado** um cliente sem álbuns, **quando** abre a lista, **então** vê a mensagem informativa e o botão que leva ao Catálogo Global.
- **CA6** (R1) — **Dado** um visitante sem login, **quando** chama a API da lista, **então** recebe `401`; **dado** dois clientes, **quando** o primeiro abre a lista, **então** não vê os álbuns do segundo.
- **CA7** (R8) — **Dado** a API da lista fora do ar, **quando** o cliente abre a tela, **então** vê o estado de erro com a mensagem da API, e enquanto a resposta não chega vê o estado de carregando.
- **CA8** (R9) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-23080`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA9** (R9) — **Dado** a tela implementada aberta em 1280 px sem álbuns, **quando** o print dela é comparado lado a lado com o print do frame `1160-29088`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `collections` | `id`, `user_id` | 1:1 com o usuário; quando nasce: L2 da CCD007 |
| `user_albums` | `collection_id`, `album_id`, `is_favorite`, `progress_percentage`, `created_at`, `deleted_at` | único por (`collection_id`, `album_id`); `is_favorite` default `false`; `progress_percentage` default 0 |
| `albums` | `title`, `cover_url`, `publisher`, `year`, `description`, `total_cards`, `category_id`, `status` (`album_status`: `ACTIVE`, `INACTIVE`), `deleted_at` | `title` obrigatório; `total_cards` default 0 |
| `categories` | `name` | categoria do álbum, se o card a mostrar (L6) |
| `collection_cards` | `card_id`, `status` (`OWNED`, `MISSING`, `DUPLICATE`), `quantity`, `deleted_at` | cartas possuídas para o valor (R5) |
| `price_history` | `card_id`, `price`, `reference_date` | só leitura (R5) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Álbuns - Meus álbuns | [1160-23080](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-23080) | R2–R6, R9 | ❌ Não bate: indicadores, selos, contadores e ordenação só no Figma (L5, L6, L8, L9) |
| Álbuns - sem álbuns | [1160-29088](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-29088) | R7, R9 | ❌ Não bate: botão "Solicitar álbum" no lugar do botão para o Catálogo Global (L4) |

- **Diferenças com o Figma** (decisão em Lacunas e decisões):
  - Sem álbuns — mostra "Você ainda não tem álbuns", "Procure um álbum no catálogo e use "Adicionar à minha coleção". Não achou? Peça o cadastro." e o botão "Solicitar álbum"; o caso de uso pede um botão que leva ao Catálogo Global (L4).
  - Menu — o item se chama "Álbuns" e a página, "Meus álbuns"; o caso de uso chama a opção de "Meus Álbuns" (L11).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões):
  - Meus álbuns e sem álbuns — indicadores "Álbuns" (<n> coleções na sua coleção), "Cartas que possuo" (<n> de <total>, "+<n> esta semana"), "Cartas faltantes" (<n> para fechar) e "Repetidas" (<n> unidades) (L5).
  - Meus álbuns — no cartão: selo sobre a capa ("OFICIAL FIFA", "EXPANSÃO", "BANDAI OFICIAL", "KONAMI 1ST ED."), selo na capa ("Prizm", "Shining Fates", "QUASE COMPLETO!", "Vintage 2002"), categoria, subtítulo, "<n> de <total> cartas", "<n>% concluído", "Faltantes" ("<n> cartas restantes", "Apenas <n> cartas!"), "Repetidas" ("<n> prontas p/ troca") e o rodapé da capa ("Ano 2026", "SWSH Series", "OP-01", "Série LOB") (L6).
  - Meus álbuns — "Ordenar por: Mais recentes" (L8).
  - Meus álbuns — botão com lupa ao lado de "Abrir álbum" e o menu "⋮" do cartão (L9).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela):
  - R7 botão que leva ao Catálogo Global (L4).
  - R8 estados de carregando e de erro.

## Fora do escopo

- Busca de álbum na lista — CCD009.
- "Solicitar álbum" (no topo, no estado vazio e no bloco "Não encontrou a coleção que você coleciona?") — CCD010.
- Remover o álbum (menu "⋮" do cartão) — CCD011.
- "Compartilhar coleção" — CCD012.
- Detalhe do álbum aberto por "Abrir álbum" — CCD013.
- Abas por categoria ("Todos (4)", "Futebol / Esportes (1)"…) — CCD034 (Buscar Categoria do Álbum).
- Cálculo do progresso do álbum — CCD019; esta story só lê `progress_percentage`.
- Adicionar um álbum à coleção — CCD022 e página pública do álbum (EA-002-01).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O `ADMIN` acessa a lista de álbuns do Painel Cliente? (proposta: não; `CUSTOMER` e `SELLER` acessam, o `ADMIN` recebe `403` na API, como na CCD007, L1) | pendente | — |
| L2 | O FP 2 do caso de uso ("exibe um formulário solicitando Título, Editora/Ano e uma descrição opcional") é cópia do Solicitar Álbum (CCD010) e não pertence à lista. Tirar do caso de uso? (proposta: sim) | pendente | — |
| L3 | "Iniciados ou favoritados": um álbum favoritado pela CCD055 (`favorites` do tipo `ALBUM`) que não está na coleção aparece? Álbum `INACTIVE` ou excluído do catálogo continua na lista? (proposta: a lista mostra só `user_albums`; favoritar fica na CCD055; álbum excluído do catálogo some, álbum `INACTIVE` continua) | pendente | — |
| L4 | Estado vazio: o caso de uso pede o botão para o Catálogo Global; o Figma mostra o texto "Procure um álbum no catálogo…" e o botão "Solicitar álbum". Qual vale? (proposta: o texto do Figma com dois botões: "Ver catálogo" (Pesquisar) e "Solicitar álbum"; o Gabriel ajusta o frame) | pendente | — |
| L5 | Os indicadores do topo só existem no Figma. Fazem sentido? Como se calcula "+<n> esta semana"? (proposta: sim, com as regras da CCD007, L3; "+<n> esta semana" = cartas marcadas como possuo nos últimos 7 dias, por `collection_cards.updated_at`) | pendente | — |
| L6 | Os campos extras do cartão só existem no Figma, e o DBML não tem coluna para os selos nem para a série do rodapé ("SWSH Series", "OP-01"). Quais entram? "prontas p/ troca" fala de trocas, que estão fora do MVP (ADR-027). (proposta: entram categoria, editora e ano, "<n> de <total> cartas", "<n>% concluído", faltantes e repetidas; os selos e a série saem do Figma; "prontas p/ troca" vira "a mais", como no detalhe do álbum) | pendente | — |
| L7 | Paginação: o caso de uso não diz quantos álbuns aparecem por vez. (proposta: todos, sem paginação, porque a coleção de um cliente tem poucos álbuns) | pendente | — |
| L8 | "Ordenar por: Mais recentes" só existe no Figma. Faz sentido? Quais outras ordens? (proposta: sim, com "Mais recentes" (`user_albums.created_at`), "Maior progresso" e "Nome") | pendente | — |
| L9 | O botão com lupa ao lado de "Abrir álbum" e o menu "⋮" do cartão não têm função descrita nem frame aberto. O que fazem? (proposta: a lupa sai; o "⋮" abre o mesmo menu do detalhe, com "Resetar progresso" e "Remover da minha coleção") | pendente | — |
| L10 | Ordem padrão da lista sem a ordenação do Figma. (proposta: mais recentes primeiro) | pendente | — |
| L11 | O caso de uso chama a opção de "Meus Álbuns"; no Figma, o item do menu é "Álbuns" e a página, "Meus álbuns". (proposta: como no Figma) | pendente | — |
