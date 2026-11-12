# CCD061 — Gestão de Catálogo

- **Status:** Rascunho
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
| R3 | Lista paginada dos itens do catálogo, sem excluídos, com busca por nome ou código; a aba de cartas filtra por franquia, álbum, raridade, ano e status (publicadas ou rascunhos) e mostra os chips dos filtros ativos | Tela | `61`, FP 2 (L7); ADR-011; ADR-015, item 5 |
| R4 | Cadastrar, editar e remover cartas e álbuns | Ação | `61`, FP 3; user-stories.md §8 |
| R5 | Álbum: `title` obrigatório (160); opcionais `publisher`, `year`, `description`, `cover_url`, `category_id` e `status` (Ativo ou Inativo) | Regra | `61`, FP 5; DBML `albums` |
| R6 | Carta: para publicar, `name` (160), `category_id` (franquia), `rarity_id`, `language_id` e a imagem da frente são obrigatórios; opcionais `album_id`, `number`, `description` e o verso | Regra | `61`, FP 5 (L6); DBML `cards` |
| R7 | Número único dentro do álbum (`album_id`, `number`); recadastrar uma carta excluída restaura a linha | Regra | DBML `cards.indexes`; ADR-015, item 7 |
| R8 | Validação com erros por campo e confirmação antes de gravar | Regra | `61`, FP 4–7 e FA 1–4 |
| R9 | O sistema confirma a operação ("Carta cadastrada no catálogo") e atualiza a lista | Mensagem | `61`, FP 8–9 |
| R10 | Remover é soft delete | Regra | ADR-015, item 1 |
| R11 | Item com vínculos que impedem a exclusão não é removido e o sistema informa o motivo (modal "Não é possível excluir esta carta") | Regra | `61`, FA 5–6 |
| R12 | Imagens vão pelo `StorageProvider`; o banco guarda a URL | Regra | ADR-009 |
| R13 | Importar cartas por CSV: modal com o modelo para baixar e o arquivo; tudo ou nada, com o total importado ou as linhas com erro | Ação | `61`, FP 10–11; user-stories.md §8 |
| R14 | Cadastrar, editar e remover gravam `audit_logs` | Regra | `61`, FP 8; ADR-034 |
| R15 | Categorias são cadastradas, editadas e removidas na aba "Categorias & Franquias": nome e tipo obrigatórios, categoria pai, descrição e selo (CCD104) opcionais, slug gerado pelo nome; raridades e idiomas vêm do seed | Ação | `61`, FP 2 e FP 5; EA-066-01 |
| R16 | Excluir pede confirmação e grava `audit_logs` | Regra | `61`, FA 7–8 |

## Critérios de aceite

- **CA1** (R3) — **Dado** o catálogo, **quando** abre Catálogo, **então** vê as abas Cartas, Álbuns e Categorias com
  busca e filtros, paginadas, e os chips dos filtros ativos na aba de cartas.
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
- **CA8** (R6) — **Dado** o formulário de carta sem raridade, **quando** o admin cadastra no catálogo, **então** a API
  responde `400` no campo `rarityId`; sem álbum e sem numeração, a carta é cadastrada.
- **CA9** (R16) — **Dado** um álbum sem cartas, **quando** o admin clica em excluir, **então** a tela pede a
  confirmação e só exclui depois dela, registrando o log.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `albums`, `cards`, `card_photos` | ver R5–R7 | fundação |
| `categories`, `rarities`, `languages` | `name`, `type`, `parent_category_id`, `sort_order`, `code` | referências dos formulários; gestão de categorias em L1 |

## Telas (Figma)

Conferidas em 12/11/2026, depois do ajuste do Figma à documentação. Links: `https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=<frame>`.

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Gestão de Catálogo (cartas) | `208-2895` | R2–R4 | ✅ Bate |
| Cadastrar nova carta | `278-3246` | R4, R6, R8, R12 | ✅ Bate |
| Erros de validação | `832-7170` | R6–R8 | ✅ Bate |
| Editar carta | `832-5744` | R4, R14 | ✅ Bate |
| Operação concluída | `832-1149` | R9 | ✅ Bate |
| Exclusão bloqueada | `832-2217` | R11 | ✅ Bate |
| Importar CSV | `832-3295` | R13 | ✅ Bate |
| Importação com erro | `832-3837` | R13 | ✅ Bate |
| Importação concluída | `832-1683` | R13 | ✅ Bate |
| Álbuns | `832-8603` | R3, R5 | ✅ Bate |
| Novo álbum | `833-9661` | R4, R5 | ✅ Bate |
| Categorias & Franquias | `833-9132` | R15 | ✅ Bate |
| Nova categoria | `833-10832` | R15 | ✅ Bate |

## Fora do escopo

- Preço médio e população (dependem de `price_history`/marketplace).
- Duplicar carta, código, variantes, filtro por ano e exclusão em lote — CCD105; rascunhos — CCD106.
- Graduação PSA/BGS, variação de preço, "Código Vault", hash SHA-256 da imagem e "Checksum de Metadados": efeito
  visual ou sem regra, retirados do Figma em 12/11/2026.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Categorias, raridades e idiomas entram? (proposta: categorias sim, na aba "Categorias & Franquias"; raridades e idiomas vêm do seed) | Categorias entram, na aba "Categorias & Franquias"; raridades e idiomas vêm do seed | `61`, FP 2 |
| L2 | Quais vínculos impedem excluir? (proposta: álbum com cartas; categoria com álbuns, cartas ou subcategorias; carta já usada em coleções) | Álbum com cartas; categoria com álbuns, cartas ou subcategorias; carta já usada em coleções | `61`, FA 5 |
| L3 | Formato do CSV (proposta: um arquivo de cartas com `album_title;number;name;rarity;language;category`; tudo ou nada; modelo para baixar) | Um arquivo de cartas com `album_title;number;name;rarity;language;category`, tudo ou nada, com modelo para baixar | `61`, FP 10–11; ADR-050, item 2 |
| L4 | Imagens: upload ou URL? (proposta: upload pelo `/uploads` da fundação; frente obrigatória, verso opcional) | Upload pelo `/uploads` da fundação; frente obrigatória e verso opcional | `61`, FP 5; ADR-050, item 1 |
| L5 | `total_cards` do álbum: informado ou calculado? (proposta: calculado pelas cartas do álbum) | Calculado pelas cartas do álbum | `61`, FP 8 |
| L6 | Quais campos são obrigatórios para publicar uma carta? O Figma marcava quase todos; o DER exige só o nome, e a CCD106 CA4 barra o rascunho sem raridade | Nome, franquia, raridade, idioma e imagem da frente; álbum, numeração e ano são opcionais (o DER permite carta avulsa). Decisão do PO (Daniel, 12/11/2026), na revisão do Figma | `61`, FP 5 |
| L7 | O filtro "Edição / Ano" do Figma | Dois filtros, Álbum e Ano, como no contrato (`albumId`, `year`), mais o filtro de status. Decisão do PO (Daniel, 12/11/2026) | `61`, FP 2; `escopo-adicional.md`, EA-061-03 |
| L8 | Excluir pede confirmação? | Sim, com modal; a exclusão em lote também pede o motivo (CCD105). Decisão do PO (Daniel, 12/11/2026) | `61`, FA 7–8 |
