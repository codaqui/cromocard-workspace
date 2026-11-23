# CCD034 — Buscar Categoria do Álbum

- **Status:** Rascunho
- **Fase:** MVP (era Futuro; o filtro por seleção foi desenhado no Figma em 22/11/2026, ADR-069)
- **User story:** #137 `CCD034 - Buscar Categoria do Álbum`
- **Caso de uso:** [34-buscar-categoria-do-album.md](../../docs/Casos-De-Uso/34-buscar-categoria-do-album.md)
- **Atores:** Cliente · **Pré-condições:** cliente autenticado, no detalhe de um álbum da sua coleção (filtro "Seleção") ou no Início (categoria raiz)
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso selecionar a categoria por seleções e times do álbum para filtrar figurinhas exatos dentro da minha coleção.

A narrativa não está nas tabelas de `user-stories.md`: vem da Finalidade do caso de uso. A fase vem da linha "** - Futuro"
das Observações de `user-stories.md` ("Categoria do album, seleção, times").

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

> **Fase Futuro** (`**` nas Observações de `user-stories.md`): esta spec existe para deixar a story pronta, mas não entra no
> MVP sem o PO puxá-la para uma sprint.

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Filtrar exige login: sem token, `401`; o filtro só vê a coleção do próprio cliente | Permissão | `34`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | Nos filtros da coleção, o cliente seleciona uma categoria, uma seleção ou um time | Ação | `34`, FP 1 (L2) |
| R3 | Categoria, seleção e time são níveis da hierarquia de `categories` (`parent_category_id`) | Regra | `34`, FP 1; DBML `categories.parent_category_id` ("Hierarquia: seleção / time") (L3) |
| R4 | O filtro mostra só as figurinhas da coleção do cliente que pertencem ao item selecionado | Regra | `34`, FP 2–3 (L4) |
| R5 | Sem figurinhas no item selecionado, a tela mostra "Nenhuma figurinha encontrada para esta categoria" | Mensagem | `34`, FA 1 |
| R6 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**), quando o frame do filtro existir: layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma (L1) |

## Critérios de aceite

- **CA1** (R2–R4) — **Dado** a coleção com cartas das seleções Argentina e Brasil, **quando** o cliente seleciona a seleção
  "Argentina", **então** só as cartas da Argentina aparecem.
- **CA2** (R3, R4) — **Dado** a categoria "Futebol" com as seleções e times como subcategorias, **quando** o cliente
  seleciona "Futebol", **então** aparecem as cartas de Futebol e das subcategorias dela.
- **CA3** (R5) — **Dado** nenhuma carta da coleção no time escolhido, **quando** o cliente o seleciona, **então** vê
  "Nenhuma figurinha encontrada para esta categoria".
- **CA4** (R1) — **Dado** um visitante sem login, **quando** chama a rota da coleção com o filtro, **então** recebe `401`.
- **CA5** (R6) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print do detalhe
  do álbum com a lista do filtro "Seleção" aberta é comparado lado a lado com o frame `1226-2361`, **então** não há diferença
  de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem
  quebra, corte nem rolagem horizontal.
- **CA6** (R6) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1122-17812`, **então** não há diferença de layout, medida, espaçamento, cor,
  fonte, texto, ícone ou imagem nos botões de categoria; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte
  nem rolagem horizontal.

- **CA7** (R6) — Idem ao CA5, com o detalhe do álbum com o filtro fechado (`1160-23696`), filtrado por "Brasil" (`1226-3003`)
  e sem figurinhas para "Uruguai" (`1226-3625`).
## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `categories` | `id`, `name`, `parent_category_id`, `display_order`, `is_pinned`, `deleted_at` | hierarquia categoria › seleção › time; ordem da CCD104 |
| `cards` | `category_id`, `album_id`, `deleted_at` | categoria da carta (L3) |
| `albums` | `category_id` | categoria do álbum (L3) |
| `collection_cards` | `collection_id`, `card_id`, `status`, `deleted_at` | cartas da coleção do cliente |

## Telas (Figma)

O filtro "Seleção" foi desenhado na linha de filtros do detalhe do álbum em 22/11/2026 (L1), nas seis telas de detalhe do
álbum e em três estados novos.

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Cliente - Início (minha coleção) — botões de categoria raiz | [1122-17812](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1122-17812) | R2, R4 | ✅ Bate |
| Álbuns - detalhe do álbum, com o filtro "Todas as seleções" | [1160-23696](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-23696) | R2 | ✅ Bate |
| Álbuns - filtrar por seleção (lista aberta, com a quantidade de figurinhas de cada seleção) | [1226-2361](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1226-2361) | R2, R3 | ✅ Bate |
| Álbuns - filtrado por seleção ("Brasil", "Exibindo 1 de 54 itens") | [1226-3003](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1226-3003) | R4 | ✅ Bate |
| Álbuns - filtro sem figurinhas ("Uruguai") | [1226-3625](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1226-3625) | R5 | ✅ Bate |

- Telas vistas que não implementam esta story: "Álbuns - Meus álbuns"
  ([1160-23080](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-23080)), cujos botões de categoria filtram álbuns, não figurinhas (L2).
- **Diferenças com o Figma:** nenhuma.
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): os botões com a contagem por categoria em "Meus
  álbuns" ("Todos (4)", "Futebol / Esportes (1)"…), que filtram álbuns (L2).

## Fora do escopo

- Buscar cartas por categoria no marketplace e no catálogo — CCD027.
- Filtrar por nome, raridade ou idioma dentro da coleção — CCD037.
- Ordenar as categorias — CCD104.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Falta o desenho do filtro por seleção e time no Figma. Em que tela ele fica (Início, detalhe do álbum ou "Meus álbuns") e como (botões em níveis, select em cascata)? | No detalhe do álbum, como seletor "Seleção" na linha de filtros, com a quantidade de figurinhas de cada opção; desenhado em 22/11/2026 (`1226-2361`, `1226-3003`, `1226-3625`) | `34`, FP 1–3; Figma |
| L2 | A Pré-condição diz "tela da sua coleção de álbuns" ("Meus álbuns"), mas o resultado são figurinhas. Os botões de "Meus álbuns" (`1160-23080`) filtram álbuns: eles são desta story ou da CCD008/CCD009? | pendente | — |
| L3 | A figurinha pertence à seleção pela própria categoria (`cards.category_id` = "Argentina") ou pela do álbum? O ADR-063 (Proposto, ainda fora da `development`) faz a carta com álbum ter a franquia do álbum e responde `422` para outra categoria: uma subcategoria (seleção, time) conta como "outra"? Sem resolver, a carta de álbum não pode ter seleção | pendente | — |
| L4 | O filtro mostra só as cartas `OWNED`/`DUPLICATE` ou também as `MISSING`? | pendente | — |
| L5 | "Cliente" são os papéis `CUSTOMER` e `SELLER`? E o `ADMIN`? (proposta: `CUSTOMER` e `SELLER`; `ADMIN` recebe `403`, como na CCD103, L8) | pendente | — |
