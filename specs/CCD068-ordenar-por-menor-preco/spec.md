# CCD068 — Ordenar por Menor Preço

- **Status:** Rascunho
- **Fase:** MVP (a CCD070, ordenar por avaliações, foi removida do projeto em 22/11/2026 (ADR-068))
- **User story:** #1343 `CCD068 - Ordenar por Menor Preço` (criada em 22/11/2026)
- **Agrupa:** CCD069 Ordenar por Maior Preço (não encontrada no board), CCD071 Ordenar por Mais Recentes (não encontrada no board)
- **Caso de uso:** [68-ordenar-por-menor-preco.md](../../docs/Casos-De-Uso/68-ordenar-por-menor-preco.md), [69-ordenar-por-maior-preco.md](../../docs/Casos-De-Uso/69-ordenar-por-maior-preco.md), [71-ordenar-por-mais-recentes.md](../../docs/Casos-De-Uso/71-ordenar-por-mais-recentes.md)
- **Atores:** Visitante e Cliente · **Pré-condições:** no Explorar marketplace ou na lista de anúncios do perfil da carta
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso ordenar as cartas pelo menor preço para encontrar as opções mais econômicas.
> Como Cliente preciso ordenar as cartas pelo maior preço para comparar os itens de maior valor.
> Como Cliente preciso ordenar as cartas pelas mais recentes para visualizar os novos anúncios publicados.

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

> R9–R11 vinham da CCD070, removida do projeto em 22/11/2026 (ADR-068). A ordenação tem mais recentes, menor preço e maior preço (`78`, FP 3).

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Seletor "Ordenar:" no Explorar marketplace e na lista "Anúncios disponíveis" do perfil da carta, com as opções menor preço, maior preço e mais recentes (texto das opções: L1) | Campo | `68`, `69`, `71`, FP 1–2; `78`, FP 3 |
| R2 | A ordenação é aberta ao visitante e ao cliente, sem login | Permissão | `68`, `69`, `71`, Atores |
| R3 | Menor preço organiza os anúncios em ordem crescente de `listings.price` | Regra | `68`, FP 3 |
| R4 | Maior preço organiza os anúncios em ordem decrescente de `listings.price` | Regra | `69`, FP 3 |
| R5 | Mais recentes organiza os anúncios pela data de publicação, do mais recente para o mais antigo | Regra | `71`, FP 3 (L3) |
| R6 | Ao trocar a ordenação, a listagem atualiza com os anúncios ordenados, mantendo os filtros aplicados; a ordem vale para toda a listagem, inclusive o que vem em "Carregar mais cartas" | Regra | `68`, `69`, `71`, FP 3–4; `78`, FP 2 e FP 5 |
| R7 | Ordenação padrão: "Mais recentes" no Explorar e "Menor preço" no perfil da carta | Regra | `78`, FP 3; `30`, FP 2 |
| R8 | Sem anúncios disponíveis, a listagem mostra "Nenhum anúncio encontrado" | Estado | `68`, `69`, `71`, FA 1 |
| ~~R9~~ | ~~CCD070~~ removido: a CCD070 foi removida do projeto em 22/11/2026 (ADR-068) | — | — |
| ~~R10~~ | ~~CCD070~~ removido: a CCD070 foi removida do projeto em 22/11/2026 (ADR-068) | — | — |
| ~~R11~~ | ~~CCD070~~ removido: a CCD070 foi removida do projeto em 22/11/2026 (ADR-068) | — | — |
| R12 | A API recebe a ordenação em `sort` (`price` crescente, `-price` decrescente, `-createdAt` mais recentes), com a lista de campos permitidos do endpoint | Regra | ADR-011, "Paginação, filtros e ordenação" |
| R13 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R1, R3, R6) — **Dado** anúncios de R$ 380, R$ 120 e R$ 1.750 no Explorar, **quando** o visitante escolhe menor
  preço, **então** a lista mostra R$ 120, R$ 380 e R$ 1.750, nessa ordem.
- **CA2** (R4) — **Dado** os mesmos anúncios, **quando** o visitante escolhe maior preço, **então** a lista mostra R$ 1.750,
  R$ 380 e R$ 120.
- **CA3** (R5) — **Dado** três anúncios publicados em dias diferentes, **quando** o visitante escolhe mais recentes, **então**
  o publicado por último aparece primeiro.
- **CA4** (R6) — **Dado** o filtro de categoria Pokémon aplicado e mais de 8 anúncios, **quando** o visitante escolhe menor
  preço e seleciona "Carregar mais cartas", **então** os novos anúncios continuam em ordem crescente depois dos primeiros 8 e
  o filtro Pokémon continua aplicado.
- **CA5** (R7) — **Dado** um visitante, **quando** abre o Explorar, **então** o seletor mostra "Mais recentes"; **quando**
  abre o perfil de uma carta, **então** a lista "Anúncios disponíveis" mostra "Menor preço".
- **CA6** (R8) — **Dado** nenhum anúncio que combine com os filtros, **quando** o visitante muda a ordenação, **então** a
  listagem continua com "Nenhum anúncio encontrado".
- **CA7** (R2, R12) — **Dado** uma requisição sem token com `sort=-price`, **quando** chama a listagem de anúncios, **então** a
  API responde `200` com os anúncios do maior para o menor preço; com um `sort` fora da lista, responde `400`.
- ~~**CA8**~~ removido: a CCD070 foi removida do projeto em 22/11/2026 (ADR-068).
- **CA9** (R13 de Fidelidade) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o
  print dela é comparado lado a lado com o print do frame `1112-3281`, **então** não há diferença de layout, medida,
  espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem
  rolagem horizontal.
- **CA10** (R13 de Fidelidade) — Idem ao CA9, com o estado sem resultados e o frame `1112-3674`.
- **CA11** (R13 de Fidelidade) — Idem ao CA9, com a lista "Anúncios disponíveis" do perfil da carta e o frame `1112-4615`.

- **CA12** (R13) — **Dado** cada tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame correspondente (`1112-3674`, `1112-4615`), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `listings` | `price`, `created_at`, `status` (`listing_status.ACTIVE`), `seller_id`, `deleted_at` | `price` decimal(10,2), obrigatório |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Público - Explorar marketplace ("Ordenar: Mais recentes") | [1112-3281](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-3281) | R1, R6, R7 | ✅ Bate (seletor fechado) |
| Público - Explorar marketplace - sem resultados | [1112-3674](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-3674) | R8 | ✅ Bate |
| Público - Perfil da carta ("Anúncios disponíveis (4)", "Ordenar: Menor preço") | [1112-4615](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-4615) | R1, R7 | ✅ Bate (seletor fechado) |

- O cliente logado usa as mesmas telas, com o menu da Área do Cliente (frame de referência `1122-18861`).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R1 o seletor aberto com as opções (L1).

## Fora do escopo

- Explorar marketplace, filtros e "Carregar mais cartas" — CCD078.
- Perfil da carta e o vazio da lista de anúncios dele ("a lista informa que não há anúncios") — CCD030, FA 3.
- Ordenar por avaliações e mostrar a nota do vendedor — as avaliações saíram do projeto em 22/11/2026 (CCD070, CCD081, ADR-068).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O Figma mostra o seletor fechado com "Ordenar: Mais recentes" e "Ordenar: Menor preço"; os casos de uso chamam as opções de “Ordenar por menor preço”, “Ordenar por maior preço” e “Ordenar por mais recentes”. Qual o texto das opções na lista aberta, que não está desenhada? (proposta: "Mais recentes", "Menor preço" e "Maior preço", como o rótulo do Figma) | pendente | — |
| L2 | Como desempatar anúncios com o mesmo preço? (proposta: o mais recente primeiro) | pendente | — |
| L3 | "Data de publicação" é `listings.created_at`? Um anúncio pausado e reativado (CCD088) volta ao topo? (proposta: `created_at`; reativar não muda a ordem) | pendente | — |
| L4 | As quatro user stories não têm user story no board (CCD067–CCD083). Criar no board antes do `/planejar`? | pendente | — |
| L5 | (CCD070) Qual a "avaliação do vendedor": a média de `reviews.rating`? Onde ficam os vendedores sem avaliação? (proposta: média decrescente; sem avaliação no fim) | Não se aplica: a CCD070 foi removida do projeto em 22/11/2026 (ADR-068) | ADR-068 |
| L6 | (CCD070) Qual o texto do aviso de vendedores sem avaliação e quantas avaliações são "suficientes"? Não há frame. | Não se aplica: a CCD070 foi removida do projeto em 22/11/2026 (ADR-068) | ADR-068 |
| L7 | (CCD070) Os outros três casos de uso aceitam o visitante; o `70` só o cliente. O visitante não vê a opção de avaliações? | Não se aplica: a CCD070 foi removida do projeto em 22/11/2026 (ADR-068) | ADR-068 |
| L8 | O Figma não mostra ordenação na página Pesquisar nem no perfil público do vendedor. A ordenação fica só no Explorar e no perfil da carta, como dizem as pré-condições? (proposta: sim) | pendente | — |
