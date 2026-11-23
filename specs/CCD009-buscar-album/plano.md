# Plano — CCD009 Buscar Álbum

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L5 pendentes)
- **Repositórios:** frontend (o backend só ganha um teste; lidos da branch `feature/336-remove-tipo-categoria`)
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

"Meus álbuns" (`/albuns`, CCD008) ganha o campo "Buscar álbum pelo nome ou ano". A lista que a página já carregou do
`GET /api/v1/collections/me/albums` (só os álbuns da coleção do cliente, sem paginação) é filtrada no navegador a cada
caractere, pelo trecho do título sem diferenciar maiúsculas e acentos, ou pelo ano exato de 4 dígitos. Nenhum endpoint
novo.

## Dependências

- **CCD008**: a página `MyAlbumsPage`, o endpoint `GET /collections/me/albums` (sem paginação, L7 da CCD008) e o estado
  vazio `MyAlbumsEmptyState`.
- **CCD034**: as abas por categoria. Quando entrarem, a busca combina com a aba selecionada (depende da L4): o filtro
  desta story recebe a lista já filtrada pela aba.

## Dados

Nenhuma tabela nem coluna nova: `albums.title` e `albums.year` já vêm na resposta da CCD008.

## Regras

- **Comparação** (R3, depende da L4): o texto e o título passam por `normalize('NFD')`, sem diacríticos e em minúsculas;
  combina se o título contém o texto. Texto de 4 dígitos também combina com `year` igual. Espaços nas pontas são
  ignorados; texto vazio mostra a lista inteira (CA3).
- **Tempo real** (R4): o filtro roda no `onChange`, sem botão e sem debounce, porque a lista já está na memória.
- **Resultado vazio** (depende da L3): "Nenhum álbum encontrado para "<texto>"" com o bloco "Não encontrou a coleção que
  você coleciona?" e "Solicitar álbum" (CCD010).
- **Sem álbuns** (R6): o mesmo `MyAlbumsEmptyState` da CCD008, sem o campo de busca.

## Contrato da API

Nenhum endpoint novo. Reaproveita `GET /api/v1/collections/me/albums` (CCD008): `authenticate` +
`authorize('CUSTOMER', 'SELLER')` (depende da L1), `401` sem token, e só devolve os álbuns da coleção do cliente (R1).

## Backend — `apps/cromocard-backend`

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `tests/integration/collection-albums.spec.ts` (CCD008) | caso de um álbum que só está na coleção de outro cliente e não volta na lista | R1 |

## Frontend — `apps/cromocard-frontend`

Feature `src/features/collection/`.

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `collection.search.ts` + `.spec.ts` | `filterAlbums(albums, text)`: normalização, trecho do título, ano exato | R3, R4 |
| `components/AlbumSearchField/` | campo com lupa e o texto "Buscar álbum pelo nome ou ano", no estilo de "Buscar carta na coleção" do `1122-17812`, na linha das abas, à esquerda de "Ordenar por" (depende da L2); sem frame próprio: segue o `1160-23080` quando o Gabriel desenhar | R2 |
| `components/AlbumSearchEmpty/` | resultado vazio com "Solicitar álbum" (depende da L3) | R4 |
| `pages/MyAlbumsPage/` (CCD008) | estado do texto, lista filtrada, resultado vazio; o campo some no vazio da coleção; frames `1160-23080` e `1160-29088` | R2, R4–R7 |

- **Componentes reaproveitados:** `SearchBar` (ou `TextField` com o ícone), `EmptyState`, `Button`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | "cop" mostra só "Copa do Mundo 2026", sem confirmar | `collection.search.spec.ts` · `MyAlbumsPage.spec.tsx` |
| CA2 | "2002" mostra só o álbum de 2002 | `collection.search.spec.ts` |
| CA3 | apagar o texto volta a lista inteira | `MyAlbumsPage.spec.tsx` |
| CA4 | selecionar o resultado vai para `/albuns/:albumId` | `MyAlbumsPage.spec.tsx` |
| CA5 | coleção vazia mostra a mensagem e o botão para o catálogo | `MyAlbumsPage.spec.tsx` |
| CA6 | álbum de outro cliente não vem; `401` sem token | `tests/integration/collection-albums.spec.ts` |
| CA7, CA8 | prints em 1280 px iguais a `1160-23080` (com o campo, L2) e `1160-29088`; 375, 768 e 1024 px sem quebra | revisão visual com o seed |

## Decisões técnicas

- A busca é no navegador: a CCD008 já carrega a lista inteira (L7), e filtrar na memória atende o "tempo real" (R4) sem
  uma chamada por caractere. Se a lista passar a paginar, a busca vira o parâmetro `q` do mesmo endpoint e o plano muda.
