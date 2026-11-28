# CCD047 — Moderar Contatos Privados

- **Status:** Planejada
- **Fase:** MVP
- **User story:** #1231 `CCD047 - Moderar Contatos Privados` (criada em 22/11/2026)
- **Caso de uso:** [47-moderar-contatos-privados.md](../../docs/Casos-De-Uso/47-moderar-contatos-privados.md)
- **Atores:** Cliente, Vendedor · **Pré-condições:** autenticado e com uma conversa pessoal com o contato
- **Data:** 2026-11-21 (revisada em 2026-11-26) · **Autor:** Daniel Andrade
- **Aprovação:** Felipe Consulim (PO), em 28/11/2026, com as decisões L1–L13 e o ADR-073 (revisão do PR #68)

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
| R1 | Moderar contatos exige login (`401` sem token) e é de `CUSTOMER` e `SELLER` (`403` para o `ADMIN`); só se modera alguém com quem o usuário tem conversa, e ninguém bloqueia nem denuncia a si mesmo | Permissão | `47`, Atores e Pré-condições (L12); ADR-005 |
| R2 | No topo da conversa, o botão de escudo abre o modal "Bloquear ou denunciar @<nome de usuário>", com "Escolha o que fazer com este contato." e o contato (iniciais, nome, @ e "conversa desde <mês> de <ano>") | Tela | `47`, FP 1–4; Figma `1160-32980`, `1160-34298` |
| R3 | Em "O que você quer fazer?", três opções: "Somente bloquear" ("Ele não poderá mais te enviar mensagens"), "Bloquear e denunciar" ("A moderação analisa a conversa") e "Somente denunciar" ("A conversa continua aberta") | Campo | `47`, FP 3 (L1, L10); user story; Figma `1160-34298` |
| R4 | Nas opções com denúncia, "Motivo da denúncia" é obrigatório, um entre "Golpe / pagamento externo", "Assédio", "Spam" e "Perfil falso", gravado com o texto da tela em `reports.reason`; "Conte o que aconteceu" é opcional, até 500 caracteres | Campo | `47`, FP 5 (L4); DBML `reports.reason` (obrigatória), `reports.description` (500); Figma `1160-34298` |
| R5 | O modal é a confirmação da ação: o rodapé "Você pode desbloquear em Configurações.", "Cancelar" e o botão da opção escolhida: "Bloquear", "Bloquear e denunciar" ou "Denunciar" | Ação | `47`, FP 7 (L5); Figma `1160-34298` |
| R6 | Bloquear grava `user_blocks` (`blocker_id` = usuário, `blocked_id` = contato); bloquear de novo quem já foi desbloqueado restaura a linha | Regra | `47`, FP 8; DBML `user_blocks` (`blocker_id`, `blocked_id` únicos); ADR-015, item 7 |
| R7 | Com bloqueio ativo, nenhum dos dois envia mensagem na conversa: a service recusa o envio | Regra | user story ("Ele não poderá mais te enviar mensagens", `1160-34298`); ADR-012, Persistência primeiro; ADR-007, Contexto (L6) |
| R8 | Depois de bloquear, a conversa continua na lista e o campo de digitação dá lugar a "Você bloqueou @<nome de usuário>. Para conversar de novo, desbloqueie em Configurações › Privacidade." com o botão "Desbloquear" | Estado | `47`, FP 12 (L8); Figma `1160-37184` |
| R9 | Denunciar grava `reports` com `reporter_id` = usuário, `target_user_id` = contato, `target_type = USER`, `reason`, `description` e `status = PENDING`, com os prints em `report_evidences` (R16), tudo na mesma transação | Regra | `47`, FP 10 (L7); DBML `reports`, `report_evidences`; ADR-032, ADR-073 |
| R10 | Ao concluir, o modal fecha e o aviso confirma a ação: "Contato bloqueado" ("Ele não poderá mais te enviar mensagens."), "Contato bloqueado e denunciado" ("A moderação vai analisar a conversa.") ou "Denúncia enviada" ("A moderação vai analisar a conversa.") | Mensagem | `47`, FP 11 (L5); Figma `1160-37184` |
| R11 | "Cancelar" ou o "✕" fecha o modal sem bloquear nem denunciar | Ação | `47`, FA 1–2 |
| R12 | Contato já bloqueado: o aviso da conversa tem o botão "Desbloquear", e o escudo abre o modal informando que o contato está bloqueado, com "Desbloquear" | Estado | `47`, FA 9 (L8) |
| R13 | Desbloquear preenche `user_blocks.deleted_at`; a conversa volta a aceitar mensagens | Ação | `47`, FA 3; ADR-015, itens 1 e 2 |
| R14 | "Contatos bloqueados": a API devolve os contatos bloqueados com o total ("1 contato bloqueado"), e o modal "Contatos bloqueados" lista cada um com "Desbloquear", pronto para a linha de Configurações › Privacidade, que entra com a CCD051 | Tela | `47`, FA 9 (L9); Figma `1160-41305` |
| R15 | Cada tela desta user story fica igual ao seu frame do Figma (seção **Telas (Figma)**): layout, medidas, espaçamentos, cores, tipografia, ícones, imagens, textos e estados | Fidelidade | Figma (`1160-32980`, `1160-34298`, `1160-37184`); ADR-060, itens 1 e 5; ADR-070; `CLAUDE.md`, Figma |
| R16 | Nas opções com denúncia, o usuário envia de 1 a 3 prints da conversa como evidência, obrigatórios: PNG, JPG ou WEBP até 4 MB cada; sem print, a tela pede "Envie pelo menos um print da conversa." e a API responde `400`; fora do formato, do tamanho ou acima de 3, a tela informa o limite e a API recusa | Campo | `47`, FP 5 e FA 3–6 (L3); ADR-073; ADR-050; ADR-068 (L13) |
| R17 | Para o contato bloqueado, o campo de digitação da conversa dá lugar a "@<nome de usuário> bloqueou você. Vocês não podem mais trocar mensagens.", e quem o bloqueou não aparece no "Nova conversa" dele (CCD046) | Estado | `47`, FA 11 (L6) |
| R18 | Com uma denúncia `PENDING` do usuário contra o mesmo contato, uma nova denúncia é recusada (`409`) e a tela informa "Você já denunciou este contato. A moderação está analisando."; com a anterior resolvida ou dispensada, pode denunciar de novo | Regra | `47`, FA 7–8 (L11) |
| R19 | Na Fila de moderação da Gestão de Comunidade (CCD062), as denúncias do chat entram com as de grupo e no contador "Denúncias pendentes": o card mostra o autor (idade da conta e advertências), "Origem: Chat pessoal • Denunciado por @<usuário>", o motivo, a descrição e as miniaturas dos prints, que abrem em tamanho maior; as ações são "Dispensar Denúncia" (com motivo) e "Aplicar sanção ao autor" (CCD099), que resolve a denúncia; "Golpe / pagamento externo" e "Assédio" entram no filtro Críticos e "Spam" no filtro Spam; o subtítulo da fila vira "Mensagens dos grupos e do chat pessoal denunciadas pelos membros." | Tela | `62`, FP 10–13 (L7); ADR-073; Figma `220-3524` |
| R20 | Se o bloqueio ou a denúncia falhar, o modal continua aberto com o que foi preenchido e informa o erro | Mensagem | `47`, FA 12 |

## Critérios de aceite

- **CA1** (R2, R3, R5, R6, R8–R10, R16) — **Dado** a conversa de Gabriel com Marcos aberta, **quando** Gabriel seleciona o escudo, escolhe "Bloquear e denunciar", o motivo "Golpe / pagamento externo", envia um print e confirma, **então** `user_blocks`, `reports` (`USER`, `PENDING`) e `report_evidences` são gravados, aparece o aviso "Contato bloqueado e denunciado" e o campo de digitação dá lugar ao texto de contato bloqueado com "Desbloquear".
- **CA2** (R3, R5, R6, R8, R10) — **Dado** o modal aberto, **quando** Gabriel escolhe "Somente bloquear" e seleciona "Bloquear", **então** só `user_blocks` é gravado, nenhuma denúncia é criada, aparece "Contato bloqueado" e a conversa mostra o texto de contato bloqueado.
- **CA3** (R3, R5, R9, R10, R16) — **Dado** o modal aberto, **quando** Gabriel escolhe "Somente denunciar", um motivo, envia um print e seleciona "Denunciar", **então** só `reports` e `report_evidences` são gravados, aparece "Denúncia enviada" e o campo de digitação continua disponível.
- **CA4** (R4, R16) — **Dado** "Bloquear e denunciar" escolhido sem motivo ou sem print, **quando** Gabriel confirma, **então** nada é gravado e a tela pede o que falta; a API responde `400` sem `reason` ou sem print.
- **CA5** (R7) — **Dado** Marcos bloqueado por Gabriel, **quando** Marcos envia uma mensagem para a conversa, **então** o ack devolve erro e nada é gravado nem emitido; o mesmo vale para Gabriel.
- **CA6** (R11) — **Dado** o modal aberto com uma opção escolhida, **quando** Gabriel seleciona "Cancelar" ou o "✕", **então** o modal fecha e nada é gravado.
- **CA7** (R12, R13) — **Dado** Marcos bloqueado, **quando** Gabriel seleciona "Desbloquear" no aviso da conversa ou no modal do escudo, **então** `user_blocks.deleted_at` é preenchido e o campo de digitação volta.
- **CA8** (R6) — **Dado** Marcos desbloqueado antes, **quando** Gabriel o bloqueia de novo, **então** a mesma linha de `user_blocks` volta a `deleted_at = NULL`, sem linha nova.
- **CA9** (R14) — **Dado** 1 contato bloqueado, **quando** Gabriel abre o modal "Contatos bloqueados", **então** vê "1 contato bloqueado" e o contato com "Desbloquear"; ao desbloquear, a lista fica vazia.
- **CA10** (R1) — **Dado** um visitante sem login, **quando** chama a rota de bloquear ou denunciar, **então** recebe `401`; **dado** um `ADMIN`, recebe `403`; **dado** Gabriel, **quando** tenta bloquear a si mesmo, **então** recebe `400`, e **quando** tenta moderar alguém sem conversa com ele, recebe `404`.
- **CA11** (R15) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-32980` (escudo no topo da conversa), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA12** (R15) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-34298` (modal bloquear ou denunciar), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- **CA13** (R15) — **Dado** a tela implementada aberta em 1280 px com os mesmos dados do frame, **quando** o print dela é comparado lado a lado com o print do frame `1160-37184` (contato bloqueado), **então** não há diferença de layout, medida, espaçamento, cor, fonte, texto, ícone ou imagem; e em 375, 768 e 1024 px o mesmo design se adapta sem quebra, corte nem rolagem horizontal.
- ~~**CA14**~~ removido: a linha "Contatos bloqueados" em Configurações (frame `1160-41305`) entra com a CCD051 (L9).
- **CA15** (R16) — **Dado** uma denúncia com 4 prints, um GIF ou um arquivo de 5 MB, **quando** Gabriel confirma, **então** a tela informa o limite e nada é gravado; a API responde `400` (ou `413` para o tamanho).
- **CA16** (R7, R17) — **Dado** Marcos bloqueado por Gabriel, **quando** Marcos abre a conversa, **então** vê "@gabriel bloqueou você. Vocês não podem mais trocar mensagens." no lugar do campo de digitação, e Gabriel não aparece no "Nova conversa" dele.
- **CA17** (R18) — **Dado** uma denúncia `PENDING` de Gabriel contra Marcos, **quando** Gabriel denuncia Marcos de novo, **então** a API responde `409` e a tela informa "Você já denunciou este contato. A moderação está analisando."; **dado** a denúncia dispensada, **então** a nova é gravada.
- **CA18** (R19) — **Dado** a denúncia do chat de Gabriel contra Marcos, **quando** o administrador abre a Fila de moderação, **então** vê o card com "Origem: Chat pessoal", o motivo, a descrição e o print, no filtro Críticos; **quando** dispensa a denúncia ou aplica uma sanção ao autor, **então** a denúncia sai da fila como dispensada ou resolvida, com o moderador e a data.
- **CA19** (R20) — **Dado** a API fora do ar, **quando** Gabriel confirma o bloqueio ou a denúncia, **então** o modal continua aberto com o que foi preenchido e informa o erro.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `user_blocks` | `blocker_id`, `blocked_id`, `deleted_at` | `(blocker_id, blocked_id)` único; desbloquear = soft delete, bloquear de novo restaura (ADR-015) |
| `reports` | `reporter_id`, `target_user_id`, `target_type` (`report_target_type`: `USER`, `PROFILE`…), `reason`, `description`, `status` (`report_status`, default `PENDING`) | `reason` obrigatório (90); `description` até 500; sem `deleted_at` de negócio (ADR-015, item 4) |
| `conversation_participants` | `conversation_id`, `user_id` | confere que há conversa com o contato (R1) |
| `report_evidences` | `report_id`, `url`, `sort_order` | tabela nova (ADR-073): de 1 a 3 prints por denúncia do chat (L3) |
| `messages` | — | a denúncia não anexa mensagens (L3) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Mensagens - conversas (escudo no topo) | [1160-32980](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-32980) | R2 | ✅ Bate |
| Mensagens - bloquear ou denunciar | [1160-34298](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-34298) | R2–R5, R11, R16 | ✅ Bate depois do ajuste no Figma de 26/11/2026: os prints no lugar de "Anexar as últimas 20 mensagens" (L3) e sem "em até 24h" (L10) |
| Mensagens - contato bloqueado | [1160-37184](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-37184) | R8, R10, R12 | ✅ Bate depois do ajuste no Figma de 26/11/2026: o botão "Desbloquear" no aviso (L8) |
| Configurações (linha "Contatos bloqueados") | [1160-41305](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=1160-41305) | — | ↪ Entra com a CCD051 (L9) |
| BackOffice - Gestão de Comunidade, Fila de moderação | [220-3524](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=220-3524) | R19 | ⚠️ O frame só desenha o card de mensagem de grupo; o card do chat segue o estilo dele (L7). O BackOffice do Figma não é editado |

- **O que falta no Figma** (implementar mesmo assim, no estilo da tela): R4 e R16 avisos de motivo e de print; R10 avisos
  de "Somente bloquear" e "Somente denunciar"; R12 o modal do escudo com o contato já bloqueado; R14 o modal "Contatos
  bloqueados"; R17 o aviso do lado de quem foi bloqueado; R19 o card do chat na fila; R20 o erro ao enviar.

## Fora do escopo

- "Remover contato" (L1): não existe; o caso de uso 47 passou a bloquear ou denunciar.
- Anexar as mensagens da conversa à denúncia (L3): a evidência é o print do usuário (ADR-073).
- A linha "Contatos bloqueados" em Configurações › Privacidade e a página de Configurações — CCD051 (L9).
- Denunciar uma mensagem específica do chat pessoal ("Denunciar mensagem" no menu da mensagem) — L2 da CCD045.
- Denunciar mensagem de grupo — CCD040. Denunciar perfil pela página pública — CCD050. Denunciar usuário pelo painel do vendedor — CCD090.
- Prazo de análise da moderação (L10).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O caso de uso diz "bloquear ou remover o contato"; a user story e o Figma dizem "bloquear ou denunciar". O DBML não tem tabela de contatos. "Remover contato" existe? O que faria (esconder a conversa)? Ajustar o `47`, FP 5? | Bloquear ou denunciar, como a user story e o Figma; "remover contato" não existe. Decisão do Daniel (26/11/2026), validada pelo PO (Felipe, 28/11/2026) | `47`, Finalidade e FP 3 |
| L2 | O `47` não fala de denúncia; a user story fala. Registrar a denúncia no caso de uso (passos e motivos)? | Sim: os passos da denúncia (motivos, descrição, prints) entram no caso de uso | `47`, FP 5–11 e FA 3–8 |
| L3 | Só no Figma: "Anexar as últimas 20 mensagens". O DBML não tem onde guardar as mensagens anexadas (`reports` não aponta para `messages`). Faz sentido implementar? | A evidência é o print do usuário: de 1 a 3, obrigatórios, PNG, JPG ou WEBP até 4 MB, na tabela nova `report_evidences`; "Anexar as últimas 20 mensagens" sai do Figma. Decisão do Daniel (26/11/2026), validada pelo PO (Felipe, 28/11/2026) | `47`, FP 5 e FA 3–6; ADR-073; DER; R16 |
| L4 | Os motivos são fixos ("Golpe / pagamento externo", "Assédio", "Spam", "Perfil falso")? Como ficam gravados em `reports.reason` (texto da tela ou código)? Mesma lista da CCD050? | Os 4 motivos do Figma, uma escolha só, gravados com o texto da tela em `reports.reason`; cada story de denúncia tem a sua lista | `47`, FP 5; R4 |
| L5 | Texto do botão e do aviso de sucesso para "Somente bloquear" e "Somente denunciar" (o frame só mostra "Bloquear e denunciar") | Botão e aviso conforme a opção: "Bloquear" / "Contato bloqueado" ("Ele não poderá mais te enviar mensagens."); "Bloquear e denunciar" / "Contato bloqueado e denunciado"; "Denunciar" / "Denúncia enviada" ("A moderação vai analisar a conversa.") | `47`, FP 7 e FP 11; R5, R10 |
| L6 | O que o contato bloqueado vê ao tentar enviar? Ele pode começar uma conversa nova com quem o bloqueou? | O bloqueado é avisado: "@<usuário> bloqueou você. Vocês não podem mais trocar mensagens." no lugar do campo; ele não acha quem o bloqueou no "Nova conversa" (CCD046) | `47`, FA 11; R17 |
| L7 | `target_type` da denúncia feita no chat: `USER` ou `PROFILE`? Quem analisa? A fila do BackOffice (CCD062) só trata `GROUP_MESSAGE` | `target_type = USER`. A Fila de moderação da Gestão de Comunidade (CCD062) passa a mostrar as denúncias do chat, feito nesta spec: card do chat com os prints, "Dispensar Denúncia" e "Aplicar sanção ao autor"; Golpe e Assédio em Críticos, Spam em Spam. Decisão do Daniel (26/11/2026), validada pelo PO (Felipe, 28/11/2026) | `47`, FP 10; `62`, FP 10–12; CCD062 L9; R19 |
| L8 | Contato já bloqueado: o `47`, FA 3, oferece desbloquear na hora; o Figma (`1160-37184`) manda para Configurações › Privacidade. Qual vale? | Desbloquear também na conversa: botão "Desbloquear" no aviso e no modal do escudo; o texto que leva a Configurações continua. O Figma ganhou o botão | `47`, FA 9–10; R8, R12 |
| L9 | A lista "Ver bloqueados" (`1160-41305`) não tem frame: pedir o desenho ao Gabriel | A API e o modal "Contatos bloqueados" ficam prontos nesta spec; a linha em Configurações entra com a CCD051 (Gabriel), que ainda não tem a página | R14; CCD051 |
| L10 | Só no Figma: o prazo "em até 24h" para a moderação. Faz sentido prometer o prazo? | Sem prazo: "A moderação analisa a conversa"; o "em até 24h" sai do Figma | `47`, FP 3; R3 |
| L11 | Denunciar o mesmo contato de novo cria outra denúncia ou é recusado? | Recusa com `409` enquanto houver denúncia `PENDING` do usuário contra o mesmo contato | `47`, FA 7–8; R18 |
| L12 | O ator é Cliente: `SELLER` e `ADMIN` também? (proposta: `CUSTOMER` e `SELLER`) | `CUSTOMER` e `SELLER`; o `ADMIN` recebe `403` | `47`, Atores; R1 |
| L13 | Os prints mostram uma conversa privada. Ficam no storage público do ADR-050 (servido em `/uploads` sem login) ou no privado do ADR-068? | Storage privado do ADR-068: `report_evidences.url` guarda a chave do arquivo, e o print só sai pela rota autenticada `GET /api/v1/admin/community/reports/:id/evidences/:evidenceId`, só para `ADMIN`. Decisão do PO (Felipe, 28/11/2026), na revisão do PR #68 | ADR-073, itens 3 e 4; DER (nota da coluna); `plano.md`; R16 |
