# CCD047 — Moderar Contatos Privados

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #1231 `CCD047 - Moderar Contatos Privados` (criada em 22/11/2026)
- **Caso de uso:** [47-moderar-contatos-privados.md](../../docs/Casos-De-Uso/47-moderar-contatos-privados.md)
- **Atores:** Cliente · **Pré-condições:** autenticado e com pelo menos um contato ou conversa privada
- **Data:** 2026-11-21 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Cliente preciso ter a opção de bloquear ou denunciar usuários com comportamento inadequado no chat.

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
| R1 | Moderar contatos exige login (`401` sem token); só se modera alguém com quem o usuário tem conversa, e ninguém bloqueia nem denuncia a si mesmo | Permissão | `47`, Pré-condições; ADR-005 |
| R2 | No topo da conversa, o botão de escudo abre o modal "Bloquear ou denunciar @<nome de usuário>", com "Escolha o que fazer com este contato." e o contato (iniciais, nome, @ e "conversa desde <mês> de <ano>") | Tela | `47`, FP 1–4; Figma `1160-32980`, `1160-34298` |
| R3 | Em "O que você quer fazer?", três opções: "Somente bloquear" ("Ele não poderá mais te enviar mensagens"), "Bloquear e denunciar" ("A moderação analisa a conversa em até 24h") e "Somente denunciar" ("A conversa continua aberta") | Campo | `47`, FP 5; user story (bloquear ou denunciar); Figma `1160-34298` (L1) |
| R4 | Nas opções com denúncia, "Motivo da denúncia" é obrigatório ("Golpe / pagamento externo", "Assédio", "Spam", "Perfil falso") e "Conte o que aconteceu" é opcional, até 500 caracteres | Campo | user story; DBML `reports.reason` (obrigatória), `reports.description` (500); Figma `1160-34298` (L4) |
| R5 | O modal é a confirmação da ação: "Cancelar" e o botão da opção escolhida (no frame, "Bloquear e denunciar"), com o rodapé "Você pode desbloquear em Configurações." | Ação | `47`, FP 6–7; Figma `1160-34298` (L5) |
| R6 | Bloquear grava `user_blocks` (`blocker_id` = usuário, `blocked_id` = contato); bloquear de novo quem já foi desbloqueado restaura a linha | Regra | `47`, FP 8; DBML `user_blocks` (`blocker_id`, `blocked_id` únicos); ADR-015, item 7 |
| R7 | Com bloqueio ativo, nenhum dos dois envia mensagem na conversa: a service recusa o envio | Regra | user story ("Ele não poderá mais te enviar mensagens", `1160-34298`); ADR-012, Persistência primeiro; ADR-007, Contexto (L6) |
| R8 | Depois de bloquear, a conversa continua na lista e o campo de digitação dá lugar a "Você bloqueou @<nome de usuário>. Para conversar de novo, desbloqueie em Configurações › Privacidade." | Estado | `47`, FP 8 e FA 3; Figma `1160-37184` |
| R9 | Denunciar grava `reports` com `reporter_id` = usuário, `target_user_id` = contato, o `target_type` do usuário, `reason`, `description` e `status = PENDING` | Regra | `47`, FP 8; DBML `reports`; ADR-032 (L7) |
| R10 | Ao concluir, o aviso confirma a ação; para "Bloquear e denunciar", "Contato bloqueado e denunciado" e "A moderação vai analisar a conversa." | Mensagem | `47`, FP 8; Figma `1160-37184` (L5) |
| R11 | "Cancelar" ou o "✕" fecha o modal sem bloquear nem denunciar | Ação | `47`, FA 1–2 |
| R12 | Contato já bloqueado: a tela informa que ele está bloqueado e oferece desbloquear | Estado | `47`, FA 3 (L8) |
| R13 | Desbloquear preenche `user_blocks.deleted_at`; a conversa volta a aceitar mensagens | Ação | `47`, FA 3; ADR-015, itens 1 e 2 |
| R14 | Em Configurações › Privacidade, "Contatos bloqueados" mostra quantos contatos estão bloqueados ("1 contato bloqueado") e "Ver bloqueados" abre a lista, com a opção de desbloquear cada um | Tela | `47`, FP 1–2 e FA 3; Figma `1160-41305` (L9) |
| R15 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (`1160-32980`, `1160-34298`, `1160-37184`, `1160-41305`); ADR-060, itens 1 e 5; `CLAUDE.md`, Figma |

## Critérios de aceite

- **CA1** (R2, R3, R5, R6, R8–R10) — **Dado** a conversa de Gabriel com Marcos aberta, **quando** Gabriel seleciona o escudo, escolhe "Bloquear e denunciar", o motivo "Golpe / pagamento externo" e confirma, **então** `user_blocks` e `reports` (`PENDING`) são gravados, aparece o aviso "Contato bloqueado e denunciado" e o campo de digitação dá lugar ao texto de contato bloqueado.
- **CA2** (R3, R6, R8) — **Dado** o modal aberto, **quando** Gabriel escolhe "Somente bloquear" e confirma, **então** só `user_blocks` é gravado, nenhuma denúncia é criada e a conversa mostra o texto de contato bloqueado.
- **CA3** (R3, R9) — **Dado** o modal aberto, **quando** Gabriel escolhe "Somente denunciar", escolhe um motivo e confirma, **então** só `reports` é gravado e o campo de digitação continua disponível.
- **CA4** (R4) — **Dado** "Bloquear e denunciar" escolhido e nenhum motivo marcado, **quando** Gabriel confirma, **então** nada é gravado e a tela pede o motivo; a API responde `400` sem `reason`.
- **CA5** (R7) — **Dado** Marcos bloqueado por Gabriel, **quando** Marcos envia uma mensagem para a conversa, **então** o ack devolve erro e nada é gravado nem emitido; o mesmo vale para Gabriel.
- **CA6** (R11) — **Dado** o modal aberto com uma opção escolhida, **quando** Gabriel seleciona "Cancelar" ou o "✕", **então** o modal fecha e nada é gravado.
- **CA7** (R12, R13) — **Dado** Marcos bloqueado, **quando** Gabriel abre a conversa e escolhe desbloquear, **então** `user_blocks.deleted_at` é preenchido e o campo de digitação volta.
- **CA8** (R6) — **Dado** Marcos desbloqueado antes, **quando** Gabriel o bloqueia de novo, **então** a mesma linha de `user_blocks` volta a `deleted_at = NULL`, sem linha nova.
- **CA9** (R14) — **Dado** 1 contato bloqueado, **quando** Gabriel abre Configurações, **então** "Contatos bloqueados" mostra "1 contato bloqueado" e "Ver bloqueados" lista o contato com a opção de desbloquear.
- **CA10** (R1) — **Dado** um visitante sem login, **quando** chama a rota de bloquear ou denunciar, **então** recebe `401`; **dado** Gabriel, **quando** tenta bloquear a si mesmo, **então** recebe `400`.
- **CA11** (R15) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-32980` (escudo no topo da conversa), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA12** (R15) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-34298` (modal bloquear ou denunciar), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA13** (R15) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-37184` (contato bloqueado), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA14** (R15) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print do bloco "Privacidade" é comparado lado a lado com o do frame `1160-41305` (linha "Contatos bloqueados"), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `user_blocks` | `blocker_id`, `blocked_id`, `deleted_at` | `(blocker_id, blocked_id)` único; desbloquear = soft delete, bloquear de novo restaura (ADR-015) |
| `reports` | `reporter_id`, `target_user_id`, `target_type` (`report_target_type`: `USER`, `PROFILE`…), `reason`, `description`, `status` (`report_status`, default `PENDING`) | `reason` obrigatório (90); `description` até 500; sem `deleted_at` de negócio (ADR-015, item 4) |
| `conversation_participants` | `conversation_id`, `user_id` | confere que há conversa com o contato (R1) |
| `messages` | — | não há coluna para anexar as últimas 20 mensagens à denúncia (L3) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Mensagens - conversas (escudo no topo) | [1160-32980](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-32980) | R2 | ✅ Bate |
| Mensagens - bloquear ou denunciar | [1160-34298](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-34298) | R2–R5, R11 | ❌ Não bate: sem "remover contato" (L1); "Anexar as últimas 20 mensagens" só no Figma (L3) |
| Mensagens - contato bloqueado | [1160-37184](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-37184) | R8, R10, R12 | ❌ Não bate: manda desbloquear em Configurações, e o caso de uso pede a opção na hora (L8) |
| Configurações (linha "Contatos bloqueados") | [1160-41305](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-41305) | R14 | ✅ Bate; a lista de bloqueados não tem frame (L9) |

- **Diferenças com o Figma** (decisão em Lacunas e decisões): bloquear ou denunciar — o `47`, FP 5, cita "bloquear ou
  remover o contato"; o Figma não tem "remover" e tem "denunciar", como a user story (L1). Contato bloqueado — o `47`,
  FA 3, pede a opção de desbloqueio; o Figma manda para Configurações › Privacidade (L8).
- **Só no Figma** (faz sentido implementar? decisão em Lacunas e decisões): "Anexar as últimas 20 mensagens" com "Ajuda a
  moderação a entender o contexto" (L3); o prazo "em até 24h" (L10).
- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R4 aviso de motivo obrigatório; R10 avisos de
  "Somente bloquear" e "Somente denunciar"; R12–R14 lista "Ver bloqueados" e o desbloqueio.

## Fora do escopo

- Denunciar uma mensagem específica do chat pessoal ("Denunciar mensagem" no menu da mensagem) — L2 da CCD045.
- Denunciar mensagem de grupo — CCD040. Denunciar perfil pela página pública — CCD050. Denunciar usuário pelo painel do vendedor — CCD090.
- Analisar a denúncia no BackOffice (L7).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O caso de uso diz "bloquear ou remover o contato"; a user story e o Figma dizem "bloquear ou denunciar". O DBML não tem tabela de contatos. "Remover contato" existe? O que faria (esconder a conversa)? Ajustar o `47`, FP 5? | pendente | — |
| L2 | O `47` não fala de denúncia; a user story fala. Registrar a denúncia no caso de uso (passos e motivos)? | pendente | — |
| L3 | Só no Figma: "Anexar as últimas 20 mensagens". O DBML não tem onde guardar as mensagens anexadas (`reports` não aponta para `messages`). Faz sentido implementar? | pendente | — |
| L4 | Os motivos são fixos ("Golpe / pagamento externo", "Assédio", "Spam", "Perfil falso")? Como ficam gravados em `reports.reason` (texto da tela ou código)? Mesma lista da CCD050? | pendente | — |
| L5 | Texto do botão e do aviso de sucesso para "Somente bloquear" e "Somente denunciar" (o frame só mostra "Bloquear e denunciar") | pendente | — |
| L6 | O que o contato bloqueado vê ao tentar enviar? Ele pode começar uma conversa nova com quem o bloqueou? | pendente | — |
| L7 | `target_type` da denúncia feita no chat: `USER` ou `PROFILE`? Quem analisa? A fila do BackOffice (CCD062) só trata `GROUP_MESSAGE` | pendente | — |
| L8 | Contato já bloqueado: o `47`, FA 3, oferece desbloquear na hora; o Figma (`1160-37184`) manda para Configurações › Privacidade. Qual vale? | pendente | — |
| L9 | A lista "Ver bloqueados" (`1160-41305`) não tem frame: pedir o desenho ao Gabriel | pendente | — |
| L10 | Só no Figma: o prazo "em até 24h" para a moderação. Faz sentido prometer o prazo? | pendente | — |
| L11 | Denunciar o mesmo contato de novo cria outra denúncia ou é recusado? | pendente | — |
| L12 | O ator é Cliente: `SELLER` e `ADMIN` também? (proposta: `CUSTOMER` e `SELLER`) | pendente | — |
