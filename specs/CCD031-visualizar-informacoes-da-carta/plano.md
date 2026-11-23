# Plano — CCD031 Visualizar Informações da Carta

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L3 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

Nenhuma rota nova. O `GET /api/v1/cards/:id` da CCD030 já traz `identification`; esta story fecha as regras do bloco: o
nome como título, "Número", "Coleção" (título do álbum), "Categoria", "Raridade" e "Idioma", sem condição, e o marcador de
vazio para o que não tem valor. O componente `CardIdentification` (criado na CCD030) mostra o bloco igual ao frame.

## Dependências

- **CCD030** — `GET /api/v1/cards/:id`, o `cards.service.ts` do catálogo público, a página `/cartas/:id` e o
  `CardIdentification`. Esta story entra depois dela, ou na mesma sprint, antes do PR da CCD030 fechar o R5.

## Dados

| Tabela | Já no `schema.prisma`? | Migration | Observação |
|---|---|---|---|
| `cards` | sim | — | `name`, `number`, `album_id`, `category_id`, `rarity_id`, `language_id` (todas opcionais, exceto `name`) |
| `albums` · `categories` · `rarities` · `languages` | sim | — | só leitura dos nomes |

Nenhuma coluna nova.

## Regras

- **Coleção** (R4): `albums.title` do álbum da carta, se não excluído.
- **Categoria** (R4, depende da L1): o nome da categoria da carta (`cards.category_id`); sem ela, a do álbum. Hierarquia
  ("Futebol › Seleções") só se a L1 pedir.
- **Raridade** e **Idioma** (R4): `rarities.name` e `languages.name`.
- **Sem condição** (R5): o bloco não lê `card_conditions`.
- **Vazio** (R6, depende da L2): a API devolve `null` e a tela mostra "—", sem mudar o layout.

## Contrato da API

Convenções do ADR-011. Nenhuma rota nova.

### `GET /api/v1/cards/:id` (CCD030) — R1–R6

- **Acesso:** público.
- **Campo desta story:** `identification = { number: string | null, album: { id, title } | null,
  category: { id, name } | null, rarity: { name } | null, language: { name } | null }`, sem condição.
- **Erros:** os da CCD030 (`404 CARD_NOT_FOUND`).

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/catalog/cards/card-identification.ts` + `.spec.ts` | função pura que monta `identification` com as Regras (categoria da carta ou do álbum, `null` no vazio) | R3–R6 |
| `src/domains/catalog/cards/cards.service.ts` (CCD030) | usa a função | R3, R4 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/catalog/card-profile.labels.ts` | "Número", "Coleção", "Categoria", "Raridade", "Idioma" e o marcador "—" (L2) | R3, R6 |
| `src/features/catalog/components/CardIdentification/` (CCD030) | o bloco com os cinco campos e o vazio, sem condição — frame `1112-4615` | R3–R7 |
| `src/features/catalog/pages/CardProfilePage/` (CCD030) | nome da carta como título — frame `1112-4615` | R1, R2, R7 |

- **Estados:** os da página da CCD030.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | "Lionel Messi", 10, Copa do Mundo 2026, Seleções, Lendária, Português - Brasil | `card-identification.spec.ts` · `CardIdentification.spec.tsx` |
| CA2 | visitante vê o bloco sem login | `tests/integration/cards-profile.spec.ts` (CCD030) · `CardProfilePage.spec.tsx` |
| CA3 | sem condição no bloco | `card-identification.spec.ts` · `CardIdentification.spec.tsx` |
| CA4 | carta avulsa sem idioma: "—" em Coleção e Idioma, layout mantido | `card-identification.spec.ts` · `CardIdentification.spec.tsx` |
| CA5 | print em 1280 px igual ao frame `1112-4615` no título e no bloco; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Decisões técnicas

- A identificação é montada por uma função pura, separada do repository, para as regras de vazio e de categoria (L1, L2)
  serem testadas sem banco e mudarem num lugar só quando o PO decidir.
- O subtítulo "Nº 10 • Argentina • Panini…" e os selos do topo (L3) não entram: dependem da L6 da CCD030.
