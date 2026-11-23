# CCD044 — Interagir no Chat do Grupo

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #147 `CCD044 - Interagir no Chat do Grupo`
- **Caso de uso:** [44-interagir-no-chat-do-grupo.md](../../docs/Casos-De-Uso/44-interagir-no-chat-do-grupo.md)
- **Atores:** Cliente · **Pré-condições:** usuário autenticado e membro do grupo
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso utilizar o chat de texto do grupo para conversar com outros membros, divulgar as cartas que procuro e combinar informalmente horários e locais para trocas presenciais.

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
| R1 | Ler e enviar mensagens exige login e ser membro do grupo: na API, sem token `401` e não membro `403`; no Socket.IO, o token vai no handshake (`auth: { token }`) e só membro entra na room `group:<id>` | Permissão | `44`, Pré-condições; ADR-005, itens 4 e 5; ADR-012 (Autenticação e Rooms) |
| R2 | A tela do grupo carrega o histórico de mensagens em ordem cronológica | Tela | `44`, FP 1–2 |
| R3 | O histórico é paginado por cursor (`?cursor=<id>&limit=50`, `meta.nextCursor`) | Regra | ADR-011 (paginação por cursor) |
| R4 | O membro digita uma mensagem de texto no campo e envia | Ação | `44`, FP 3 |
| R5 | A mensagem é gravada primeiro e só depois emitida em tempo real para todos os membros: o cliente envia `group-message:send`, o servidor valida o payload com o Zod do domínio, grava e emite `group-message:new` na room `group:<id>`; se a gravação falhar, nada é emitido e o ack devolve o erro | Regra | `44`, FP 4; ADR-012 (Eventos e Persistência primeiro) |
| R6 | Pelos ícones de ação do chat, o membro compartilha imagens, cartas da coleção e anúncios do marketplace e cria enquetes | Ação | `44`, FP 5; DBML `group_messages.content_type`, `card_id`, `listing_id`, `attachment_url`; `polls`, `poll_options` (L1) |
| R7 | Cada tipo aparece formatado na conversa: preview de carta, card de anúncio e enquete | Tela | `44`, FP 6; DBML `message_content_type` (L1) |
| R8 | Se o grupo tem mensagem fixada, o topo do chat mostra o indicador de mensagem fixada | Estado | `44`, FA 1; DBML `group_messages.pinned` |
| R9 | Conteúdo que viola as regras do grupo é bloqueado e a tela informa a violação | Regra | `44`, FA 2 (L2) |
| R10 | No grupo suspenso, os membros só leem: o envio é recusado. O grupo excluído some para todos | Regra | `62`, FP 8; ADR-015, item 6 |
| R11 | Mensagens excluídas (inclusive as removidas pela moderação) não aparecem no histórico nem chegam em tempo real | Regra | ADR-015, item 5; `62`, FP 13 |
| R12 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (`675-14037`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

Tipos: Tela · Campo · Ação · Regra · Permissão · Mensagem · Estado · Fidelidade.

## Critérios de aceite

- **CA1** (R2, R3) — **Dado** um membro e um grupo com 120 mensagens, **quando** ele abre a tela do grupo, **então** vê
  as 50 mais recentes em ordem cronológica e, ao rolar para cima, as anteriores carregam pelo `nextCursor`.
- **CA2** (R4, R5) — **Dado** dois membros com a tela do grupo aberta, **quando** um envia "Alguém tem Charizard?",
  **então** a mensagem é gravada em `group_messages` com `content_type = TEXT`, o ack devolve o id e o outro membro a vê
  na hora, sem recarregar.
- **CA3** (R5) — **Dado** uma falha ao gravar, **quando** o membro envia, **então** nenhum `group-message:new` é emitido,
  o ack devolve o erro e a tela avisa que a mensagem não foi enviada.
- **CA4** (R6, R7) — Para os tipos que a L1 aceitar: **dado** um membro, **quando** ele compartilha pelo ícone de ação,
  **então** a mensagem é gravada com o `content_type` e a referência certos (`card_id`, `listing_id` ou `polls`) e aparece
  formatada para todos.
- **CA5** (R8) — **Dado** um grupo com uma mensagem `pinned = true`, **quando** o membro abre o chat, **então** o topo
  mostra o indicador da fixada com o texto dela; **dado** nenhuma fixada, **então** o indicador não aparece.
- **CA6** (R9) — **Dado** uma mensagem que viola as regras, como a L2 definir, **quando** o membro envia, **então** ela
  não é gravada nem emitida e a tela informa a violação.
- **CA7** (R10) — **Dado** um grupo suspenso, **quando** um membro abre o chat, **então** vê o histórico; **quando**
  tenta enviar, **então** o envio é recusado e nada é gravado.
- **CA8** (R11) — **Dado** uma mensagem removida pela moderação, **quando** um membro abre ou recarrega o chat, **então**
  ela não aparece.
- **CA9** (R1) — **Dado** um visitante sem login, **quando** chama o histórico, **então** a API responde `401` e o
  handshake do Socket.IO é recusado; **dado** um usuário logado que não é membro, **então** o histórico responde `403` e
  ele não entra na room do grupo.
- **CA10** (R12) — **Dado** a tela do grupo aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é
  comparado lado a lado com o print do frame `675-14037`, **então** não há diferença de layout, medida, espaçamento, cor,
  fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem
  horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `group_messages` | `id`, `group_id`, `author_id`, `reply_to_id`, `card_id`, `listing_id`, `content_type` (`message_content_type`: `TEXT`, `IMAGE`, `CARD`, `LISTING`, `POLL`), `content`, `attachment_url`, `pinned`, `created_at`, `deleted_at` | `content_type` default `TEXT`; `pinned` default `false`; soft delete (ADR-015) |
| `polls` | `group_message_id`, `question`, `multiple_choice`, `closes_at` | se a L1 aceitar enquete; `group_message_id` único; `question` obrigatória (255) |
| `poll_options` | `poll_id`, `text` | `text` obrigatório (160) |
| `poll_votes` | `poll_option_id`, `user_id` | chave `(poll_option_id, user_id)`; sem `deleted_at` útil: voto definitivo (ADR-015, item 4) |
| `groups` | `name`, `description`, `access_type`, `status` (`group_status`: `SUSPENDED`), `deleted_at` | cabeçalho e "Sobre o grupo"; suspenso só leitura (R10) |
| `group_members` | `group_id`, `user_id`, `role`, `deleted_at` | membro (R1) e quantidade de membros no cabeçalho |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Comunidade - chat do grupo | [675-14037](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=675-14037) | R2, R4, R5, R8 | ❌ Não bate: sem os ícones de ação de imagem, carta, anúncio e enquete (L1); reações (L3); resposta citada (L4); aviso de entrada (L5); "✓✓" (L6); online (L7); hashtags e regras (L8); "FIXADA POR" (L15 da CCD043) |

- **Diferenças com o Figma** (decisão em Lacunas e decisões):
  - Chat do grupo — o campo "Mensagem para Pokémon TCG São Paulo..." só tem "Enviar"; o `44` FP 5 pede ícones de ação
    para imagens, cartas, anúncios e enquetes (L1).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões):
  - Chat do grupo — reações nas mensagens ("🔥 4", "👀 2", "👍 6") (L3).
  - Chat do grupo — mensagem que responde citando outra (bloco "Marcos Vinicius — Tenho sim! Levo no encontro de sábado.") (L4).
  - Chat do grupo — aviso "@lucas_trader entrou no grupo" (L5) e "14:07 ✓✓" na própria mensagem (L6).
  - Chat do grupo — "184 membros • 28 online • você é Admin" e o painel "Online agora (28)" com "Ver todos" e a função de
    cada um (L7); selos "Moderador" e "Admin" ao lado do nome (L8 da CCD043).
  - Chat do grupo — painel "Sobre o grupo" com hashtags ("#Trocas", "#PokémonTCG", "#SP"), "Compartilhar" e "Regras" (L8).
  - Chat do grupo — menu "⋯" no topo (L11).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela):
  - R6, R7 — os ícones de ação e os formatos de carta, anúncio e enquete (se a L1 os aceitar).
  - R9 — o aviso de conteúdo bloqueado (L2).
  - R10 — o aviso de grupo suspenso, só leitura.
  - Estados sem mensagens, carregando, erro de envio e reconexão (L13).

## Fora do escopo

- Pesquisar no histórico (ícone "⌕") — CCD042.
- Silenciar (ícone do sino) — CCD041.
- Membros e administração (ícone de pessoas), fixar mensagens — CCD043.
- Denunciar mensagem — CCD040.
- Compartilhar o grupo (botão "Compartilhar" do painel) — CCD039.
- Status de leitura ("✓✓") — "Visualizar Status de Leitura" (`**`, Futuro).
- Enviar carta, localização e anexo no grupo e agendar encontro de troca — `escopo-adicional.md`, seção 3 (`**`) e
  "Compartilhar Cartas" e "Compartilhar Imagens" (`**`, Futuro) na seção 4 das user stories (L1).
- Chat pessoal — CCD045–CCD047.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O que entra no MVP do `44` FP 5–6? "Compartilhar Cartas" e "Compartilhar Imagens" são `**` (Futuro) nas user stories e o `escopo-adicional.md`, seção 3, tira enviar carta e anexo no grupo; o anúncio no grupo não está na fatia mínima do marketplace (ADR-027), mas o EA-062-03 soma os anúncios compartilhados no grupo; a enquete tem tabelas e nenhum frame. O Figma não desenha nenhum ícone de ação. (proposta: só texto no MVP; anúncio e enquete viram story própria se o PO quiser) | pendente | — |
| L2 | Quais são as "regras do grupo" que bloqueiam o envio (`44` FA 2) e como detectá-las? As regras do Figma são texto livre (L6 da CCD043), e a mensagem "chama no zap… paga no Pix direto" aparece enviada no frame. (proposta: lista fixa da plataforma, como telefone e pagamento fora da plataforma; texto do aviso a desenhar) | pendente | — |
| L3 | Reações com emoji (Figma): faz sentido implementar? O DBML não tem tabela de reação | pendente | — |
| L4 | Responder citando uma mensagem (Figma): `group_messages.reply_to_id` existe, mas o `45` (Responder Mensagem Específica) é do chat pessoal. Entra nesta story ou numa story de resposta no grupo? | pendente | — |
| L5 | Avisos de sistema ("@lucas_trader entrou no grupo"): faz sentido implementar? O `message_content_type` não tem um tipo de sistema | pendente | — |
| L6 | "✓✓" na própria mensagem: é status de leitura (Futuro) ou só confirmação de envio (ack, ADR-012)? (proposta: tirar do frame no MVP) | pendente | — |
| L7 | Presença ("28 online", "Online agora (28)", "Ver todos"): faz sentido implementar? Nenhum caso de uso a descreve; pelo Socket.IO daria para contar as conexões da room, sem tabela | pendente | — |
| L8 | Painel "Sobre o grupo": a descrição vem de `groups.description`; as hashtags não têm coluna; "Regras" depende da L6 da CCD043. Faz sentido implementar as hashtags? | pendente | — |
| L9 | Tamanho máximo da mensagem de texto (o `content` é `text`)? (proposta: 2.000 caracteres, validado no Zod) | pendente | — |
| L10 | Cada mensagem nova gera aviso em `notifications` para os outros membros (CCD053 cita novas mensagens; o silêncio da CCD041 pausa esses avisos)? (proposta: sim, agrupado por grupo, respeitando o silêncio e as preferências da CCD053) | pendente | — |
| L11 | O que tem o menu "⋯" do topo? Sair do grupo não está em nenhum caso de uso. (proposta: as opções do grupo da CCD041, como silenciar e reativar, e sair do grupo, se o PO aprovar) | pendente | — |
| L12 | Como o cliente recebe as mensagens de quem entra depois da página aberta e depois de reconectar (mensagens perdidas na queda)? (proposta técnica: ao reconectar, buscar pelo histórico a partir da última mensagem recebida; decidir no plano) | pendente | — |
| L13 | Estados sem mensagens, carregando, erro de envio e reconexão não estão desenhados (proposta: os componentes padrão do app, no estilo do chat) | pendente | — |
