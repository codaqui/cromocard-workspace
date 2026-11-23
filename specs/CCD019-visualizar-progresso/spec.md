# CCD019 — Visualizar Progresso

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #125 `CCD019 -Visualizar Progresso`
- **Caso de uso:** [19-visualizar-progresso.md](../../docs/Casos-De-Uso/19-visualizar-progresso.md)
- **Atores:** Cliente · **Pré-condições:** cliente autenticado, com o álbum na sua coleção
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso visualizar o progresso do álbum para acompanhar o percentual de figurinhas que já possuo.

A seção 3 de `user-stories.md` repete a ideia em "Visualizar Progresso do Álbum" ("visualizar a porcentagem de completude
do álbum e poder compartilhá-lo externamente"); o compartilhamento é da CCD020.

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
| R1 | Ver o progresso exige login: sem token, `401`. O cliente só vê o progresso dos álbuns da própria coleção: álbum que não está na coleção dele responde `404` | Permissão | `19`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | O percentual é a proporção entre as cartas possuídas e o total de cartas do álbum | Regra | `19`, FP 2 |
| R3 | No detalhe do álbum, o cabeçalho mostra a barra de progresso com "Progresso do Álbum: <n>% Concluído" e "<x> de <total> cartas colecionadas (Faltam apenas <y> cartas)" | Tela | `19`, FP 1 e FP 3; Figma `1160-23696` |
| R4 | Em "Meus álbuns", cada álbum mostra "<x> de <total> cartas", "<n>% concluído" e a barra | Tela | `19`, FP 1 ("resumo da sua coleção") e FP 3; Figma `1160-23080` |
| R5 | No Início, o bloco "Álbum em destaque: <título>" mostra a barra e "<x> de <total> cartas • <n>% completo" | Tela | `19`, FP 1 e FP 3; Figma `1122-17812` |
| R6 | Álbum sem total de cartas cadastrado (`albums.total_cards` = 0) mostra "Progresso indisponível" no lugar da barra e do percentual | Estado | `19`, FA 1; DBML `albums.total_cards` (default 0) |
| R7 | Álbum sem nenhuma carta possuída mostra 0% e "0 de <total> cartas" | Estado | `19`, FP 2 |
| R8 | Quando uma marcação muda as cartas possuídas do álbum (CCD014–018, CCD022, CCD035, CCD036), o progresso é recalculado e a tela mostra o valor novo sem recarregar a página | Regra | `14`, FP 4; `22`, FP 3; `35`, FP 5; `36`, FP 6; Figma `1160-23696` ("o progresso do álbum é recalculado na hora") |
| R9 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames `1160-23696`, `1160-23080`, `1122-17812`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2, R3) — **Dado** um álbum com 54 cartas no total e 44 possuídas na coleção do cliente, **quando** ele abre o
  detalhe do álbum, **então** vê a barra preenchida na proporção 44/54, o percentual pela regra da L3 e "44 de 54 cartas
  colecionadas (Faltam apenas 10 cartas)".
- **CA2** (R4) — **Dado** quatro álbuns na coleção, **quando** o cliente abre "Meus álbuns", **então** cada cartão mostra
  "<x> de <total> cartas", "<n>% concluído" e a barra do próprio álbum.
- **CA3** (R5) — **Dado** um álbum em destaque no Início, **quando** o cliente abre o Início, **então** vê "Álbum em
  destaque: <título>", a barra e "<x> de <total> cartas • <n>% completo".
- **CA4** (R6) — **Dado** um álbum com `total_cards` = 0, **quando** o cliente abre o detalhe, "Meus álbuns" ou o Início,
  **então** vê "Progresso indisponível" e nenhuma barra nem percentual.
- **CA5** (R7) — **Dado** um álbum de 54 cartas sem nenhuma possuída, **quando** o cliente abre o detalhe, **então** vê 0%,
  a barra vazia e "0 de 54 cartas colecionadas".
- **CA6** (R8) — **Dado** o detalhe de um álbum aberto com 44 de 54, **quando** o cliente marca mais uma carta como possuo,
  **então** o cabeçalho passa a "45 de 54" e o percentual muda sem recarregar a página.
- **CA7** (R1) — **Dado** um visitante sem login, **quando** chama a rota do progresso, **então** recebe `401`; **dado** um
  cliente logado, **quando** pede o progresso de um álbum que não está na coleção dele, **então** recebe `404`.
- **CA8** (R9) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1160-23696`, **então** não há diferença de layout, medida, espaçamento, cor,
  fonte, texto, ícone ou imagem no cabeçalho do álbum e na barra de progresso; e em 375, 768 e 1024 px o mesmo design se
  adapta sem quebra, corte nem rolagem horizontal.
- **CA9** (R9) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1160-23080`, **então** não há diferença de layout, medida, espaçamento, cor,
  fonte, texto, ícone ou imagem nos cartões de álbum; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte
  nem rolagem horizontal.
- **CA10** (R9) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1122-17812`, **então** não há diferença de layout, medida, espaçamento, cor,
  fonte, texto, ícone ou imagem no bloco "Álbum em destaque"; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra,
  corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `albums` | `title`, `total_cards`, `deleted_at` | `total_cards` obrigatório, default 0 (0 = progresso indisponível, R6) |
| `user_albums` | `collection_id`, `album_id`, `progress_percentage`, `deleted_at` | `progress_percentage` `decimal(5,2)`, default 0; único por (`collection_id`, `album_id`) |
| `collection_cards` | `collection_id`, `card_id`, `status` (`collection_card_status`: `OWNED`, `MISSING`, `DUPLICATE`), `quantity`, `deleted_at` | único por (`collection_id`, `card_id`); quem conta como possuída depende da L1 |
| `cards` | `album_id`, `status` (`card_status`), `deleted_at` | liga a carta da coleção ao álbum |
| `collections` | `user_id` | coleção 1:1 com o usuário |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Álbuns - detalhe do álbum | [1160-23696](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-23696) | R2, R3, R8 | ❌ Não bate: o percentual de exemplo (82% para 44 de 54) não segue nenhuma regra de arredondamento (L3); indicadores do cabeçalho sem dono definido (L5) |
| Álbuns - Meus álbuns | [1160-23080](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-23080) | R4 | ❌ Não bate: selo "QUASE COMPLETO!" e "Apenas 5 cartas!" só no Figma (L6); "prontas p/ troca" fala de troca, fora do MVP (L7) |
| Cliente - Início (minha coleção) | [1122-17812](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1122-17812) | R5 | ✅ Bate (o critério de escolha do álbum em destaque é da CCD007) |

- **Diferenças com o Figma** (decisão em Lacunas e decisões): detalhe do álbum e Meus álbuns — percentual: 44 de 54
  aparece como 82% e 23 de 40 como 57%; nenhuma regra única de arredondamento gera os dois (L3).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): Meus álbuns — selo "QUASE COMPLETO!" e
  "Apenas 5 cartas!" (L6); detalhe do álbum — indicadores "NO ÁLBUM", "FALTANTES", "REPETIDAS" e "VALOR ESTIMADO" (L5).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R6 o estado "Progresso indisponível" (L8).

## Fora do escopo

- Escolher qual álbum aparece em destaque no Início e os demais indicadores do Início — CCD007.
- "VALOR ESTIMADO" do álbum — CCD007 (EA-007-01).
- Marcar cartas (possuo, faltante, repetida, quantidade) — CCD014–CCD018; a CCD019 só exibe o resultado.
- Compartilhar o progresso — CCD020. Resetar o progresso — CCD035.
- Listar, filtrar e ordenar os álbuns em "Meus álbuns" — CCD008 e CCD009.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Quem conta como "carta possuída" no FP 2? O Figma soma as repetidas nas possuídas (44 no álbum + 10 faltantes = 54; repetidas "a mais"). (proposta: `OWNED` e `DUPLICATE`, cada carta conta uma vez, qualquer que seja a quantidade) | pendente | — |
| L2 | O total do álbum é `albums.total_cards` ou a contagem das cartas ativas do álbum? O Figma mostra "54 cartas catalogadas". O que fazer se os dois números diferirem? (proposta: `total_cards`, e 0 = indisponível, como no FA 1) | pendente | — |
| L3 | Arredondamento: o Figma mostra 82% para 44 de 54 (81,48%) e 57% para 23 de 40 (57,5%). Qual regra? (proposta: inteiro arredondado para baixo, 100% só com todas as cartas; corrigir o exemplo do Figma para 81%) | pendente | — |
| L4 | "Faltam apenas <y> cartas" é o total menos as possuídas ou a contagem das cartas marcadas `MISSING`? (proposta: total menos possuídas) | pendente | — |
| L5 | Os indicadores do cabeçalho do detalhe ("NO ÁLBUM", "FALTANTES", "REPETIDAS", "VALOR ESTIMADO") entram nesta story? Nenhum caso de uso os cita. (proposta: os três primeiros sim, como o progresso em números; "VALOR ESTIMADO" na CCD007, EA-007-01) | pendente | — |
| L6 | Selo "QUASE COMPLETO!" e o aviso "Apenas 5 cartas!" no cartão do álbum (`1160-23080`) só existem no Figma: faz sentido implementar? A partir de qual percentual? | pendente | — |
| L7 | O cartão do álbum diz "6 prontas p/ troca", mas trocas estão fora do MVP (`escopo-adicional.md`, seção 3). Trocar o texto (proposta: "6 a mais", como no detalhe do álbum)? | pendente | — |
| L8 | O Figma não desenha o estado "Progresso indisponível" (FA 1). Pedir o desenho ou seguir o estilo da tela? | pendente | — |
| L9 | "Cliente" são os papéis `CUSTOMER` e `SELLER`? E o `ADMIN`? (proposta: `CUSTOMER` e `SELLER`; `ADMIN` recebe `403`, como na CCD103, L8) | pendente | — |
