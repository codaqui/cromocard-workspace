# CCD060 — Disparar Notificação Global

- **Status:** Rascunho
- **Fase:** MVP
- **User story:** #335 `CCD060-Disparar Notificação Global` · responsável Daniel Andrade · Sprint 07
- **Caso de uso:** [60-disparar-notificacao-global.md](../../docs/Casos-De-Uso/60-disparar-notificacao-global.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO)

## Objetivo

> Como Administrador eu quero ter um painel para criar e disparar notificações em massa para a base inteira de
> usuários informando novidades.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN` dispara; `401`/`403` | Permissão | `60`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | Tela em `/backoffice/notificacoes`, item "Notificação" do menu | Tela | `60`, FP 1–2; ADR-038 |
| R3 | Campo título, obrigatório, até 120 caracteres | Campo | `60`, FP 3 e FA 1; DBML `global_notifications.title` |
| R4 | Campo conteúdo, obrigatório, até 500 caracteres | Campo | `60`, FP 3 e FA 1; DBML `global_notifications.content` |
| R5 | Validação antes do envio, indicando os campos que faltam (`400` com `details`) | Regra | `60`, FP 4 e FA 1–4; ADR-006 |
| R6 | Confirmar o envio | Ação | `60`, FP 5 |
| R7 | Botão "Cancelar" ao lado do envio limpa o formulário sem enviar | Ação | `60`, FA 5–6 (L6) |
| R8 | O envio gera uma linha em `notifications` para cada usuário da plataforma, ligada ao disparo | Regra | `60`, FP 6; user-stories.md §8; DBML `notifications.global_notification_id` |
| R9 | A notificação entregue nasce não lida, com o título e o conteúdo do disparo | Estado | DBML `notifications` |
| R10 | O disparo é registrado em `global_notifications` com o admin e a quantidade de destinatários | Regra | `60`, FP 7; DBML `admin_id`, `recipient_count` |
| R11 | Modal "Notificação enviada" com título, público, canais e quantidade de destinatários, e os botões "Ver histórico de disparos" e "Voltar à central" | Mensagem | `60`, FP 8 (L7) |
| R12 | Resposta `201` com o disparo criado | Regra | ADR-011 |
| R13 | O disparo grava `audit_logs` | Regra | ADR-034; `.claude/rules/backend.md` |
| R14 | Recebem todos os usuários não excluídos e não suspensos, menos o próprio admin | Regra | `60`, FP 6 |
| R15 | Link de destino opcional, copiado para `reference_link` de cada notificação | Campo | `60`, FP 3; DBML `notifications.reference_link` |
| R16 | Histórico paginado dos disparos, dos mais recentes para os mais antigos, sem recorte de período | Tela | `60`, FP 2 (L8); ADR-011 |
| R17 | Pré-visualização de como a notificação aparece na central de notificações da plataforma | Tela | `60`, FP 2; EA-060-02; ADR-058 |

## Critérios de aceite

- **CA1** (R3–R6, R8–R12) — **Dado** 3 usuários ativos, **quando** o admin preenche título e conteúdo e confirma,
  **então** a API responde `201`, grava o disparo com `recipient_count = 3` e 3 notificações não lidas.
- **CA2** (R5) — **Dado** o título vazio ou o conteúdo acima de 500, **quando** envia, **então** a API responde `400`
  e a tela indica o campo.
- **CA3** (R7) — **Dado** o formulário preenchido, **quando** o admin clica em "Cancelar", **então** o formulário é
  limpo e nada é gravado.
- **CA4** (R14) — **Dado** um usuário suspenso e um excluído, **quando** o disparo acontece, **então** nenhum dos dois
  recebe.
- **CA5** (R11) — **Dado** o envio concluído, **quando** a API responde, **então** a tela mostra a confirmação com o
  total de destinatários e o histórico ganha a linha.
- **CA6** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama a rota, **então** recebe `403`.
- **CA7** (R17) — **Dado** título e conteúdo digitados, **quando** o admin olha a pré-visualização, **então** vê a
  notificação como item da central de notificações, com o título, o começo do texto e "agora".

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `global_notifications` | `admin_id`, `title`, `content`, `recipient_count`, `created_at` | fundação |
| `notifications` | `user_id`, `global_notification_id`, `title`, `message`, `type`, `reference_link`, `is_read` | fundação; lida pela CCD053 |
| `users` | `status`, `deleted_at` | destinatários |

## Telas (Figma)

Conferidas em 12/11/2026, depois do ajuste do Figma à documentação. Links: `https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=<frame>`.

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Notificação Global (formulário e histórico) | `208-2380` | R2–R7, R15–R17 | ✅ Bate |
| Notificação enviada | `277-2982` | R11 | ✅ Bate |
| Erros de validação | `827-1523` | R5 | ✅ Bate |

- Os seletores de público e canais são da CCD101; agendamento, status "Na fila"/"Cancelado" e cancelar agendamento,
  da CCD100.

## Fora do escopo

- Push do sistema operacional e e-mail: o DER só tem notificação dentro da plataforma, e não há app mobile (ADR-058).
- Agendamento e segmentação por público.
- Itens do Figma antigo que não entram (decisão de 12/11/2026, `escopo-adicional.md` §3): push, pré-visualização
  num celular, "telemetria", certificado de operação, ID de transmissão, taxa de entrega projetada, SLA e SHA-256.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Canal: só dentro do app (central de notificações)? (proposta: sim; emitir `notification:new` via Socket.IO fica para quando a CCD053 existir) | Só dentro do app (central de notificações); o evento `notification:new` via Socket.IO entra com a CCD053 | `60`, FP 6 |
| L2 | Quem recebe? (proposta: todos os usuários não excluídos e não suspensos, menos o próprio admin) | Todos os usuários não excluídos e não suspensos, menos o próprio admin | `60`, FP 6 |
| L3 | Agendamento e público do Figma (proposta: fora do MVP) | Fora do MVP; viraram a CCD100 e a CCD101 (escopo adicional) | CCD100; CCD101 |
| L4 | Link de destino: o Figma tem; o DER tem `notifications.reference_link`, mas `global_notifications` não guarda (proposta: campo opcional copiado para `reference_link` de cada notificação, sem guardar no disparo) | Link de destino opcional, copiado para `reference_link` de cada notificação, sem guardar no disparo | `60`, FP 3 |
| L5 | Valor de `notifications.type` (proposta: `GLOBAL`) e histórico (proposta: lista dos disparos, mais recentes primeiro) | `type = GLOBAL`; histórico dos disparos, dos mais recentes para os mais antigos | `60`, FP 2; ADR-051, item 2 |
| L6 | O que faz o "Cancelar" do formulário? | Limpa o formulário sem enviar. Decisão do PO (Daniel, 12/11/2026), na revisão do Figma | `60`, FA 5–6 |
| L7 | Como é a confirmação do envio? | Modal "Notificação enviada" com título, público, canais e destinatários; "Ver histórico de disparos" leva ao histórico da própria tela. Decisão do PO (Daniel, 12/11/2026), na revisão do Figma | `60`, FP 8 |
| L8 | O histórico tem recorte de 30 dias? | Não: paginado, do mais recente ao mais antigo. Decisão do PO (Daniel, 12/11/2026), na revisão do Figma | `60`, FP 2; ADR-011 |
