# CCD082 — Denunciar Anúncio

- **Status:** Rascunho
- **Fase:** Futuro Marketplace (marca `***` na user story; o ADR-027 mantém as denúncias do marketplace fora do MVP)
- **User story:** não encontrada no board
- **Caso de uso:** [82-denunciar-anuncio.md](../../docs/Casos-De-Uso/82-denunciar-anuncio.md)
- **Atores:** Cliente · **Pré-condições:** o cliente está autenticado e na página de detalhes do anúncio
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso denunciar um anúncio para informar à plataforma possíveis irregularidades.

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

> **Fase Futuro Marketplace.** A user story tem a marca `***`, e o ADR-027 (18/11/2026) lista as denúncias do
> marketplace entre o que continua fora do MVP. A spec fica pronta para quando a fase entrar.

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Denunciar exige login: sem token, a API responde `401` | Permissão | `82-denunciar-anuncio.md`, Atores e Pré-condições; ADR-011 |
| R2 | O detalhe do anúncio tem a opção "Denunciar Anúncio" | Ação | `82`, FP 1 |
| R3 | A opção abre um modal que pede o motivo da denúncia | Tela | `82`, FP 2 |
| R4 | O cliente escolhe um motivo numa lista (ex.: fraude, item falso) | Campo | `82`, FP 3; DBML `reports.reason` (obrigatório, até 90 caracteres) |
| R5 | O cliente adiciona uma observação | Campo | `82`, FP 3; DBML `reports.description` (até 500 caracteres) |
| R6 | Ao confirmar, o sistema grava a denúncia em `reports` com `target_type = LISTING`, o `listing_id` do anúncio, o `reporter_id` do cliente, o motivo, a observação e `status = PENDING` | Ação | `82`, FP 4; DBML `reports`; ADR-032 |
| R7 | Depois de gravar, a tela mostra uma mensagem confirmando o envio da denúncia | Mensagem | `82`, FP 4 |
| R8 | Sem motivo, o envio é bloqueado: o campo fica destacado com uma mensagem de erro, e a API, se chamada, responde `400` | Regra | `82`, FA 1–2; ADR-011 |
| R9 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados. Para o modal, vale quando o frame existir (L1) | Fidelidade | Figma (frames da seção Telas; modal a desenhar, L1); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2–R7) — **Dado** um cliente logado no detalhe de um anúncio, **quando** ele clica em "Denunciar Anúncio",
  escolhe o motivo "Fraude", escreve uma observação e confirma, **então** a API responde `201`, `reports` ganha uma linha
  com `target_type = LISTING`, o `listing_id` do anúncio, o `reporter_id` dele e `status = PENDING`, o modal fecha e a tela
  mostra a confirmação do envio.
- **CA2** (R8) — **Dado** o modal aberto, **quando** o cliente confirma sem escolher o motivo, **então** nada é enviado, o
  campo do motivo fica destacado com a mensagem de erro e o modal continua aberto; chamada direta à API sem `reason`
  responde `400` e não grava nada.
- **CA3** (R1) — **Dado** um visitante sem login, **quando** a API recebe a denúncia, **então** responde `401` e não grava nada.
- **CA4** (R6) — **Dado** um anúncio excluído (`deleted_at` preenchido), **quando** o cliente tenta denunciá-lo pela API,
  **então** a API responde `404` e não grava nada.
- **CA5** (R9) — **Dado** o frame do modal "Denunciar Anúncio" desenhado (L1) e a tela implementada aberta em 1280 px com
  os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame, **então** não há diferença
  de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem
  quebra, corte nem rolagem horizontal. O mesmo vale para os frames do erro sem motivo e da confirmação.
- **CA6** (R9) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print do detalhe
  do anúncio com a opção "Denunciar Anúncio" é comparado lado a lado com o frame `1112-5772` (ajustado pela L1), **então**
  não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo
  design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `reports` | `reporter_id`, `listing_id`, `target_type` (`report_target_type`: `LISTING`), `reason`, `description`, `status` (`report_status`: `PENDING`), `created_at` | `reporter_id`, `target_type` e `reason` (até 90) obrigatórios; `description` opcional (até 500); `status` default `PENDING`. Alvo polimórfico: só `listing_id` preenchido (ADR-032) |
| `listings` | `id`, `seller_id`, `deleted_at` | O anúncio denunciado tem de existir |

## Telas (Figma)

O **modal "Denunciar Anúncio" não tem frame no Figma**, e o detalhe do anúncio não tem a opção (L1).

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Público - Detalhe do anúncio (onde entra a opção) | [1112-5772](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-5772) | R2 | ❌ Não bate (sem a opção "Denunciar Anúncio", L1) |
| Modal "Denunciar Anúncio", erro sem motivo e confirmação | falta o desenho (L1) | R3–R8 | ❌ Sem frame |

- **Diferenças com o Figma** (decisão em Lacunas e decisões): Detalhe do anúncio `1112-5772` — não mostra a opção
  "Denunciar Anúncio" que o FP 1 pede (L1).
- **Só no Figma**: nada.
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R2 a opção; R3–R5 o modal; R7 a confirmação;
  R8 o erro sem motivo. O modal "Denunciar @<usuário>" do perfil público (`1160-17495`) é o mais próximo (L1).

## Fora do escopo

- Tratar a denúncia no BackOffice (fila, dispensar, pausar o anúncio, sancionar o vendedor) — não há caso de uso para
  denúncias de anúncio (L4); a CCD062 só modera mensagens de grupo e a CCD099 aplica sanções.
- Denunciar o vendedor — CCD083; denunciar perfil — CCD050.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Falta o desenho no Figma: a opção "Denunciar Anúncio" no detalhe do anúncio, o modal, o erro sem motivo e a confirmação (proposta: reaproveitar o modal "Denunciar @<usuário>" de `1160-17495`, com os motivos do anúncio) | pendente | — |
| L2 | Quais são os motivos? O caso de uso só dá exemplos ("fraude, item falso") | pendente | — |
| L3 | A observação é obrigatória ou opcional? O FP 3 diz "adiciona uma observação", sem dizer se é obrigatória; o modal do perfil (`1160-17495`) usa "Detalhes (opcional)" (proposta: opcional, como `reports.description`) | pendente | — |
| L4 | Quem trata a denúncia de anúncio? O BackOffice só tem a fila de mensagens de grupo (CCD062); `LISTING` não aparece em nenhum caso de uso de moderação | pendente | — |
| L5 | O visitante vê a opção? Se sim, ela abre "Entre para continuar", como "Comprar" (CCD072, FA 1)? | pendente | — |
| L6 | O dono vê a opção no próprio anúncio? (proposta: não; a API responde `422` se ele tentar) | pendente | — |
| L7 | O mesmo cliente pode denunciar o mesmo anúncio mais de uma vez? (proposta: não enquanto a denúncia dele estiver `PENDING` ou `UNDER_REVIEW`; a API responde `409`) | pendente | — |
| L8 | Textos da confirmação e do erro sem motivo não estão na documentação (proposta: os do modal do perfil, quando a L1 for desenhada) | pendente | — |
