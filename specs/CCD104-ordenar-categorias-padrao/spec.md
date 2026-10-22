# CCD104 — Ordenar Categorias Padrão

- **Status:** Planejada
- **Fase:** Escopo Adicional
- **User story:** #608 `CCD104-Ordenar Categorias Padrão` · responsável Gabriel Nascimento · Sprint 06
- **Caso de uso:** [104-ordenar-categorias-padrao.md](../../docs/Casos-De-Uso/104-ordenar-categorias-padrao.md) · índice: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO)

## Objetivo

> Como Administrador eu quero definir a ordem das categorias padrão e fixar uma no topo para controlar o que aparece primeiro no menu e na vitrine.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401` sem token, `403` para outro papel | Permissão | `104`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | Módulo com as categorias padrão na ordem atual: posição, nome, slug, quantidade de cartas e selo | Tela | `104`, FP 1–2; EA-066-01 |
| R3 | Mover uma categoria pelas setas ou arrastando | Ação | `104`, FP 3–4 |
| R4 | "Fixado no topo" coloca a categoria na primeira posição | Ação | `104`, FP 5–6 |
| R5 | "Salvar Ordem" grava `display_order` e `is_pinned` e registra em `audit_logs` | Regra | `104`, FP 7–8; DBML `categories` |
| R6 | Menu, filtros e vitrine exibem as categorias nessa ordem | Regra | `104`, FP 9 |
| R7 | Sair sem salvar descarta as mudanças | Ação | `104`, FA 1–2 |
| R8 | Setas desabilitadas na primeira e na última posição | Estado | `104`, FA 3–4 |
| R9 | O slug é gerado do nome e é único; recriar com o mesmo nome restaura a categoria excluída | Regra | ADR-053, item 4; ADR-015, item 7 |
| R10 | Selo de exibição (`STANDARD` ou `TRENDING`) editável no formulário de categoria | Campo | EA-066-01; DBML `categories.badge` |

## Critérios de aceite

- **CA1** (R2) — **Dado** cinco categorias padrão, **quando** o admin abre o módulo, **então** vê posição, nome, slug, quantidade de cartas e selo de cada uma.
- **CA2** (R3, R5) — **Dado** a ordem atual, **quando** o admin move Yu-Gi-Oh! para o segundo lugar e salva, **então** a ordem nova é gravada e o log registra.
- **CA3** (R4) — **Dado** nenhuma categoria fixada, **quando** o admin fixa One Piece, **então** One Piece vai para o primeiro lugar com o selo "Fixado no topo".
- **CA4** (R7) — **Dado** mudanças não salvas, **quando** o admin sai da tela, **então** a ordem anterior continua.
- **CA5** (R6) — **Dado** a ordem salva, **quando** um cliente abre o menu de categorias, **então** vê as categorias nessa ordem.
- **CA6** (R9) — **Dado** uma categoria "Pokémon TCG", **quando** é criada, **então** o slug é `pokemon-tcg`.
- **CA7** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama uma das rotas, **então** recebe `403`.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `categories` | `slug`, `display_order`, `is_pinned`, `badge` | colunas novas (ADR-053) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Configurações da plataforma — Módulo 2 | [228-3048](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=228-3048) | R2–R8, R10 | ✅ Bate |

- "Status: Exibição Primária/Normal" corresponde a fixada ou não.

## Fora do escopo

- Criar e editar categorias — CCD061.
- Hierarquia de subcategorias pela tela de ordem.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Uma ou várias categorias fixadas? (proposta: uma só) | Uma só | `104`, FP 5 |
| L2 | Quem define o selo? (proposta: o admin, no formulário de categoria da CCD061) | O admin, no formulário de categoria da CCD061 | `escopo-adicional.md`, EA-066-01 |
| L3 | Slug das categorias que já existem (proposta: a migration gera) | A migration gera | plano.md (migration) |
| L4 | Arrastar pelo teclado (proposta: as setas são a alternativa acessível) | As setas são a alternativa acessível | plano.md |
