# CCD104 — Ordenar Categorias Padrão

- **Status:** Planejada
- **Fase:** Escopo Adicional
- **User story:** #608 `CCD104-Ordenar Categorias Padrão` · responsável Lucas Oliveira Lima · Sprint 07
- **Caso de uso:** [104-ordenar-categorias-padrao.md](../../docs/Casos-De-Uso/104-ordenar-categorias-padrao.md) · índice: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade · revisada em 2026-11-16 e 2026-11-17 por Lucas Oliveira Lima (L6–L18)
- **Aprovação:** 2026-10-22, Daniel Andrade (PO); reaprovada em 2026-11-12, depois da revisão do Figma do painel admin; volta a Rascunho em 2026-11-16; reaprovada em 2026-11-17, quando o PO, Felipe Consulim, confirmou as decisões L6–L18 (tomadas por Lucas Oliveira Lima em 16 e 17/11/2026) e aceitou o ADR-062

## Objetivo

> Como Administrador eu quero definir a ordem das categorias padrão e fixar uma no topo para controlar o que aparece primeiro no menu e na vitrine.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401` sem token, `403` para outro papel | Permissão | `104`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | Módulo com as categorias padrão na ordem atual: posição, nome, slug, quantidade de cartas e selo. A quantidade soma as cartas não excluídas da categoria e das subcategorias, direto ou pelos álbuns delas | Tela | `104`, FP 1–2 (L13); EA-066-01 |
| R3 | Mover uma categoria pelas setas ou arrastando pela alça da linha (arrastar com o mouse; no toque e no teclado, as setas) | Ação | `104`, FP 3–4 (L4, L16) |
| R4 | O alfinete da linha fixa a categoria no topo: ela vai para a primeira posição com o selo "Fixado no topo"; só uma fica fixada, então fixar outra tira o fixado da anterior; o alfinete da fixada a desafixa, e ela continua na posição em que está | Ação | `104`, FP 5–6 e FA 5–6 (L6, L10) |
| R5 | "Salvar ordem" grava, no `PATCH /admin/settings/default-categories` da CCD066, a lista na ordem da tela (`display_order`) com `is_pinned`, junto com as categorias padrão e os versos, e registra `DEFAULT_CATEGORIES_UPDATED` em `audit_logs` com a ordem antes e depois | Regra | `104`, FP 7–8 (L11, L17); DBML `categories` |
| R6 | A API devolve as categorias padrão ordenadas: a fixada primeiro, depois por `display_order`. Menu, filtros e vitrine aplicam essa ordem nas stories deles (CCD001 e CCD027) | Regra | `104`, FP 9; `01`, FP 2; `27`, FP 1 (L12) |
| R7 | Sair sem salvar, ou "Cancelar", descarta as mudanças | Ação | `104`, FA 1–2 |
| R8 | Setas desabilitadas na primeira e na última posição | Estado | `104`, FA 3–4 (L7) |
| R9 | O slug é gerado do nome e refeito quando a categoria é renomeada; é único entre as categorias não excluídas: repetido responde `409 SLUG_TAKEN` no campo nome; uma categoria excluída com o mesmo slug não bloqueia e não é restaurada | Regra | `61`, FP 5–6; ADR-053, item 4; ADR-062 (L14) |
| R10 | Selo de exibição opcional no formulário de categoria: "Nenhum" (nulo), "Padrão" (`STANDARD`) ou "Em alta" (`TRENDING`), começando em "Nenhum" | Campo | `61`, FP 5; EA-066-01; DBML `categories.badge` (L15) |
| R11 | A aba Categorias do Catálogo mostra o slug abaixo do nome, o selo, a quantidade de cartas (mesma regra do R2) e busca por nome ou slug | Tela | `61`, FP 2; EA-061-10 (L15) |
| R12 | Ao salvar, o aviso "Categorias padrão atualizadas" da CCD066; sem nenhuma categoria padrão, o módulo mostra só "Adicionar categoria padrão" | Mensagem | `104`, FP 9 e Pré-condições (L17) |
| R13 | A migration gera o slug das categorias existentes (repetidos ganham sufixo `-2`, `-3`…, pela ordem de criação) e numera `display_order` em ordem alfabética, sem nenhuma fixada | Regra | ADR-062, item 3 (L3, L14) |
| R14 | A categoria fixada fica sempre no topo: ela não desce e nenhuma outra passa por cima dela (setas desabilitadas e arrastar sem efeito) até ser desafixada | Estado | `104`, FA 7–8 (L21) |

## Critérios de aceite

- **CA1** (R2) — **Dado** as categorias padrão do seed (Futebol, Magic: The Gathering e Pokémon), **quando** o admin abre o módulo, **então** vê posição, nome, slug, quantidade de cartas e selo de cada uma, e Futebol soma as cartas dos álbuns das subcategorias dela.
- **CA2** (R3, R5) — **Dado** a ordem Futebol, Magic: The Gathering, Pokémon, **quando** o admin move Pokémon para o primeiro lugar e salva, **então** a ordem nova é gravada e o log registra `DEFAULT_CATEGORIES_UPDATED` com a ordem antes e depois.
- **CA3** (R4) — **Dado** nenhuma categoria fixada, **quando** o admin fixa Magic: The Gathering, **então** Magic vai para o primeiro lugar com o selo "Fixado no topo".
- **CA4** (R7) — **Dado** mudanças não salvas, **quando** o admin sai da tela ou seleciona "Cancelar", **então** a ordem anterior continua.
- ~~**CA5**~~ removido: menu, filtros e vitrine são telas das stories CCD001 e CCD027, que aplicam a ordem (L12). A ordem devolvida pela API está no CA11.
- **CA6** (R9) — **Dado** nenhuma categoria "One Piece", **quando** o admin a cria, **então** o slug é `one-piece`.
- **CA7** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama uma das rotas, **então** recebe `403`.
- **CA8** (R4) — **Dado** Pokémon fixada, **quando** o admin seleciona o alfinete de Magic: The Gathering, **então** Magic vai para o primeiro lugar com o selo "Fixado no topo" e Pokémon deixa de estar fixada.
- **CA9** (R4) — **Dado** Pokémon fixada na primeira posição, **quando** o admin seleciona o alfinete de Pokémon, **então** Pokémon perde o selo "Fixado no topo" e continua na primeira posição.
- **CA10** (R8) — **Dado** o módulo aberto, **quando** o admin olha a primeira e a última linha, **então** a seta para cima da primeira e a seta para baixo da última estão desabilitadas.
- **CA11** (R6) — **Dado** Pokémon fixada e a ordem salva Futebol, Magic: The Gathering, **quando** `GET /admin/settings/default-categories` é chamado, **então** vem Pokémon, Futebol e Magic, nessa ordem.
- **CA12** (R9) — **Dado** Yu-Gi-Oh! com o slug `yu-gi-oh`, **quando** o admin a renomeia para "Yu-Gi-Oh! TCG", **então** o slug passa a `yu-gi-oh-tcg`.
- **CA13** (R9) — **Dado** Pokémon ativa, **quando** o admin cria "Pokemon", **então** recebe `409 SLUG_TAKEN` no campo nome; **dado** uma categoria "One Piece" excluída, **quando** o admin cria "One Piece", **então** uma categoria nova é criada e a excluída continua excluída.
- **CA14** (R10, R11) — **Dado** o formulário de categoria, **quando** o admin salva com "Em alta", **então** o selo aparece no módulo e na aba Categorias; **quando** salva com "Nenhum", **então** a categoria fica sem selo.
- **CA15** (R11) — **Dado** a aba Categorias do Catálogo, **quando** o admin busca `magic-the`, **então** encontra Magic: The Gathering pelo slug, com o selo e a quantidade de cartas na linha.
- **CA16** (R13) — **Dado** categorias já gravadas antes da migration, duas delas com nomes que geram o mesmo slug ("Pokémon TCG" e "Pokemon TCG"), **quando** ela roda, **então** cada uma tem slug, a criada depois ganha o sufixo `-2`, as categorias padrão ficam em ordem alfabética e nenhuma fica fixada.
- **CA17** (R14) — **Dado** Pokémon fixada na primeira posição, **quando** o admin olha a seta para baixo de Pokémon e a seta para cima da segunda linha, ou arrasta outra categoria para cima de Pokémon, **então** as setas estão desabilitadas e a ordem não muda.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `categories` | `slug`, `display_order`, `is_pinned`, `badge` | colunas novas (ADR-053, item 4); `slug` com índice único parcial (ADR-062) |
| `categories` | `is_default`, `parent_category_id`, `name`, `deleted_at` | quem entra na lista (CCD066, R10), subcategorias na contagem, slug |
| `cards` | `category_id`, `album_id`, `deleted_at` | contagem direta e pelos álbuns (R2) |
| `albums` | `category_id`, `deleted_at` | contagem pelos álbuns (R2) |
| `global_settings` | `catalog.default_backs` | os versos, gravados no mesmo `PATCH` (CCD066, ADR-061) |
| `audit_logs` | `action`, `details` | `DEFAULT_CATEGORIES_UPDATED`, já existente (CCD066) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Configurações Globais — Módulo 2 | [228-3048](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=228-3048) | R2–R8, R12 | ⚠️ Difere por decisão: botão de alfinete na linha, que o frame não tem (L6); seta para baixo da última linha desabilitada, que o frame mostra habilitada (L7); a fixada não desce, com a seta para baixo dela desabilitada, que o frame mostra habilitada (L21); verso como no frame, com a ação da CCD066 (L8); "Adicionar categoria padrão" e remover na linha, da CCD066 (L9 da CCD066). O botão volta a "Salvar ordem", como no frame (L18) |
| Nova categoria (selo no formulário) | [833-10832](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=833-10832) | R9, R10 | ✅ Bate; o select tem também "Nenhum", que o frame não abre (L15) |
| Catálogo — aba Categorias (fundo do mesmo frame) | [833-10832](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=833-10832) | R11 | ✅ Segue o frame: slug abaixo do nome, selo, coluna Cartas e busca por nome ou slug (L15); sem a descrição na lista (L22) |

- O verso padrão na linha de cada categoria é da CCD066 (R17), já implementado: a CCD104 só acrescenta posição,
  alça, setas, alfinete, slug, quantidade de cartas e selo à mesma linha.

## Fora do escopo

- Cadastrar, editar e excluir categorias — CCD061. A CCD104 só acrescenta slug e selo ao formulário e as colunas da aba.
- Enviar e trocar o verso padrão de cada categoria — CCD066 (R17) e CCD106.
- Endpoint público e telas públicas de categorias (menu, filtros e vitrine) — CCD001 e CCD027 (L12).
- Arrastar com o dedo no celular: no toque, as setas fazem o mesmo (L16).
- Hierarquia de subcategorias pela tela de ordem.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Uma ou várias categorias fixadas? (proposta: uma só) | Uma só | `104`, FP 5 |
| L2 | Quem define o selo? (proposta: o admin, no formulário de categoria da CCD061) | O admin, no formulário de categoria da CCD061 | `escopo-adicional.md`, EA-066-01 |
| L3 | Slug das categorias que já existem (proposta: a migration gera) | A migration gera | R13; ADR-062, item 3 |
| L4 | Arrastar pelo teclado (proposta: as setas são a alternativa acessível) | As setas são a alternativa acessível | R3 |
| L5 | O Figma tinha "Adicionar nova categoria" no módulo (registrada antes como uma segunda L3) | Sai; fica o link "Gerenciar categorias no Catálogo" (CCD061). Decisão do PO (Daniel, 12/11/2026), na revisão do Figma | CCD066, Fora do escopo |
| L6 | O frame `228-3048` mostra o selo "Fixado no topo", mas nenhum controle para fixar ou desafixar | Botão de alfinete na linha, ao lado das setas e no estilo delas; liga e desliga o fixado, e fixar outra tira o fixado da anterior. Decisão de Lucas Oliveira Lima, 16/11/2026 | `104`, FP 5–6 e FA 5–6; R4; Telas |
| L7 | No frame `228-3048`, a seta para baixo da última linha aparece habilitada; o `104`, FA 3–4, a desabilita | Segue a documentação: desabilitada, no estilo apagado da seta para cima da primeira linha. Decisão de Lucas Oliveira Lima, 16/11/2026 | R8; CA10; Telas |
| L8 | A linha mostra o verso padrão ("Trocar verso" / "Enviar verso"), que é da CCD066 (R17) e da CCD106 | Mostrar como no frame e deixar a ação para a CCD066/CCD106. Decisão de Lucas Oliveira Lima, 16/11/2026. Em 17/11/2026 a CCD066 já implementou o verso na linha (PR 21 do frontend) | Telas; Fora do escopo |
| L9 | A CCD066 (página de Configurações e `settings.service`) ainda não foi implementada, e o plano da CCD104 depende dela | A CCD104 espera a CCD066 terminar. Decisão de Lucas Oliveira Lima, 16/11/2026. Em 17/11/2026, o backend da CCD066 está no `develop` (#28) e o frontend no PR 21 | esta spec |
| L10 | Para onde vai a categoria desafixada? | Continua na posição em que está, até o admin movê-la. Decisão de Lucas Oliveira Lima, 17/11/2026 | `104`, FA 6; R4; CA9 |
| L11 | O Módulo 2 grava `is_default` e o verso (CCD066) e a ordem (CCD104): um "Salvar" só ou um por assunto? | Um só: o `PATCH /admin/settings/default-categories` da CCD066 recebe a lista na ordem da tela e `isPinned` em cada item; sem rota nova, o que também tira o `PUT .../order` do plano e o risco de `/:key` capturar a rota. Decisão de Lucas Oliveira Lima, 17/11/2026 | `104`, FP 8; R5 |
| L12 | Onde a ordem vale para o cliente (R6, CA5)? Ainda não há endpoint público de categorias, e a página Categorias é da CCD027 | A CCD104 grava a ordem e a API admin devolve as categorias ordenadas; menu, filtros e vitrine aplicam a ordem nas stories deles. Decisão de Lucas Oliveira Lima, 17/11/2026 | `01`, FP 2; `27`, FP 1; R6; CA5 riscado; Fora do escopo |
| L13 | Quem entra na lista e como se conta "quantidade de cartas" numa categoria de álbum (Futebol)? | Entra quem a CCD066 definiu (raiz, não excluída, `is_default`). A quantidade soma as cartas não excluídas da categoria e das subcategorias, direto ou pelos álbuns; quando a CCD106 criar o rascunho, os rascunhos ficam de fora. Decisão de Lucas Oliveira Lima, 17/11/2026 | `104`, FP 2; EA-066-01; R2 |
| L14 | Slug: muda ao renomear? Quando é `409` e quando restaura a excluída? Como a migration desempata a ordem inicial e resolve slugs repetidos? | Acompanha o nome; único só entre as não excluídas, com `409 SLUG_TAKEN` e sem restaurar (índice parcial, ADR-062, que abre exceção ao item 7 do ADR-015); a migration numera em ordem alfabética, sem fixada, e resolve repetidos com sufixo. A coluna continua aceitando nulo, como no DBML, mas a migration e o cadastro sempre geram o slug. Como o slug muda ao renomear, nenhuma tela pode guardar o slug como identificador fixo: quando a CCD027 usar o slug na URL, a spec dela decide o que fazer com o slug antigo (redirecionar ou buscar pelo id). Hoje nenhuma rota usa o slug. Decisão de Lucas Oliveira Lima, 17/11/2026 | `61`, FP 5–6; ADR-062; DBML `categories`; R9, R13 |
| L15 | Selo: o select tem "Nenhum"? A aba Categorias do Catálogo passa a mostrar slug, selo e quantidade e a buscar por slug, como no fundo do frame `833-10832`? | Sim aos dois: "Nenhum", "Padrão" e "Em alta", começando em "Nenhum"; a aba segue o frame. Decisão de Lucas Oliveira Lima, 17/11/2026 | `61`, FP 2 e FP 5; EA-061-10; EA-066-01; R10, R11 |
| L16 | Arrastar no celular: nativo do navegador ou biblioteca nova? | Nativo do navegador (HTML5), sem dependência nem ADR; no toque e no teclado, as setas. Decisão de Lucas Oliveira Lima, 17/11/2026 | R3; Fora do escopo |
| L17 | Mensagem de sucesso, estado sem categoria padrão, ação de auditoria e dados dos CAs | Reaproveita o aviso "Categorias padrão atualizadas", o estado vazio e a ação `DEFAULT_CATEGORIES_UPDATED` da CCD066; os CAs usam as categorias do seed. Decisão de Lucas Oliveira Lima, 17/11/2026 | R5, R12; CAs |
| L18 | O frame diz "Salvar ordem"; a CCD066 (L20) chamou o botão de "Salvar categorias", porque ele não salvava ordem | Segue o Figma: "Salvar ordem". Decisão de Lucas Oliveira Lima, 17/11/2026 | Telas |
| L19 | O Figma (`228-3048`) chama o módulo de "Módulo 2: Categorias padrão", e o `104` (FP 1) dizia "Ordenação e Gestão de Categorias Padrão" | Segue o Figma e a CCD066, já mesclada: "Módulo 2: Categorias padrão"; o FP 1 do `104` foi ajustado. Decisão de Lucas Oliveira Lima, 17/11/2026 | `104`, FP 1; Telas |
| L20 | No Figma (`228-3048`, `833-10832`) o selo "Padrão" aparece nas categorias padrão e o Pokémon só tem "Em alta": o `badge` depende de `is_default`? | Independente: o admin escolhe o selo (Nenhum, Padrão ou Em alta) e uma categoria padrão pode ficar sem selo ou com "Em alta". O selo "Fixado no topo" aparece junto do selo de exibição. Decisão de Lucas Oliveira Lima, 17/11/2026 | R2, R4, R10; L15 |
| L21 | O que acontece quando o admin move a categoria fixada ou passa outra por cima dela? (achado da revisão do backend e do frontend) | Bloqueia: a fixada não desce e nenhuma outra a ultrapassa, com as setas desabilitadas e o arrastar sem efeito; ela só sai do topo ao ser desafixada. Decisão de Lucas Oliveira Lima, 17/11/2026, confirmada pelo PO (Felipe Consulim) na revisão do PR #27, em 18/11/2026 | `104`, FA 7–8; R14; CA17 |
| L22 | A aba Categorias do Catálogo mostrava a descrição da categoria; o frame `833-10832` mostra só nome, slug e selo na coluna "Nome e slug" | Segue o Figma: a lista não mostra a descrição, que continua no formulário de edição. Decisão do PO (Felipe Consulim) na revisão do PR #27, 18/11/2026 | `61`, FP 2; R11; Telas |
