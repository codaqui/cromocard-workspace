# CCD101 — Segmentar Notificação Global

- **Status:** Planejada
- **Fase:** Escopo Adicional
- **User story:** #605 `CCD101-Segmentar Notificação Global` · responsável Felipe Consulim · Sprint 06
- **Caso de uso:** [101-segmentar-notificacao-global.md](../../docs/Casos-De-Uso/101-segmentar-notificacao-global.md) · índice: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO)

## Objetivo

> Como Administrador eu quero enviar uma notificação global só para um público (colecionadores ativos ou vendedores) e escolher os canais para não incomodar quem não é o alvo.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401` sem token, `403` para outro papel | Permissão | `101`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | Público: toda a base, colecionadores ativos ou vendedores | Campo | `101`, FP 2 |
| R3 | O sistema mostra quantos usuários o público tem | Campo | `101`, FP 3 |
| R4 | Canais: notificação no app e e-mail | Campo | `101`, FP 4 |
| R5 | O envio vai só para o público e pelos canais escolhidos | Regra | `101`, FP 6 |
| R6 | O disparo grava `audience`, `channels`, `recipient_count` e `audit_logs` | Regra | `101`, FP 7; ADR-053, item 6 |
| R7 | Confirmação com o público selecionado | Mensagem | `101`, FP 8 |
| R8 | Público vazio não permite o envio | Regra | `101`, FA 1–2 |
| R9 | Pelo menos um canal é obrigatório | Regra | `101`, FA 3–4 |
| R10 | O histórico mostra o público e o canal de cada disparo | Tela | EA-060-05 |

## Critérios de aceite

- **CA1** (R2, R3) — **Dado** o formulário, **quando** o admin escolhe "Vendedores", **então** a tela mostra quantos vendedores vão receber.
- **CA2** (R4–R6) — **Dado** o público "Vendedores" e os canais app e e-mail, **quando** o admin envia, **então** só os vendedores recebem, no app e por e-mail, e o disparo grava público e canais.
- **CA3** (R8) — **Dado** um público sem usuários, **quando** o admin tenta enviar, **então** a API responde `422 EMPTY_AUDIENCE`.
- **CA4** (R9) — **Dado** nenhum canal marcado, **quando** o admin tenta enviar, **então** a API responde `400`.
- **CA5** (R10) — **Dado** disparos para públicos diferentes, **quando** o admin abre o histórico, **então** vê o público e o canal de cada um.
- **CA6** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama uma das rotas, **então** recebe `403`.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `global_notifications` | `audience`, `channels` | colunas novas (ADR-053) |
| `users` | `role`, `last_login_at` | `last_login_at` da CCD098 |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Notificação (histórico) | [208-2380](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=208-2380) | R10 | ✅ Bate |
| Notificação enviada | [277-2982](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=277-2982) | R7 | ⚠️ Divergente |

- O Figma não tem o seletor de público nem de canais no formulário; só o histórico e a confirmação mostram (L5).

## Fora do escopo

- Push no celular (L1).
- Segmento "Com saldo" (L3).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Push, citado no caso de uso, não tem infraestrutura (proposta: fora; só app e e-mail, ADR-053, item 6) | Fora; só app e e-mail, ADR-053, item 6 | `101`, FP 4; ADR-053, item 6 |
| L2 | Quem é "colecionador ativo" (proposta: `CUSTOMER` que entrou nos últimos 30 dias, por `last_login_at`) | `CUSTOMER` que entrou nos últimos 30 dias, por `last_login_at` | `101`, FP 2 |
| L3 | Segmento "Com saldo" do Figma (proposta: não entra; depende de carteira, que não existe) | Não entra; depende de carteira, que não existe | esta spec (Fora do escopo) |
| L4 | E-mail em massa (proposta: enviado em lotes fora da requisição, por um job) | Enviado em lotes fora da requisição, por um job | plano.md (ADR-010) |
| L5 | Seletor de público e de canais sem desenho (proposta: o Gabriel desenha no formulário da CCD060) | O Gabriel desenha no formulário da CCD060 | esta spec (Telas) |
