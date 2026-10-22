# CCD106 — Salvar Rascunho de Carta

- **Status:** Planejada
- **Fase:** Escopo Adicional
- **User story:** #610 `CCD106-Salvar Rascunho de Carta` · responsável Lucas Oliveira Lima · Sprint 06
- **Caso de uso:** [106-salvar-rascunho-de-carta.md](../../docs/Casos-De-Uso/106-salvar-rascunho-de-carta.md) · índice: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO)

## Objetivo

> Como Administrador eu quero salvar uma carta incompleta como rascunho, fora do catálogo, para terminar o cadastro depois.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401` sem token, `403` para outro papel | Permissão | `106`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | "Salvar como Rascunho" grava a carta com `status = DRAFT`, sem exigir todos os campos obrigatórios | Ação | `106`, FP 1–3; ADR-053, item 5 |
| R3 | O rascunho não aparece no catálogo, nas buscas nem nas coleções | Regra | `106`, FP 4 |
| R4 | O admin abre o rascunho pela Gestão de Catálogo | Ação | `106`, FP 5–6 |
| R5 | "Cadastrar Carta no Catálogo" valida tudo, muda para `ACTIVE` e registra em `audit_logs` | Regra | `106`, FP 7–8 |
| R6 | Publicar com campo obrigatório vazio indica o campo e mantém o rascunho | Regra | `106`, FA 1–2 |
| R7 | Excluir o rascunho (soft delete) | Ação | `106`, FA 3–4; ADR-015 |
| R8 | Ano de lançamento da carta | Campo | EA-061-06; DBML `cards.release_year` |
| R9 | Sem verso enviado, a carta usa o verso padrão da franquia | Regra | EA-061-07 |
| R10 | Aviso de possível carta duplicada antes de cadastrar | Regra | EA-061-08 |
| R11 | Imagem com no mínimo 1200×1600 px | Regra | EA-061-09 |

## Critérios de aceite

- **CA1** (R2, R3) — **Dado** o formulário só com o nome, **quando** o admin salva como rascunho, **então** a carta fica `DRAFT` e não aparece no catálogo público.
- **CA2** (R4) — **Dado** um rascunho salvo, **quando** o admin filtra por "Rascunhos" e abre, **então** o formulário vem com os dados salvos.
- **CA3** (R5) — **Dado** um rascunho completo, **quando** o admin publica, **então** a carta fica `ACTIVE` e o log registra.
- **CA4** (R6) — **Dado** um rascunho sem raridade, **quando** o admin publica, **então** a API responde `400` no campo e a carta continua `DRAFT`.
- **CA5** (R9) — **Dado** uma franquia com verso padrão, **quando** o admin cadastra sem verso, **então** a carta usa o verso padrão.
- **CA6** (R10) — **Dado** uma carta com o mesmo nome e numeração no álbum, **quando** o admin começa outra igual, **então** a tela avisa da possível duplicata.
- **CA7** (R11) — **Dado** uma imagem de 800×1000 px, **quando** o admin envia, **então** a API responde `400` com o tamanho mínimo.
- **CA8** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama uma das rotas, **então** recebe `403`.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `cards` | `status`, `release_year` | colunas novas e enum `card_status` (ADR-053) |
| `global_settings` | `catalog.default_backs` | chave nova (L2) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Cadastrar nova carta no catálogo | [278-3246](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=278-3246) | R2, R5, R8–R11 | ⚠️ Divergente |

- "Hash SHA-256 da imagem" é efeito visual.
- O Figma marca o verso como obrigatório; com o verso padrão (R9) ele passa a ser opcional, como no DER.

## Fora do escopo

- Duplicar carta — CCD105.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O que o rascunho exige no mínimo? (proposta: só o nome, porque `cards.name` é obrigatório no DER) | Só o nome, porque `cards.name` é obrigatório no DER | `106`, FP 3 |
| L2 | Onde fica o verso padrão de cada franquia? (proposta: chave `catalog.default_backs` em `global_settings`, por categoria) | Chave `catalog.default_backs` em `global_settings`, por categoria | `escopo-adicional.md`, EA-061-07 |
| L3 | O que conta como duplicata? (proposta: mesmo nome e numeração no mesmo álbum, ou mesmo nome sem álbum; só aviso, sem bloquear) | Mesmo nome e numeração no mesmo álbum, ou mesmo nome sem álbum; só aviso, sem bloquear | `escopo-adicional.md`, EA-061-08 |
| L4 | Onde os rascunhos aparecem? (proposta: filtro "Rascunhos" na lista de cartas) | Filtro "Rascunhos" na lista de cartas | `106`, FP 5 |
