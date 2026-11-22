# CCD021 — Pesquisar Carta

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #127 `CCD021 -Pesquisar Carta`
- **Caso de uso:** [21-pesquisar-carta.md](../../docs/Casos-De-Uso/21-pesquisar-carta.md)
- **Atores:** Cliente · **Pré-condições:** cliente autenticado
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso pesquisar uma carta para localizar o item que desejo adicionar à minha coleção.

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
| R1 | Pesquisar exige login: sem token, `401` | Permissão | `21`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | O modal "Adicionar carta" tem o campo de busca com a orientação "Procure a carta no catálogo pelo nome ou pelo número." | Campo | `21`, FP 1; Figma `1160-28449` (L1, L2) |
| R3 | A busca procura o termo no nome e no número das cartas do catálogo | Regra | `21`, FP 1–2 (L2) |
| R4 | Só entram cartas publicadas e não excluídas: `cards.status` = `ACTIVE` e `deleted_at` nulo; rascunho (`DRAFT`) fica de fora | Regra | `21`, FP 2 ("base de cartas disponíveis"); DBML `cards.status` ("DRAFT = rascunho fora do catálogo"); ADR-015, item 5 |
| R5 | Cada resultado mostra a imagem da carta, o nome e a linha "<álbum> • Nº <número> • <…>" | Tela | `21`, FP 3; `36`, FP 3; Figma `1160-28449` (L4) |
| R6 | O cliente seleciona a carta nos resultados, o que leva à ação de adicionar (CCD022 e CCD036) | Ação | `21`, FP 4; Figma `1160-28449` ("Adicionar") |
| R7 | Sem nenhum resultado, a tela mostra "Nenhuma carta encontrada com os termos informados" | Mensagem | `21`, FA 1 |
| R8 | "Fechar" e "✕" fecham o modal | Ação | Figma `1160-28449` |
| R9 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frame `1160-28449`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2, R3, R5) — **Dado** o catálogo com três cartas chamadas "Kylian Mbappé", **quando** o cliente digita
  "mbappé" no campo de busca do modal, **então** vê as três, cada uma com imagem, nome e a linha "<álbum> • Nº <número> •
  <…>".
- **CA2** (R3) — **Dado** a carta Nº 09 da Copa do Mundo 2026, **quando** o cliente busca "09", **então** a carta aparece
  nos resultados.
- **CA3** (R4) — **Dado** uma carta em rascunho (`DRAFT`) e uma carta excluída com o termo no nome, **quando** o cliente
  busca o termo, **então** nenhuma das duas aparece.
- **CA4** (R7) — **Dado** um termo que não corresponde a nenhuma carta, **quando** o cliente busca, **então** vê
  "Nenhuma carta encontrada com os termos informados".
- **CA5** (R6) — **Dado** os resultados na tela, **quando** o cliente seleciona "Adicionar" numa carta, **então** segue o
  fluxo da CCD022 para essa carta.
- **CA6** (R8) — **Dado** o modal aberto, **quando** o cliente seleciona "Fechar" ou "✕", **então** o modal fecha.
- **CA7** (R1) — **Dado** um visitante sem login, **quando** chama a rota de busca de cartas do cliente, **então** recebe
  `401`.
- **CA8** (R9) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1160-28449`, **então** não há diferença de layout, medida, espaçamento, cor,
  fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem
  horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `cards` | `name`, `number`, `album_id`, `rarity_id`, `variants`, `front_image_url`, `status` (`card_status`: `DRAFT`, `ACTIVE`), `deleted_at` | só `ACTIVE` e não excluídas (R4) |
| `albums` | `title`, `deleted_at` | nome do álbum na linha do resultado |
| `rarities` | `name` | se a L4 decidir pela raridade |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Álbuns - adicionar carta | [1160-28449](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-28449) | R2–R6, R8 | ❌ Não bate: busca só por nome e número, sem "característica" (L2) |

- A busca do menu "Pesquisar" (`1122-18396`, que aponta para "2. Público › Busca", `1112-3970` e sem resultados `1112-4356`)
  é a Buscar Global, da CCD002 (L1).
- **Diferenças com o Figma** (decisão em Lacunas e decisões): modal — o FP 1 aceita "nome, número ou característica"; a
  orientação do Figma diz "pelo nome ou pelo número" (L2).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): nenhum elemento além dos que pertencem à
  CCD022, CCD023 e CCD036 (selo "JÁ ESTÁ NA COLEÇÃO", "Adicionar" e "Solicitar cadastro da carta →").
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R7 a mensagem "Nenhuma carta encontrada com os
  termos informados" (L6).

## Fora do escopo

- Adicionar a carta e o selo "JÁ ESTÁ NA COLEÇÃO" — CCD022 e CCD036.
- "Não encontrou a carta? Solicitar cadastro da carta →" — CCD023.
- Busca global de cartas, usuários, grupos e álbuns (menu "Pesquisar") — CCD002.
- Filtros por coleção, categoria, raridade e idioma no marketplace — CCD024–CCD029.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Em que tela o cliente pesquisa para adicionar? O Figma tem o modal "Adicionar carta" (`1160-28449`, no detalhe do álbum) e a busca do menu "Pesquisar" (`1122-18396`, a mesma da CCD002). (proposta: o modal, que leva direto a "Adicionar") | pendente | — |
| L2 | O FP 1 aceita "característica" da carta; o Figma só fala em nome e número. Quais características (raridade, idioma, álbum) ou tirar do caso de uso? | pendente | — |
| L3 | A busca do modal procura só no álbum aberto ou no catálogo inteiro? O Figma, dentro da Copa do Mundo 2026, mostra "Copa do Mundo 2022 • Nº 21". (proposta: catálogo inteiro, com as cartas do álbum aberto primeiro) | pendente | — |
| L4 | O terceiro item da linha ("Refractor", "Paralela") é a raridade (`rarities.name`) ou as variantes (`cards.variants`, CCD105)? | pendente | — |
| L5 | A partir de quantos caracteres a busca roda, quantos resultados mostra, em que ordem, e se ignora acento e maiúsculas ("mbappé" = "mbappe")? (proposta: a partir de 2 caracteres, até 20 resultados, por nome, ignorando acento e maiúsculas) | pendente | — |
| L6 | O Figma não desenha o estado sem resultados (FA 1) nem o carregando. Pedir o desenho ou seguir o estilo do modal? | pendente | — |
| L7 | "Cliente" são os papéis `CUSTOMER` e `SELLER`? E o `ADMIN`? (proposta: `CUSTOMER` e `SELLER`; `ADMIN` recebe `403`, como na CCD103, L8) | pendente | — |
