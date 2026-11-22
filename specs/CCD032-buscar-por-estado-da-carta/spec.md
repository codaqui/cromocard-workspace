# CCD032 — Buscar por Estado da Carta

- **Status:** Rascunho
- **Fase:** MVP (era Futuro; puxada para o MVP em 22/11/2026 com as telas já no Figma, ADR-068)
- **User story:** #165 `CCD032 - Interagir com o Álbum` ⚠️ o título do board não é o deste caso de uso (L1)
- **Caso de uso:** [32-buscar-por-estado-da-carta.md](../../docs/Casos-De-Uso/32-buscar-por-estado-da-carta.md)
- **Atores:** Cliente · **Pré-condições:** autenticado e na tela de pesquisa de cartas
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso filtrar cartas por estado de conservação para encontrar itens de acordo com a condição desejada.

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
| R1 | O filtro exige login: sem token, a API responde `401` | Permissão | `32`, Pré-condições (L4) |
| R2 | Filtro de estado de conservação na tela de pesquisa, com as condições cadastradas (Mint, Near Mint, Ótimo, Bom, Regular) | Campo | `32`, FP 1; DBML `card_conditions` (L3) |
| R3 | O sistema filtra as cartas do estado escolhido e exibe a lista encontrada | Regra | `32`, FP 2–3 (L3) |
| R4 | Selecionar um item da lista abre o item escolhido | Ação | `32`, FP 4 (L3) |
| R5 | Sem resultado, a tela mostra "Nenhuma carta encontrada com os termos informados" | Mensagem | `32`, FA 1 (L5) |
| R6 | As opções seguem a ordem de `card_conditions.sort_order` | Regra | DBML `card_conditions.sort_order` |
| R7 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2, R3) — **Dado** anúncios em Near Mint e em Bom, **quando** o cliente escolhe "Near Mint" no filtro, **então** a
  lista mostra só os itens em Near Mint.
- **CA2** (R4) — **Dado** a lista filtrada, **quando** o cliente seleciona um item, **então** abre o item escolhido (destino da
  L3).
- **CA3** (R5) — **Dado** nenhum item em "Regular", **quando** o cliente escolhe "Regular", **então** a tela mostra "Nenhuma
  carta encontrada com os termos informados".
- **CA4** (R1) — **Dado** uma requisição sem token, **quando** chama o filtro, **então** a API responde `401` (conforme a L4).
- **CA5** (R6) — **Dado** o filtro aberto, **quando** o cliente vê as opções, **então** elas aparecem na ordem Mint, Near Mint,
  Ótimo, Bom e Regular.
- **CA6** (R7 de Fidelidade) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o
  print dela é comparado lado a lado com o print do frame `1112-3281`, **então** não há diferença de layout, medida,
  espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem
  rolagem horizontal.
- **CA7** (R7 de Fidelidade) — Idem ao CA6, com o filtro "Condição" aplicado, sem resultados, e o frame `1112-3674`.

- **CA8** (R7) — **Dado** cada tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame correspondente (`1112-3674`), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `card_conditions` | `id`, `name`, `sort_order`, `deleted_at` | `name` único; ex.: Mint, Near Mint, Ótimo, Bom, Regular |
| `listings` | `condition_id`, `status` (`ACTIVE`), `deleted_at` | a condição só existe no anúncio (L3) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Público - Explorar marketplace (filtro "Condição: Todas") | [1112-3281](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-3281) | R2, R3 | ⚠️ Difere: está no Explorar, aberto ao visitante, e filtra anúncios (L2–L4) |
| Público - Explorar marketplace - sem resultados ("Near Mint ✕") | [1112-3674](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-3674) | R5 | ⚠️ Difere: "Nenhum anúncio encontrado" (L5) |

- O único filtro de estado de conservação do Figma é o "Condição" do Explorar marketplace, que a CCD078 (FP 3) já pede no MVP.
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R2 a lista aberta do filtro "Condição".

## Fora do escopo

- Explorar marketplace, demais filtros e ordenação — CCD078 e CCD068.
- Mostrar a condição no detalhe do anúncio — CCD079 e a "Visualizar Estado da Carta" (futuro).
- Busca por nome, número, coleção, categoria, raridade e idioma — CCD024.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | No board, a user story #165 se chama "CCD032 - Interagir com o Álbum", e o arquivo 32 é "Buscar por Estado da Carta" (divergência conhecida entre o board e a planilha `CromoCard 1.xlsx`). Qual vale? (proposta: o arquivo; corrigir o título no board) | pendente | — |
| L2 | A CCD078 (MVP, FP 3) já filtra por condição no Explorar marketplace (Mint, Near Mint, Ótimo, Bom e Regular). A CCD032 fica coberta por ela, deve ser cancelada ou continua Futuro para outra tela? (proposta: coberta pela CCD078; cancelar a CCD032) | pendente | — |
| L3 | O estado de conservação só existe no anúncio (`listings.condition_id`); a carta do catálogo não tem condição. O filtro é sobre anúncios, e o item selecionado abre o detalhe do anúncio? (proposta: sim) | pendente | — |
| L4 | O caso de uso exige login, mas o filtro "Condição" do Figma está no Explorar, aberto ao visitante (CCD078). Qual vale? (proposta: aberto, como o Explorar) | pendente | — |
| L5 | A mensagem do caso de uso é "Nenhuma carta encontrada com os termos informados"; o vazio do Explorar diz "Nenhum anúncio encontrado" (CCD078, FA 1). Qual vale? | pendente | — |
