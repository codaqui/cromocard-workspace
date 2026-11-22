# CCD022 — Adicionar Carta

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #128 `CCD022 -Adicionar Carta`
- **Caso de uso:** [22-adicionar-carta.md](../../docs/Casos-De-Uso/22-adicionar-carta.md)
- **Atores:** Cliente · **Pré-condições:** cliente autenticado, que localizou a carta na plataforma
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso adicionar uma carta à minha coleção para registrar o item entre os meus itens.

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
| R1 | Adicionar exige login: sem token, `401` | Permissão | `22`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | O cliente adiciona pela opção "Adicionar" no resultado da busca do modal "Adicionar carta" e por "Adicionar à coleção" no perfil da carta | Ação | `22`, FP 1; Figma `1160-28449`, `1112-4615` |
| R3 | A carta entra na coleção do cliente (`collection_cards`) com quantidade 1 | Regra | `22`, FP 2; DBML `collection_cards.quantity` (default 1) (L1) |
| R4 | Depois de adicionar, a interface atualiza o estado da carta e recalcula o progresso do álbum dela | Regra | `22`, FP 3; `19`, FP 2 |
| R5 | Carta que já está na coleção não ganha outro registro: a quantidade sobe 1 e a tela avisa o cliente da atualização | Regra | `22`, FA 1–2; DBML `collection_cards` (único por `collection_id`, `card_id`) (L2, L3) |
| R6 | Carta removida antes da coleção (`deleted_at` preenchido) volta pelo mesmo registro, restaurado com quantidade 1 | Regra | ADR-015, item 7 |
| R7 | Carta inexistente, excluída ou em rascunho (`DRAFT`) responde `404` | Regra | `22`, Pré-condições ("ter localizado a carta na plataforma"); DBML `cards.status`; ADR-011 |
| R8 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames `1160-28449`, `1112-4615`, `1160-23696`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2, R3, R4) — **Dado** uma carta da Copa do Mundo 2026 que não está na coleção, **quando** o cliente seleciona
  "Adicionar" no modal, **então** a carta é gravada na coleção com quantidade 1, o estado dela muda na tela e o progresso
  do álbum sobe.
- **CA2** (R2, R3) — **Dado** o perfil de uma carta que não está na coleção, com o cliente logado, **quando** ele seleciona
  "Adicionar à coleção", **então** a carta é gravada com quantidade 1 e o botão reflete que ela está na coleção (L7).
- **CA3** (R5) — **Dado** uma carta já na coleção com quantidade 1, **quando** o cliente a adiciona de novo pelo perfil da
  carta, **então** a quantidade passa a 2, não surge outro registro e a tela mostra o aviso de atualização.
- **CA4** (R6) — **Dado** uma carta removida antes da coleção, **quando** o cliente a adiciona, **então** o registro antigo
  é restaurado com quantidade 1.
- **CA5** (R7) — **Dado** uma carta em rascunho, **quando** a rota de adicionar é chamada com o id dela, **então** a API
  responde `404`.
- **CA6** (R1) — **Dado** um visitante sem login, **quando** chama a rota de adicionar, **então** recebe `401`.
- **CA7** (R8) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1160-28449`, **então** não há diferença de layout, medida, espaçamento, cor,
  fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem
  horizontal.
- **CA8** (R8) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1112-4615`, **então** não há diferença de layout, medida, espaçamento, cor,
  fonte, texto, ícone ou imagem no botão "Adicionar à coleção"; e em 375, 768 e 1024 px o mesmo design se adapta sem
  quebra, corte nem rolagem horizontal.
- **CA9** (R8) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1160-23696`, **então** não há diferença de layout, medida, espaçamento, cor,
  fonte, texto, ícone ou imagem no estado da carta adicionada e na barra de progresso; e em 375, 768 e 1024 px o mesmo
  design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `collection_cards` | `collection_id`, `card_id`, `status` (`OWNED`, `MISSING`, `DUPLICATE`), `quantity`, `deleted_at` | `status` obrigatório (valor na L1); `quantity` default 1; único por (`collection_id`, `card_id`), restaura ao re-adicionar (ADR-015) |
| `collections` | `id`, `user_id` | coleção 1:1 com o usuário |
| `cards` | `id`, `album_id`, `status`, `deleted_at` | `album_id` nulo = carta avulsa (L5) |
| `user_albums` | `collection_id`, `album_id`, `progress_percentage` | progresso recalculado (R4); álbum fora da coleção na L5 |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Álbuns - adicionar carta | [1160-28449](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-28449) | R2, R5 | ❌ Não bate: carta já na coleção aparece com "JÁ ESTÁ NA COLEÇÃO" e sem "Adicionar" (L2) |
| Público - Perfil da carta | [1112-4615](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-4615) | R2 | ⚠️ Só a versão do visitante; a do cliente logado não tem frame (L7) |
| Álbuns - detalhe do álbum | [1160-23696](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-23696) | R4 | ✅ Bate |

- **Diferenças com o Figma** (decisão em Lacunas e decisões): modal — carta já na coleção: o Figma mostra o selo "JÁ ESTÁ
  NA COLEÇÃO" sem botão; o FA 1–2 pede incrementar a quantidade (L2).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): nenhum.
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R5 o aviso de quantidade atualizada e a mensagem de
  sucesso (L6); o perfil da carta para o cliente logado (L7).

## Fora do escopo

- Pesquisar a carta — CCD021. Solicitar o cadastro de carta que não existe — CCD023.
- Informar a quantidade ao adicionar — CCD036 (L3).
- Marcar possuo, faltante e repetida e mudar a quantidade na grade do álbum — CCD014–CCD017.
- "Adicionar à coleção" do visitante, que abre "Entre para continuar" — CCD030 (FA 1–2).
- "Adicionar à minha coleção" do álbum do catálogo (`1160-1845`) — CCD002 (EA-002-01).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Com que status a carta entra? O `22` não diz e `collection_cards.status` é obrigatório. (proposta: `OWNED`, como no `36`, FP 5) | pendente | — |
| L2 | Carta já na coleção: o Figma mostra "JÁ ESTÁ NA COLEÇÃO" sem botão; o FA 1–2 pede incrementar a quantidade e avisar. Qual vale? | pendente | — |
| L3 | A CCD036 descreve a mesma ação com outras regras: o cliente informa a quantidade e, se a carta já existe, a tela informa e oferece atualizar a quantidade. Qual regra vale? Juntar CCD022 e CCD036 numa spec só (decisão do usuário)? | pendente | — |
| L4 | Se a carta está na coleção como `MISSING`, ela "já consta"? Adicionar soma 1 à quantidade ou passa a `OWNED` com quantidade 1? E ao chegar a 2 ou mais, o status passa a `DUPLICATE` (o Figma mostra "2 REPETIDAS" com Qtd 3)? | pendente | — |
| L5 | O modal da Copa do Mundo 2026 oferece cartas de outros álbuns (ex.: "Copa do Mundo 2022 • Nº 21"). Adicionar uma delas põe o álbum dela na coleção (`user_albums`)? E a carta avulsa (`album_id` nulo), que não tem progresso? | pendente | — |
| L6 | Textos da mensagem de sucesso e do aviso de quantidade atualizada (FA 2), que o Figma não desenha | pendente | — |
| L7 | O perfil da carta só tem frame para o visitante. Para o cliente logado, o que o botão mostra depois de adicionar (ex.: "Na coleção") e a tela usa o menu do cliente? | pendente | — |
| L8 | "Cliente" são os papéis `CUSTOMER` e `SELLER`? E o `ADMIN`? (proposta: `CUSTOMER` e `SELLER`; `ADMIN` recebe `403`, como na CCD103, L8) | pendente | — |
