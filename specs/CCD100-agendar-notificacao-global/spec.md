# CCD100 — Agendar Notificação Global

- **Status:** Rascunho
- **Fase:** Escopo Adicional
- **User story:** #604 `CCD100-Agendar Notificação Global` · responsável Felipe Consulim · Sprint 06
- **Caso de uso:** [100-agendar-notificacao-global.md](../../docs/Casos-De-Uso/100-agendar-notificacao-global.md) · índice: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Administrador eu quero agendar uma notificação global para uma data e hora futuras para comunicar novidades no momento certo.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401` sem token, `403` para outro papel | Permissão | `100`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | Opção "Disparo Imediato" ou "Agendar Horário" | Campo | `100`, FP 2 |
| R3 | Calendário e horário de liberação no fuso de Brasília (UTC-3) | Campo | `100`, FP 3–4 |
| R4 | Data e hora precisam ser futuras (`400`) | Regra | `100`, FP 6 e FA 1–2 |
| R5 | A notificação agendada grava `status = SCHEDULED`, `scheduled_at`, o link e `audit_logs` | Regra | `100`, FP 7; ADR-053, item 6 |
| R6 | Confirmação com o título, o público e o horário programado | Mensagem | `100`, FP 8 |
| R7 | Um job envia no horário e muda para `SENT`, com `sent_at` | Regra | `100`, FP 9; ADR-010 |
| R8 | Histórico com data e horário, título, público, canal e status | Tela | `100`, FP 10–11; EA-060-05 |
| R9 | Cancelar um agendamento na fila: `CANCELED` e `audit_logs` | Ação | `100`, FA 3–4 |

## Critérios de aceite

- **CA1** (R2–R6) — **Dado** o formulário preenchido, **quando** o admin agenda para amanhã às 20h30, **então** a API grava `SCHEDULED` com o horário e a tela confirma.
- **CA2** (R4) — **Dado** o formulário preenchido, **quando** o admin agenda para uma hora passada, **então** a API responde `400`.
- **CA3** (R7) — **Dado** um agendamento vencido, **quando** o job roda, **então** as notificações são criadas e o disparo fica `SENT` com `sent_at`.
- **CA4** (R9) — **Dado** um agendamento na fila, **quando** o admin cancela, **então** o status vira `CANCELED`, nada é enviado e o log registra.
- **CA5** (R8) — **Dado** disparos enviados, agendados e cancelados, **quando** o admin abre o histórico, **então** vê o status de cada um.
- **CA6** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama uma das rotas, **então** recebe `403`.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `global_notifications` | `reference_link`, `status`, `scheduled_at`, `sent_at` | colunas novas e enum `notification_dispatch_status` (ADR-053) |
| `notifications` | criadas no envio | MVP |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Notificação | [208-2380](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=208-2380) | R2, R8 | ✅ Bate |
| Adicionando notificação (agendamento) | [277-2689](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=277-2689) | R2–R4 | ✅ Bate |
| Notificação enviada | [277-2982](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=277-2982) | R6 | ⚠️ Divergente |

- "Assinada criptograficamente via SHA-256", "Certificado de operação" e "SLA garantido" são efeito visual.

## Fora do escopo

- Público e canais — CCD101.
- Editar um agendamento (L4).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Os destinatários são calculados no envio ou no agendamento? (proposta: no envio) | pendente — proposta | — |
| L2 | Antecedência mínima (proposta: 5 minutos) | pendente — proposta | — |
| L3 | Frequência do job (proposta: a cada minuto) | pendente — proposta | — |
| L4 | Editar um agendamento (proposta: não; cancelar e criar de novo) | pendente — proposta | — |
