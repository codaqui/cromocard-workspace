# CCD104 — Ordenar Categorias Padrão

- **Status:** Rascunho
- **Fase:** Escopo Adicional
- **User story:** #608 `CCD104-Ordenar Categorias Padrão` · responsável Lucas Oliveira Lima · Sprint 07
- **Caso de uso:** [104-ordenar-categorias-padrao.md](../../docs/Casos-De-Uso/104-ordenar-categorias-padrao.md) · índice: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO); reaprovada em 2026-11-12, depois da revisão do Figma do painel admin; volta a Rascunho em 2026-11-16, com as decisões L6–L9 e as lacunas pendentes L10–L17

## Objetivo

> Como Administrador eu quero definir a ordem das categorias padrão e fixar uma no topo para controlar o que aparece primeiro no menu e na vitrine.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401` sem token, `403` para outro papel | Permissão | `104`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | Módulo com as categorias padrão na ordem atual: posição, nome, slug, quantidade de cartas e selo | Tela | `104`, FP 1–2; EA-066-01 |
| R3 | Mover uma categoria pelas setas ou arrastando | Ação | `104`, FP 3–4 |
| R4 | O alfinete da linha fixa a categoria no topo: ela vai para a primeira posição com o selo "Fixado no topo"; só uma fica fixada, então fixar outra tira o fixado da anterior; o alfinete da fixada a desafixa | Ação | `104`, FP 5–6 e FA 5–6 (L6) |
| R5 | "Salvar Ordem" grava `display_order` e `is_pinned` e registra em `audit_logs` | Regra | `104`, FP 7–8; DBML `categories` |
| R6 | Menu, filtros e vitrine exibem as categorias nessa ordem | Regra | `104`, FP 9 |
| R7 | Sair sem salvar descarta as mudanças | Ação | `104`, FA 1–2 |
| R8 | Setas desabilitadas na primeira e na última posição | Estado | `104`, FA 3–4 |
| R9 | O slug é gerado do nome e é único; recriar com o mesmo nome restaura a categoria excluída | Regra | ADR-053, item 4; ADR-015, item 7 |
| R10 | Selo de exibição (`STANDARD` ou `TRENDING`, na tela "Padrão" e "Em alta") editável no formulário de categoria | Campo | EA-066-01; DBML `categories.badge` |

## Critérios de aceite

- **CA1** (R2) — **Dado** cinco categorias padrão, **quando** o admin abre o módulo, **então** vê posição, nome, slug, quantidade de cartas e selo de cada uma.
- **CA2** (R3, R5) — **Dado** a ordem atual, **quando** o admin move Yu-Gi-Oh! para o segundo lugar e salva, **então** a ordem nova é gravada e o log registra.
- **CA3** (R4) — **Dado** nenhuma categoria fixada, **quando** o admin fixa One Piece, **então** One Piece vai para o primeiro lugar com o selo "Fixado no topo".
- **CA4** (R7) — **Dado** mudanças não salvas, **quando** o admin sai da tela, **então** a ordem anterior continua.
- **CA5** (R6) — **Dado** a ordem salva, **quando** um cliente abre o menu de categorias, **então** vê as categorias nessa ordem.
- **CA6** (R9) — **Dado** uma categoria "Pokémon TCG", **quando** é criada, **então** o slug é `pokemon-tcg`.
- **CA7** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama uma das rotas, **então** recebe `403`.
- **CA8** (R4) — **Dado** Pokémon fixada, **quando** o admin seleciona o alfinete de Magic: The Gathering, **então** Magic vai para o primeiro lugar com o selo "Fixado no topo" e Pokémon deixa de estar fixada.
- **CA9** (R4) — **Dado** Pokémon fixada, **quando** o admin seleciona o alfinete de Pokémon, **então** Pokémon perde o selo "Fixado no topo".
- **CA10** (R8) — **Dado** o módulo aberto, **quando** o admin olha a primeira e a última linha, **então** a seta para cima da primeira e a seta para baixo da última estão desabilitadas.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `categories` | `slug`, `display_order`, `is_pinned`, `badge` | colunas novas (ADR-053) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Configurações Globais — Módulo 2 | [228-3048](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=228-3048) | R2–R8, R10 | ⚠️ Difere por decisão (16/11/2026): botão de alfinete na linha, que o frame não tem (L6); seta para baixo da última linha desabilitada, que o frame mostra habilitada (L7); verso mostrado como no frame, com a ação para depois (L8). Antes, ajustado em 12/11/2026: selos em português, nomes e números iguais ao Catálogo, Cancelar ao lado de Salvar ordem |
| Nova categoria (selo no formulário de categoria, desenhado em 12/11/2026) | [833-10832](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=833-10832) | R10 | ✅ Bate |

- O verso padrão na linha de cada categoria é da CCD066 (R17) e da CCD106. A CCD104 mostra a miniatura e o link
  "Trocar verso" / "Enviar verso" como no frame, com a ação levando para a página "em construção" até a CCD066/CCD106
  (L8).

## Fora do escopo

- Criar e editar categorias — CCD061.
- Enviar e trocar o verso padrão de cada categoria — CCD066 (R17) e CCD106 (L8).
- Hierarquia de subcategorias pela tela de ordem.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Uma ou várias categorias fixadas? (proposta: uma só) | Uma só | `104`, FP 5 |
| L2 | Quem define o selo? (proposta: o admin, no formulário de categoria da CCD061) | O admin, no formulário de categoria da CCD061 | `escopo-adicional.md`, EA-066-01 |
| L3 | Slug das categorias que já existem (proposta: a migration gera) | A migration gera | plano.md (migration) |
| L4 | Arrastar pelo teclado (proposta: as setas são a alternativa acessível) | As setas são a alternativa acessível | plano.md |
| L5 | O Figma tinha "Adicionar nova categoria" no módulo (registrada antes como uma segunda L3) | Sai; fica o link "Gerenciar categorias no Catálogo" (CCD061). Decisão do PO (Daniel, 12/11/2026), na revisão do Figma | CCD066, Fora do escopo |
| L6 | O frame `228-3048` mostra o selo "Fixado no topo", mas nenhum controle para fixar ou desafixar | Botão de alfinete na linha, ao lado das setas e no estilo delas; liga e desliga o fixado, e fixar outra tira o fixado da anterior. Decisão de Lucas Oliveira Lima, 16/11/2026 | `104`, FP 5–6 e FA 5–6; R4; Telas |
| L7 | No frame `228-3048`, a seta para baixo da última linha aparece habilitada; o `104`, FA 3–4, a desabilita | Segue a documentação: desabilitada, no estilo apagado da seta para cima da primeira linha. Decisão de Lucas Oliveira Lima, 16/11/2026 | R8; CA10; Telas |
| L8 | A linha mostra o verso padrão ("Trocar verso" / "Enviar verso"), que é da CCD066 (R17) e da CCD106 | Mostrar como no frame e deixar a ação para a CCD066/CCD106. Decisão de Lucas Oliveira Lima, 16/11/2026 | Telas; Fora do escopo |
| L9 | A CCD066 (página de Configurações e `settings.service`) ainda não foi implementada, e o plano da CCD104 depende dela | A CCD104 espera a CCD066 terminar; o desenvolvimento fica parado até lá. Decisão de Lucas Oliveira Lima, 16/11/2026 | esta spec |
| L10 | Para onde vai a categoria desafixada? (proposta: continua na posição atual) | pendente | — |
| L11 | O Módulo 2 grava `is_default` (CCD066), o verso (CCD066/CCD106) e a ordem (CCD104): um "Salvar" só ou um por assunto? Como as rotas de `/admin/settings` evitam que `/:key` capture `default-categories`? | pendente (depende da CCD066) | — |
| L12 | Onde a ordem vale para o cliente (R6, CA5)? Ainda não há endpoint público de categorias, e a página Categorias é da CCD027 | pendente | — |
| L13 | Quem entra na lista: só `is_default = true`, com categorias de álbum e de carta juntas? Como se conta "quantidade de cartas" numa categoria de álbum (Futebol)? Rascunhos contam? | pendente | — |
| L14 | Slug: muda ao renomear? Quando é `409` e quando restaura a excluída (o ADR-015, item 7, não lista `categories.slug`)? Pode ficar nulo, como no DBML? Como a migration desempata a ordem inicial e resolve slugs repetidos? | pendente | — |
| L15 | Selo: o select tem "Nenhum" (no Catálogo do frame `833-10832`, Yu-Gi-Oh! está sem selo)? A tabela de categorias passa a mostrar slug e selo e a buscar por slug, como no fundo desse frame? | pendente | — |
| L16 | Arrastar no celular: arrastar nativo do navegador (sem toque, com as setas como alternativa) ou biblioteca nova (pede ADR)? | pendente | — |
| L17 | A spec não trata a mensagem de sucesso (`104`, FP 9), o estado sem categoria padrão (Pré-condições) nem qual ação de auditoria usar; os CAs citam categorias que o seed não tem (One Piece, cinco padrão); o plano usa `PUT`, que o ADR-011 não permite | pendente | — |
