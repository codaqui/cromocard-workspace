# CCD045 — Responder Mensagem Específica

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** não encontrada no board
- **Caso de uso:** [45-responder-mensagem-especifica.md](../../docs/Casos-De-Uso/45-responder-mensagem-especifica.md)
- **Atores:** Cliente · **Pré-condições:** autenticado e com uma conversa ativa com outro usuário
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

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
| R1 | Responder exige login (`401` sem token) e ser participante da conversa; quem não participa não entra na room nem envia (`403`) | Permissão | `45`, Pré-condições; ADR-005, item 5; ADR-012, Rooms (`conversation:<id>`, entrada só se participante) |
| R2 | O usuário seleciona uma mensagem da conversa e o sistema mostra as ações dela, com a opção "Responder" | Ação | `45`, FP 1–2; Figma `1160-33616` |
| R3 | Ao escolher "Responder", acima do campo de digitação aparece o bloco "Respondendo a @<nome de usuário do autor>:" com o texto da mensagem citada entre aspas, cortado com "..." quando é longo | Tela | `45`, FP 3–4; Figma `1160-32980` |
| R4 | O campo de digitação mostra o texto de ajuda "Digite sua mensagem para @<nome de usuário>..." e o botão "Enviar" | Campo | `45`, FP 5; Figma `1160-32980` |
| R5 | "Enviar" grava a mensagem nova com `reply_to_id` apontando para a mensagem citada | Ação | `45`, FP 5–6; DBML `messages.reply_to_id` |
| R6 | A mensagem citada tem que ser da mesma conversa e não estar excluída | Regra | `45`, Finalidade e FP 1 ("dentro de uma conversa"); `45`, FA 3–4; ADR-015, item 5 |
| R7 | A resposta aparece na conversa dos dois participantes com o bloco "Respondendo a @<autor>" e o trecho da mensagem original acima do texto | Tela | `45`, FP 6; Figma `1160-32980` |
| R8 | O envio segue o ADR-012: evento `message:send` com ack; a service grava primeiro e só depois emite para a room `conversation:<id>`; se a gravação falhar, nada é emitido e o ack devolve o erro; o payload é validado com o Zod do domínio | Regra | ADR-012, Decisão (Eventos e Persistência primeiro) |
| R9 | Mensagem vazia (ou só com espaços) não é enviada e a tela mostra "Digite uma mensagem antes de enviar" | Mensagem | `45`, FA 1–2 |
| R10 | Se a mensagem citada não está mais disponível, o sistema informa isso e cancela a referência (o bloco "Respondendo a" some e a mensagem pode ser enviada sem citação) | Mensagem | `45`, FA 3–4 |
| R11 | Com bloqueio entre os dois participantes, o envio é recusado | Regra | ADR-012, Persistência primeiro ("valida o bloqueio"); ADR-007, Contexto |
| R12 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (`1160-32980`, `1160-33616`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2–R5, R7, R8) — **Dado** uma conversa entre Gabriel e Marcos com uma mensagem de Marcos, **quando** Gabriel seleciona a mensagem, escolhe "Responder", digita um texto e seleciona "Enviar", **então** a mensagem é gravada com `reply_to_id` igual ao id da mensagem de Marcos e aparece para os dois com o bloco "Respondendo a @marcos_tcg" e o trecho citado.
- **CA2** (R3) — **Dado** uma mensagem citada com mais texto do que cabe no bloco, **quando** o usuário escolhe "Responder", **então** o bloco "Respondendo a @<autor>:" mostra o começo do texto entre aspas terminando em "...".
- **CA3** (R9) — **Dado** o bloco "Respondendo a" aberto e o campo vazio, **quando** o usuário seleciona "Enviar", **então** nada é gravado e a tela mostra "Digite uma mensagem antes de enviar".
- **CA4** (R6, R10) — **Dado** uma resposta em andamento a uma mensagem que foi excluída (`deleted_at` preenchido), **quando** o usuário envia, **então** o envio com a referência é recusado, a tela informa que a mensagem não está mais disponível e o bloco "Respondendo a" some.
- **CA5** (R6) — **Dado** um `reply_to_id` de uma mensagem de outra conversa, **quando** o evento `message:send` chega, **então** o ack devolve erro de validação e nada é gravado nem emitido.
- **CA6** (R1) — **Dado** um handshake sem token válido, **quando** o cliente tenta conectar, **então** a conexão é recusada; **dado** um usuário que não participa da conversa, **quando** ele envia `message:send` para ela, **então** o ack devolve `403` e nada é gravado.
- **CA7** (R8) — **Dado** uma falha na gravação, **quando** o usuário envia a resposta, **então** nenhum evento é emitido para a room e a tela mostra o erro devolvido pelo ack.
- **CA8** (R11) — **Dado** Marcos bloqueado por Gabriel, **quando** qualquer um dos dois tenta responder uma mensagem da conversa, **então** o envio é recusado e nada é gravado.
- **CA9** (R12) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-32980` (conversa com a resposta em andamento), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA10** (R12) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-33616` (mensagem selecionada com as ações), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `messages` | `id`, `conversation_id`, `author_id`, `reply_to_id`, `content`, `created_at`, `deleted_at` | `reply_to_id` opcional (autorrelação); `content` é `text`, sem limite no DBML (L6) |
| `conversation_participants` | `conversation_id`, `user_id`, `deleted_at` | confere se quem envia participa da conversa (R1) |
| `user_blocks` | `blocker_id`, `blocked_id`, `deleted_at` | bloqueio ativo nos dois sentidos impede o envio (R11) |
| `users` | `username` | o "@" do bloco "Respondendo a" |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Mensagens - conversas (com a resposta em andamento) | [1160-32980](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-32980) | R3, R4, R7 | ❌ Não bate: "×" para cancelar a resposta e botão de emoji só no Figma (L3, L7) |
| Mensagens - ações da mensagem | [1160-33616](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-33616) | R2 | ❌ Não bate: o print mostra só a barra de reações, sem a opção "Responder" (L1); ações extras só no Figma (L2) |

- **Diferenças com o Figma** (decisão em Lacunas e decisões): Mensagens - ações da mensagem — o print do frame mostra a
  mensagem selecionada com a barra de reações (👍 🔥 😂 😮 🤝 💰 +), mas não o menu com "↩ Responder"; o menu só existe
  nas camadas de texto do frame (L1).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): Mensagens - ações da mensagem — "Copiar
  texto", "Encaminhar", "Fixar na conversa", "Salvar mensagem", "Apagar para mim", "Denunciar mensagem" e as reações (L2);
  Mensagens - conversas — "×" que cancela a resposta em andamento (L3); botão de emoji no campo de digitação e "Pressione
  Enter para enviar" (L7).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R9 aviso "Digite uma mensagem antes de enviar";
  R10 aviso de mensagem não disponível; R11 envio recusado por bloqueio.

## Fora do escopo

- Listar conversas e abrir a conversa — CCD046. Bloquear e denunciar o contato — CCD047.
- Começar uma conversa nova e enviar mensagem sem citação — user story "Conversar com Colecionador", sem caso de uso (L5).
- Indicador de leitura (✓) — user story "Visualizar Status de Leitura" (fase Futuro).
- Enviar imagem, carta ou localização — user story "Enviar Anexos e Localização" (fase Futuro).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O frame `1160-33616` mostra só a barra de reações; o menu com "↩ Responder" está nas camadas de texto, mas não aparece no print (escondido ou fora da área do frame). Como o usuário chega em "Responder"? (proposta: pedir ao Gabriel que mostre o menu no frame) | pendente | — |
| L2 | Só no Figma (`1160-33616`): "Copiar texto", "Encaminhar", "Fixar na conversa", "Salvar mensagem", "Apagar para mim", "Denunciar mensagem" e as reações. Faz sentido implementar? O DBML não tem tabela de reação, de mensagem fixada ou salva, nem `reports` para mensagem privada (só `group_message_id`) | pendente | — |
| L3 | Só no Figma (`1160-32980`): o "×" que cancela a resposta em andamento. Faz sentido implementar? (proposta: sim, só no frontend) | pendente | — |
| L4 | Texto exato do aviso de mensagem não disponível (FA 4) e o que a resposta já enviada mostra quando a mensagem original é excluída depois (proposta: "Mensagem indisponível" no lugar do trecho) | pendente | — |
| L5 | Enviar mensagem é da user story "Conversar com Colecionador", que não tem caso de uso nem código CCD. Quem implementa o envio simples, de que esta story depende? (proposta: criar o caso de uso ou incluir o envio na CCD046) | pendente | — |
| L6 | Tamanho máximo da mensagem (`messages.content` é `text`) | pendente | — |
| L7 | Só no Figma (`1160-32980`): botão de emoji no campo e o atalho "Pressione Enter para enviar". Faz sentido implementar? | pendente | — |
| L8 | O ator é Cliente: `SELLER` e `ADMIN` também usam o chat pessoal? (proposta: `CUSTOMER` e `SELLER`) | pendente | — |
