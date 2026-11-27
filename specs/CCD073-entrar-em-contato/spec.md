# CCD073 — Entrar em Contato

- **Status:** Em implementação
- **Fase:** MVP (era Futuro Marketplace; puxada para o MVP em 22/11/2026 com as telas já no Figma, ADR-069)
- **User story:** #1366 `CCD073 - Entrar em Contato` (criada em 22/11/2026)
- **Caso de uso:** [73-entrar-em-contato.md](../../docs/Casos-De-Uso/73-entrar-em-contato.md)
- **Atores:** Cliente (e Vendedor, que também compra) · **Pré-condições:** autenticado, visualizando um anúncio ativo de outro usuário
- **Data:** 2026-11-21 (revista em 2026-11-27 com as decisões L1, L2 e L4–L10) · **Autor:** Daniel Andrade
- **Aprovação:** Daniel Andrade, 27/11/2026 (a validar pelo PO)

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

> **Fase MVP** desde 22/11/2026: as telas já estão no Figma, e o Daniel puxou a story para o MVP (ADR-069).

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Entrar em contato exige login: a API responde `401` sem token. O anúncio tem de estar ativo (`listings.status = ACTIVE`, não excluído) e ser de outro usuário: anúncio inexistente ou excluído → `404 LISTING_NOT_FOUND`; não ativo → `422 LISTING_UNAVAILABLE`; o próprio → `422 OWN_LISTING` | Permissão | `73`, Pré-condições e FA 5; ADR-005 (L8) |
| R2 | O detalhe do anúncio tem o botão "Entrar em contato" no quadro do vendedor, à esquerda de "⚑ Denunciar anúncio". Para o visitante, o botão abre o aviso "Entre para continuar" (frame `1112-5461`), como Comprar e Favoritar; no anúncio do próprio cliente, não aparece | Ação | `73`, FP 2 e FA 3–5 (L1, L7, L8) |
| R3 | Ao entrar em contato, Mensagens abre a conversa com o vendedor e o campo de mensagem já preenchido com "Olá! Tenho interesse no anúncio <carta> (<preço>)." (preço no formato `R$ 1.750`), que o cliente pode editar antes de enviar | Campo | `73`, FP 5–6 (L1) |
| R4 | O sistema identifica o vendedor pelo anúncio (`listings.seller_id`) | Regra | `73`, FP 3 |
| R5 | Há uma conversa só por par de usuários: se já existe uma conversa direta entre os dois (vinda da Nova conversa ou de outro anúncio), ela é aberta; senão, é criada (`conversations` com `listing_id` nulo e os dois em `conversation_participants`), como a Nova conversa da CCD046 | Regra | `73`, FP 4 (L5) |
| R6 | A mensagem é enviada pelo campo de Mensagens da CCD046 (`message:send`): é gravada em `messages` com `author_id` = cliente | Regra | `73`, FP 6–7; CCD046 |
| R7 | O vendedor recebe a mensagem em tempo real na conversa (room `user:<id>` da CCD046, com o contador de não lidas). O aviso no sino (`notifications`, tipo `NEW_MESSAGE`) entra com a CCD053 | Regra | `73`, FP 7; ADR-012 (L9) |
| R8 | Se o vendedor está suspenso, bloqueado pela plataforma ou excluído, ou se bloqueou o cliente, o anúncio mostra "Não foi possível iniciar a conversa com este vendedor." e nada é criado (`422 SELLER_UNAVAILABLE`; o bloqueio feito pelo vendedor não é revelado) | Mensagem | `73`, FA 1 (L4, L6) |
| R9 | Se o cliente bloqueou o vendedor, o anúncio mostra "Você bloqueou @<vendedor>. Para conversar de novo, desbloqueie em Configurações › Privacidade." e nada é criado (`403 CONTACT_BLOCKED`) | Regra | `73`, FA 2; `user_blocks`; texto do frame `1160-37184` (L6) |
| R10 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**); o botão segue o do quadro do vendedor de `1112-5772`, no estilo do botão cinza "Favoritar" do mesmo anúncio | Fidelidade | Figma (frames da seção Telas); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |
| R11 | O botão é um componente do chat (`ContactSellerButton`, exportado pelo `index.ts` da feature) que a página do anúncio (CCD079/CCD080) monta passando o anúncio, o vendedor, se o usuário é o dono e a ação de pedir o login | Regra | L10 |

## Critérios de aceite

- **CA1** (R2–R6) — **Dado** o cliente logado no detalhe de um anúncio ativo de outro usuário, sem conversa com o vendedor, **quando** seleciona "Entrar em contato", **então** uma conversa direta com os dois participantes é criada, Mensagens abre essa conversa com o campo preenchido com "Olá! Tenho interesse no anúncio Lionel Messi (R$ 1.750)."; **quando** ele envia, **então** a mensagem é gravada e o vendedor a recebe em tempo real.
- **CA2** (R5) — **Dado** uma conversa já existente entre o cliente e o vendedor (pela Nova conversa ou por outro anúncio), **quando** o cliente entra em contato, **então** Mensagens abre a mesma conversa e nenhuma conversa nova é criada.
- **CA3** (R8) — **Dado** um vendedor suspenso, excluído ou que bloqueou o cliente, **quando** o cliente seleciona "Entrar em contato", **então** a API responde `422 SELLER_UNAVAILABLE`, nada é criado e o anúncio mostra "Não foi possível iniciar a conversa com este vendedor.".
- **CA4** (R9) — **Dado** o cliente que bloqueou o vendedor, **quando** seleciona "Entrar em contato", **então** a API responde `403 CONTACT_BLOCKED`, nada é criado e o anúncio mostra "Você bloqueou @tiago_trocas. Para conversar de novo, desbloqueie em Configurações › Privacidade.".
- **CA5** (R1, R2) — **Dado** uma chamada sem token, **então** recebe `401`; **dado** um anúncio pausado, **então** `422 LISTING_UNAVAILABLE`; excluído ou inexistente, `404 LISTING_NOT_FOUND`; o próprio anúncio, `422 OWN_LISTING` e o botão não aparece; em todos, nada é criado.
- **CA6** (R3) — **Dado** a API fora do ar, **quando** o cliente seleciona "Entrar em contato", **então** ele continua no anúncio, vê "Não foi possível abrir a conversa. Tente de novo." e o botão volta a ficar disponível.
- **CA7** (R10) — **Dado** a conversa aberta pelo "Entrar em contato" em 1280 px com os mesmos dados do frame, **quando** o print é comparado lado a lado com o print do frame `1160-32980`, **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem além do texto sugerido no campo; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- ~~**CA8**~~ removido: o bloqueio é avisado no anúncio, e não na conversa do frame `1160-37184` (L4, L6).
- **CA9** (R2) — **Dado** um visitante sem login no detalhe do anúncio, **quando** seleciona "Entrar em contato", **então** vê o aviso "Entre para continuar" e nada é chamado na API.
- **CA10** (R2, R10) — **Dado** o botão montado no quadro do vendedor, **quando** a tela é aberta em 375, 768, 1024 e 1280 px, **então** "Entrar em contato" fica à esquerda de "⚑ Denunciar anúncio", no estilo do botão "Favoritar", sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `listings` | `id`, `seller_id`, `status`, `deleted_at` | anúncio ativo e vendedor |
| `users` | `id`, `status`, `role`, `deleted_at` | vendedor disponível (a regra `reachableBy` da CCD046) |
| `conversations` | `id`, `listing_id` | conversa direta: `listing_id` nulo (L5); a coluna fica no DER para uso futuro |
| `conversation_participants` | `conversation_id`, `user_id` | chave composta |
| `messages` | `conversation_id`, `author_id`, `content`, `is_read` | gravada pelo envio da CCD046 |
| `user_blocks` | `blocker_id`, `blocked_id`, `deleted_at` | bloqueio nos dois sentidos |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Mensagens — conversas | [1160-32980](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-32980) | R3, R5, R6 | ✅ A conversa aberta é a da CCD046; o texto sugerido entra no campo (L1) |
| Detalhe do anúncio | [1112-5772](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-5772) | R2, R8, R9, R10 | ✅ O botão "Entrar em contato" (`1344:381`) entrou no quadro do vendedor, à esquerda de "⚑ Denunciar anúncio", no estilo de "Favoritar", em 27/11/2026 (L1). A página é da CCD079/CCD080 (L10) |
| Entre para continuar | [1112-5461](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1112-5461) | R2 | ✅ O mesmo aviso de Comprar e Favoritar (L7) |

- Textos de `1160-32980`: "Dica de segurança", "Nunca pague por Pix ou link fora da CromoCard. Compre pelo anúncio no marketplace: o pagamento fica retido até a entrega.", "Digite sua mensagem para @marcos_tcg...", "Enviar", "Faça compras e pagamentos só pelo marketplace da CromoCard."
- Textos de `1112-5772` no quadro do vendedor: "tiago_trocas", "São Paulo - SP", "⚑ Denunciar anúncio".
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): os avisos de vendedor indisponível (R8), de bloqueio feito pelo cliente (R9) e de erro ao abrir a conversa (CA6), abaixo do botão, no quadro do vendedor.

## Fora do escopo

- Listar conversas, responder e ver mensagens — CCD045 e CCD046; bloquear e denunciar — CCD047.
- A página do detalhe do anúncio e o quadro do vendedor — CCD079 e CCD080 (L10); o aviso "Entre para continuar" — CCD030.
- O aviso no sino para mensagem nova — CCD053 (L9).
- Comprar — CCD072.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Falta o desenho de "Entrar em contato" no detalhe do anúncio (`1112-5772`). O botão abre Mensagens com a conversa ou uma caixa de mensagem no próprio anúncio? Onde fica? | Abre Mensagens com a conversa e o texto sugerido "Olá! Tenho interesse no anúncio <carta> (<preço>).", editável; o botão fica no quadro do vendedor, à esquerda de "Denunciar anúncio" (decisão do Daniel em 27/11/2026) | `73-entrar-em-contato.md`, FP 2 e 4–6 |
| L2 | A user story "Conversar com Vendedor" (`***`, seção 2 de `user-stories.md`) tem o mesmo objetivo. É a mesma story? | É a mesma: anotada como atendida pela CCD073 (decisão do Daniel em 27/11/2026) | `user-stories.md` e `resumo-user-stories.md` |
| L3 | Fase: a story é Futuro Marketplace, mas o Figma de Mensagens já mostra conversas sobre anúncios ("Te mandei o link do anúncio"). Continua fora do MVP? | Entra no MVP (decisão do Daniel em 22/11/2026) | ADR-069 |
| L4 | O que é "vendedor não disponível para contato"? A regra dos "desconhecidos" de `1160-34999` vale? Qual o texto do aviso? | Conta suspensa, bloqueada pela plataforma ou excluída, ou vendedor que bloqueou o cliente: "Não foi possível iniciar a conversa com este vendedor." A regra dos desconhecidos saiu do Figma em 24/11/2026 e não vale (decisão do Daniel em 27/11/2026) | `73-entrar-em-contato.md`, FA 1 |
| L5 | Já existe uma conversa entre os dois sem anúncio ou sobre outro anúncio: reaproveita ou cria uma conversa por anúncio? | Uma conversa por par de usuários: reaproveita a que existe, como a Nova conversa da CCD046 (decisão do Daniel em 27/11/2026) | `73-entrar-em-contato.md`, FP 4 |
| L6 | Texto para quem foi bloqueado pelo vendedor: só o caso "Você bloqueou" está desenhado | Quem foi bloqueado vê o aviso de vendedor indisponível (L4), sem revelar o bloqueio; quem bloqueou vê "Você bloqueou @<vendedor>. Para conversar de novo, desbloqueie em Configurações › Privacidade.", no anúncio (decisão do Daniel em 27/11/2026) | `73-entrar-em-contato.md`, FA 1–2 |
| L7 | Visitante que seleciona "Entrar em contato": vê "Entre para continuar", como em "Comprar" (CCD072, R15)? | Sim, o aviso de `1112-5461` (decisão do Daniel em 27/11/2026) | `73-entrar-em-contato.md`, FA 3–4 |
| L8 | No anúncio do próprio cliente, o botão não aparece? | Não aparece, e a API responde `422 OWN_LISTING` (decisão do Daniel em 27/11/2026) | `73-entrar-em-contato.md`, FA 5 |
| L9 | O caso de uso pede notificar o vendedor (FP 7), mas a central de notificações da CCD053 ainda não existe | O vendedor é avisado pelo chat em tempo real; o aviso no sino (`NEW_MESSAGE`) entra com a CCD053 para toda mensagem nova (decisão do Daniel em 27/11/2026) | Esta spec, R7 e Fora do escopo |
| L10 | A página do anúncio (CCD079/CCD080, do Lucas) ainda não existe. Esperar por ela? | Fazer agora o backend e o botão como componente do chat; a página do anúncio monta o botão quando existir (decisão do Daniel em 27/11/2026) | Esta spec, R11 |
