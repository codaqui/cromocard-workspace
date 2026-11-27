# CCD030 — Visualizar Detalhes

- **Status:** Em implementação
- **Fase:** MVP
- **User story:** #163 `CCD030 - Visualizar Detalhes`
- **Caso de uso:** [30-visualizar-detalhes.md](../../docs/Casos-De-Uso/30-visualizar-detalhes.md)
- **Atores:** Visitante, Cliente · **Pré-condições:** nenhuma; comprar, favoritar e adicionar à coleção pedem login
- **Data:** 2026-11-21 (revisada em 2026-11-23) · **Autor:** Daniel Andrade
- **Aprovação:** Lucas Oliveira Lima, pelo PO, em 23/11/2026; reaprovada em 24/11/2026 com as L9 (revista), L18 e L19, e em 26/11/2026 com a L20

## Objetivo

> Como Cliente preciso visualizar os detalhes de uma carta para conhecer suas características antes de realizar uma compra.

O caso de uso estende a story ao visitante, que vê a página inteira.

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
| R1 | O perfil da carta é público: abre sem login, e o visitante vê a página inteira | Permissão | `30`, Pré-condições |
| R2 | O ator chega ao perfil da carta selecionando a carta na busca, no marketplace ou na Home | Ação | `30`, FP 1; `escopo-adicional.md`, revisão da Área Pública de 20/11/2026 |
| R3 | O perfil mostra as imagens da carta: frente, verso e detalhe | Tela | `30`, FP 2 (L1) |
| R4 | O perfil mostra "Preço médio de mercado", "Menor anúncio" e "Anúncios ativos" (quantidade) | Tela | `30`, FP 2; Figma `1112-4615` (L2) |
| R5 | O perfil mostra os dados de identificação da carta, pelas regras da CCD031 | Tela | `30`, FP 2 |
| R6 | O perfil mostra o histórico de preços, pelas regras da CCD075 | Tela | `30`, FP 2; `75`, FP 2–4 |
| R7 | "Anúncios disponíveis (<n>)" lista os anúncios com vendedor, condição, preço e "Ver anúncio", ordenados pelo menor preço | Tela | `30`, FP 2; Figma `1112-4615` (L3, L5) |
| R8 | Só os anúncios ativos (`listing_status` = `ACTIVE`, não excluídos) entram na lista, na contagem e no menor anúncio | Regra | `30`, FP 2 ("anúncios ativos"); DBML `listings.status`; ADR-015, item 5 |
| R9 | "Ver anúncio" abre o detalhe do anúncio, de onde parte a compra | Ação | `30`, FP 4–5 |
| R10 | Ao visitante, o perfil mostra "Ainda não tem conta? Você pode ver tudo nesta página; para comprar, favoritar ou adicionar à coleção, basta entrar."; o cliente logado não vê o aviso | Mensagem | `30`, Pré-condições; Figma `1112-4615` |
| R11 | O visitante que seleciona "Adicionar à coleção" ou "Favoritar" vê o modal "Entre para continuar", com "Faça login para continuar. É rápido e grátis.", "Continuar com Google", "Entrar com e-mail e senha", "Criar conta grátis" e "Ao continuar, você aceita os Termos de Uso e a Política de Privacidade."; depois do login, volta para a carta | Ação | `30`, FA 1–2; Figma `1112-5461` (L11) |
| R12 | Sem anúncios ativos, a lista informa que não há anúncios; o vendedor logado vê "Anunciar esta carta" e o visitante não vê o botão | Estado | `30`, FA 3; `84`, FP 1 |
| R13 | Carta inexistente, excluída ou em rascunho (`DRAFT`) não abre: a API responde `404` | Regra | DBML `cards.status` ("DRAFT = rascunho fora do catálogo"); ADR-011 (L9) |
| R15 | O card de preços tem "Ver anúncios (<n>)", que rola até a lista de anúncios | Ação | `30`, FP 2 (L4) |
| R16 | A lista tem a nota "Pagamento retido pela CromoCard até você receber a carta" | Tela | `30`, FP 2 (L4) |
| R17 | O topo mostra o caminho "Início / Marketplace / <categoria> / <álbum> / <carta>", os selos de raridade, álbum e categoria e o subtítulo "Nº <número> • <álbum>" | Tela | `30`, FP 2 (L6) |
| R18 | A lista carrega 20 anúncios por vez, com "Carregar mais" | Tela | `30`, FP 2 (L8) |
| R14 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames `1112-4615`, `1112-5038`, `1112-5461`); ADR-060, itens 1 e 5; ADR-070; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R1–R7) — **Dado** uma carta com 4 anúncios ativos, **quando** um visitante a seleciona na busca, **então** vê
  as imagens, o preço médio de mercado, o menor anúncio, "4" em anúncios ativos, os dados de identificação, o histórico de
  preços e "Anúncios disponíveis (4)".
- **CA2** (R7, R8) — **Dado** uma carta com anúncios ativos de R$ 1.980, R$ 1.750 e R$ 2.390 e um pausado de R$ 1.500,
  **quando** o ator abre o perfil, **então** a lista mostra os três ativos na ordem R$ 1.750, R$ 1.980, R$ 2.390, o menor
  anúncio é R$ 1.750 e o pausado não aparece.
- **CA3** (R9) — **Dado** a lista de anúncios, **quando** o ator seleciona "Ver anúncio", **então** abre o detalhe daquele
  anúncio.
- **CA4** (R10, R11) — **Dado** um visitante no perfil da carta, **quando** seleciona "Favoritar", **então** vê o modal
  "Entre para continuar"; **quando** entra com e-mail e senha, **então** volta para o perfil da mesma carta.
- **CA5** (R11) — **Dado** um visitante no perfil da carta, **quando** seleciona "Adicionar à coleção", **então** vê o
  modal "Entre para continuar".
- **CA6** (R10) — **Dado** um cliente logado, **quando** abre o perfil da carta, **então** não vê o aviso "Ainda não tem
  conta?…".
- **CA7** (R12) — **Dado** uma carta sem anúncios ativos, **quando** um visitante abre o perfil, **então** a lista informa
  que não há anúncios e não mostra "Anunciar esta carta"; **quando** um vendedor logado abre, **então** vê "Anunciar esta
  carta".
- **CA8** (R13) — **Dado** uma carta em rascunho, **quando** o ator abre o endereço dela, **então** a API responde `404`.
- **CA9** (R14) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `1112-4615`, **então** não há diferença de layout, medida, espaçamento, cor,
  fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem
  horizontal.
- **CA10** (R14) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame e o período "1 ano"
  escolhido, **quando** o print dela é comparado lado a lado com o print do frame `1112-5038`, **então** não há diferença de
  layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem
  quebra, corte nem rolagem horizontal.
- **CA11** (R14) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame e o modal "Entre para
  continuar" aberto, **quando** o print dela é comparado lado a lado com o print do frame `1112-5461`, **então** não há
  diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se
  adapta sem quebra, corte nem rolagem horizontal.
- **CA12** (R15) — **Dado** uma carta com 4 anúncios ativos, **quando** o ator seleciona "Ver anúncios (4)" no card de
  preços, **então** a página rola até a lista "Anúncios disponíveis".
- **CA13** (R16) — **Dado** o perfil de uma carta, **quando** o ator chega à lista de anúncios, **então** vê a nota
  "Pagamento retido pela CromoCard até você receber a carta" sob o título.
- **CA14** (R17) — **Dado** uma carta com categoria, álbum e raridade, **quando** o ator abre o perfil, **então** vê o caminho
  "Início / Marketplace / <categoria> / <álbum> / <carta>", os selos de raridade, álbum e categoria e o subtítulo
  "Nº <número> • <álbum>".
- **CA15** (R18) — **Dado** uma carta com 25 anúncios ativos, **quando** o ator abre o perfil, **então** a lista mostra 20
  anúncios e "Carregar mais"; **quando** seleciona "Carregar mais", **então** vê os 25 e o botão some.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `cards` | `id`, `name`, `number`, `album_id`, `category_id`, `rarity_id`, `language_id`, `front_image_url`, `back_image_url`, `status`, `deleted_at` | só `ACTIVE` e não excluída abre (R13) |
| `card_photos` | `card_id`, `url`, `sort_order`, `deleted_at` | imagem de detalhe (L1) |
| `albums` · `categories` · `rarities` · `languages` | `id`, `title`/`name` | identificação da carta (R5, regras da CCD031) |
| `listings` | `card_id`, `seller_id`, `condition_id`, `price`, `available_quantity`, `status` (`listing_status`: `ACTIVE`, `PAUSED`, `CLOSED`), `deleted_at` | lista, contagem e menor anúncio (R7, R8); `condition_id` aceita nulo (L13); `available_quantity` pode ser 0 num anúncio `ACTIVE` (L12) |
| `card_conditions` | `name`, `sort_order` | condição do anúncio (ex.: Mint, Near Mint, Ótimo, Bom, Regular) |
| `users` | `username`, `role` | vendedor na lista; `SELLER` vê "Anunciar esta carta" |
| `profiles` | `city`, `avatar_url` | cidade do vendedor, se a L5 aceitar |
| `price_history` | `card_id`, `price`, `reference_date`, `source` (`price_source`: `SALE`, `LISTING`) | preço médio de mercado (L2) e histórico (CCD075) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Público - Perfil da carta | [1112-4615](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-4615) | R1–R10, R15–R18 | ✅ Bate, com diferenças decididas: a lista não mostra a cidade do vendedor (L5), o select só tem "Menor preço" (L3) e o subtítulo não tem o país (L6) |
| Público - Perfil da carta - 1 ano | [1112-5038](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-5038) | R6 | ✅ Bate (o período é da CCD075) |
| Público - Entre para continuar | [1112-5461](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-5461) | R11 | ✅ Bate |

- **Diferenças com o Figma** (decisão em Lacunas e decisões): perfil — imagens: o FP 2 pede frente, verso e detalhe; o
  frame mostra a imagem principal e uma miniatura (L1). Lista: o FP 2 fixa a ordem pelo menor preço; o frame tem o select
  "Ordenar: Menor preço ▾" (L3).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): "Ver anúncios (4)" e "Pagamento retido pela
  CromoCard até você receber a carta" (L4); a cidade do vendedor na lista (L5); os selos do topo, o subtítulo
  "Nº 10 • Argentina • Panini Copa do Mundo 2026" e o caminho "Início / Marketplace / Futebol / …" (L6).
- **Diferenças aceitas:** a casca do site (menu, topo e rodapé) é o `SiteShell` atual (L15); a lista não mostra a cidade do vendedor (L5); o select "Ordenar" só tem "Menor preço" (L3); o subtítulo é "Nº <número> • <álbum>", sem o país (L6).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R12 a lista sem anúncios e o botão "Anunciar esta
  carta"; R10 o perfil para o cliente e para o vendedor logados (L7); R13 a tela de carta não encontrada (L9).

## Fora do escopo

- Os dados de identificação em si — CCD031. O gráfico e os períodos do histórico — CCD075.
- O detalhe do anúncio (CCD074, CCD079, CCD080) e a compra (CCD072), da fatia mínima do marketplace (ADR-027).
- Favoritar a carta logado — CCD056. Adicionar à coleção logado — CCD022.
- Criar o anúncio por "Anunciar esta carta" — CCD084.
- A cidade do vendedor na lista — CCD080 (L5). As outras ordens do select ("Maior preço", "Mais recentes") — CCD068 (L3).
- "Alerta de preço" e "Compartilhar" no perfil da carta — não viram requisito (`escopo-adicional.md`, seção 3).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Imagens: o FP 2 pede frente, verso e detalhe; o Figma mostra a principal e uma miniatura. Quantas miniaturas? A de "detalhe" vem de `card_photos`? | Imagem principal e uma miniatura por imagem: frente, verso e as fotos de `card_photos` não excluídas, por `sort_order`; com uma imagem só, fica igual ao frame | `30-visualizar-detalhes.md` (23/11/2026), FP 2 |
| L2 | De onde sai o "Preço médio de mercado" e de que período (`price_history`, só `SALE` ou também `LISTING`)? A CCD075 baseia o histórico só em vendas concluídas (`SALE`): o preço médio segue a mesma base? Sem vendas, o que aparece? (proposta: média dos últimos 30 dias, só `SALE`, igual à CCD075; sem vendas, "—"). A Gestão de Catálogo (CCD097, L4) usa todo o `price_history` dos 30 dias: a decisão vale para as duas telas, e se for só `SALE` a CCD097 muda | Média de `price_history.price` com `source = SALE` dos últimos 30 dias, a base da CCD075; sem vendas, "—". A L4 da CCD097 é reaberta para seguir a mesma base | `30-visualizar-detalhes.md` (23/11/2026), FP 2; spec da CCD097, L4 |
| L3 | O FP 2 fixa a ordem pelo menor preço; o Figma tem o select "Ordenar: Menor preço ▾". Quais outras ordens (maior preço, CCD069; mais recentes, CCD071), ou só a fixa? | O select "Ordenar" aparece como no frame, só com "Menor preço"; as outras ordens são da CCD068 | esta spec, Telas |
| L4 | "Ver anúncios (4)" (rola até a lista?) e "Pagamento retido pela CromoCard até você receber a carta" só existem no Figma: faz sentido implementar? | Os dois entram: "Ver anúncios (<n>)" rola até a lista e a nota "Pagamento retido pela CromoCard até você receber a carta" fica sob o título da lista (R15, R16) | `30-visualizar-detalhes.md` (23/11/2026), FP 2 |
| L5 | A cidade do vendedor ("São Paulo - SP") na lista só existe no Figma. Faz sentido? Configurações tem "Mostrar a cidade no perfil público", mas o DBML não tem coluna para essa escolha | Não entra agora: a cidade do vendedor fica com a CCD080; a lista mostra só o nome de usuário | esta spec, Fora do escopo |
| L6 | De onde vêm os selos do topo ("LENDÁRIA", "COPA DO MUNDO 2026", "SELEÇÕES"), o "Argentina" do subtítulo e o caminho que começa em "Marketplace" mesmo quando o ator veio da Home ou da busca? | Com os dados que existem: selos de raridade, álbum e categoria; subtítulo "Nº <número> • <álbum>", sem o país; caminho "Início / Marketplace / <categoria> / <álbum> / <carta>" (R17) | `30-visualizar-detalhes.md` (23/11/2026), FP 2 |
| L7 | O Figma só desenha o perfil do visitante. Para o cliente e o vendedor logados, a tela usa o menu do cliente e o topo com notificações? O que muda nos botões? | Mesma página no `PublicLayout`, com o topo do logado e sem o aviso; "Favoritar" e "Adicionar à coleção" levam ao que a CCD056 e a CCD022 entregarem (em construção até lá) | esta spec, Telas |
| L8 | A lista mostra todos os anúncios ativos ou pagina? (proposta: 20 por página, com "Carregar mais"; o endpoint é o mesmo da CCD079, cujo padrão é 10) | 20 anúncios por vez, com "Carregar mais" só quando houver mais; o padrão do endpoint continua 10 (R18) | `30-visualizar-detalhes.md` (23/11/2026), FP 2 |
| L9 | O Figma não desenha a carta não encontrada (`404`): pedir o desenho ou seguir o estado vazio da busca (`1112-4356`)? | `NotFoundPage` com "Carta não encontrada" e o link "Voltar para o marketplace", que leva à página inicial (`paths.home`) enquanto o marketplace não tem tela própria (revisto em 24/11/2026), no estilo do vazio da busca | `30-visualizar-detalhes.md` (23/11/2026), FA 4 |
| L10 | O FA 1 cita "Comprar" no perfil da carta, mas o perfil não tem esse botão: a compra parte do anúncio (FP 5, CCD072). Tirar "Comprar" do FA 1? | "Comprar" sai do FA 1: a compra parte do anúncio | `30-visualizar-detalhes.md` (23/11/2026), FA 1 |
| L11 | O modal "Entre para continuar" abre por cima do perfil; "Criar conta grátis" também volta para a carta depois do cadastro e da confirmação do e-mail? | As três saídas (e-mail e senha, Google e cadastro) voltam para a carta pelo `loginRedirect` | `30-visualizar-detalhes.md` (23/11/2026), FA 2 |
| L12 | Um anúncio `ACTIVE` com `available_quantity = 0` aparece como "Indisponível" na CCD079. Ele entra na lista, na contagem de "Anúncios ativos" e no "Menor anúncio" da CCD030, ou só contam os com quantidade maior que 0? (proposta: só quantidade maior que 0 conta no menor anúncio e na contagem; o esgotado continua na lista, marcado como indisponível; o título "Anúncios disponíveis (<n>)" usa a mesma contagem do card, e o contrato da lista ganha `availableQuantity`, nos planos da CCD030 e da CCD079) | Anúncio com `available_quantity = 0` fica fora da lista, da contagem e do menor anúncio, igual à CCD079; o contrato não ganha `availableQuantity` | `30-visualizar-detalhes.md` (23/11/2026), FP 2 |
| L13 | `listings.condition_id` aceita nulo no DBML, mas a lista mostra a condição de cada anúncio. Sem condição, a lista mostra "—" ou o anúncio exige condição na criação (CCD084)? | `condition` vem `null` e a lista mostra "—" sem selo; a obrigatoriedade na criação fica com a CCD084 | `30-visualizar-detalhes.md` (23/11/2026), FP 2 |
| L14 | "Anunciar esta carta" aparece para todo vendedor logado? A CCD084 exige conta de recebimento pronta e endereço principal; o Figma tem o estado "Criar anúncio bloqueado" (`1112-10828`). Sem isso, o botão leva ao estado bloqueado ou fica desabilitado? | Aparece para todo `SELLER` e leva à criação de anúncio (CCD084, em construção até lá), que decide o bloqueio | `30-visualizar-detalhes.md` (23/11/2026), FA 3 |
| L15 | A casca do frame (menu lateral, "Entrar"/"Criar conta grátis" e rodapé) difere do `SiteShell` de todas as páginas públicas | A CCD030 desenha o conteúdo da página igual ao frame, dentro do `SiteShell` atual; a casca fica para a story da Área Pública | esta spec, Telas |
| L16 | Como "Criar conta grátis" volta para a carta, se o cadastro passa pela confirmação do e-mail? | O endereço da carta fica no `sessionStorage` ao abrir o cadastro pelo modal; o próximo login no mesmo navegador volta para ela. Confirmando em outro dispositivo, segue o destino padrão | esta spec, R11 |
| L17 | A busca, o marketplace e a Home ainda não têm cartões de carta no `develop` (rotas em construção) | O perfil fica pronto em `/cartas/:id` e `cardProfilePathFor(id)` é exportado; cada lista liga o cartão quando for feita (CCD001, CCD002, CCD068) | esta spec, R2 |
| L18 | O login com Google (CCD004) ainda não existe: para onde vai "Continuar com Google" no modal? | Para a rota em construção `/login/google` (`underConstructionRoute`, CCD004), como no Figma; e-mail e senha e cadastro seguem voltando para a carta | `30-visualizar-detalhes.md` (24/11/2026), FA 2 |
| L19 | Até quando vale a carta guardada pela L16, se a pessoa desiste do cadastro? | 30 minutos; depois disso o login segue o destino padrão do papel | esta spec, R11 |
| L20 | O título "Anúncios disponíveis (<n>)" usa a contagem do perfil ou o total da lista? Com o perfil em cache dizendo 0, a lista nem era consultada | A lista é sempre consultada e o total dela manda no título e no estado vazio; a contagem do perfil só aparece enquanto a lista carrega | esta spec e `plano.md` (26/11/2026), revisão da CCD030 |
