# CCD037 — Buscar Categoria do Card

- **Status:** Rascunho
- **Fase:** MVP (era Futuro; puxada para o MVP em 22/11/2026 com as telas já no Figma, ADR-068)
- **User story:** #140 `CCD037 - Buscar Categoria do Card`
- **Caso de uso:** [37-buscar-categoria-do-card.md](../../docs/Casos-De-Uso/37-buscar-categoria-do-card.md)
- **Atores:** Cliente · **Pré-condições:** cliente autenticado, na área de busca ou no inventário de cards
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso pesquisar e visualizar os cards através dos seus elementos específicos para encontrar Card exatos dentro da minha coleção.

A narrativa não está nas tabelas de `user-stories.md`: vem da Finalidade do caso de uso. A fase vinha da linha "** - Futuro" (até 22/11/2026, quando virou MVP)
das Observações de `user-stories.md` ("Categoria card, elementos").

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

> **Fase MVP** desde 22/11/2026: as telas já estão no Figma, e o Daniel puxou a story para o MVP (ADR-068).

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Pesquisar exige login: sem token, `401`; a pesquisa só vê a coleção do próprio cliente | Permissão | `37`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | O cliente informa os elementos da carta (nome, raridade, atributos) nos campos de pesquisa da coleção | Campo | `37`, FP 1 (L1, L2) |
| R3 | O sistema valida os parâmetros: valor fora da lista (raridade ou idioma inexistente) responde `400 VALIDATION_ERROR` | Regra | `37`, FP 2; ADR-011 |
| R4 | O resultado mostra só as cartas da coleção do cliente que atendem a todos os elementos informados | Regra | `37`, FP 3 (L3) |
| R5 | Sem resultado, a tela mostra "Nenhum card encontrado com estes elementos" e sugere limpar os filtros | Mensagem | `37`, FA 1 (L4) |
| R6 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames `1160-23696`, `1122-17812`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2, R4) — **Dado** o detalhe da Copa do Mundo 2026 com cartas de várias raridades na coleção, **quando** o
  cliente escolhe uma raridade em "Todas as Raridades" e digita parte de um nome em "Buscar carta pelo nome ou número",
  **então** só as cartas com aquela raridade e aquele nome aparecem.
- **CA2** (R2, R4) — **Dado** o Início com cartas de vários álbuns, **quando** o cliente digita "charizard" em "Buscar carta
  na coleção", **então** só as cartas da coleção com "charizard" no nome aparecem.
- **CA3** (R5) — **Dado** elementos que nenhuma carta da coleção atende, **quando** o cliente pesquisa, **então** vê
  "Nenhum card encontrado com estes elementos" e a opção de limpar os filtros; **quando** limpa, **então** todas as cartas
  voltam.
- **CA4** (R3) — **Dado** uma raridade inexistente na chamada, **quando** a rota é chamada, **então** a API responde `422`.
- **CA5** (R1) — **Dado** um visitante sem login, **quando** chama a rota de pesquisa da coleção, **então** recebe `401`.
- **CA6** (R6) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1160-23696`, **então** não há diferença de layout, medida, espaçamento, cor,
  fonte, texto, ícone ou imagem na barra de busca e filtros; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra,
  corte nem rolagem horizontal.
- **CA7** (R6) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1122-17812`, **então** não há diferença de layout, medida, espaçamento, cor,
  fonte, texto, ícone ou imagem no campo "Buscar carta na coleção"; e em 375, 768 e 1024 px o mesmo design se adapta sem
  quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `collection_cards` | `collection_id`, `card_id`, `status`, `deleted_at` | cartas da coleção do cliente |
| `cards` | `name`, `number`, `rarity_id`, `language_id`, `variants`, `deleted_at` | "atributos" não têm coluna no DBML (L2) |
| `rarities` | `id`, `name`, `sort_order` | opções de "Todas as Raridades" |
| `languages` | `id`, `name` | opções de "Todos os idiomas" |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Álbuns - detalhe do álbum — busca e filtros | [1160-23696](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-23696) | R2, R4 | ⚠️ Tem nome ou número, "Nº (#01 a #54)", idioma e raridade; sem atributos (L2) |
| Cliente - Início (minha coleção) — busca | [1122-17812](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1122-17812) | R2, R4 | ⚠️ Só nome; sem raridade nem atributos (L1) |

- **Diferenças com o Figma** (decisão em Lacunas e decisões): o FP 1 cita "atributos", que nenhuma tela tem (L2); o Figma
  acrescenta número e idioma, que o FP 1 não cita (L1).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): "Nº (#01 a #54)" e "Todos os idiomas" (L1).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R5 a mensagem sem resultado e a ação de limpar os
  filtros (L4).

## Fora do escopo

- Botões de status ("Todas", "Possuo", "Faltantes", "Repetidas") e a grade do álbum — CCD013 e CCD014–CCD016.
- "Ordenar por" e "Ordenar" — CCD033 no board (`CCD033 - Ordenar Coleção`).
- Filtro por categoria, seleção e time — CCD034.
- Busca por nome, número, coleção, categoria, raridade e idioma no catálogo e no marketplace — CCD024–CCD029.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Quais elementos entram? O FP 1 cita nome, raridade e atributos; o detalhe do álbum tem nome ou número, faixa de número e idioma; o Início só tem nome. Valem os do Figma, os do caso de uso ou os dois? Em qual das telas? | pendente | — |
| L2 | O que são "atributos" (ex.: "Goleiro (GK)", "Refractor")? O DBML não tem coluna para eles; `cards.variants` (CCD105) serve, ou tirar do caso de uso? | pendente | — |
| L3 | A pesquisa entra também nas cartas `MISSING` da coleção, ou só nas `OWNED`/`DUPLICATE`? | pendente | — |
| L4 | O Figma não desenha o estado sem resultado (FA 1) nem o botão de limpar os filtros: pedir o desenho ou seguir o estilo da tela? | pendente | — |
| L5 | A CCD037 se sobrepõe à CCD024–CCD029 (busca por nome, raridade e idioma) e à CCD034: juntar as buscas da coleção numa spec só (decisão do usuário)? | pendente | — |
| L6 | "Cliente" são os papéis `CUSTOMER` e `SELLER`? E o `ADMIN`? (proposta: `CUSTOMER` e `SELLER`; `ADMIN` recebe `403`, como na CCD103, L8) | pendente | — |
