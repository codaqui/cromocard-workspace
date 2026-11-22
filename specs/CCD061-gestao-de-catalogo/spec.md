# CCD061 — Gestão de Catálogo

- **Status:** Implementada
- **Fase:** MVP
- **User story:** #336 `CCD061-Gestão de Catálogo` · responsável Lucas Oliveira Lima · Sprint 06
- **Caso de uso:** [61-gestao-de-catalogo.md](../../docs/Casos-De-Uso/61-gestao-de-catalogo.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO); reaprovada em 2026-11-12, depois da revisão do Figma do painel admin; L9 decidida pelo PO (Felipe Consulim) em 2026-11-18, na revisão do PR 44

## Objetivo

> Como Administrador eu quero cadastrar, editar, excluir ou importar em lote (CSV) as cartas e álbuns do sistema global.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401`/`403` | Permissão | `61`, Pré-condições; ADR-005, item 4 |
| R2 | Tela em `/backoffice/catalog`, item "Catálogo" do menu | Tela | `61`, FP 1; ADR-038 |
| R3 | Lista paginada dos itens do catálogo, sem excluídos, com busca por nome ou código; a aba de cartas filtra por franquia, álbum, raridade, ano e status (publicadas ou rascunhos) e mostra os chips dos filtros ativos | Tela | `61`, FP 2 (L7); ADR-011; ADR-015, item 5 |
| R4 | Cadastrar, editar e remover cartas e álbuns | Ação | `61`, FP 3; user-stories.md §8 |
| R5 | Álbum: `title` obrigatório (160); opcionais `publisher`, `year`, `description`, `cover_url`, `category_id` e `status` (Ativo ou Inativo) | Regra | `61`, FP 5; DBML `albums` |
| R6 | Carta: para publicar, `name` (160), `category_id` (franquia), `rarity_id`, `language_id` e a imagem da frente são obrigatórios; opcionais `album_id`, `number`, `description` e o verso. Com álbum que tem franquia, a franquia da carta é a do álbum (L11) | Regra | `61`, FP 5 (L6, L11); DBML `cards`; ADR-064 |
| R7 | Número único dentro do álbum (`album_id`, `number`); recadastrar uma carta excluída restaura a linha | Regra | DBML `cards.indexes`; ADR-015, item 7 |
| R8 | Validação com erros por campo e confirmação antes de gravar | Regra | `61`, FP 4–7 e FA 1–4 |
| R9 | O sistema confirma a operação ("Carta cadastrada no catálogo") e atualiza a lista | Mensagem | `61`, FP 8–9 |
| R10 | Remover é soft delete | Regra | ADR-015, item 1 |
| R11 | Item com vínculos que impedem a exclusão não é removido e o sistema informa o motivo (modal "Não é possível excluir esta carta") | Regra | `61`, FA 5–6 |
| R12 | Imagens vão pelo `StorageProvider`; o banco guarda a URL | Regra | ADR-009 |
| R13 | Importar cartas por CSV: modal com o modelo para baixar e o arquivo; tudo ou nada, com o total importado ou as linhas com erro; as cartas importadas entram como rascunho (L12) | Ação | `61`, FP 10–11; user-stories.md §8; L12 |
| R14 | Cadastrar, editar e remover gravam `audit_logs` | Regra | `61`, FP 8; ADR-034 |
| R15 | Categorias são cadastradas, editadas e removidas na aba "Categorias & Franquias": nome obrigatório (sem tipo, L11), categoria pai, descrição e selo (CCD104) opcionais, slug gerado pelo nome; raridades e idiomas vêm do seed | Ação | `61`, FP 2 e FP 5; EA-066-01 |
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
- **CA5** (R13) — **Dado** um CSV válido com 50 cartas, **quando** importa, **então** as 50 são criadas como rascunho (L12) e a tela
  mostra o resumo.
- **CA6** (R13) — **Dado** um CSV com linhas inválidas, **quando** importa, **então** nada é gravado e a tela lista
  as linhas com erro.
- **CA7** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama a API do catálogo de admin, **então** recebe `403`.
- **CA8** (R6) — **Dado** o formulário de carta sem raridade, **quando** o admin cadastra no catálogo, **então** a API
  responde `400` no campo `rarityId`; sem álbum e sem numeração, a carta é cadastrada.
- **CA9** (R16) — **Dado** um álbum sem cartas, **quando** o admin clica em excluir, **então** a tela pede a
  confirmação e só exclui depois dela, registrando o log.
- **CA10** (R6, L11) — **Dado** um álbum da franquia Futebol, **quando** o admin cadastra uma carta nele com outra
  franquia, **então** a API responde `422 CARD_CATEGORY_MISMATCH`; ao escolher o álbum no formulário, a franquia
  Futebol já vem preenchida.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `albums`, `cards`, `card_photos` | ver R5–R7 | fundação |
| `categories`, `rarities`, `languages` | `name`, `parent_category_id`, `sort_order`, `code` | referências dos formulários; gestão de categorias em L1 |

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
| Categorias & Franquias | `833-9132` | R15 | ✅ Bate (coluna e filtro "Tipo" removidos do Figma em 18/11/2026, L11) |
| Nova categoria | `833-10832` | R15 | ✅ Bate (campo "Tipo" removido do Figma em 18/11/2026, L11) |

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
| L9 | Como escolher entre muitos álbuns e categorias nos selects? | Aceito como está: a implementação carrega a primeira página (até 100, o máximo da API) e sempre inclui o item já escolhido na edição; as categorias vêm todas juntas, sem tipo (L11); um select com busca fica para quando o catálogo passar de 100. Decisão do PO (Felipe Consulim, 18/11/2026), na revisão do PR 44 | Só aqui |
| L10 | A categoria pai precisa ser do mesmo tipo (`ALBUM`/`CARD`)? | Não há mais tipo (L11): a categoria pai pode ser qualquer categoria, menos a própria ou uma descendente dela (`422 CATEGORY_PARENT_INVALID`). Decisão do Daniel em 18/11/2026, na revisão do catálogo em homologação | ADR-064 (Proposto, aguardando o PO) |
| L11 | O tipo da categoria (`ALBUM`/`CARD`) é regra ou só rótulo? | Nenhum dos dois: o tipo sai do modelo. A mesma franquia serve a álbuns e cartas. A carta com álbum que tem franquia precisa ter a franquia do álbum (`422 CARD_CATEGORY_MISMATCH`, também na importação, no campo `<linha>.category`); escolher o álbum no formulário preenche a franquia; trocar a franquia do álbum troca a das cartas dele. Decisão do Daniel em 18/11/2026: com o tipo como regra, a carta do Brasileirão não aceitava a franquia "Brasileirão" (criada como álbum), e o seed tinha "Pokémon" e "Pokémon TCG" duplicadas | `61`, FP 5, 6 e 11; ADR-064 (Proposto, aguardando o PO) |
| L12 | A carta importada por CSV precisa da imagem da frente? O CSV não tem coluna de imagem (L3), e a L6 exige a frente para publicar | A carta importada entra como rascunho (`status = DRAFT`, o mesmo da CCD106), sem imagem, e não aparece no catálogo público; o admin envia a frente pela edição e só então a publica, com a validação da L6. O CSV continua sem coluna de imagem (L3). Decisão do PO (Daniel, 14/11/2026) | `61`, FP 11 |
