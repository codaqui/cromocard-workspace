# CCD042 — Pesquisar no Histórico do Grupo

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #145 `CCD042 - Pesquisar no Histórico do Grupo`
- **Caso de uso:** [42-pesquisar-no-historico-do-grupo.md](../../docs/Casos-De-Uso/42-pesquisar-no-historico-do-grupo.md)
- **Atores:** Cliente · **Pré-condições:** usuário autenticado e membro do grupo onde deseja pesquisar
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso uma barra de busca dentro do grupo para localizar mensagens, links ou cartas enviadas em dias anteriores.

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
| R1 | Pesquisar exige login e ser membro do grupo: sem token, `401`; quem não é membro, `403` | Permissão | `42`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | A tela do grupo tem a opção "Pesquisar", que abre a busca no grupo | Ação | `42`, FP 1 |
| R3 | Campo para digitar o termo de busca | Campo | `42`, FP 2 (L6) |
| R4 | A busca procura no histórico do grupo: no texto das mensagens, no nome das cartas compartilhadas e nos anúncios compartilhados | Regra | `42`, FP 3; DBML `group_messages.content`, `card_id` → `cards.name`, `listing_id` (L1) |
| R5 | A busca só considera mensagens não excluídas, inclusive as removidas pela moderação | Regra | ADR-015, itens 5 e 6; `62`, FP 13 |
| R6 | Cada resultado mostra o trecho com o termo destacado, a data e o autor da mensagem | Tela | `42`, FP 4 |
| R7 | Selecionar um resultado rola a conversa até a mensagem, no contexto, e a destaca | Ação | `42`, FP 5–6 (L7) |
| R8 | Sem resultado, a tela informa que nenhum conteúdo correspondente foi encontrado no histórico do grupo | Estado | `42`, FA 1 |
| R9 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (`675-14484`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

Tipos: Tela · Campo · Ação · Regra · Permissão · Mensagem · Estado · Fidelidade.

## Critérios de aceite

- **CA1** (R2–R4, R6) — **Dado** um membro e mensagens do grupo com "Charizard" no texto, **quando** ele seleciona
  "Pesquisar" e digita "charizard", **então** o painel "Buscar no grupo" lista essas mensagens com "Charizard" destacado,
  o autor e a data de cada uma.
- **CA2** (R4) — **Dado** uma mensagem do tipo `CARD` com a carta "Charizard VMAX" e sem a palavra no texto, **quando** o
  membro busca "charizard", **então** essa mensagem aparece nos resultados.
- **CA3** (R7) — **Dado** a lista de resultados, **quando** o membro seleciona uma mensagem de dias anteriores, **então** o
  chat rola até ela, carregando as mensagens ao redor, e ela fica destacada.
- **CA4** (R8) — **Dado** nenhum conteúdo com "zzzz", **quando** o membro busca, **então** a tela informa que nenhum
  conteúdo correspondente foi encontrado no histórico do grupo.
- **CA5** (R5) — **Dado** uma mensagem com "charizard" removida pela moderação, **quando** o membro busca "charizard",
  **então** ela não aparece.
- **CA6** (R1) — **Dado** um visitante sem login, **quando** chama a busca, **então** a API responde `401`; **dado** um
  usuário logado que não é membro do grupo, **então** a API responde `403`.
- **CA7** (R9) — **Dado** a tela do grupo com a busca aberta em 1280 px e os mesmos dados do frame, **quando** o print
  dela é comparado lado a lado com o print do frame `675-14484`, **então** não há diferença de layout, medida,
  espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte
  nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `group_messages` | `id`, `group_id`, `author_id`, `content`, `content_type` (`message_content_type`: `TEXT`, `CARD`, `LISTING`), `card_id`, `listing_id`, `pinned`, `created_at`, `deleted_at` | `content` opcional; soft delete (ADR-015) |
| `cards` | `name`, `deleted_at` | nome da carta compartilhada |
| `listings` | `card_id`, `description` | o anúncio não tem título no DBML: busca-se pelo nome da carta e pela descrição (L1) |
| `users` | `name`, `username` | autor do resultado |
| `group_members` | `group_id`, `user_id`, `deleted_at` | confere se quem busca é membro |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Comunidade - pesquisar no grupo | [675-14484](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-14484) | R2, R3, R4, R6, R7 | ❌ Não bate: abas Mensagens, Links e Fotos (L1, L2), filtros (L3), navegação entre resultados (L4), selos (L5), "✕" (L10) |

- **Diferenças com o Figma** (decisão em Lacunas e decisões):
  - Pesquisar no grupo — abas "Mensagens 12", "Links 3" e "Fotos 2": o `42` (Finalidade e FP 3) fala em mensagens, cartas,
    anúncios e mídias, e a narrativa em mensagens, links ou cartas; o frame não tem aba de cartas nem de anúncios (L1, L2).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões):
  - Pesquisar no grupo — filtros "De: todos ▾" e "Últimos 30 dias ▾" (L3).
  - Pesquisar no grupo — faixa "Resultado 1 de 12 para “charizard”" com "↑" e "↓" no topo do chat, e "12 resultados" (L4, L8).
  - Pesquisar no grupo — selos "Carta compartilhada" e "Mensagem fixada" no resultado (L5).
  - Pesquisar no grupo — "✕" no painel "Buscar no grupo" (L10).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela):
  - R8 — o estado sem resultado (L9).
  - Estados de carregando e de erro da busca (L9).

## Fora do escopo

- Enviar mensagens, fixadas e o restante da tela do grupo — CCD044 e CCD043.
- Busca global de grupos — CCD002; busca de grupos em "Comunidades" — CCD039.
- Fotos e imagens compartilhadas, se a L1 confirmar que dependem de "Compartilhar Imagens" (`**`, Futuro).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O que a busca cobre e como os resultados se dividem? O `42` diz mensagens, cartas, anúncios e mídias; a narrativa, mensagens, links ou cartas; o Figma, abas Mensagens, Links e Fotos. Fotos dependem de mensagens `IMAGE`, de "Compartilhar Imagens" (`**`, Futuro); cartas e anúncios no grupo dependem da L1 da CCD044. Qual conjunto vale no MVP? (proposta: texto, mais o nome da carta e do anúncio se a CCD044 os aceitar; abas Mensagens e Links) | pendente | — |
| L2 | O que é um "link" na aba Links: uma URL dentro do `content`? As regras do grupo no Figma proíbem links externos | pendente | — |
| L3 | Filtros por autor ("De: todos") e por período ("Últimos 30 dias") (Figma): faz sentido implementar? Quais períodos? | pendente | — |
| L4 | Navegação "Resultado 1 de 12" com "↑" e "↓" no topo do chat (Figma): faz sentido implementar? | pendente | — |
| L5 | Selos "Carta compartilhada" e "Mensagem fixada" no resultado (Figma): faz sentido implementar? Os dados existem (`card_id`, `pinned`) | pendente | — |
| L6 | Tamanho mínimo do termo e comparação sem diferenciar maiúsculas e acentos ("charizard" acha "Charizard")? (proposta: a partir de 2 caracteres, sem diferenciar maiúsculas nem acentos; se precisar da extensão `unaccent` no PostgreSQL, ADR novo) | pendente | — |
| L7 | Como rolar até uma mensagem antiga que não está carregada, com o histórico por cursor (ADR-011)? (proposta técnica: endpoint que devolve a página ao redor da mensagem; decidir no plano ou em ADR) | pendente | — |
| L8 | Os resultados são paginados? O total ("12 resultados") é mostrado? (proposta: cursor, como o histórico, com o total) | pendente | — |
| L9 | Estados sem resultado, carregando e erro não estão desenhados (proposta: os componentes padrão do app dentro do painel) | pendente | — |
| L10 | "✕" fecha o painel e tira o destaque da mensagem? (proposta: sim) | pendente | — |
