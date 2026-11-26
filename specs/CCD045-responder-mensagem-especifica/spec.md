# CCD045 — Responder Mensagem Específica

- **Status:** Em implementação
- **Fase:** MVP
- **User story:** #1208 `CCD045 - Responder Mensagem Específica` (criada em 22/11/2026)
- **Caso de uso:** [45-responder-mensagem-especifica.md](../../docs/Casos-De-Uso/45-responder-mensagem-especifica.md)
- **Atores:** Cliente e Vendedor · **Pré-condições:** autenticado como `CUSTOMER` ou `SELLER` e com uma conversa ativa com outro usuário
- **Data:** 2026-11-21 (revista em 2026-11-26 com as decisões L1–L11) · **Autor:** Daniel Andrade
- **Aprovação:** Daniel Andrade, 26/11/2026 (a validar pelo PO)

## Objetivo

> Como Cliente preciso poder dar "reply" diretamente em uma mensagem antiga no chat para manter o contexto da conversa.

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
| R1 | Responder exige login (`401` sem token), o papel `CUSTOMER` ou `SELLER` e ser participante da conversa; quem não participa recebe `404 CONVERSATION_NOT_FOUND`, como na CCD046 | Permissão | `45`, Atores e Pré-condições (L8, L11); ADR-005, item 5; ADR-012, Rooms (`conversation:<id>`, entrada só se participante) |
| R2 | Selecionar (clicar ou tocar) uma mensagem da conversa abre o menu da mensagem, só com "↩ Responder" | Ação | `45`, FP 1–2 (L1, L2); Figma `1160-33616` |
| R3 | Ao escolher "Responder", acima do campo de digitação aparece o bloco "Respondendo a @<nome de usuário do autor>:" com o começo da mensagem citada entre aspas, em uma linha, cortado com "..." quando não cabe | Tela | `45`, FP 3–4 (L9); Figma `1160-32980` |
| R4 | O campo de digitação mostra o texto de ajuda "Digite sua mensagem para @<nome de usuário>..." e o botão "Enviar" | Campo | `45`, FP 5; Figma `1160-32980` |
| R5 | "Enviar" grava a mensagem nova com `reply_to_id` apontando para a mensagem citada | Ação | `45`, FP 5–6; DBML `messages.reply_to_id` |
| R6 | A mensagem citada tem que ser da mesma conversa e não estar excluída | Regra | `45`, Finalidade e FP 1 ("dentro de uma conversa"); `45`, FA 3–4; ADR-015, item 5 |
| R7 | A resposta aparece na conversa dos dois participantes com o bloco "Respondendo a @<autor>" e o começo da mensagem original (uma linha, com "...") acima do texto | Tela | `45`, FP 6 (L9); Figma `1160-32980` |
| R8 | O envio segue o ADR-012: evento `message:send` com ack; a service grava primeiro e só depois emite para a room `conversation:<id>`; se a gravação falhar, nada é emitido e o ack devolve o erro; o payload é validado com o Zod do domínio | Regra | ADR-012, Decisão (Eventos e Persistência primeiro) |
| R9 | "Enviar" fica ativo com o campo vazio; enviar mensagem vazia (ou só com espaços), pelo botão ou pelo Enter, não envia nada e a tela mostra "Digite uma mensagem antes de enviar". Vale para toda mensagem, com ou sem citação | Mensagem | `45`, FA 1–2 (L10); Figma `1160-32980` |
| R10 | Se a mensagem citada não está mais disponível, a tela mostra "A mensagem que você está respondendo não está mais disponível.", o bloco "Respondendo a" some e o texto continua no campo, para ser enviado sem citação | Mensagem | `45`, FA 3–4 (L4) |
| R11 | Com bloqueio entre os dois participantes, o envio é recusado (`422 CONTACT_BLOCKED`, já feito na CCD047) e a conversa mostra o aviso de bloqueio no lugar do campo | Regra | ADR-012, Persistência primeiro ("valida o bloqueio"); ADR-007, Contexto; CCD047 |
| R12 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (`1160-32980`, `1160-33616`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |
| R13 | O "×" do bloco "Respondendo a" ou a tecla Esc cancela a resposta em andamento: o bloco some e o texto digitado continua no campo | Ação | `45`, FA 5–6 (L3); Figma `1160-32980` |
| R14 | Na resposta já enviada cuja mensagem original deixou de estar disponível, a citação mostra "Mensagem indisponível" no lugar do trecho | Tela | `45`, FA 7 (L4) |

## Critérios de aceite

- **CA1** (R2–R5, R7, R8) — **Dado** uma conversa entre Gabriel e Marcos com uma mensagem de Marcos, **quando** Gabriel seleciona a mensagem, escolhe "Responder", digita um texto e seleciona "Enviar", **então** a mensagem é gravada com `reply_to_id` igual ao id da mensagem de Marcos e aparece para os dois com o bloco "Respondendo a @marcos_tcg" e o trecho citado.
- **CA2** (R3) — **Dado** uma mensagem citada com mais texto do que cabe no bloco, **quando** o usuário escolhe "Responder", **então** o bloco "Respondendo a @<autor>:" mostra o começo do texto entre aspas terminando em "...".
- **CA3** (R9) — **Dado** o bloco "Respondendo a" aberto e o campo vazio, **quando** o usuário seleciona "Enviar" (ativo) ou pressiona Enter, **então** nada é enviado e a tela mostra "Digite uma mensagem antes de enviar".
- **CA4** (R6, R10) — **Dado** uma resposta em andamento a uma mensagem que foi excluída (`deleted_at` preenchido), **quando** o usuário envia, **então** o ack devolve `422 REPLY_TARGET_UNAVAILABLE`, nada é gravado, a tela mostra "A mensagem que você está respondendo não está mais disponível.", o bloco "Respondendo a" some e o texto continua no campo.
- **CA5** (R6) — **Dado** um `reply_to_id` de uma mensagem de outra conversa, **quando** o evento `message:send` chega, **então** o ack devolve erro de validação e nada é gravado nem emitido.
- **CA6** (R1) — **Dado** um handshake sem token válido, **quando** o cliente tenta conectar, **então** a conexão é recusada; **dado** um usuário que não participa da conversa, **quando** ele envia `message:send` com `replyToId` para ela, **então** o ack devolve `404 CONVERSATION_NOT_FOUND` e nada é gravado.
- **CA7** (R8) — **Dado** uma falha na gravação, **quando** o usuário envia a resposta, **então** nenhum evento é emitido para a room e a tela mostra o erro devolvido pelo ack.
- **CA8** (R11) — **Dado** Marcos bloqueado por Gabriel, **quando** qualquer um dos dois tenta responder uma mensagem da conversa, **então** o envio é recusado e nada é gravado.
- **CA11** (R13) — **Dado** o bloco "Respondendo a @marcos_tcg:" aberto e um texto digitado, **quando** o usuário seleciona o "×" ou pressiona Esc, **então** o bloco some, o texto continua no campo e o próximo envio não leva citação.
- **CA12** (R14) — **Dado** uma resposta de Gabriel citando uma mensagem de Marcos que depois foi excluída, **quando** a conversa é aberta, **então** a citação mostra "Respondendo a @marcos_tcg" e "Mensagem indisponível" no lugar do trecho.
- **CA9** (R12) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-32980` (conversa com a resposta em andamento), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA10** (R12) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-33616` (mensagem selecionada com as ações), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `messages` | `id`, `conversation_id`, `author_id`, `reply_to_id`, `content`, `created_at`, `deleted_at` | `reply_to_id` opcional (autorrelação); `content` até 2000 caracteres, como na CCD046 (L6) |
| `conversation_participants` | `conversation_id`, `user_id`, `deleted_at` | confere se quem envia participa da conversa (R1) |
| `user_blocks` | `blocker_id`, `blocked_id`, `deleted_at` | bloqueio ativo nos dois sentidos impede o envio (R11) |
| `users` | `username` | o "@" do bloco "Respondendo a" |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Mensagens - conversas (com a resposta em andamento) | [1160-32980](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-32980) | R3, R4, R7, R9, R13 | ✅ Bate (a citação do balão enviado passou a ser o começo da mensagem, L9) |
| Mensagens - ações da mensagem | [1160-33616](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-33616) | R2 | ✅ Bate depois do ajuste de 26/11/2026: menu só com "↩ Responder" dentro do frame, sem reações, emoji nem as outras ações (L1, L2) |

- **Figma ajustado em 26/11/2026** (pelo Playwright, com versão salva antes e depois): no frame `1160-33616`, o menu foi
  trazido para dentro da tela e ficou só com "↩ Responder"; saíram "Copiar texto", "Encaminhar", "Fixar na conversa",
  "Salvar mensagem", "Apagar para mim", "Denunciar mensagem", a barra de reações, "Reagir", as reações da mensagem, o
  botão de emoji, o ✓ de leitura e o que a CCD046 já tinha tirado do `1160-32980` (filtros, "Ver Arquivadas", "Visto há",
  "Concluído"). Nos dois frames, a citação do balão enviado mostra o começo da mensagem (L9).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R9 aviso "Digite uma mensagem antes de enviar";
  R10 aviso de mensagem não disponível; R14 "Mensagem indisponível".

## Fora do escopo

- Listar conversas e abrir a conversa — CCD046. Bloquear e denunciar o contato — CCD047.
- Começar uma conversa nova e enviar mensagem sem citação — CCD046 (L5).
- Copiar, encaminhar, fixar, salvar, apagar e denunciar mensagem, reações e emoji (L2, L7).
- Escolher um trecho do meio da mensagem para citar (L9).
- Indicador de leitura (✓) — user story "Visualizar Status de Leitura" (fase Futuro).
- Enviar imagem, carta ou localização — user story "Enviar Anexos e Localização" (fase Futuro).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Como o usuário chega em "Responder" (o menu estava fora da área do frame `1160-33616`) | Clicar ou tocar na mensagem abre o menu no estilo do Figma, só com "↩ Responder", sem atalho; o frame foi ajustado (26/11/2026, Daniel) | `45`, FP 2; R2; Figma |
| L2 | Copiar, encaminhar, fixar, salvar, apagar para mim, denunciar mensagem e reações | Ficam fora; tirados do Figma | Fora do escopo; Figma |
| L3 | "×" que cancela a resposta | Entra, com a tecla Esc; o texto digitado continua no campo | `45`, FA 5–6; R13 |
| L4 | Aviso de mensagem indisponível e a resposta antiga | "A mensagem que você está respondendo não está mais disponível."; na resposta já enviada, "Mensagem indisponível" no lugar do trecho | `45`, FA 3–4 e FA 7; R10, R14 |
| L5 | Quem faz o envio simples | A CCD046 (L5 de lá), já implementado | Fora do escopo |
| L6 | Tamanho máximo da mensagem | 2000 caracteres, o mesmo do envio da CCD046 | Dados |
| L7 | Botão de emoji e "Pressione Enter para enviar" | Emoji fica fora e saiu do Figma; o Enter já existe (CCD046) | Fora do escopo; Figma |
| L8 | Papéis | `CUSTOMER` e `SELLER`, como na CCD046 (L15 de lá) | `45`, Atores; R1 |
| L9 | Qual trecho a citação mostra (o balão do Figma citava o meio da mensagem) | O começo da mensagem, em uma linha, cortado com "..."; o Figma foi ajustado | `45`, FP 4 e FP 6; R3, R7; Figma |
| L10 | Mensagem vazia com o "Enviar" desabilitado (CCD046) | "Enviar" fica ativo, como no Figma, e enviar vazio mostra "Digite uma mensagem antes de enviar", com ou sem citação | `45`, FA 1–2; R9 |
| L11 | Não participante: `403` (spec) ou `404` (CCD046) | `404 CONVERSATION_NOT_FOUND`, como na CCD046 | R1, CA6 |
