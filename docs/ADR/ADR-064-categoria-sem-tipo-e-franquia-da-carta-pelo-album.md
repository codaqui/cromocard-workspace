# ADR-064 — Categoria sem tipo; a carta com álbum tem a franquia do álbum

- **Status:** Proposto (aguardando validação do PO)
- **Data:** 2026-11-18
- **Decisores:** Daniel Andrade (proposta, na revisão do catálogo da CCD061); validação: Felipe Consulim (PO)

## Contexto

O DER criou `categories.type` (enum `category_type`: `ALBUM`, `CARD`). Na CCD061, as lacunas L10 e L11 (ainda sem
validação do PO) transformaram esse tipo em regra: o álbum só aceitava categoria `ALBUM`, a carta só aceitava
categoria `CARD` (no formulário e na importação CSV) e a categoria pai precisava ser do mesmo tipo da filha. Outro tipo
respondia `422 CATEGORY_TYPE_MISMATCH`.

Na homologação, ao cadastrar uma carta do Brasileirão, o admin não conseguiu escolher a franquia "Brasileirão", que
fora criada como `ALBUM`. O próprio seed mostrava o problema: "Pokémon TCG" (`ALBUM`) e "Pokémon" (`CARD`) eram a mesma
franquia cadastrada duas vezes, e as cartas de futebol não tinham franquia nenhuma.

Para a documentação, a franquia é uma só: a carta "informa a franquia" (CCD061, FP 5), o verso padrão é por franquia
(CCD106, EA-061-07) e a ordem das categorias padrão vale para o menu, os filtros e a vitrine (CCD104). Separar por
tipo obrigaria a duplicar a franquia e, com ela, o verso padrão, a ordem, os filtros e a contagem de cartas. Além disso,
a carta já se distingue do álbum pela tabela (`cards` e `albums`): o tipo da categoria não informava nada além disso.

Fora dessa regra, o tipo não era usado: vitrine, menu, categorias padrão, verso padrão e coleção do cliente não o leem.

## Decisão

1. **Remova `categories.type` e o enum `category_type`** do DER (nos três `.dbml`), do diagrama de classes, do
   `schema.prisma` (migration `remove_type_from_categories_table`), da API e do frontend. A mesma categoria (franquia)
   serve a álbuns e a cartas.
2. **A carta com álbum tem a franquia do álbum.** Se o álbum tem franquia e a carta informa outra, a API responde
   `422 CARD_CATEGORY_MISMATCH`, no cadastro, na edição (comparando com o álbum que a carta vai ter) e na importação
   CSV (erro `<linha>.category`). A carta avulsa e a carta de um álbum sem franquia aceitam qualquer franquia.
3. **Trocar a franquia do álbum leva junto as cartas dele**, na mesma escrita, para a regra do item 2 continuar valendo.
   Sem isso, o álbum não poderia mudar de franquia (as cartas seriam de outra) e as cartas não poderiam mudar (o álbum
   seria de outro).
4. No formulário da carta, **escolher o álbum preenche a franquia dele**. Os selects de franquia (álbum, carta, filtros
   e categoria pai) listam todas as categorias.
5. A categoria pai pode ser qualquer categoria, desde que não seja a própria nem uma descendente dela
   (`422 CATEGORY_PARENT_INVALID`, que já existia).
6. A sugestão de categoria da comunidade (`catalog_requests.type = CATEGORY`) deixa de levar `type` no `data`.

## Alternativas consideradas

- **Manter o tipo como regra (L10 e L11):** recusada pelo contexto, porque duplica a franquia.
- **Manter o tipo só para o álbum** (a carta aceitaria qualquer franquia): resolve o caso do Brasileirão, mas deixa uma
  coluna que só restringe o álbum, sem nenhuma regra de negócio que a justifique, e continua permitindo a carta com
  franquia diferente da do álbum.
- **Aceitar qualquer franquia na carta, sem conferir o álbum:** mais simples, mas permite uma carta do álbum do
  Brasileirão marcada como Pokémon, o que bagunça os filtros e a contagem de cartas por franquia.

## Consequências

- A migration apaga a coluna e o enum. Os dados das categorias continuam; só se perde o rótulo do tipo. As franquias
  duplicadas por tipo (como "Pokémon" e "Pokémon TCG" num banco já populado) continuam lá, e o admin junta ou exclui à
  mão. O seed passa a ter uma franquia "Pokémon" só, e as cartas com álbum ganham a franquia do álbum.
- O erro `CATEGORY_TYPE_MISMATCH` sai da API, e entra o `CARD_CATEGORY_MISMATCH`. O filtro `type` de
  `GET /admin/catalog/categories` deixa de existir (o parâmetro é ignorado).
- O campo "Tipo" sai do formulário de categoria, e a coluna e o filtro "Tipo" saem da aba Categorias. As telas
  "Categorias & Franquias" e "Nova categoria" do Figma foram ajustadas em 18/11/2026.
- O DER fica com 50 tabelas, 90 FKs e 26 enums.

## Referências

- ADR-003 (nomes em inglês) · ADR-011 (erros `422`) · ADR-036 (diagrama de classes 1:1 com o DER)
- `docs/Casos-De-Uso/61-gestao-de-catalogo.md`, FP 5 · `docs/Casos-De-Uso/104-ordenar-categorias-padrao.md` ·
  `docs/Casos-De-Uso/106-salvar-rascunho-de-carta.md`
- `specs/CCD061-gestao-de-catalogo/spec.md`, L10 e L11
- `docs/Diagramas/DER/03-der-completo.dbml`, tabela `categories`
