# CCD013 — Visualizar Cartas

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #119 `CCD013 -Visualizar Cartas`
- **Caso de uso:** [13-visualizar-cartas.md](../../docs/Casos-De-Uso/13-visualizar-cartas.md)
- **Atores:** Cliente · **Pré-condições:** autenticado e acessando os detalhes de um álbum
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso visualizar as cartas de um álbum para acompanhar os itens que fazem parte da coleção.

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
| R1 | Ver as cartas do álbum exige login: sem token, a API responde `401`. O status de cada carta é o da coleção do próprio cliente (álbum fora da coleção: L2) | Permissão | `13`, Pré-condições; ADR-005, item 4; ADR-011 (papel `ADMIN`: L1) |
| R2 | O cliente seleciona um álbum e abre o detalhe dele | Ação | `13`, FP 1 |
| R3 | O detalhe busca as cartas do álbum selecionado: `cards` com o `album_id` do álbum, sem `deleted_at` e com `status = ACTIVE` (rascunhos, `DRAFT`, ficam fora) | Regra | `13`, FP 2; DBML `cards.status` |
| R4 | As cartas aparecem em formato de lista ou de grade (desenho da lista: L5) | Tela | `13`, FP 3 |
| R5 | Cada carta mostra o seu status na coleção do cliente: Possuo, Faltante ou Repetida (`collection_cards.status`) (rótulos: L3; carta sem marcação: L4) | Tela | `13`, FP 3; DBML `collection_card_status` |
| R6 | Álbum sem cartas mapeadas mostra a mensagem "Nenhuma carta cadastrada para este álbum ainda" | Estado | `13`, FA 1 |
| R7 | Enquanto as cartas carregam, a tela mostra o estado de carregando; se a API falha, mostra o estado de erro com a mensagem da API | Estado | ADR-041, Erros e Consequências (`LoadingState`, `ErrorState`) |
| R8 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas: `1160-23696`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2, R3, R4, R5) — **Dado** o álbum "Copa do Mundo 2026" na coleção do cliente, com 54 cartas publicadas, **quando** ele seleciona "Abrir álbum", **então** vê as cartas do álbum em grade, cada uma com o seu status na coleção dele.
- **CA2** (R3) — **Dado** um álbum com uma carta em rascunho (`DRAFT`) e uma carta excluída, **quando** o cliente abre o álbum, **então** nenhuma das duas aparece.
- **CA3** (R4) — **Dado** as cartas em grade, **quando** o cliente seleciona o ícone de lista, **então** as mesmas cartas aparecem em lista, com o status de cada uma.
- **CA4** (R5) — **Dado** uma carta marcada como repetida pelo cliente e não marcada por outro cliente, **quando** cada um abre o álbum, **então** o primeiro vê a carta como repetida e o segundo não.
- **CA5** (R6) — **Dado** um álbum sem cartas, **quando** o cliente o abre, **então** vê "Nenhuma carta cadastrada para este álbum ainda".
- **CA6** (R1) — **Dado** um visitante sem login, **quando** chama a API das cartas do álbum com status da coleção, **então** recebe `401`.
- **CA7** (R7) — **Dado** a API fora do ar, **quando** o cliente abre o álbum, **então** vê o estado de erro com a mensagem da API, e enquanto a resposta não chega vê o estado de carregando.
- **CA8** (R8) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-23696`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `user_albums` | `collection_id`, `album_id`, `deleted_at` | o álbum está na coleção (L2) |
| `albums` | `title`, `publisher`, `cover_url`, `total_cards`, `category_id`, `deleted_at` | cabeçalho, se entrar (L9) |
| `cards` | `album_id`, `number`, `name`, `description`, `variants`, `front_image_url`, `status` (`card_status`: `ACTIVE`), `deleted_at` | único por (`album_id`, `number`); `status` default `ACTIVE` |
| `collection_cards` | `collection_id`, `card_id`, `status` (`OWNED`, `MISSING`, `DUPLICATE`), `quantity`, `deleted_at` | único por (`collection_id`, `card_id`) |
| `price_history` | `card_id`, `price`, `reference_date` | só se o preço médio entrar (L7) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Álbuns - detalhe do álbum | [1160-23696](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-23696) | R2–R5, R8 | ❌ Não bate: selos de status com outros nomes (L3) e campos e controles só no Figma (L7–L10) |

- **Diferenças com o Figma** (decisão em Lacunas e decisões):
  - Detalhe do álbum — os selos de status são "NO ÁLBUM", "<n> REPETIDAS" e "FALTANDO"; o caso de uso chama os status de Possuo, Faltante e Repetida, e o Início (`1122-17812`) usa "Possuo", "Repetida (x2)" e "Faltante" (L3).
  - Detalhe do álbum — só a grade está desenhada; o ícone de lista existe, mas a lista não tem frame (L5).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões):
  - Detalhe do álbum — no cartão: número ("#01"), selo de variante ("BASE FOIL", "HOLO PRIZM", "REFRACTOR SILVERY", "PRIZM OURO 1/10"), "Preço médio:" com o valor e o subtítulo ("Bélgica • Goleiro (GK)") (L7).
  - Detalhe do álbum — abas "Todas", "Possuo", "Faltantes" e "Repetidas" com contagem, "Ordenar por: Número (#01 a #54)" e "Exibindo <n> de <total> itens" (L8).
  - Detalhe do álbum — cabeçalho: caminho "Início / Álbuns / <álbum>", seletor "COLEÇÃO:", selos "PANINI PRIZM 2026", "LICENCIADO FIFA" e "OFICIAL", e "Panini • Futebol • 54 cartas catalogadas" (L9).
  - Detalhe do álbum — bloco "Dica: marque cada carta do álbum" com "Comprar Faltantes" (L10).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela):
  - R4 exibição em lista (L5).
  - R6 álbum sem cartas (L6).
  - R7 estados de carregando e de erro.

## Fora do escopo

- Marcar Possuo, Falta ou Repetida — CCD014, CCD015 e CCD016 (spec CCD014).
- "Qtd:" com "−" e "+" — CCD017 e CCD018; ícone de lixeira do cartão — CCD018 (L2 da CCD018).
- Barra "Progresso do Álbum" e os indicadores "NO ÁLBUM", "FALTANTES", "REPETIDAS" e "VALOR ESTIMADO" — CCD019 e EA-007-01.
- "Compartilhar progresso" — CCD020; "+ Adicionar carta" — CCD022; menu "⋯" ("Resetar progresso", "Remover da minha coleção") — CCD035 e CCD011.
- "Ver Detalhes" — CCD030 e CCD031.
- "Buscar carta pelo nome ou número" e "Nº (#01 a #54)" — CCD024 e CCD025; "Todos os idiomas" — CCD029; "Todas as Raridades" — CCD028.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O `ADMIN` acessa o detalhe do álbum do Painel Cliente? (proposta: não, como na CCD007, L1) | pendente | — |
| L2 | O detalhe vale só para álbum da coleção do cliente ou para qualquer álbum do catálogo? (proposta: só da coleção; álbum fora dela responde `404` e o catálogo usa a página pública do álbum, EA-002-01) | pendente | — |
| L3 | Rótulos dos status: o caso de uso diz Possuo, Faltante e Repetida; o detalhe mostra "NO ÁLBUM", "<n> REPETIDAS" e "FALTANDO"; o Início mostra "Possuo", "Repetida (x2)" e "Faltante". Qual vale? (proposta: os do Figma em cada tela) | pendente | — |
| L4 | Carta do álbum que o cliente nunca marcou (sem linha em `collection_cards`): aparece como faltante? (proposta: sim, "FALTANDO" com "Qtd: 0", sem gravar nada até o cliente marcar) | pendente | — |
| L5 | Falta o desenho da exibição em lista (o caso de uso pede lista ou grade; o Figma tem os dois ícones e só desenha a grade). (proposta: o Gabriel desenha a lista; a grade é o padrão) | pendente | — |
| L6 | Falta o desenho do álbum sem cartas. (proposta: o estado vazio no lugar da grade, no estilo de "Álbuns - sem álbuns", com o texto do FA 1) | pendente | — |
| L7 | Os campos do cartão do Figma não estão no caso de uso. Fazem sentido? De onde vêm? (proposta: sim; número = `cards.number`, variante = primeira de `cards.variants`, subtítulo = `cards.description`, preço médio = média de `price_history` nos últimos 30 dias, como no EA-061-05) | pendente | — |
| L8 | Abas por status com contagem, ordenação e "Exibindo <n> de <total> itens" só existem no Figma. Fazem sentido? Há paginação? (proposta: sim; abas filtram pelo status; ordem por número; 24 cartas por página com "Carregar mais") | pendente | — |
| L9 | O cabeçalho do Figma (seletor "COLEÇÃO:" para trocar de álbum, selos e "Panini • Futebol • 54 cartas catalogadas") não está no caso de uso, e o DBML não tem coluna para os selos. O que entra? (proposta: capa, título, editora, categoria e total de cartas; o seletor lista os álbuns da coleção; os selos saem do Figma) | pendente | — |
| L10 | O bloco "Dica: marque cada carta do álbum" com "Comprar Faltantes" só existe no Figma. Faz sentido? O que "Comprar Faltantes" abre? (proposta: sim; abre o marketplace filtrado pelas cartas faltantes do álbum, CCD078) | pendente | — |
