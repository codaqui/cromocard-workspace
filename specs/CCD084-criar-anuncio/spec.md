# CCD084 — Criar Anúncio

- **Status:** Em implementação
- **Fase:** MVP (sem marca na user story; fatia mínima do marketplace, "Vender", no ADR-027)
- **User story:** #343 `CCD084-Criar Anúncio`
- **Caso de uso:** [84-criar-anuncio.md](../../docs/Casos-De-Uso/84-criar-anuncio.md)
- **Atores:** Vendedor · **Pré-condições:** autenticado como `SELLER`, com a conta de recebimento pronta (CCD108) e um endereço principal cadastrado, que é a origem do frete
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-11-24, Felipe Consulim (PO), com as lacunas L1–L13 decididas

## Objetivo

> Como Vendedor preciso criar um anúncio para disponibilizar minhas cartas para venda no marketplace.

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
| R1 | Só `SELLER` cria anúncio: `401` sem token, `403` para outro papel | Permissão | `84`, Atores e Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | "Criar anúncio" no Painel do vendedor, "Anunciar esta carta" no perfil da carta e "Anunciar repetida" na Início do cliente (só para `SELLER`) abrem o formulário de anúncio; vindo do perfil da carta ou da Início, a carta já vem escolhida | Ação | `84`, FP 1 (L9) |
| R3 | O formulário tem a carta (escolhida por busca no catálogo), a condição obrigatória (Mint, Near Mint, Ótimo, Bom ou Regular), o preço, a quantidade disponível inteira de 1 a 99, a descrição opcional de até 2000 caracteres e até 4 fotos opcionais: os 2 espaços do frame (Foto Frontal e Foto do Verso) e, preenchidos, mais espaços até 4. Sem condição ou com quantidade fora de 1–99, não publica e a API responde `400` | Tela | `84`, FP 2 e FA 6–7 (L1, L5, L10, L17); DBML `listings`, `card_conditions` |
| R4 | A busca da carta só traz cartas do catálogo: não excluídas e fora de rascunho (`cards.status = ACTIVE`) | Regra | `84`, FP 2; DBML `cards.status` (DRAFT fica fora do catálogo, CCD106) |
| R5 | Preço zerado ou negativo não publica e mostra "Por favor, insira um valor válido maior que zero" | Mensagem | `84`, FA 1–2 |
| R6 | Enquanto o vendedor digita o preço, o formulário mostra a taxa de 5% e o valor líquido que o vendedor recebe por unidade vendida: preço menos a taxa, com a taxa arredondada para baixo, a favor do vendedor | Tela | `84`, FP 2 (L2); `110`, FP 6; ADR-066, item 4 |
| R7 | "Publicar anúncio" valida os dados e cria o anúncio `ACTIVE` do vendedor, visível no marketplace | Ação | `84`, FP 3–5; DBML `listings.status` (default `ACTIVE`) |
| R8 | Fotos opcionais, até 4, PNG, JPG ou WEBP de até 4 MB cada, gravadas em ordem; sem foto, o anúncio usa a imagem da carta no catálogo | Regra | `84`, FP 2 e FP 5; ADR-050, item 1; DBML `listing_photos.sort_order`, `cards.front_image_url` |
| R9 | Sem a conta de recebimento pronta, "Criar Novo Anúncio" e "Criar Anúncio" ficam desabilitados no Painel do vendedor. Pelas outras entradas ("Anunciar esta carta" e "Anunciar repetida"), aparece o aviso "Conecte sua conta de recebimento antes de anunciar" com "Conectar conta Stripe" (fluxo da CCD108) e "Agora não", que fecha o aviso. A API recusa a criação. O credenciamento (ADR-052) não é exigido | Regra | `84`, Pré-condições e FA 3–4 (L7, L8, L11); `108`, FP 7; ADR-066, item 5; DBML `users.stripe_account_status` |
| R10 | Sem endereço principal, o sistema mostra "Cadastre seu endereço principal antes de anunciar. Ele é a origem do frete." com "Cadastrar endereço", que leva ao Perfil, e a API recusa a criação | Regra | `84`, Pré-condições e FA 5 (L12); DBML `addresses.is_primary` |
| R11 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (frames `282-4482`, `1112-10828`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |
| R12 | Abaixo da carta escolhida, a ajuda "Identificada no catálogo oficial <categoria> • <álbum>", com a categoria e o álbum da carta | Tela | `84`, FP 2 (L6); Figma `282-4482` |

## Critérios de aceite

- **CA1** (R2, R3, R6, R7) — **Dado** um vendedor com conta pronta e endereço principal, **quando** ele abre "Criar anúncio", escolhe uma carta na busca, marca "Mint", informa preço 1.850,00, quantidade 1 e descrição e seleciona "Publicar anúncio", **então** o formulário mostra a taxa (R$ 92,50) e o líquido (R$ 1.757,50) antes de publicar, a API grava o anúncio `ACTIVE` com o vendedor, a carta, a condição, o preço, a quantidade e a descrição, e ele aparece no marketplace.
- **CA2** (R2) — **Dado** o vendedor no perfil de uma carta, **quando** seleciona "Anunciar esta carta", **então** o formulário abre com essa carta já escolhida.
- **CA3** (R4) — **Dado** uma carta em rascunho (`DRAFT`) e uma excluída, **quando** o vendedor busca pelo nome delas, **então** nenhuma das duas aparece na busca.
- **CA4** (R5) — **Dado** o formulário preenchido, **quando** o vendedor informa preço 0 ou -10 e seleciona "Publicar anúncio", **então** vê "Por favor, insira um valor válido maior que zero", nada é gravado, e a API responde `400` se chamada direto.
- **CA5** (R8) — **Dado** um anúncio publicado com 2 fotos, **quando** ele é aberto no marketplace, **então** mostra as 2 fotos na ordem enviada; **dado** um anúncio sem foto, **então** mostra a imagem da carta no catálogo.
- **CA6** (R8) — **Dado** o formulário, **quando** o vendedor tenta enviar a quinta foto ou um arquivo PDF ou maior que 4 MB, **então** o arquivo é recusado com a mensagem de erro e nada é gravado.
- **CA7** (R9) — **Dado** um vendedor sem a conta de recebimento pronta, **quando** abre o Painel do vendedor, **então** "Criar Novo Anúncio" e "Criar Anúncio" estão desabilitados; **quando** seleciona "Anunciar esta carta" ou "Anunciar repetida", **então** vê o aviso "Conecte sua conta de recebimento antes de anunciar" com "Conectar conta Stripe", que leva ao cadastro da CCD108; chamando a API direto, ela responde `422` e não grava nada.
- **CA8** (R10) — **Dado** um vendedor com conta pronta e sem endereço principal, **quando** tenta publicar, **então** o sistema pede o cadastro do endereço e não publica; chamando a API direto, ela responde `422`.
- **CA9** (R1) — **Dado** um visitante sem login, **quando** chama a criação de anúncio, **então** recebe `401`; **dado** um `CUSTOMER` ou um `ADMIN`, **então** recebe `403`.
- **CA10** (R3, R7) — **Dado** a publicação em andamento, **quando** o vendedor seleciona "Publicar anúncio", **então** o botão fica em carregamento até a resposta; se a API falhar, o formulário continua preenchido e mostra o erro.
- **CA11** (R11) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `282-4482` (Criar anúncio), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA12** (R11) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1112-10828` (Criar anúncio bloqueado), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA13** (R3) — **Dado** o formulário preenchido, **quando** o vendedor publica sem condição, ou com quantidade 0 ou 100, **então** vê o erro no campo e nada é gravado; chamando a API direto, ela responde `400` `VALIDATION_ERROR`.
- **CA14** (R2) — **Dado** um `SELLER` com uma carta repetida na Início, **quando** seleciona "Anunciar repetida", **então** o formulário abre com essa carta já escolhida; **dado** um `CUSTOMER`, **então** o botão não aparece.
- **CA15** (R12) — **Dado** a carta "Charizard" do álbum "Shining Fates" na categoria "Pokémon TCG", **quando** o vendedor a escolhe, **então** a ajuda mostra "Identificada no catálogo oficial Pokémon TCG • Shining Fates".

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `listings` | `seller_id`, `card_id`, `condition_id`, `price`, `available_quantity`, `description`, `status` (`listing_status`) | `price` decimal(10,2) obrigatório; `available_quantity` obrigatório, default 1; `condition_id` opcional no DBML, obrigatório na API (L5); `available_quantity` de 1 a 99 (L10); `status` default `ACTIVE` |
| `listing_photos` | `listing_id`, `url`, `sort_order` | `url` obrigatória; `sort_order` default 0 |
| `card_conditions` | `id`, `name`, `sort_order` | Mint, Near Mint, Ótimo, Bom, Regular (seed) |
| `cards` | `id`, `name`, `number`, `album_id`, `front_image_url`, `status` (`card_status`), `deleted_at` | busca do catálogo; imagem padrão do anúncio |
| `users` | `role` (`user_role`), `stripe_account_status` | `SELLER`; conta pronta = `READY` (CCD108) |
| `addresses` | `user_id`, `is_primary`, `deleted_at` | endereço principal obrigatório |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Painel vendedor - criar anuncio | [282-4482](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=282-4482) | R3, R5–R8, R12 | ✅ Bate, com as diferenças decididas (L1–L4, L6) |
| Painel vendedor - criar anúncio bloqueado | [1112-10828](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-10828) | R9 | ✅ Bate, com as diferenças decididas (L7, L8) |

- O modal "Criar anúncio" abre sobre "Meus Anúncios" (`675-1452`): título "Criar anúncio", subtítulo "Escolha a carta no
  catálogo e informe a condição, o preço e as fotos.", "Carta do catálogo" com a ajuda "Identificada no catálogo oficial
  Pokémon TCG • Shining Fates", "Fotos (opcional, até 4)", "Condição", "Preço de Venda (R$)", "Quantidade Disponível",
  "Taxa  (5%):", "Você recebe líquido:", "Descrição do Anúncio", "Cancelar" e "Publicar anúncio".
- O aviso bloqueado abre quando a criação começa por "Anunciar esta carta" ou "Anunciar repetida" (no Painel, os botões ficam desabilitados, L7): "Conecte sua conta de recebimento antes de anunciar", "Para publicar um
  anúncio, sua conta Stripe precisa estar pronta para receber. O cadastro leva poucos minutos.", "Agora não" e
  "Conectar conta Stripe". O print extraído de `1112-10828` sai todo desfocado; confira o frame no protótipo.
- **Diferenças com o Figma** (decisão em Lacunas e decisões): Criar anúncio — "Fotos (opcional, até 4)": desenha só 2
  espaços (Foto Frontal e Foto do Verso); o caso de uso pede até 4 (L1). Criar anúncio — taxa e líquido aparecem enquanto
  o vendedor digita; o caso de uso mostra depois de validar, no passo 4 (L2). Painel sem conta (`1112-9866`) — "Criar Novo
  Anúncio" e "Criar Anúncio" aparecem desabilitados, e o caso de uso foi ajustado para seguir o Figma (L7).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): Criar anúncio — rodapé "Transação protegida por
  CromoCard Vault / Escrow" (L3); campo sem rótulo abaixo da descrição (L4); ajuda "Identificada no catálogo oficial…"
  (L6). Bloqueado — botão "Agora não" (L8).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R2 "Anunciar esta carta" no perfil da carta visto
  pelo vendedor (o frame público `1112-4615` é o do visitante, que não vê o botão); R5 a mensagem de preço inválido; R10 o
  pedido de cadastro do endereço principal; R8 o erro de foto recusada.

## Fora do escopo

- Conectar a conta Stripe — CCD108 (este caso de uso só leva até lá).
- Lista "Meus Anúncios" ao fundo do modal, editar, excluir, pausar e reativar — CCD085 (agrupa CCD086–088).
- Visão geral do painel ao fundo do aviso bloqueado — CCD092 e CCD093.
- Cadastrar o endereço principal — CCD048 (Perfil, endereços).
- "Anunciar repetida" na Início do cliente (`1122-17812`): o botão é da CCD007; esta story liga o botão ao formulário (L9, R2).
- Rodapé "Transação protegida por CromoCard Vault / Escrow" (L3) e o campo sem rótulo abaixo da descrição (L4): não são implementados.
- Exigir o credenciamento do vendedor (`seller_verifications`, ADR-052) para anunciar (L11).
- Impedir dois anúncios ativos da mesma carta e condição do mesmo vendedor (L13).
- Propostas de compra e graduação PSA/BGS como condição — fora do MVP (ADR-027; `escopo-adicional.md`, 20/11/2026).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O Figma desenha 2 espaços de foto (Frontal e Verso) e o rótulo diz "até 4"; o caso de uso pede até 4. Como chegar às 4? (proposta: os 2 espaços do frame e, depois de preenchidos, mais espaços até 4, no mesmo estilo; o Gabriel ajusta o frame) | Os 2 espaços do frame (Foto Frontal e Foto do Verso) e, depois de preenchidos, mais espaços no mesmo estilo até 4. O Gabriel ajusta o frame. Decisão do PO (Felipe, 24/11/2026) | `84`, FP 2; R3 |
| L2 | Taxa e líquido: em tempo real enquanto digita (Figma) ou só depois de validar (`84`, FP 4)? (proposta: em tempo real, como no Figma, ajustando o FP 4) | Em tempo real, enquanto o vendedor digita o preço, como no Figma. Decisão do PO (Felipe, 24/11/2026) | `84`, FP 2 e FP 4; R6 |
| L3 | Rodapé "Transação protegida por CromoCard Vault / Escrow" só existe no Figma, e "Escrow" saiu das outras telas em 20/11/2026. Faz sentido implementar? (proposta: trocar por um texto sem "Vault / Escrow" ou tirar) | Tirar o rodapé "Transação protegida por CromoCard Vault / Escrow", como nas outras telas desde 20/11/2026; a tela fica diferente do frame nesse ponto. Decisão do PO (Felipe, 24/11/2026) | Fora do escopo; Telas |
| L4 | Há um campo sem rótulo abaixo de "Descrição do Anúncio" no frame. É sobra do desenho ou um campo? (proposta: sobra; o Gabriel tira do frame) | Sobra do desenho: não é implementado; o Gabriel tira do frame. Decisão do PO (Felipe, 24/11/2026) | Fora do escopo; Telas |
| L5 | A condição é obrigatória? O caso de uso lista a condição no formulário, mas `listings.condition_id` é opcional no DBML (proposta: obrigatória na API e no formulário, sem mudar o DBML) | Obrigatória na API e no formulário; o DBML continua aceitando nulo (anúncios antigos do seed). Decisão do PO (Felipe, 24/11/2026) | `84`, FP 2 e FA 6–7; R3; CA13 |
| L6 | Ajuda "Identificada no catálogo oficial <categoria> • <álbum>" abaixo da carta só existe no Figma. Faz sentido implementar? (proposta: sim, com a categoria e o álbum da carta) | Sim: "Identificada no catálogo oficial <categoria> • <álbum>", com a categoria e o álbum da carta. Decisão do PO (Felipe, 24/11/2026) | `84`, FP 2; R12; CA15 |
| L7 | Sem conta pronta, o botão "Criar anúncio" fica desabilitado (Figma `1112-9866`) ou abre o aviso (`84`, FA 3–4, e frame `1112-10828`)? (proposta: habilitado, abrindo o aviso, como no caso de uso) | Desabilitados, como no Figma (`1112-9866`): "Criar anúncio" e "Criar Novo Anúncio" ficam desabilitados no Painel até a conta ficar `READY`. Pelas outras entradas ("Anunciar esta carta" e "Anunciar repetida"), ou se a criação chegar à API, ela recusa com `422 STRIPE_ACCOUNT_NOT_READY` e o aviso do frame `1112-10828` abre. Decisão do PO (Felipe, 25/11/2026), que revê a de 24/11/2026 para seguir a L2 da CCD108 | `84`, FA 3–4; R9; CCD108, L2; Telas |
| L8 | Botão "Agora não" no aviso bloqueado só existe no Figma. Faz sentido implementar? (proposta: sim, fecha o aviso) | Sim: "Agora não" fecha o aviso. Decisão do PO (Felipe, 24/11/2026) | `84`, FA 4; R9; CA7 |
| L9 | "Anunciar repetida" na Início do cliente (`1122-17812`) abre este formulário com a carta escolhida? O caso de uso só cita o Painel e o perfil da carta (proposta: sim, como mais uma entrada do FP 1, e só para `SELLER`) | Sim, como mais uma entrada do FP 1, com a carta já escolhida, e só para `SELLER` (quem não é vendedor não vê o botão). Liga o link que a CCD007 deixou em construção. Decisão do PO (Felipe, 24/11/2026) | `84`, FP 1; R2; CA14 |
| L10 | Quantidade disponível: mínimo 1 e algum máximo? O caso de uso não diz (proposta: inteiro de 1 a 99) | Inteiro de 1 a 99. Decisão do PO (Felipe, 24/11/2026) | `84`, FP 2 e FA 6–7; R3; CA13 |
| L11 | O vendedor precisa ter o credenciamento aprovado (`seller_verifications.status = APPROVED`, ADR-052) para anunciar, além da conta Stripe pronta? (proposta: não; o ADR-052 só usa a aprovação nos indicadores) | Não: basta a conta Stripe pronta (`READY`); o credenciamento do ADR-052 não bloqueia o anúncio. Decisão do PO (Felipe, 24/11/2026) | R9; Fora do escopo |
| L12 | Texto e forma do pedido de endereço principal (FA 5), que não tem frame nem texto (proposta: aviso no modal "Cadastre seu endereço principal antes de anunciar. Ele é a origem do frete." com o botão "Cadastrar endereço", que leva ao Perfil) | Aviso no modal "Cadastre seu endereço principal antes de anunciar. Ele é a origem do frete." com o botão "Cadastrar endereço", que leva ao Perfil, no estilo do aviso da conta Stripe. Decisão do PO (Felipe, 24/11/2026) | `84`, FA 5; R10; CA8 |
| L13 | O mesmo vendedor pode ter dois anúncios ativos da mesma carta na mesma condição? (proposta: pode; o DBML não tem índice único) | Pode: sem regra de unicidade (o vendedor pode ter preços diferentes para a mesma carta e condição). Decisão do PO (Felipe, 24/11/2026) | Fora do escopo |
| L14 | O Painel do vendedor (`/vendedor`) e a checagem da conta Stripe pronta são da CCD108, ainda fora do `develop` (backend #45, frontend #34). Como seguir? | O backend é feito agora, lendo `users.stripe_account_status` direto; o frontend começa depois que a CCD108 entrar no `develop`, sobre o Painel dela. Decisão do PO (Felipe, 24/11/2026) | Plano (Dependências, Backend); tarefas T5, T8–T12 |
| L15 | A busca do R4 filtra `cards.status`, coluna da CCD106 que ainda não está no `develop`. Como fazer a busca? | Agora filtra só as cartas não excluídas; o filtro `status = ACTIVE` entra quando a CCD106 criar a coluna. O CA3 fica parcial até lá. Decisão do PO (Felipe, 24/11/2026) | Plano (Regras); T3 |
| L16 | O R2 tem três entradas, mas o perfil da carta (CCD030) e a Início (CCD007) ainda não existem no código. O que a T12 faz? | Liga o botão do Painel e expõe o fluxo com a carta escolhida; "Anunciar esta carta" e "Anunciar repetida" chamam o fluxo quando a CCD030 e a CCD007 fizerem as páginas. O CA2 e o CA14 são verificados nelas. Decisão do PO (Felipe, 24/11/2026) | Plano (Frontend); T12 |
| L17 | A descrição é obrigatória? Tem limite? (o DBML usa `text` e o plano fixava 2000 sem origem) | Opcional, até 2000 caracteres. Decisão do PO (Felipe, 24/11/2026) | `84`, FP 2; R3 |
