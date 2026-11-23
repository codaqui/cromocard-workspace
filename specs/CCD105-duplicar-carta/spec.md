# CCD105 — Duplicar Carta

- **Status:** Implementada
- **Fase:** Escopo Adicional
- **User story:** #609 `CCD105-Duplicar Carta` · responsável Lucas Oliveira Lima · Sprint 06
- **Caso de uso:** [105-duplicar-carta.md](../../docs/Casos-De-Uso/105-duplicar-carta.md) · índice: [escopo-adicional.md](../../docs/Casos-De-Uso/escopo-adicional.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-22 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO); reaprovada em 2026-11-12, depois da revisão do Figma do painel admin; reaprovada em 2026-11-19 por Lucas Oliveira Lima, com a revisão do plano e as decisões L7–L13, e de novo com a L14; reaprovada em 2026-11-20 por Lucas Oliveira Lima, com a L15 e a L16

## Objetivo

> Como Administrador eu quero criar uma carta a partir de outra já cadastrada para não digitar de novo os dados em comum.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401` sem token, `403` para outro papel | Permissão | `105`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | A ação "Duplicar" abre o formulário "Duplicar carta" preenchido com nome, franquia, álbum, raridade, idioma, variantes e descrição da carta de origem, sem numeração, código e imagens | Ação | `105`, FP 1–2 (L11) |
| R3 | O formulário valida como num cadastro novo | Regra | `105`, FP 3–5 |
| R4 | A carta nova é gravada e registrada em `audit_logs` | Regra | `105`, FP 6 |
| R5 | Numeração já usada no álbum responde erro | Regra | `105`, FA 1–2; DBML `cards (album_id, number)` |
| R6 | Cancelar não cria a carta | Ação | `105`, FA 3–4 |
| R7 | Indicadores: total de álbuns (não excluídos), álbuns licenciados e, embaixo deles, os pendentes de revisão; substituem os indicadores da CCD061 | Campo | EA-061-01 (L2, L8) |
| R8 | Código da carta (único, com "Este código já está em uso por <nome da carta>." quando repete) e etiquetas de variante | Campo | EA-061-02 (L10); ADR-053, item 5 |
| R9 | Filtros por álbum e por ano e chips dos filtros ativos com "Limpar todos os filtros" | Campo | EA-061-03 (L5) |
| R10 | Seleção de várias cartas e "Excluir selecionadas", com modal de confirmação e motivo obrigatório; as cartas usadas em coleções não são excluídas e o aviso diz quais | Ação | EA-061-04 (L3, L6, L13); `61`, FA 7–8 |
| R11 | A busca da lista de cartas encontra a carta também pelo código | Campo | `61`, FP 2; EA-061-02 (L9) |

## Critérios de aceite

- **CA1** (R2) — **Dado** uma carta cadastrada, **quando** o admin clica em "Duplicar", **então** o formulário abre com nome, franquia, álbum, raridade, idioma, variantes e descrição da carta de origem, sem numeração, código e imagens.
- **CA2** (R3, R4) — **Dado** o formulário duplicado com nova numeração e imagens, **quando** o admin confirma, **então** a carta nova é criada e o log registra.
- **CA3** (R5) — **Dado** o formulário duplicado com a mesma numeração no mesmo álbum, **quando** o admin confirma, **então** a API responde `409` e nada é criado.
- **CA4** (R7) — **Dado** álbuns ativos e solicitações de álbum pendentes, **quando** o admin abre o catálogo, **então** vê o total, os licenciados e os pendentes.
- **CA5** (R8) — **Dado** um código já usado, **quando** o admin cadastra outra carta com ele, **então** a API responde `409` no campo `code` e a tela mostra "Este código já está em uso por <nome da carta>.".
- **CA6** (R9) — **Dado** filtros de franquia e álbum aplicados, **quando** o admin clica em "Limpar todos os filtros", **então** a lista volta sem filtros.
- **CA7** (R10) — **Dado** cinco cartas selecionadas, **quando** o admin exclui em lote com motivo, **então** as cinco recebem `deleted_at` e o log registra cada uma.
- **CA8** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama uma das rotas, **então** recebe `403`.
- **CA9** (R10) — **Dado** cinco cartas selecionadas, duas delas em coleções, **quando** o admin exclui em lote com motivo, **então** só as três sem coleção recebem `deleted_at` e o aviso lista as duas que ficaram. Depende da CCD014 para valer de ponta a ponta (L14).
- **CA10** (R11) — **Dado** uma carta com o código `CRD-POK-0004`, **quando** o admin busca `POK-0004`, **então** a carta aparece na lista.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `cards` | `code`, `variants` | colunas novas (ADR-053) |
| `albums` | `status`, `year` | MVP |
| `catalog_requests` | `type = ALBUM`, `status` | pendentes de revisão |

## Telas (Figma)

Conferidas em 12/11/2026, depois do ajuste do Figma à documentação, e de novo em 19/11/2026 (L8–L13). Links: `https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=<frame>`.

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Catálogo (indicadores, filtros, código e variantes) | `208-2895` | R7–R9, R11 | ✅ Bate, com o filtro de status da CCD106 desabilitado (L12) |
| Duplicar carta | `832-6457` | R2, R3, R6 | ✅ Bate, com os elementos da CCD106 desabilitados (L12) |
| Erros de validação (numeração e código repetidos) | `832-7170` | R5, R8 | ✅ Bate, com os elementos da CCD106 desabilitados (L12) |
| Excluir em lote | `832-4908` | R10 | ✅ Bate (L15); o aviso depois da exclusão não tem frame e segue o estilo da tela (L13) |

- "População" e "Preço médio" são da CCD097.
- Da CCD106 (rascunho), os frames mostram "Ano de lançamento", "Salvar como Rascunho", o verso padrão da franquia, o
  aviso de carta parecida, o filtro de status e a etiqueta "Rascunho". "Ano de lançamento", "Salvar como Rascunho" e o
  filtro de status aparecem desabilitados; o verso padrão e o aviso de carta parecida ficam ocultos, porque mostrariam
  dados que ainda não existem; a etiqueta "Rascunho" não aparece porque ainda não há rascunhos (L12).

## Fora do escopo

- População e preço médio — CCD097.
- Importação em lote por CSV — CCD061.
- "+420 esta semana" no total de álbuns: sem origem, retirado do Figma em 12/11/2026.
- Consultar `collection_cards` para saber se a carta está em coleções — CCD014 (L14).
- Funcionar o rascunho, o ano de lançamento, o verso padrão e a checagem de carta parecida — CCD106 (aqui só aparecem
  desabilitados, L12).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Duplicar no backend ou só no frontend? (proposta: só no frontend, abrindo o formulário de criar; sem rota nova) | Só no frontend, abrindo o formulário de criar; sem rota nova | plano.md, Decisões técnicas |
| L2 | "Álbuns licenciados" e "pendentes de revisão" (proposta: licenciado = álbum `ACTIVE`; pendente = solicitação de álbum `PENDING`) | Licenciado = álbum `ACTIVE`; pendente = solicitação de álbum `PENDING` | `escopo-adicional.md`, EA-061-01 |
| L3 | Ação em lote sobre a seleção, que o Figma não desenha (proposta: excluir em lote, com motivo) | Excluir em lote, com motivo | `escopo-adicional.md`, EA-061-04 |
| L4 | Código gerado ou digitado? (proposta: digitado, opcional e único) | Digitado, opcional e único | `escopo-adicional.md`, EA-061-02 |
| L5 | O filtro "Edição / Ano" do Figma | Dois filtros, Álbum e Ano. Decisão do PO (Daniel, 12/11/2026), na revisão do Figma | `escopo-adicional.md`, EA-061-03 |
| L6 | Exclusão em lote com cartas usadas em coleções | Essas cartas não são excluídas (CCD061 FA 5–6) e o aviso diz quais; as outras são excluídas. Decisão do PO (Daniel, 12/11/2026) | `61`, FA 7–8; `escopo-adicional.md`, EA-061-04 |
| L7 | O código de uma carta excluída continua reservado? (o índice único de `cards.code` também conta as cartas com `deleted_at`) | Não: o código é único só entre as cartas não excluídas (índice único parcial, como o ADR-062); a carta excluída mantém o código e não bloqueia o reuso, e o `409 CARD_CODE_TAKEN` só vale para carta ativa. A primeira proposta (gravar `code = null` ao excluir) foi trocada por esta ao achar o ADR-062. Decisão de Lucas Oliveira Lima em 19/11/2026 | ADR-063 (Aceito em 20/11/2026); `escopo-adicional.md`, EA-061-02; DBML `cards` |
| L8 | Indicadores do Figma (`208-2895`: "Total de álbuns" e "Álbuns licenciados", com os pendentes embaixo) contra os da CCD061 ("Total de cartas" e "Álbuns oficiais"); o total conta os `INACTIVE`? | Seguir o Figma: os dois cards substituem os da CCD061; o total conta todos os álbuns não excluídos. Decisão de Lucas Oliveira Lima em 19/11/2026 | `escopo-adicional.md`, EA-061-01 |
| L9 | A busca "por nome ou código" (`61`, FP 2 e Figma) busca hoje por nome e número | A busca passa a incluir o `code` (R11). Decisão de Lucas Oliveira Lima em 19/11/2026 | `escopo-adicional.md`, EA-061-02 |
| L10 | Mensagem de código repetido (`832-7170`: "Este código já está em uso por Charizard.") | Seguir o Figma: o `409 CARD_CODE_TAKEN` traz a mensagem com o nome da carta dona do código. Decisão de Lucas Oliveira Lima em 19/11/2026 | `escopo-adicional.md`, EA-061-02 |
| L11 | Quais dados o "Duplicar" copia (`832-6457` copia também nome, variantes e descrição) | Seguir o Figma: nome, franquia, álbum, raridade, idioma, variantes e descrição; numeração, código e imagens vazios. Decisão de Lucas Oliveira Lima em 19/11/2026 | `105`, FP 2 |
| L12 | Elementos da CCD106 nos frames (ano de lançamento, rascunho, verso padrão, carta parecida, filtro de status, etiqueta "Rascunho") | Ano de lançamento, "Salvar como Rascunho" e filtro de status desabilitados até a CCD106; verso padrão e aviso de carta parecida ocultos, porque mostrariam dados que não existem. Decisão de Lucas Oliveira Lima em 19/11/2026 | spec.md, Telas e Fora do escopo |
| L13 | O aviso das cartas que ficaram na exclusão em lote não tem frame | Fazer no estilo da tela: quantas saíram e o nome e o número das que ficaram. Decisão de Lucas Oliveira Lima em 19/11/2026 | `escopo-adicional.md`, EA-061-04 |
| L14 | A checagem "carta em coleções" (R10, CA9; CCD061 L2) depende de `collection_cards`, que só nasce com a CCD014. O que vale até lá? | Pendência explícita: a checagem é uma dependência obrigatória do catálogo; até a CCD014 o módulo injeta uma implementação "ainda sem coleções", que não bloqueia nenhuma carta (uma ou em lote). A CCD014 troca essa implementação pela consulta real. O CA9 só vale de ponta a ponta depois da CCD014. Decisão de Lucas Oliveira Lima em 19/11/2026, na revisão da CCD105 | `escopo-adicional.md`, EA-061-04; plano.md, Decisões técnicas |
| L15 | O modal de exclusão em lote (`832-4908`) usa o `ConfirmDialog` compartilhado, que tem rótulo em caixa alta, botão × e 512 px; o Figma tem "Motivo (obrigatório)", sem ×, e cerca de 560 px | Igualar os três ao Figma só neste modal, com props opcionais do `ConfirmDialog` (tamanho, sem ×, rótulo sem caixa alta); as outras telas não mudam. Decisão de Lucas Oliveira Lima em 20/11/2026, na 2ª revisão | spec.md, Telas; plano.md, Frontend |
| L16 | As opções do filtro Ano vinham só dos primeiros 100 álbuns carregados no frontend | O `GET /summary` devolve `albumYears`: os anos distintos dos álbuns não excluídos, do mais novo ao mais antigo. Decisão de Lucas Oliveira Lima em 20/11/2026, na 2ª revisão | plano.md, Contrato da API |
