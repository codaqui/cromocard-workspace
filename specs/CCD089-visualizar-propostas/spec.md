# CCD089 — Visualizar Propostas

- **Status:** Rascunho
- **Fase:** Futuro Marketplace (o ADR-027 mantém propostas e trocas fora do MVP; a user story, no Painel Vendedor, não tem a marca `***`: ver L1)
- **User story:** #348 `CCD089-Visualizar Propostas`
- **Caso de uso:** [89-visualizar-propostas.md](../../docs/Casos-De-Uso/89-visualizar-propostas.md)
- **Atores:** Vendedor · **Pré-condições:** o vendedor recebeu ao menos uma proposta em seus anúncios
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Vendedor preciso visualizar propostas recebidas para analisar as condições oferecidas pelos compradores.

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

> **Fase Futuro Marketplace.** O ADR-027 (18/11/2026) lista "propostas e trocas" entre o que continua fora do MVP, e o
> `escopo-adicional.md` (seção 3) diz que as telas de propostas recebidas foram para o Arquivo do Figma e saíram do menu.
> A user story não tem a marca `***` (L1). A spec fica pronta para quando a fase entrar.

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só o vendedor autenticado vê propostas: sem token, `401`; papel diferente de `SELLER`, `403` | Permissão | `89-visualizar-propostas.md`, Atores; ADR-011 |
| R2 | O vendedor só vê as propostas feitas nos próprios anúncios; a proposta de outro vendedor responde `404` | Regra | `89`, Finalidade ("propostas recebidas"); DBML `offers.listing_id` → `listings.seller_id`; ADR-011 |
| R3 | O vendedor chega à lista pelo menu "Propostas Recebidas" ou pelas notificações | Ação | `89`, FP 1 |
| R4 | A lista mostra as propostas ativas, cada uma com o valor, a data e o usuário que propôs | Tela | `89`, FP 2; DBML `offers.offered_amount`, `offers.created_at`, `offers.buyer_id`, `offers.status` |
| R5 | Clicar numa proposta abre os detalhes dela | Ação | `89`, FP 3 |
| R6 | Os detalhes abrem a interface de negociação, com as opções de aceitar e recusar a proposta | Tela | `89`, FP 4; DBML `offer_status` (`ACCEPTED`, `REJECTED`) |
| R7 | Sem propostas ativas, a tela mostra "Você não tem novas propostas no momento" | Mensagem | `89`, FA 1 |
| R8 | Enquanto carrega, a tela mostra o estado de carregamento; se a API falha, mostra a mensagem de erro que a API devolve | Estado | ADR-041 (erros e estado do servidor) |
| R9 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados. Vale quando o frame existir (L2) | Fidelidade | Figma (frames da seção Telas, a desenhar, L2); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R3, R4) — **Dado** um vendedor com 2 propostas `PENDING` e 1 `REJECTED` nos seus anúncios, **quando** ele abre
  "Propostas Recebidas", **então** a API responde `200` e a lista mostra só as 2 ativas, cada uma com o valor, a data e o
  usuário.
- **CA2** (R5, R6) — **Dado** a lista do CA1, **quando** o vendedor clica numa proposta, **então** abre a interface de
  negociação com os detalhes dela e as opções de aceitar e recusar.
- **CA3** (R7) — **Dado** um vendedor sem propostas ativas, **quando** ele abre "Propostas Recebidas", **então** vê "Você
  não tem novas propostas no momento".
- **CA4** (R1) — **Dado** um visitante sem login, **quando** pede a lista, **então** a API responde `401`; **dado** um
  `CUSTOMER`, **então** responde `403`.
- **CA5** (R2) — **Dado** a proposta feita no anúncio de outro vendedor, **quando** o vendedor pede os detalhes dela pela
  API, **então** a resposta é `404`.
- **CA6** (R3) — **Dado** uma notificação de proposta nova, **quando** o vendedor clica nela, **então** abre a lista (ou os
  detalhes da proposta, conforme a L6).
- **CA7** (R8) — **Dado** a API lenta, **quando** o vendedor abre a lista, **então** a tela mostra o carregamento; **dado** a
  API fora do ar, **então** a tela mostra a mensagem de erro.
- **CA8** (R9) — **Dado** os frames de "Propostas Recebidas" desenhados (L2) e a tela implementada aberta em 1280 px com os
  mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print de cada frame (lista, detalhes e lista
  vazia), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e
  1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `offers` | `id`, `listing_id`, `buyer_id`, `offered_amount`, `message`, `status` (`offer_status`: `PENDING`, `ACCEPTED`, `REJECTED`, `EXPIRED`), `created_at`, `deleted_at` | `listing_id`, `buyer_id` e `offered_amount` obrigatórios; `status` default `PENDING`; `message` opcional, até 255 caracteres (L8) |
| `listings` | `id`, `seller_id`, `card_id`, `price` | Liga a proposta ao vendedor (R2) |
| `users` | `username` | O usuário que propôs (L7) |
| `notifications` | `type`, `reference_link` | Acesso pelas notificações (R3, L6) |

## Telas (Figma)

Esta user story **não tem frame no Figma**. As telas de propostas recebidas foram para o Arquivo em 20/11/2026, e o item
"Propostas" saiu do menu do vendedor (`escopo-adicional.md`, seção 3 e seção 4, "Revisão profunda da Área do Cliente").

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Propostas Recebidas: lista, detalhes com aceitar e recusar, lista vazia | falta o desenho (L2) | R3–R8 | ❌ Sem frame |

- **Diferenças com o Figma** (decisão em Lacunas e decisões): o menu do vendedor (ex.: `492-2007`, `675-1452`) não tem o
  item "Propostas Recebidas" que o FP 1 pede (L2).
- **Só no Figma**: nada.
- **O que falta no Figma** (implementar mesmo assim, no estilo do Painel do vendedor): R3–R8, todas as telas.

## Fora do escopo

- Fazer uma proposta num anúncio (comprador) — não há caso de uso (L3).
- O efeito de aceitar ou recusar (pedido, preço, estoque, aviso ao comprador) — sem caso de uso (L4).
- Denunciar o usuário pela proposta — escopo adicional fora do MVP (`escopo-adicional.md`, seção 3); denunciar usuário é a CCD090.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Fase: a user story não tem a marca `***` (Painel Vendedor), mas o ADR-027 e o `escopo-adicional.md` tiram propostas do MVP. Confirmar Futuro Marketplace e pôr a marca `***` na user story? | pendente | — |
| L2 | Falta o desenho da tela no Figma (as telas antigas estão no Arquivo): lista, detalhes com aceitar e recusar, lista vazia e o item "Propostas Recebidas" no menu do vendedor | pendente | — |
| L3 | Não há caso de uso para o comprador fazer uma proposta; sem ele, `offers` fica vazia. Criar o caso de uso? | pendente | — |
| L4 | O que acontece ao aceitar ou recusar? Aceitar cria um pedido pelo valor proposto (checkout da CCD072)? Reserva o estoque? Avisa o comprador? É desta story ou de uma nova? | pendente | — |
| L5 | "Propostas ativas" são só as `PENDING`? Quando uma proposta vira `EXPIRED`? O DBML não tem prazo (`expires_at`) | pendente | — |
| L6 | Qual notificação leva às propostas (tipo em `notifications.type`) e para onde ela aponta: a lista ou a proposta? Quem gera a notificação? | pendente | — |
| L7 | "Usuário" na lista é o nome de usuário (@) do comprador? Clicar nele abre o perfil público (CCD080)? | pendente | — |
| L8 | A mensagem do comprador (`offers.message`) e os dados do anúncio (carta, preço pedido) aparecem na lista ou nos detalhes? A documentação não diz | pendente | — |
| L9 | A pré-condição exige ao menos uma proposta, mas o FA 1 trata a lista vazia. Tirar a pré-condição? (proposta: sim; a lista vazia é o FA 1) | pendente | — |
