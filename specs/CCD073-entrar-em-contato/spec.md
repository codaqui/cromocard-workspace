# CCD073 — Entrar em Contato

- **Status:** Rascunho
- **Fase:** Futuro Marketplace
- **User story:** não encontrada no board
- **Caso de uso:** [73-entrar-em-contato.md](../../docs/Casos-De-Uso/73-entrar-em-contato.md)
- **Atores:** Cliente · **Pré-condições:** autenticado, visualizando um anúncio ativo
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso entrar em contato com o vendedor pelo chat para negociar e tirar dúvidas.

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

> **Fase Futuro Marketplace** (`***` em `user-stories.md`): fica fora da fatia mínima do marketplace que entrou no MVP
> (ADR-027). A spec existe para quando o PO puxar a story (L3).

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Entrar em contato exige login: a API responde `401` sem token; o anúncio tem de estar ativo (`listings.status = ACTIVE`, não excluído) | Permissão | `73`, Pré-condições; ADR-005 (L7, L8) |
| R2 | O detalhe do anúncio tem a opção "Entrar em contato" | Ação | `73`, FP 1–2 (L1) |
| R3 | O cliente digita e envia uma mensagem ao vendedor | Campo | `73`, FP 3 |
| R4 | O sistema identifica o vendedor pelo anúncio (`listings.seller_id`) | Regra | `73`, FP 4 |
| R5 | O sistema cria ou abre a conversa entre o cliente e o vendedor (`conversations` com `listing_id` do anúncio e os dois em `conversation_participants`) | Regra | `73`, FP 5; DBML `conversations.listing_id` (L5) |
| R6 | A mensagem é gravada em `messages` (`author_id` = cliente) e enviada | Regra | `73`, FP 6; DBML `messages` |
| R7 | O vendedor é notificado da mensagem nova: em tempo real na conversa e no aviso pessoal (`message:send`, `notification:new` na room `user:<id>`) | Regra | `73`, FP 7; ADR-012 (Convenções) |
| R8 | Se o vendedor não está disponível para contato, o sistema informa que não foi possível iniciar a conversa | Mensagem | `73`, FA 1 (L4) |
| R9 | Se o cliente bloqueou o vendedor ou foi bloqueado por ele (`user_blocks`, nos dois sentidos), a mensagem não é enviada | Regra | `73`, FA 2; DBML `user_blocks` (L6) |
| R10 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados. Vale também para o botão "Entrar em contato" quando o frame dele existir (L1) | Fidelidade | Figma (frames da seção Telas); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2–R7) — **Dado** o cliente logado no detalhe de um anúncio ativo de outro usuário, sem conversa com o vendedor, **quando** seleciona "Entrar em contato", digita "A carta tem marcas no verso?" e envia, **então** uma conversa com o `listing_id` do anúncio e os dois participantes é criada, a mensagem é gravada, o cliente vê a conversa em Mensagens e o vendedor recebe a mensagem e o aviso em tempo real.
- **CA2** (R5) — **Dado** uma conversa já existente sobre o mesmo anúncio, **quando** o cliente entra em contato de novo, **então** a mensagem vai para a mesma conversa e nenhuma conversa nova é criada.
- **CA3** (R8) — **Dado** um vendedor indisponível para contato (L4), **quando** o cliente tenta enviar, **então** vê que não foi possível iniciar a conversa e nada é gravado.
- **CA4** (R9) — **Dado** o cliente que bloqueou o vendedor, ou foi bloqueado por ele, **quando** tenta enviar, **então** a API recusa (`403`), nada é gravado e a tela mostra o aviso de contato bloqueado.
- **CA5** (R1) — **Dado** uma chamada sem token, **quando** tenta enviar, **então** recebe `401`; **dado** um anúncio pausado ou excluído, **então** a API responde `422` ou `404` e nada é gravado.
- **CA6** (R6) — **Dado** a falha ao gravar a mensagem, **quando** o cliente envia, **então** nada é emitido ao vendedor e a tela avisa o erro, mantendo o texto digitado (ADR-012, persistência primeiro).
- **CA7** (R10) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-32980`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA8** (R10) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-37184`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `listings` | `id`, `seller_id`, `status`, `deleted_at` | anúncio ativo e vendedor |
| `conversations` | `id`, `listing_id` | `listing_id` preenchido quando a conversa nasce de um anúncio |
| `conversation_participants` | `conversation_id`, `user_id` | chave composta |
| `messages` | `conversation_id`, `author_id`, `content`, `is_read` | `is_read` default `false` |
| `user_blocks` | `blocker_id`, `blocked_id`, `deleted_at` | único por par |
| `notifications` | `user_id`, `title`, `message`, `type`, `reference_link` | aviso ao vendedor (tipo novo, ADR-051, item 2) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Mensagens — conversas | [1160-32980](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-32980) | R5, R6 | ⚠️ Conversa aberta; o caminho a partir do anúncio não está desenhado (L1) |
| Mensagens — contato bloqueado | [1160-37184](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-37184) | R9 | ⚠️ Só o caso "Você bloqueou" (L6) |
| Detalhe do anúncio com "Entrar em contato" | **falta o desenho no Figma** (L1) | R2, R3 | ❌ O detalhe do anúncio (`1112-5772`) não tem a opção |

- Textos de `1160-32980`: "Dica de segurança", "Nunca pague por Pix ou link fora da CromoCard. Compre pelo anúncio no marketplace: o pagamento fica retido até a entrega.", "Digite sua mensagem para @marcos_tcg...", "Enviar", "Faça compras e pagamentos só pelo marketplace da CromoCard."
- Texto de `1160-37184`: "Você bloqueou @marcos_tcg. Para conversar de novo, desbloqueie em Configurações › Privacidade."
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R2 e R3 o botão e a caixa da mensagem a partir do anúncio; R8 o aviso de vendedor indisponível; o aviso de quem foi bloqueado pelo vendedor (L6).

## Fora do escopo

- Listar conversas, responder e ver mensagens — CCD045 e CCD046; bloquear e denunciar — CCD047.
- Comprar — CCD072.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Falta o desenho de "Entrar em contato" no detalhe do anúncio (`1112-5772`). O botão abre Mensagens com a conversa ou uma caixa de mensagem no próprio anúncio? | pendente | — |
| L2 | A user story "Conversar com Vendedor" (`***`, seção 2 de `user-stories.md`) tem o mesmo objetivo. É a mesma story? | pendente | — |
| L3 | Fase: a story é Futuro Marketplace, mas o Figma de Mensagens já mostra conversas sobre anúncios ("Te mandei o link do anúncio"). Continua fora do MVP? | pendente | — |
| L4 | O que é "vendedor não disponível para contato" (conta suspensa, bloqueada ou excluída)? A regra de `1160-34999`, "🔒 Só é possível conversar com quem aceita mensagens de desconhecidos ou participa de um grupo com você.", vale para o contato pelo anúncio? Qual o texto do aviso? | pendente | — |
| L5 | Já existe uma conversa entre os dois sem anúncio ou sobre outro anúncio: reaproveita ou cria uma conversa por anúncio? | pendente | — |
| L6 | Texto para quem foi bloqueado pelo vendedor: só o caso "Você bloqueou" está desenhado | pendente | — |
| L7 | Visitante que seleciona "Entrar em contato": vê "Entre para continuar", como em "Comprar" (CCD072, R15)? | pendente | — |
| L8 | No anúncio do próprio cliente, o botão não aparece? | pendente | — |
