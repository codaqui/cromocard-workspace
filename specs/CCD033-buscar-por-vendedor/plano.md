# Plano — CCD033 Buscar por Vendedor

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

> Fase Futuro Marketplace: implementar depois do MVP.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L5 pendentes)
- **Repositórios:** backend · frontend (lidos da branch `feature/336-remove-tipo-categoria` dos dois apps)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

Pela proposta da L2, "Buscar por Vendedor" fica com o caso de uso `67` e a CCD033 é cancelada: a implementação é a do
[plano da CCD067](../CCD067-buscar-por-vendedor/plano.md) (`GET /api/v1/sellers`, filtro `sellerId` em
`GET /api/v1/listings`, a opção "Cartas | Vendedores" no Explorar e os anúncios ativos no perfil público). Este plano não
cria endpoint nem tela próprios: ele lista o que a CCD033 pede a mais que a CCD067 e o que muda se a L2 decidir manter as
duas. Pela proposta da L5, a busca usa só o nome de usuário; pela proposta da L3, o caminho é o que o Figma já tem.

## Dependências

- **CCD067:** endpoints, telas e testes. Esta story entra depois dela, ou é cancelada.
- **CCD078, CCD080:** as mesmas da CCD067.

## Diferenças da CCD033 sobre a CCD067

| Ponto | CCD033 (`33`) | CCD067 (`67`) | Neste plano | Requisitos |
|---|---|---|---|---|
| Login | exige (`401` sem token) | não exige | depende da L2: mantida a CCD033, `GET /sellers` e o escopo "Vendedores" passam a exigir `authenticate` | R1 |
| Anúncios | "cadastrados" | ativos | os ativos da CCD067 (depende da L2) | R3, R4 |
| Mensagem sem vendedor | "Nenhum resultado encontrado" | “Nenhum vendedor encontrado.” | depende da L2: o texto do caso de uso que ficar | R6 |
| Lista de vendedores antes dos anúncios | não tem | tem | a da CCD067 | R2–R5 |

## Dados

Os da CCD067 (`users`, `listings`): nenhuma tabela, coluna ou migration nova.

## Contrato da API

Nenhuma rota nova. Usa o contrato da CCD067:

| Método e caminho | Uso | Requisitos |
|---|---|---|
| `GET /api/v1/sellers?q=` | vendedores por nome de usuário (L5); com a CCD033 mantida, `401 UNAUTHENTICATED` sem token | R1, R2, R6 |
| `GET /api/v1/listings?sellerId=` | anúncios do vendedor | R3, R4 |

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/domains/users/sellers.routes.ts` (da CCD067) | só se a L2 mantiver a CCD033: `authenticate` na rota | R1 |
| `tests/integration/sellers.spec.ts` | CA1, CA3 e CA4 da CCD033 sobre os endpoints da CCD067 | R1–R4, R6 |

## Frontend — `apps/cromocard-frontend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/features/users/sellers.labels.ts` (da CCD067) | a mensagem sem vendedor que a L2 decidir | R6 |
| `src/features/marketplace/listings/components/ListingSearchScope/` (da CCD067) | só se a L2 mantiver a CCD033: o escopo "Vendedores" pede login ao visitante (`RequireAuth` ou o modal "Entre para continuar" da CCD002) | R1 |

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | "tiago_trocas" mostra o anúncio dele | os testes da CCD067 |
| CA2 | o anúncio abre o detalhe (`/anuncios/:id`) | `SellerActiveListings.spec.tsx` (CCD067) |
| CA3 | sem vendedor, a mensagem decidida na L2 | `SellerResultList.spec.tsx` |
| CA4 | sem token, `401` (só com a CCD033 mantida) | `tests/integration/sellers.spec.ts` |
| CA5–CA9 | os prints da CCD067 (`1112-3281`, `1112-3970`, `1160-1396`) | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Dependências e riscos

- Com a L2 aprovada como proposta, a spec vira `Cancelada` e só a T1 (documentação) é feita.
- A user story #166 tem outro título no board (L1); corrigir o board é com o Daniel, fora deste plano.
- O R1 da CCD033 (login) e o Explorar público da CCD078 se contradizem; manter as duas stories exige a decisão do PO sobre
  qual vale para a mesma tela.

## Decisões técnicas

- Uma implementação só para os dois casos de uso duplicados, para não ter duas buscas por vendedor com regras diferentes.
