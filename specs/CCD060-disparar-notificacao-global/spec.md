# CCD060 — Disparar Notificação Global

- **Status:** Planejada
- **Fase:** MVP
- **User story:** #335 `CCD060-Disparar Notificação Global` · responsável Felipe Broetto · Sprint 07
- **Caso de uso:** [60-disparar-notificacao-global.md](../../docs/Casos-De-Uso/60-disparar-notificacao-global.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO)

## Objetivo

> Como Administrador eu quero ter um painel para criar e disparar notificações push em massa para a base inteira de
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
| R7 | Cancelar sem enviar | Ação | `60`, FA 5–6 |
| R8 | O envio gera uma linha em `notifications` para cada usuário da plataforma, ligada ao disparo | Regra | `60`, FP 6; user-stories.md §8; DBML `notifications.global_notification_id` |
| R9 | A notificação entregue nasce não lida, com o título e o conteúdo do disparo | Estado | DBML `notifications` |
| R10 | O disparo é registrado em `global_notifications` com o admin e a quantidade de destinatários | Regra | `60`, FP 7; DBML `admin_id`, `recipient_count` |
| R11 | Mensagem de sucesso ao admin | Mensagem | `60`, FP 8 |
| R12 | Resposta `201` com o disparo criado | Regra | ADR-011 |
| R13 | O disparo grava `audit_logs` | Regra | ADR-034; `.claude/rules/backend.md` |
| R14 | Recebem todos os usuários não excluídos e não suspensos, menos o próprio admin | Regra | `60`, FP 6 |
| R15 | Link de destino opcional, copiado para `reference_link` de cada notificação | Campo | `60`, FP 3; DBML `notifications.reference_link` |
| R16 | Histórico dos disparos, dos mais recentes para os mais antigos | Tela | `60`, FP 2 |

## Critérios de aceite

- **CA1** (R3–R6, R8–R12) — **Dado** 3 usuários ativos, **quando** o admin preenche título e conteúdo e confirma,
  **então** a API responde `201`, grava o disparo com `recipient_count = 3` e 3 notificações não lidas.
- **CA2** (R5) — **Dado** o título vazio ou o conteúdo acima de 500, **quando** envia, **então** a API responde `400`
  e a tela indica o campo.
- **CA3** (R7) — **Dado** o diálogo "Enviar para N usuários?", **quando** cancela, **então** nada é gravado.
- **CA4** (R14) — **Dado** um usuário suspenso e um excluído, **quando** o disparo acontece, **então** nenhum dos dois
  recebe.
- **CA5** (R11) — **Dado** o envio concluído, **quando** a API responde, **então** a tela mostra a confirmação com o
  total de destinatários e o histórico ganha a linha.
- **CA6** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama a rota, **então** recebe `403`.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `global_notifications` | `admin_id`, `title`, `content`, `recipient_count`, `created_at` | fundação |
| `notifications` | `user_id`, `global_notification_id`, `title`, `message`, `type`, `reference_link`, `is_read` | fundação; lida pela CCD053 |
| `users` | `status`, `deleted_at` | destinatários |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| administração - notificação | [208-2380](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=208-2380) | R2–R7 | ⚠️ Divergente |
| adicionando notificação (agendamento) | [277-2689](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=277-2689) | — | Fora do escopo (L3) |
| notificação enviada | [277-2982](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=277-2982) | R11 | ⚠️ Divergente |

- **Onde o Figma está errado:** o corpo da mensagem tem limite de 240 no Figma; o DER permite 500 (R4).
- **Fora da documentação no Figma:** agendamento (data e hora), público-alvo, canais push/e-mail, "SLA",
  "certificado de operação", "assinado via SHA-256".

## Fora do escopo

- Push do sistema operacional e e-mail: o DER só tem notificação dentro do app.
- Agendamento e segmentação por público.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Canal: só dentro do app (central de notificações)? (proposta: sim; emitir `notification:new` via Socket.IO fica para quando a CCD053 existir) | Só dentro do app (central de notificações); o evento `notification:new` via Socket.IO entra com a CCD053 | `60`, FP 6 |
| L2 | Quem recebe? (proposta: todos os usuários não excluídos e não suspensos, menos o próprio admin) | Todos os usuários não excluídos e não suspensos, menos o próprio admin | `60`, FP 6 |
| L3 | Agendamento e público do Figma (proposta: fora do MVP) | Fora do MVP; viraram a CCD100 e a CCD101 (escopo adicional) | CCD100; CCD101 |
| L4 | Link de destino: o Figma tem; o DER tem `notifications.reference_link`, mas `global_notifications` não guarda (proposta: campo opcional copiado para `reference_link` de cada notificação, sem guardar no disparo) | Link de destino opcional, copiado para `reference_link` de cada notificação, sem guardar no disparo | `60`, FP 3 |
| L5 | Valor de `notifications.type` (proposta: `GLOBAL`) e histórico (proposta: lista dos disparos, mais recentes primeiro) | `type = GLOBAL`; histórico dos disparos, dos mais recentes para os mais antigos | `60`, FP 2; ADR-051, item 2 |
