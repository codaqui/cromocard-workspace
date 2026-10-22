# CCD099 — Aplicar Sanção a Usuário

- **Status:** Rascunho
- **Fase:** Escopo Adicional
- **User story:** #603 `CCD099-Aplicar Sanção a Usuário` · responsável Lucas Oliveira Lima · Sprint 06
- **Caso de uso:** [99-aplicar-sancao-a-usuario.md](../../docs/Casos-De-Uso/99-aplicar-sancao-a-usuario.md) · índice: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade
- **Aprovação:** —

## Objetivo

> Como Administrador eu quero advertir, suspender por um prazo ou banir definitivamente um usuário, com justificativa, para punir quem descumpre as regras na medida da infração.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401` sem token, `403` para outro papel | Permissão | `99`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | As sanções ficam na fila de moderação e na Gestão de Usuários, mostrando as advertências anteriores | Tela | `99`, FP 1–2 |
| R3 | Justificativa obrigatória em toda sanção e prazo na suspensão | Campo | `99`, FP 4–5 e FA 7–8 |
| R4 | Advertir cria um registro em `user_warnings` e notifica o usuário | Ação | `99`, FP 6; DBML `user_warnings` |
| R5 | Suspender por prazo: `SUSPENDED` com `suspended_until`, revoga as sessões e a lista mostra o prazo | Ação | `99`, FP 7; DBML `users.suspended_until` |
| R6 | Banir definitivamente: `BLOCKED`, revoga as sessões e impede o login | Ação | `99`, FP 8; ADR-053, item 1 |
| R7 | Toda sanção grava `audit_logs` com a justificativa | Regra | `99`, FP 9 |
| R8 | "Remover Mensagem & Advertir Usuário" remove a mensagem, adverte e resolve a denúncia | Ação | `99`, FA 1–2 |
| R9 | Um job volta para `ACTIVE` quem teve a suspensão vencida | Regra | `99`, FA 3–4; ADR-010 |
| R10 | Reativar um usuário suspenso ou bloqueado | Ação | `99`, FA 5–6 |
| R11 | Usuário `BLOCKED` não loga nem renova o token | Regra | ADR-053, Consequências; ADR-005, item 6 |
| R12 | Advertir um grupo: status `WARNED`, com o selo "Advertido por Regras" | Ação | EA-062-02; DBML `group_status` |
| R13 | Categoria da denúncia e filtro da fila por gravidade | Campo | EA-062-04; DBML `reports.reason` |
| R14 | Na denúncia: idade da conta do autor, advertências anteriores e quantos membros denunciaram | Campo | EA-062-06 |

## Critérios de aceite

- **CA1** (R4, R7) — **Dado** uma denúncia pendente, **quando** o admin adverte o autor com justificativa, **então** o usuário ganha uma advertência, recebe a notificação e o log registra.
- **CA2** (R5) — **Dado** um usuário ativo, **quando** o admin suspende por 7 dias, **então** o status fica `SUSPENDED` até a data, as sessões caem e a lista mostra "Suspenso (7d)".
- **CA3** (R6, R11) — **Dado** um usuário ativo, **quando** o admin bane definitivamente, **então** o status fica `BLOCKED` e o login responde `403`.
- **CA4** (R3) — **Dado** o diálogo de sanção, **quando** o admin confirma sem justificativa, **então** a API responde `400`.
- **CA5** (R8) — **Dado** uma denúncia de mensagem, **quando** o admin escolhe "Remover Mensagem & Advertir", **então** a mensagem some, o autor é advertido e a denúncia fica `RESOLVED`.
- **CA6** (R9) — **Dado** uma suspensão vencida, **quando** o job roda, **então** o usuário volta a `ACTIVE`.
- **CA7** (R10) — **Dado** um usuário bloqueado, **quando** o admin reativa com justificativa, **então** o status volta a `ACTIVE`.
- **CA8** (R12) — **Dado** um grupo ativo, **quando** o admin adverte o grupo, **então** o status vira `WARNED` e a lista mostra o selo.
- **CA9** (R13, R14) — **Dado** denúncias de spam e de discurso de ódio, **quando** o admin filtra por "Críticos", **então** a fila mostra só as críticas, com idade da conta, advertências e número de denúncias.
- **CA10** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama uma das rotas, **então** recebe `403`.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `users` | `status`, `suspended_until` | coluna nova e valor `BLOCKED` (ADR-053) |
| `user_warnings` | todas | tabela nova (ADR-053) |
| `groups` | `status` | valor `WARNED` (ADR-053) |
| `reports` | `reason`, `status` | MVP |
| `refresh_tokens` | `revoked_at` | CCD004 |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Gestão de usuários | [208-1793](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=208-1793) | R2, R5, R6, R10 | ⚠️ Divergente |
| Comunidade | [220-3524](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=220-3524) | R2, R8, R12–R14 | ⚠️ Divergente |
| Logs do sistema | [228-2395](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=228-2395) | R7 | ✅ Bate |

- "Denunciado por: Algoritmo Heurístico" e "Link Malicioso Detectado" pedem detecção automática (L3).

## Fora do escopo

- Detecção automática de conteúdo (EA-062-05) — L3.
- Suspensão automática por número de advertências — L5.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Prazos de suspensão (proposta: 3, 7, 15 e 30 dias, a partir do "3 dias" e do "7d" do Figma) | pendente — proposta | — |
| L2 | O que é denúncia crítica (proposta: categorias "Spam/Golpe" e "Discurso de ódio/Ameaça"; filtros "Críticos" e "Spam") | pendente — proposta | — |
| L3 | Denúncia por detecção automática (EA-062-05) (proposta: não entra; não há caso de uso) | pendente — proposta | — |
| L4 | O que muda para o grupo advertido (proposta: só o selo; reativar volta a `ACTIVE`) | pendente — proposta | — |
| L5 | Advertências acumuladas suspendem sozinhas? (proposta: não) | pendente — proposta | — |
