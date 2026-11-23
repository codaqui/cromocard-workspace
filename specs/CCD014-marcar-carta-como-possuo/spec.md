# CCD014 — Marcar Carta como Possuo

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #120 `CCD014 -Marcar Carta como Possuo`
- **Agrupa:** CCD015 Marcar Carta como Faltante (#121 `CCD015 -Marcar Carta como Faltante`), CCD016 Marcar Carta Repetida (#122 `CCD016 -Marcar Carta Repetida`)
- **Caso de uso:** [14-marcar-carta-como-possuo.md](../../docs/Casos-De-Uso/14-marcar-carta-como-possuo.md) · [15-marcar-carta-como-faltante.md](../../docs/Casos-De-Uso/15-marcar-carta-como-faltante.md) · [16-marcar-carta-repetida.md](../../docs/Casos-De-Uso/16-marcar-carta-repetida.md)
- **Atores:** Cliente · **Pré-condições:** autenticado e na tela de cartas do álbum (CCD014, CCD015); para Repetida, possuir pelo menos uma unidade da carta (CCD016)
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso marcar uma carta como possuo para registrar que o item faz parte da minha coleção.
>
> Como Cliente preciso marcar uma carta como faltante para identificar quais itens ainda preciso adquirir.
>
> Como Cliente preciso marcar uma carta como repetida para identificar os itens duplicados da minha coleção.

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
| R1 | Marcar exige login e só altera a coleção do próprio cliente: sem token, a API responde `401` (carta de álbum fora da coleção: L11) | Permissão | `14`, `15` e `16`, Pré-condições; ADR-005, item 4; ADR-011 (papel `ADMIN`: L1) |
| R2 | Cada carta da tela de cartas do álbum tem as opções "Possuo", "Faltante" e "Repetida" (rótulos: L2) | Ação | `14`, FP 1; `15`, FP 1; `16`, FP 1 |
| R3 | "Possuo": a API valida a alteração e grava o status `OWNED` da carta na coleção do cliente (`collection_cards`; a linha excluída antes é restaurada, sem criar outra) (quantidade: L4, L6) | Regra | `14`, FP 2–3; DBML `collection_cards`; ADR-015, item 7 |
| R4 | "Faltante": a API grava o status `MISSING` e zera a quantidade, se houver | Regra | `15`, FP 2 |
| R5 | A opção "Faltante" fica desabilitada quando a carta já está como faltante | Estado | `15`, FA 1 |
| R6 | "Repetida" só vale para carta que o cliente possui: a API valida se o status atual permite a ação | Regra | `16`, Pré-condições e FP 2 |
| R7 | "Repetida" incrementa o contador de repetidas da carta e muda a indicação visual dela (relação com a quantidade: L4, L5) | Regra | `16`, FP 3 |
| R8 | "Repetida" numa carta faltante converte o status para Possuo antes de contar a repetição | Regra | `16`, FA 1–2 |
| R9 | Depois de cada marcação, a API recalcula o progresso do álbum (`user_albums.progress_percentage`): cartas possuídas do álbum dividido pelo total de cartas do álbum (repetidas: L8) | Regra | `14`, FP 4; `15`, FP 3; `19`, FP 2 |
| R10 | A carta e o progresso do álbum mudam na tela logo depois da marcação | Tela | `15`, FP 3; `16`, FP 3 |
| R11 | Se a conexão falha, a tela informa o erro ao salvar e orienta o cliente a tentar novamente (texto: L9) | Mensagem | `14`, FA 1 |
| R12 | Carta marcada na coleção de algum cliente passa a contar como "usada em coleções" e não pode ser excluída no catálogo (a CCD014 liga a implementação de `CardUsage` que a CCD061 deixou pendente) | Regra | `61`, FA 5; CCD061, L2 e `plano.md` (pendência da CCD014) |
| R13 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas: `1160-23696`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2, R3, R9, R10) — **Dado** um álbum de 54 cartas com 43 possuídas e a carta #09 faltante, **quando** o cliente marca "Possuo" na #09, **então** a API grava `OWNED` para a carta, `progress_percentage` passa a 81,48 e a carta e a barra de progresso mudam na tela.
- **CA2** (R3) — **Dado** uma carta cuja marcação foi excluída (álbum removido e adicionado de novo), **quando** o cliente marca "Possuo", **então** a linha antiga de `collection_cards` é restaurada com `OWNED`, sem criar outra.
- **CA3** (R4, R9, R10) — **Dado** uma carta possuída com quantidade 1, **quando** o cliente marca "Faltante", **então** a API grava `MISSING` com quantidade 0, o progresso do álbum cai e a carta muda na tela.
- **CA4** (R5) — **Dado** uma carta faltante, **quando** o cliente olha as opções dela, **então** "Faltante" está desabilitada.
- **CA5** (R6, R7, R10) — **Dado** uma carta possuída, **quando** o cliente marca "Repetida", **então** o contador de repetidas da carta sobe e a indicação visual muda para repetida.
- **CA6** (R8, R9) — **Dado** uma carta faltante, **quando** o cliente marca "Repetida", **então** a carta passa a possuída antes de contar a repetição, fica como repetida e o progresso do álbum sobe.
- **CA7** (R11) — **Dado** a conexão com a API caída, **quando** o cliente marca "Possuo", **então** a tela informa que houve erro ao salvar, orienta tentar novamente e a carta volta ao status anterior.
- **CA8** (R1) — **Dado** um visitante sem login, **quando** chama a API de marcação, **então** recebe `401`; **dado** dois clientes, **quando** o primeiro marca uma carta, **então** a coleção do segundo não muda.
- **CA9** (R12) — **Dado** uma carta marcada como possuo por um cliente, **quando** o admin tenta excluí-la na Gestão de Catálogo, **então** a exclusão é bloqueada com o modal "Não é possível excluir esta carta" da CCD061.
- **CA10** (R13) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-23696`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem nos marcadores "Possuo", "Falta" e "Repetida" (normal e selecionado) e nos selos das cartas; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `collection_cards` | `collection_id`, `card_id`, `status` (`collection_card_status`: `OWNED`, `MISSING`, `DUPLICATE`), `quantity`, `deleted_at` | `status` obrigatório; `quantity` obrigatória, default 1; único por (`collection_id`, `card_id`), então marcar de novo restaura a linha (ADR-015, item 7) |
| `user_albums` | `collection_id`, `album_id`, `progress_percentage`, `deleted_at` | `progress_percentage` `decimal(5,2)`, default 0 |
| `albums` | `total_cards` | denominador do progresso; total 0 é a CCD019 ("Progresso indisponível") |
| `cards` | `album_id`, `status`, `deleted_at` | a carta pertence ao álbum |
| `collections` | `id`, `user_id` | quando nasce: L2 da CCD007 |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Álbuns - detalhe do álbum | [1160-23696](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-23696) | R2, R5, R7, R10, R13 | ❌ Não bate: marcador "Falta" no lugar de "Faltante" e selos com outros nomes (L2) |

- Textos do frame para esta story: marcadores "Possuo", "Falta" e "Repetida"; selos "NO ÁLBUM", "2 REPETIDAS" e "FALTANDO"; "Clique nos marcadores Possuo, Falta ou Repetida para atualizar instantaneamente."; e o bloco "Dica: marque cada carta do álbum" / "Marque Possuo, Falta ou Repetida em cada carta: o progresso do álbum é recalculado na hora. As repetidas podem ser anunciadas no marketplace.".
- **Diferenças com o Figma** (decisão em Lacunas e decisões):
  - Detalhe do álbum — o marcador é "Falta"; o caso de uso chama a opção de "Faltante" (L2).
  - Detalhe do álbum — "2 REPETIDAS" aparece numa carta com "Qtd: 3", ou seja, repetidas = quantidade − 1; o caso de uso fala de um "contador de repetidas" que o DBML não tem (L4).
- **Só no Figma**: o texto "atualizar instantaneamente" sugere atualização otimista (L9).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela):
  - R5 marcador "Falta" desabilitado (no frame, a carta faltante mostra "Falta" selecionado, sem estado desabilitado).
  - R11 aviso de erro ao salvar (L9).

## Fora do escopo

- Lista das cartas do álbum e os selos de status — CCD013.
- "Qtd:" com "+" — CCD017; com "−" e a lixeira — CCD018.
- Barra e indicadores de progresso do álbum — CCD019 (esta story só grava o `progress_percentage`).
- Zerar todas as marcações do álbum — CCD035.
- Anunciar as repetidas no marketplace — CCD084.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O `ADMIN` marca cartas pelo Painel Cliente? (proposta: não, `403`, como na CCD007, L1) | pendente | — |
| L2 | Rótulos: o caso de uso diz "Faltante"; o detalhe mostra o marcador "Falta" e os selos "NO ÁLBUM", "<n> REPETIDAS" e "FALTANDO"; o Início mostra "Possuo", "Repetida (x2)" e "Faltante". Qual vale? (proposta: os do Figma em cada tela) | pendente | — |
| L3 | Carta nunca marcada (sem linha em `collection_cards`) conta como faltante na tela e nas contagens? (proposta: sim; a linha só nasce quando o cliente marca; igual à CCD013, L4) | pendente | — |
| L4 | O DBML só tem `status` e `quantity` (default 1). Como ficam status, quantidade e o "contador de repetidas"? (proposta: `quantity` = unidades que o cliente tem; `OWNED` com 1; `DUPLICATE` com 2 ou mais; repetidas = `quantity` − 1, como no Figma; `MISSING` com 0) | pendente | — |
| L5 | "Repetida" soma uma unidade a cada clique ou só marca? E numa carta que já está repetida? (proposta: em Possuo, vai para 2 unidades; já repetida, o marcador fica selecionado e desabilitado, e mais unidades entram pelo "+" da CCD017) | pendente | — |
| L6 | "Possuo" numa carta repetida volta para 1 unidade? "Possuo" numa carta já possuída fica desabilitado, como o "Faltante" (`15`, FA 1)? (proposta: sim nos dois) | pendente | — |
| L7 | "Faltante" numa carta repetida zera tudo sem confirmação? (proposta: sim, como o `15`, FP 2) | pendente | — |
| L8 | Repetidas contam no progresso? (proposta: sim, uma vez cada carta, com status `OWNED` ou `DUPLICATE`) | pendente | — |
| L9 | Texto e desenho do erro ao salvar (`14`, FA 1) não existem. A atualização é otimista, como sugere "atualizar instantaneamente"? (proposta: otimista; em erro, a carta volta ao status anterior e o aviso padrão mostra "Não foi possível salvar. Verifique a conexão e tente novamente.") | pendente | — |
| L10 | O Início (`1122-17812`) também mostra o status das cartas. A marcação acontece só no detalhe do álbum? (proposta: só no detalhe, como dizem as pré-condições; o Início só mostra) | pendente | — |
| L11 | Carta de um álbum que não está na coleção do cliente, ou carta avulsa (`album_id` nulo): pode marcar? (proposta: não; a API responde `404` e o cliente adiciona o álbum antes, CCD022) | pendente | — |
