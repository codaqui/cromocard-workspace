# CCD078 — Mostrar Todas as Cartas

- **Status:** Rascunho
- **Fase:** MVP (fatia mínima do marketplace, ADR-027)
- **User story:** não encontrada no board
- **Caso de uso:** [78-mostrar-todas-as-cartas.md](../../docs/Casos-De-Uso/78-mostrar-todas-as-cartas.md)
- **Atores:** Visitante, Cliente · **Pré-condições:** nenhuma
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso visualizar todas as cartas disponíveis no marketplace para encontrar itens de meu interesse.

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
| R1 | O Explorar marketplace abre sem login, e a API da listagem responde sem token; o cliente logado vê a mesma tela com o menu da Área do Cliente | Permissão | `78`, Atores e Pré-condições; EA-001-01 |
| R2 | "Marketplace" no menu lateral e "Explorar o marketplace" na Home abrem o Explorar marketplace | Ação | `78`, FP 1; `01`, FP 2 |
| R3 | Cabeçalho com o rótulo "MARKETPLACE", o título "Explorar marketplace" e o texto "Encontre cartas anunciadas por colecionadores de todo o Brasil." | Tela | `78`, FP 2 |
| R4 | Lista dos anúncios ativos (`listings.status = ACTIVE`, sem `deleted_at`), cada um com imagem, "<categoria> • <coleção>", nome da carta, condição, "Preço", preço e @vendedor | Tela | `78`, FP 2 (L6, L7) |
| R5 | A lista mostra 8 anúncios por vez; "Carregar mais cartas" traz os próximos 8 | Ação | `78`, FP 2 |
| R6 | Total de anúncios encontrados com os filtros aplicados ("<n> anúncios") | Tela | `78`, FP 2 |
| R7 | Filtro "Categoria:" com "Todas" e as categorias padrão (`is_default`) | Campo | `78`, FP 3 (L4, L6) |
| R8 | Filtro "Condição:" com "Todas", Mint, Near Mint, Ótimo, Bom e Regular | Campo | `78`, FP 3; DBML `card_conditions` |
| R9 | Filtro "Preço:" por faixa de preço, começando em "Qualquer valor" | Campo | `78`, FP 3 (L3) |
| R10 | Ordenação "Ordenar:" por mais recentes (padrão), menor preço ou maior preço (regras na CCD068) | Campo | `78`, FP 3; `68`, `69`, `71` |
| R11 | Aplicar um filtro ou mudar a ordenação atualiza a lista e o total | Ação | `78`, FP 4–5 |
| R12 | Cada filtro aplicado aparece como uma etiqueta com "✕" (ex.: "Pokémon ✕", "R$ 100 – R$ 2.000 ✕"); o "✕" remove só aquele filtro | Ação | `78`, FP 5 |
| R13 | Selecionar um anúncio abre o detalhe do anúncio | Ação | `78`, FP 6–7 |
| R14 | Sem anúncio que combine com os filtros, a lista mostra "Nenhum anúncio encontrado", o texto "Nenhum anúncio combina com esses filtros. Tente outra categoria ou uma faixa de preço maior.", "0 anúncios" e o botão "Limpar filtros", que remove todos os filtros | Estado | `78`, FA 1 |
| R15 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2–R6) — **Dado** 20 anúncios ativos, **quando** o visitante seleciona "Marketplace" no menu, **então** abre o
  Explorar com "20 anúncios", os 8 mais recentes e "Carregar mais cartas".
- **CA2** (R5) — **Dado** o Explorar com 20 anúncios, **quando** o visitante seleciona "Carregar mais cartas" duas vezes,
  **então** a lista chega a 20 anúncios.
- **CA3** (R7, R11, R12) — **Dado** o Explorar, **quando** o visitante escolhe a categoria Pokémon, **então** a lista e o total
  mostram só anúncios de Pokémon e aparece a etiqueta "Pokémon ✕"; **quando** seleciona o "✕", **então** o filtro sai e a
  lista volta a ter todas as categorias.
- **CA4** (R8) — **Dado** anúncios em Near Mint e em Bom, **quando** o visitante escolhe a condição "Near Mint", **então** só
  aparecem anúncios em Near Mint.
- **CA5** (R9) — **Dado** anúncios de R$ 50, R$ 380 e R$ 2.500, **quando** o visitante escolhe a faixa de R$ 100 a R$ 2.000,
  **então** só aparece o de R$ 380 e a etiqueta "R$ 100 – R$ 2.000 ✕".
- **CA6** (R10) — **Dado** o Explorar aberto, **quando** o visitante olha o seletor, **então** ele mostra "Mais recentes" e a
  lista vem do anúncio mais novo para o mais antigo.
- **CA7** (R13) — **Dado** a lista, **quando** o visitante seleciona um anúncio, **então** abre o detalhe daquele anúncio.
- **CA8** (R14) — **Dado** filtros sem nenhum anúncio, **quando** a lista atualiza, **então** mostra "Nenhum anúncio
  encontrado", "0 anúncios" e "Limpar filtros"; **quando** o visitante seleciona "Limpar filtros", **então** todos os filtros
  saem e a lista volta.
- **CA9** (R1) — **Dado** uma requisição sem token, **quando** chama a listagem, **então** a API responde `200`; **dado** um
  cliente logado, **então** a tela é a mesma, com o menu da Área do Cliente e "Marketplace" destacado.
- **CA10** (R4) — **Dado** um anúncio pausado e um excluído, **quando** o Explorar abre, **então** nenhum dos dois aparece.
- **CA11** (R15 de Fidelidade) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o
  print dela é comparado lado a lado com o print do frame `1112-3281`, **então** não há diferença de layout, medida,
  espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem
  rolagem horizontal.
- **CA12** (R15 de Fidelidade) — Idem ao CA11, com os filtros aplicados sem resultados e o frame `1112-3674`.

- **CA13** (R15) — **Dado** cada tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame correspondente (`1112-3674`), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `listings` | `id`, `card_id`, `seller_id`, `condition_id`, `price`, `available_quantity`, `status` (`listing_status.ACTIVE`), `created_at`, `deleted_at` | `price` decimal(10,2), como string na API (ADR-011) |
| `listing_photos` | `listing_id`, `url`, `sort_order` | imagem (L7) |
| `cards` | `name`, `front_image_url`, `album_id`, `category_id`, `status` (`ACTIVE`) | ADR-053, item 5 |
| `albums` | `title`, `category_id` | a coleção do cartão |
| `categories` | `name`, `parent_category_id`, `is_default`, `is_pinned`, `display_order`, `deleted_at` | filtro (L4, L6) |
| `card_conditions` | `id`, `name`, `sort_order` | filtro de condição |
| `users` | `username`, `status` | vendedor (@) (L8) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Público - Explorar marketplace | [1112-3281](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-3281) | R3–R11, R13 | ⚠️ Difere: campo "Buscar por carta ou coleção" só no Figma (L1) |
| Público - Explorar marketplace - sem resultados | [1112-3674](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-3674) | R6, R12, R14 | ⚠️ Difere: "Limpar filtros" também ao lado das etiquetas (L2) |

- O frame de referência "Referência - Marketplace" (`1122-18861`) diz que o cliente logado usa o mesmo Explorar, com o menu
  do cliente (menu e topo seguem `1122-17812`).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): Explorar — campo "Buscar por carta ou coleção"
  (L1); sem resultados — link "Limpar filtros" ao lado das etiquetas, além do botão do vazio (L2).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R7–R10 as listas abertas dos filtros e da ordenação
  (L3); R12 o Explorar com filtros aplicados e com resultados.

## Fora do escopo

- Regras de cada ordenação — CCD068 (agrupa 069, 070 e 071).
- Detalhe do anúncio — CCD079, CCD080, CCD074 e CCD072.
- Busca por nome ou coleção — CCD024/CCD026 (L1); busca por vendedor — CCD067.
- Filtro "somente verificados", localização, selos "Frete grátis", "Aceita troca" etc. — saíram do Figma (`escopo-adicional.md`, seção 3).
- Gravar a ordem das categorias padrão — CCD104.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O Figma tem o campo "Buscar por carta ou coleção" no Explorar; o `78` não fala de busca. Faz sentido implementar? (proposta: sim, pelo nome da carta ou do álbum; liga com CCD024 e CCD026) | pendente | — |
| L2 | No vazio (`1112-3674`), além do botão "Limpar filtros" do `78`, FA 1, o Figma mostra um link "Limpar filtros" ao lado das etiquetas. Faz sentido implementar? Ele aparece também quando há resultados? (proposta: sim, sempre que houver filtro aplicado) | pendente | — |
| L3 | Como funciona a faixa de preço? Faixas fixas ou valor mínimo e máximo digitados? As listas abertas não estão desenhadas. (proposta: mínimo e máximo, com "Qualquer valor" quando vazios) | pendente | — |
| L4 | O filtro de categoria segue a ordem de Ordenar Categorias Padrão (fixada primeiro, depois `display_order`), como a Home (CCD001) e a pesquisa (CCD027)? A CCD104 (L12) só citou a CCD001 e a CCD027. (proposta: sim) | pendente | — |
| L5 | O caso de uso não tem user story no board (CCD067–CCD083). Criar antes do `/planejar`? | pendente | — |
| L6 | Qual categoria do anúncio aparece e conta no filtro (da carta ou do álbum, com subcategorias)? Mesma pergunta da CCD001 (L7) e da CCD024 (L5) | pendente | — |
| L7 | Qual imagem o cartão mostra (primeira foto do anúncio ou frente da carta)? Mesma pergunta da CCD001 (L8) | pendente | — |
| L8 | Anúncio com `available_quantity = 0`, de vendedor suspenso ou sem conta de recebimento pronta (`stripe_account_status`) aparece no Explorar? (proposta: só `available_quantity > 0` e vendedor `ACTIVE`) | pendente | — |
| L9 | Os filtros e a ordenação ficam na URL (para voltar do detalhe do anúncio ou compartilhar)? (proposta: sim, como parâmetros) | pendente | — |
| L10 | Estados de carregando e de erro não estão na documentação nem no Figma. (proposta: o padrão da Área do Cliente) | pendente | — |
