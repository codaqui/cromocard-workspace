# CCD001 — Visualizar Destaques

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #88 `CCD001-Visualizar Destaques`
- **Caso de uso:** [01-visualizar-destaques.md](../../docs/Casos-De-Uso/01-visualizar-destaques.md) · complementos: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md) (EA-001-01, EA-001-03)
- **Atores:** Visitante · **Pré-condições:** acessar a URL base da aplicação (sem login)
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como visitante eu quero ver destaques, cartas mais procuradas, anúncios recentes e categorias na tela Home.

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
| R1 | A Home abre na URL base sem login, e a API que alimenta a Home responde sem token | Permissão | `01`, Atores e Pré-condições |
| R2 | Destaque principal com o rótulo "MARKETPLACE DE CARTAS COLECIONÁVEIS", o título "Organize, encontre e compre cartas", o texto de apoio e os atalhos "Criar conta grátis" e "Explorar o marketplace" | Tela | `01`, FP 2 |
| R3 | "Criar conta grátis" abre o cadastro (CCD003); "Explorar o marketplace" abre o Explorar marketplace (CCD078) | Ação | `01`, FP 2; `78`, FP 1 |
| R4 | Seção "Mais procuradas nos últimos 30 dias" com as 4 cartas do catálogo que têm mais vendas concluídas nos últimos 30 dias, em ordem decrescente de vendas: imagem, quantidade de vendas e categoria ("<n> vendas • <categoria>") e nome da carta | Tela | `01`, FP 2 |
| R5 | Só contam as vendas concluídas com data dentro dos últimos 30 dias (status e data que contam: L3) | Regra | `01`, FP 2 (L3) |
| R6 | Seção "Cartas recém-anunciadas" com os anúncios ativos (`listings.status = ACTIVE`, não excluídos) do mais novo para o mais antigo (`created_at`): imagem, categoria e coleção ("<categoria> • <coleção>"), nome da carta, condição, "Preço", preço e o nome de usuário do vendedor (@) | Tela | `01`, FP 2; DBML `listings` |
| R7 | O filtro de "Cartas recém-anunciadas" tem "Todas" e as categorias padrão (`is_default`), com a fixada (`is_pinned`) primeiro e as demais por `display_order` | Campo | `01`, FP 2; `104`, FP 9 (CCD104, R6 e L12) |
| R8 | Selecionar uma carta de "Mais procuradas" abre o perfil da carta (CCD030) | Ação | `01`, FP 3–4 |
| R9 | Selecionar um anúncio de "Cartas recém-anunciadas" abre o detalhe do anúncio | Ação | `01`, FP 3–4 |
| R10 | Escolher uma categoria abre o Explorar marketplace filtrado nela (o Figma filtra a seção na própria Home: L5) | Ação | `01`, FP 4 (L5) |
| R11 | Sem vendas concluídas nos últimos 30 dias, a seção "Mais procuradas" não aparece | Estado | `01`, FA 1 |
| R12 | Sem anúncios ativos, a seção "Cartas recém-anunciadas" informa que ainda não há anúncios (texto: L6) | Estado | `01`, FA 2 (L6) |
| R13 | Menu lateral do visitante com Início, Marketplace e Pesquisar e, abaixo da divisória, Como funciona e Central de ajuda; o item da tela aberta fica destacado. Logado, o menu é o da Área do Cliente | Tela | EA-001-01 |
| R14 | Rodapé em todas as telas públicas com "© 2026 CromoCard" e os links "Como funciona", "Central de ajuda" e "Termos de Uso e Privacidade" | Tela | EA-001-03 |
| R15 | Topo com a barra de busca global "Buscar cartas, álbuns, usuários e grupos" (comportamento na CCD002) e os botões "Entrar" (CCD004) e "Criar conta grátis" (CCD003) | Tela | `02`, Pré-condições; Figma `1112-2169` |
| R16 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames da seção Telas); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2, R4, R6) — **Dado** anúncios ativos e vendas concluídas nos últimos 30 dias, **quando** o visitante abre a URL
  base sem login, **então** vê o destaque principal com os dois atalhos, "Mais procuradas nos últimos 30 dias" com 4 cartas em
  ordem decrescente de vendas e "Cartas recém-anunciadas" do anúncio mais novo para o mais antigo.
- **CA2** (R1) — **Dado** uma requisição sem token, **quando** o frontend chama a API da Home, **então** ela responde `200`
  com os destaques.
- **CA3** (R5) — **Dado** uma carta com 10 vendas concluídas há 40 dias e nenhuma nos últimos 30, **quando** a Home abre,
  **então** essa carta não aparece em "Mais procuradas".
- **CA4** (R7) — **Dado** Pokémon fixada e a ordem salva Futebol, Magic: The Gathering, **quando** a Home abre, **então** o
  filtro mostra "Todas", Pokémon, Futebol e Magic: The Gathering, nessa ordem.
- **CA5** (R10) — **Dado** a Home aberta, **quando** o visitante escolhe "Pokémon" no filtro, **então** acontece o que a L5
  decidir (pela documentação: abre o Explorar marketplace com o filtro Categoria em Pokémon).
- **CA6** (R8) — **Dado** a seção "Mais procuradas", **quando** o visitante seleciona uma carta, **então** abre o perfil
  daquela carta.
- **CA7** (R9) — **Dado** a seção "Cartas recém-anunciadas", **quando** o visitante seleciona um anúncio, **então** abre o
  detalhe daquele anúncio.
- **CA8** (R3) — **Dado** a Home, **quando** o visitante seleciona "Criar conta grátis" ou "Explorar o marketplace", **então**
  abre o cadastro ou o Explorar marketplace.
- **CA9** (R11) — **Dado** nenhuma venda concluída nos últimos 30 dias, **quando** a Home abre, **então** a seção "Mais
  procuradas" não aparece e o resto da página continua igual.
- **CA10** (R12) — **Dado** nenhum anúncio ativo, **quando** a Home abre, **então** "Cartas recém-anunciadas" mostra o aviso
  de que ainda não há anúncios.
- **CA11** (R13, R14) — **Dado** um visitante, **quando** abre a Home, **então** vê o menu lateral do visitante com "Início"
  destacado e o rodapé com os três links; **dado** um cliente logado, **então** o menu é o da Área do Cliente.
- **CA12** (R15) — **Dado** a Home, **quando** o visitante digita um termo na barra do topo e confirma, **então** abre a
  busca global (CCD002) com esse termo.
- **CA13** (R16 de Fidelidade) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o
  print dela é comparado lado a lado com o print do frame `1112-2169`, **então** não há diferença de layout, medida,
  espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem
  rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `listings` | `id`, `card_id`, `seller_id`, `condition_id`, `price`, `available_quantity`, `status` (`listing_status.ACTIVE`), `created_at`, `deleted_at` | `status` default `ACTIVE`; `price` decimal(10,2), devolvido como string (ADR-011) |
| `listing_photos` | `listing_id`, `url`, `sort_order` | imagem do anúncio (L8) |
| `cards` | `id`, `name`, `front_image_url`, `album_id`, `category_id`, `status` (`card_status.ACTIVE`), `deleted_at` | só `ACTIVE` (ADR-053, item 5) |
| `albums` | `title`, `category_id` | a "coleção" do cartão |
| `categories` | `name`, `parent_category_id`, `is_default`, `is_pinned`, `display_order`, `deleted_at` | filtro e rótulo da categoria (L7) |
| `card_conditions` | `name` | Mint, Near Mint, Ótimo, Bom, Regular |
| `users` | `username` | vendedor (@); `username` aceita nulo no DBML |
| `orders` | `listing_id`, `quantity`, `status` (`order_status`), datas | "vendas concluídas" (L3) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Público - Home | [1112-2169](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-2169) | R2–R10, R13–R15 | ⚠️ Difere: filtro de categoria na própria Home (L5); bloco de 3 passos, "A partir de" e links "Ver …" só no Figma (L1, L2, L4) |

- **Diferenças com o Figma** (decisão em Lacunas e decisões): Home — filtro "Todas / Pokémon / Magic …": no frame, os chips
  parecem filtrar a seção na própria Home; o `01`, FP 4, manda abrir o Explorar marketplace filtrado (L5).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): Home — bloco "1 Encontre a carta / 2 Pague com
  proteção / 3 Receba e confirme" (L1); "A partir de" com o preço nas cartas de "Mais procuradas" (L2); links "Ver no
  marketplace →" e "Ver todas →" (L4).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R11 Home sem a seção "Mais procuradas"; R12 aviso de
  que ainda não há anúncios; R13 Home com o menu da Área do Cliente (L9).

## Fora do escopo

- Busca global (comportamento da barra do topo) — CCD002.
- Cadastro e login ("Criar conta grátis", "Entrar") — CCD003 e CCD004.
- Explorar marketplace, filtros e ordenação — CCD078 e CCD068.
- Perfil da carta — CCD030; detalhe do anúncio — CCD079, CCD080 e CCD072.
- Como funciona e Central de ajuda (destino dos links do menu e do rodapé) — CCD005; Termos de Uso — CCD003 (EA-001-04).
- Gravar a ordem das categorias padrão — CCD104 (esta story só aplica a ordem).
- "Categorias", "Comunidades", "Recursos" e "notícias" no menu ou na Home — saíram na revisão da Área Pública (EA-001-01; `escopo-adicional.md`, seção 3).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O Figma (`1112-2169`) mostra, abaixo do destaque, o bloco "1 Encontre a carta / 2 Pague com proteção / 3 Receba e confirme" com textos de apoio; o `01` não fala dele. Faz sentido implementar? (proposta: sim, estático) | pendente | — |
| L2 | O Figma mostra "A partir de" e um preço em cada carta de "Mais procuradas"; o `01` não fala de preço. Faz sentido implementar? Se sim, é o menor preço entre os anúncios ativos da carta? E se a carta não tiver anúncio ativo? (proposta: sim, menor anúncio ativo; sem anúncio, sem preço) | pendente | — |
| L3 | O que é "venda concluída" e por qual data conta os 30 dias? O `order_status` tem `DELIVERED` e `COMPLETED`, e `orders` tem `paid_at`, `delivered_at` e `released_at`. Conta pedidos ou a soma de `quantity`? (proposta: `COMPLETED` por `released_at`, somando `quantity`) | pendente | — |
| L4 | Os links "Ver no marketplace →" (Mais procuradas) e "Ver todas →" (Cartas recém-anunciadas) só existem no Figma. Faz sentido implementar? Para onde levam? (proposta: os dois abrem o Explorar marketplace; "Ver todas" na ordem "Mais recentes") | pendente | — |
| L5 | O filtro de categorias filtra "Cartas recém-anunciadas" na própria Home (como o Figma sugere e o EA-001-01 chama de "abas na Home") ou abre o Explorar marketplace filtrado (`01`, FP 4)? | pendente | — |
| L6 | Qual o texto do aviso sem anúncios ativos (`01`, FA 2)? Não há frame desse estado. (proposta: "Ainda não há anúncios", no estilo do vazio do Explorar `1112-3674`) | pendente | — |
| L7 | Qual categoria do anúncio aparece no cartão e conta no filtro: a da carta (`cards.category_id`) ou a do álbum (`albums.category_id`)? Uma carta de subcategoria (ex.: "Seleções", filha de Futebol) entra no filtro da categoria raiz? (proposta: a categoria raiz, pela carta ou pelo álbum, incluindo as subcategorias; decidir junto com CCD027 e CCD078) | pendente | — |
| L8 | Qual imagem o cartão do anúncio mostra: a primeira foto do anúncio (`listing_photos`) ou a frente da carta do catálogo? (proposta: a primeira foto e, sem foto, a frente da carta, como no `74`, FA 1) | pendente | — |
| L9 | O que o cliente logado vê na URL base: esta Home com o menu da Área do Cliente (EA-001-01) ou o Início da coleção (CCD007, `1122-17812`)? | pendente | — |
| L10 | Quantos anúncios "Cartas recém-anunciadas" mostra? O Figma mostra 8 (duas linhas de 4) e o `01` não diz. Anúncio com `available_quantity = 0` ou de vendedor suspenso aparece? (proposta: 8; só `available_quantity > 0` e vendedor `ACTIVE`) | pendente | — |
| L11 | Os estados de carregando e de erro da Home não estão na documentação nem no Figma. (proposta: o padrão de carregando e erro já usado na Área do Cliente, por seção) | pendente | — |
