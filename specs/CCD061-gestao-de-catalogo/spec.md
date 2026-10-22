# CCD061 — Gestão de Catálogo

- **Status:** Planejada
- **Fase:** MVP
- **User story:** #336 `CCD061-Gestão de Catálogo` · responsável Lucas Oliveira Lima · Sprint 06
- **Caso de uso:** [61-gestao-de-catalogo.md](../../docs/Casos-De-Uso/61-gestao-de-catalogo.md) (a Finalidade foi copiada do caso 60)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO)

## Objetivo

> Como Administrador eu quero cadastrar, editar, excluir ou importar em lote (CSV) as cartas e álbuns do sistema global.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401`/`403` | Permissão | `61`, Pré-condições; ADR-005, item 4 |
| R2 | Tela em `/backoffice/catalogo`, item "Catálogo" do menu | Tela | `61`, FP 1; ADR-038 |
| R3 | Lista paginada dos itens do catálogo, sem excluídos | Tela | `61`, FP 2; ADR-011; ADR-015, item 5 |
| R4 | Cadastrar, editar e remover cartas e álbuns | Ação | `61`, FP 3; user-stories.md §8 |
| R5 | Álbum: `title` obrigatório (160); opcionais `publisher`, `year`, `description`, `cover_url`, `category_id` | Regra | DBML `albums` |
| R6 | Carta: `name` obrigatório (160); opcionais `number`, `description`, imagens de frente e verso, `album_id`, `category_id`, `rarity_id`, `language_id` | Regra | DBML `cards` |
| R7 | Número único dentro do álbum (`album_id`, `number`); recadastrar uma carta excluída restaura a linha | Regra | DBML `cards.indexes`; ADR-015, item 7 |
| R8 | Validação com erros por campo e confirmação antes de gravar | Regra | `61`, FP 4–7 e FA 1–4 |
| R9 | O sistema confirma a operação e atualiza a lista | Mensagem | `61`, FP 8–9 |
| R10 | Remover é soft delete | Regra | ADR-015, item 1 |
| R11 | Item com vínculos que impedem a exclusão não é removido e o sistema informa o motivo | Regra | `61`, FA 5–6 |
| R12 | Imagens vão pelo `StorageProvider`; o banco guarda a URL | Regra | ADR-009 |
| R13 | Importar cartas e álbuns em lote por CSV | Ação | user-stories.md §8 |
| R14 | Cadastrar, editar e remover gravam `audit_logs` | Regra | `61`, FP 8; ADR-034 (Proposto) |
| R15 | Categorias são cadastradas, editadas e removidas na aba "Categorias & Franquias"; raridades e idiomas vêm do seed | Ação | `61`, FP 2 |

## Critérios de aceite

- **CA1** (R3) — **Dado** o catálogo, **quando** abre Catálogo, **então** vê as abas Cartas e Álbuns com busca e
  filtros, paginadas.
- **CA2** (R4–R6, R8, R9, R12) — **Dado** o formulário de carta, **quando** salva com nome, álbum, número e imagem,
  **então** a API responde `201` e a carta aparece na lista.
- **CA3** (R7) — **Dado** um álbum com a carta nº 10, **quando** cadastra outra nº 10 no mesmo álbum, **então** a API
  responde `409`.
- **CA4** (R10, R11) — **Dado** um álbum com cartas, **quando** tenta excluir, **então** a API responde `422` com o
  motivo; um álbum sem cartas é excluído (`204`).
- **CA5** (R13) — **Dado** um CSV válido com 50 cartas, **quando** importa, **então** as 50 são criadas e a tela
  mostra o resumo.
- **CA6** (R13) — **Dado** um CSV com linhas inválidas, **quando** importa, **então** nada é gravado e a tela lista
  as linhas com erro.
- **CA7** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama a API do catálogo de admin, **então** recebe `403`.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `albums`, `cards`, `card_photos` | ver R5–R7 | fundação |
| `categories`, `rarities`, `languages` | `name`, `type`, `parent_category_id`, `sort_order`, `code` | referências dos formulários; gestão de categorias em L1 |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| administração - catalago | [208-2895](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=208-2895) | R2–R4 | ⚠️ Divergente |

- O Figma tem as abas Todas as Cartas, Álbuns Oficiais e Categorias & Franquias, os botões "+ Cadastrar Carta" e
  "+ Novo Álbum", filtros de franquia, raridade e edição/ano, seleção em lote e as ações editar, duplicar e excluir.
- **O que falta no Figma:** a importação CSV (R13) não aparece na área visível (o frame está cortado à direita).
- **Fora da documentação no Figma:** "população base", "preço médio ref." e "duplicar".

## Fora do escopo

- Preço médio e população (dependem de `price_history`/marketplace).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Categorias, raridades e idiomas entram? (proposta: categorias sim, na aba "Categorias & Franquias"; raridades e idiomas vêm do seed) | Categorias entram, na aba "Categorias & Franquias"; raridades e idiomas vêm do seed | `61`, FP 2 |
| L2 | Quais vínculos impedem excluir? (proposta: álbum com cartas; categoria com álbuns, cartas ou subcategorias; carta já usada em coleções) | Álbum com cartas; categoria com álbuns, cartas ou subcategorias; carta já usada em coleções | `61`, FA 5 |
| L3 | Formato do CSV (proposta: um arquivo de cartas com `album_title;number;name;rarity;language;category`; tudo ou nada; modelo para baixar) | Um arquivo de cartas com `album_title;number;name;rarity;language;category`, tudo ou nada, com modelo para baixar | `61`, FP 10–11; ADR-050, item 2 |
| L4 | Imagens: upload ou URL? (proposta: upload pelo `/uploads` da fundação; frente obrigatória, verso opcional) | Upload pelo `/uploads` da fundação; frente obrigatória e verso opcional | `61`, FP 5; ADR-050, item 1 |
| L5 | `total_cards` do álbum: informado ou calculado? (proposta: calculado pelas cartas do álbum) | Calculado pelas cartas do álbum | `61`, FP 8 |
