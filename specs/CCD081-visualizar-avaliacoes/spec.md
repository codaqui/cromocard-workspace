# CCD081 — Visualizar Avaliações

- **Status:** Rascunho
- **Fase:** Futuro Marketplace (marca `***` na user story; o ADR-027 mantém as avaliações fora do MVP)
- **User story:** não encontrada no board
- **Caso de uso:** [81-visualizar-avaliacoes.md](../../docs/Casos-De-Uso/81-visualizar-avaliacoes.md)
- **Atores:** Cliente · **Pré-condições:** o cliente está autenticado e na página de um anúncio ou no perfil do vendedor
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso visualizar as avaliações do vendedor para avaliar sua reputação na plataforma.

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

> **Fase Futuro Marketplace.** A user story tem a marca `***`, e o ADR-027 (18/11/2026) lista as avaliações entre o que
> continua fora do MVP. O EA-080-01 também tirou a nota do perfil público. A spec fica pronta para quando a fase entrar.

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Ver as avaliações exige login: sem token, a API responde `401` | Permissão | `81-visualizar-avaliacoes.md`, Atores e Pré-condições; ADR-011 |
| R2 | A página do anúncio e o perfil do vendedor têm a seção "Avaliações" do vendedor, que o cliente abre com um clique | Ação | `81`, FP 1; Pré-condições |
| R3 | O sistema busca o histórico de avaliações recebidas pelo vendedor e calcula a nota média | Regra | `81`, FP 2; DBML `reviews.seller_id`, `reviews.rating` |
| R4 | A seção mostra a nota consolidada do vendedor | Campo | `81`, FP 3; DBML `reviews.rating` (1 a 5) |
| R5 | A seção lista os comentários dos compradores | Tela | `81`, FP 3; DBML `reviews.comment`, `reviews.author_id`, `reviews.created_at` |
| R6 | Vendedor sem nenhuma venda avaliada: a seção mostra "Este vendedor ainda não possui avaliações" | Mensagem | `81`, FA 1 |
| R7 | Enquanto carrega, a seção mostra o estado de carregamento; se a API falha, mostra a mensagem de erro que a API devolve | Estado | ADR-041 (erros e estado do servidor) |
| R8 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados. Vale quando o frame existir (L1) | Fidelidade | Figma (frames da seção Telas, a desenhar, L1); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2–R5) — **Dado** um vendedor com 3 avaliações (notas 5, 4 e 3, duas com comentário), **quando** o cliente logado
  abre a seção "Avaliações" no anúncio dele, **então** a API responde `200` e a tela mostra a nota consolidada 4 e a lista
  com os comentários dos compradores.
- **CA2** (R2) — **Dado** o perfil público do mesmo vendedor, **quando** o cliente abre a seção "Avaliações", **então** vê a
  mesma nota e a mesma lista do CA1.
- **CA3** (R6) — **Dado** um vendedor sem avaliações, **quando** o cliente abre a seção, **então** vê "Este vendedor ainda não
  possui avaliações".
- **CA4** (R1) — **Dado** um visitante sem login, **quando** a tela pede as avaliações, **então** a API responde `401` e a
  tela não mostra a lista.
- **CA5** (R7) — **Dado** a API lenta, **quando** o cliente abre a seção, **então** a tela mostra o carregamento; **dado** a
  API fora do ar, **então** a tela mostra a mensagem de erro.
- **CA6** (R8) — **Dado** o frame da seção "Avaliações" desenhado (L1) e a tela implementada aberta em 1280 px com os mesmos
  dados do frame, **quando** o print dela é comparado lado a lado com o print do frame, **então** não há diferença de
  layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem
  quebra, corte nem rolagem horizontal. O mesmo vale para o frame do estado sem avaliações.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `reviews` | `order_id`, `author_id`, `seller_id`, `rating`, `comment`, `created_at`, `deleted_at` | `order_id` obrigatório e único (uma avaliação por pedido); `rating` obrigatório, de 1 a 5; `comment` opcional, até 500 caracteres |
| `users` | `username` | Nome de quem avaliou, se a L5 decidir mostrá-lo |

## Telas (Figma)

Esta user story **não tem frame no Figma**. As telas de avaliações recebidas do vendedor foram para o Arquivo em
20/11/2026, o item "Avaliações" saiu do menu do vendedor, e o detalhe do anúncio (`1112-5772`) e o perfil público
(`1160-1396`) não têm a seção (L1).

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Seção "Avaliações" no anúncio e no perfil do vendedor | falta o desenho (L1) | R2–R8 | ❌ Sem frame |

- **Diferenças com o Figma** (decisão em Lacunas e decisões): o perfil público `1160-1396` e o anúncio `1112-5772` não
  mostram avaliação nenhuma, por decisão do EA-080-01 e do ADR-027 (L1).
- **Só no Figma**: nada.
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R2–R7, toda a seção.

## Fora do escopo

- Avaliar o vendedor depois da compra (criar a avaliação) — não há caso de uso (L3).
- Ordenar anúncios por avaliações — CCD070 (Futuro Marketplace).
- Nota média junto dos dados do vendedor — CCD080, FP 3 (suspensa pela L2 da CCD080).
- "Avaliações" recebidas no Painel do vendedor — escopo adicional fora do MVP (`escopo-adicional.md`, seção 3).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Falta o desenho da tela no Figma: a seção "Avaliações" no anúncio e no perfil do vendedor, com o estado sem avaliações. Quem desenha e quando, já que a fase é Futuro Marketplace? | pendente | — |
| L2 | Fase: a marca `***` e o ADR-027 dizem Futuro Marketplace, mas o caso de uso 80 (FP 3, fase MVP) mostra a nota média junto dos dados do vendedor. Confirmar que a nota só entra com esta story? | pendente | — |
| L3 | Não há caso de uso para o comprador avaliar o vendedor; sem ele, `reviews` fica vazia. Criar o caso de uso (ex.: avaliar depois de confirmar o recebimento, CCD110)? | pendente | — |
| L4 | O visitante vê as avaliações? A CCD080 abre os dados do vendedor sem login; a CCD081 exige login (proposta: manter o login, como o caso de uso) | pendente | — |
| L5 | O que cada item da lista mostra além do comentário: nome de usuário de quem avaliou, nota, data, carta comprada? E avaliação sem comentário entra na lista? | pendente | — |
| L6 | Formato da nota consolidada (casas decimais, estrelas, total de avaliações), ordem da lista e paginação (proposta: uma casa decimal com o total, mais recentes primeiro, 10 por vez) | pendente | — |
