# CCD100 — Agendar Notificação Global

- **Status:** Planejada
- **Fase:** Escopo Adicional
- **User story:** #604 `CCD100-Agendar Notificação Global` · responsável Felipe Consulim · Sprint 06
- **Caso de uso:** [100-agendar-notificacao-global.md](../../docs/Casos-De-Uso/100-agendar-notificacao-global.md) · índice: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO); reaprovada em 2026-11-12, depois da revisão do Figma do painel admin

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
| R6 | Modal "Notificação agendada" com título, público, canais e horário programado | Mensagem | `100`, FP 8 |
| R7 | Um job envia no horário e muda para `SENT`, com `sent_at` | Regra | `100`, FP 9; ADR-010 |
| R8 | Histórico com data e horário, título, público, canal e status ("Na fila", "Entregue" ou "Cancelado") | Tela | `100`, FP 10–11; EA-060-05 |
| R9 | "Cancelar agendamento" na linha "Na fila" do histórico, com modal de confirmação: `CANCELED` e `audit_logs` | Ação | `100`, FA 3–4 (L5) |
| R10 | Com "Agendar Horário" marcado, o botão vira "Agendar notificação para N usuários" | Ação | `100`, FP 5 |

## Critérios de aceite

- **CA1** (R2–R6) — **Dado** o formulário preenchido, **quando** o admin agenda para amanhã às 20h30, **então** a API grava `SCHEDULED` com o horário e a tela confirma.
- **CA2** (R4) — **Dado** o formulário preenchido, **quando** o admin agenda para uma hora passada, **então** a API responde `400`.
- **CA3** (R7) — **Dado** um agendamento vencido, **quando** o job roda, **então** as notificações são criadas e o disparo fica `SENT` com `sent_at`.
- **CA4** (R9) — **Dado** um agendamento na fila, **quando** o admin clica em "Cancelar agendamento" e confirma no modal, **então** o status vira `CANCELED`, a linha mostra "Cancelado", nada é enviado e o log registra.
- **CA7** (R10) — **Dado** o formulário, **quando** o admin marca "Agendar Horário", **então** o calendário aparece e o botão vira "Agendar notificação para N usuários".
- **CA5** (R8) — **Dado** disparos enviados, agendados e cancelados, **quando** o admin abre o histórico, **então** vê o status de cada um.
- **CA6** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama uma das rotas, **então** recebe `403`.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `global_notifications` | `reference_link`, `status`, `scheduled_at`, `sent_at` | colunas novas e enum `notification_dispatch_status` (ADR-053) |
| `notifications` | criadas no envio | MVP |

## Telas (Figma)

Conferidas em 12/11/2026, depois do ajuste do Figma à documentação. Links: `https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=<frame>`.

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Notificação Global (histórico com status) | `208-2380` | R2, R8, R9 | ✅ Bate |
| Agendamento (calendário de novembro de 2026) | `277-2689` | R2–R4, R10 | ✅ Bate |
| Notificação agendada | `821-1118` | R6 | ✅ Bate |
| Erros de validação (horário no passado) | `827-1523` | R4 | ✅ Bate |
| Cancelar agendamento | `827-2006` | R9 | ✅ Bate |

## Fora do escopo

- Público e canais — CCD101.
- Editar um agendamento (L4).
- "Assinada criptograficamente via SHA-256", "Certificado de operação" e "SLA garantido": efeito visual, retirados do
  Figma em 12/11/2026.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Os destinatários são calculados no envio ou no agendamento? (proposta: no envio) | No envio | `100`, FP 9 |
| L2 | Antecedência mínima (proposta: 5 minutos) | 5 minutos | `100`, FP 6 |
| L3 | Frequência do job (proposta: a cada minuto) | A cada minuto | plano.md, Decisões técnicas (ADR-010) |
| L4 | Editar um agendamento (proposta: não; cancelar e criar de novo) | Não; cancelar e criar de novo | `100`, FA 5–6 |
| L5 | Onde se cancela um agendamento? | No botão "Cancelar agendamento" da linha "Na fila", com modal de confirmação; a linha passa a "Cancelado". Decisão do PO (Daniel, 12/11/2026), na revisão do Figma | `100`, FA 3–4 |
