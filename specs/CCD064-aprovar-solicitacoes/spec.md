# CCD064 — Aprovar Solicitações

- **Status:** Planejada
- **Fase:** MVP
- **User story:** #339 `CCD064-Aprovar Solicitações` · responsável Felipe Consulim · Sprint 07
- **Caso de uso:** [64-aprovar-solicitacoes.md](../../docs/Casos-De-Uso/64-aprovar-solicitacoes.md) (pré-condições e passos 3, 7 e 8 têm texto do caso 63)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO)

## Objetivo

> Como Administrador eu quero analisar e aprovar sugestões de novas cartas, álbuns e categorias feitas pelos usuários.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401`/`403` | Permissão | `64`, Atores; ADR-005, item 4 |
| R2 | Tela em `/backoffice/solicitacoes`, item "Solicitações" do menu | Tela | `64`, FP 1; ADR-038 |
| R3 | Lista das solicitações pendentes, paginada | Tela | `64`, FP 2; DBML `request_status`; ADR-011 |
| R4 | Tipos: carta, álbum e categoria | Regra | user-stories.md §8; DBML `catalog_request_type` |
| R5 | O admin seleciona uma solicitação e vê o tipo e os dados sugeridos | Tela | `64`, FP 3–5; DBML `catalog_requests.data` |
| R6 | Opção "Aprovar" com confirmação | Ação | `64`, FP 6–7 |
| R7 | Aprovar grava quem e quando (`reviewed_by_id`, `reviewed_at`) e muda o status para `APPROVED` | Regra | `64`, FP 7–8; DBML |
| R8 | Aprovar carta ou álbum cria o item no catálogo e liga em `card_id`/`album_id` | Regra | DBML `catalog_requests` ("item criado após aprovação") |
| R9 | O item criado segue as regras do catálogo (CCD061) | Regra | DBML `albums`, `cards` |
| R10 | O sistema informa que a solicitação foi aprovada | Mensagem | `64`, FP 9 |
| R11 | Solicitação já processada não pode ser aprovada e o sistema informa | Regra | `64`, FA 1–2 |
| R12 | Cancelar volta à lista sem aprovar | Ação | `64`, FA 3–4 |
| R13 | Aprovar grava `audit_logs` | Regra | ADR-034 (Proposto) |
| R14 | Recusar com motivo obrigatório: status `REJECTED`, motivo em `data.rejectionReason` e no `audit_logs` | Ação | `64`, FA 5–6; ADR-051, item 3 |
| R15 | Aprovar ou recusar avisa o solicitante com uma notificação `CATALOG_REQUEST` | Regra | `64`, FP 9 e FA 6; ADR-051, item 2 |

## Critérios de aceite

- **CA1** (R3, R4) — **Dado** solicitações pendentes, **quando** abre Solicitações, **então** vê as abas Todas,
  Cartas, Álbuns e Categorias com o número de pendentes.
- **CA2** (R5–R10, R13) — **Dado** uma solicitação de carta pendente, **quando** o admin aprova e confirma, **então**
  a carta é criada no catálogo, a solicitação fica `APPROVED` com quem e quando, e o log registra.
- **CA3** (R8) — **Dado** uma solicitação de álbum com lista de cartas, **quando** aprova, **então** o álbum e as
  cartas são criados.
- **CA4** (R14) — **Dado** uma solicitação pendente, **quando** o admin recusa com motivo, **então** ela fica
  `REJECTED` e some da lista de pendentes.
- **CA5** (R11) — **Dado** uma solicitação já aprovada, **quando** alguém tenta aprovar de novo, **então** a API
  responde `409` e a tela informa.
- **CA6** (R9) — **Dado** uma carta sugerida com número que já existe no álbum, **quando** aprova, **então** a API
  responde `409` e a solicitação continua pendente.
- **CA7** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama a rota, **então** recebe `403`.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `catalog_requests` | `requester_id`, `reviewed_by_id`, `card_id`, `album_id`, `type`, `data`, `status`, `reviewed_at` | fundação |
| `albums`, `cards`, `categories` | — | criados pelo `catalogService` (CCD061) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| administração - fila de solicitações de cartas | [228-1804](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=228-1804) | R3–R8 | ⚠️ Divergente |

- O Figma mostra cartões por solicitação (imagens, dados, justificativa, solicitante) com "Recusar" e "Aprovar e
  integrar"; o de álbum traz a lista de cartas.
- **Fora da documentação no Figma:** "votos da comunidade" e "quórum" na solicitação de categoria; "população
  estimada"; "fontes oficiais e arquivos criptográficos".

## Fora do escopo

- Criar as solicitações (lado do cliente) — CCD010 e CCD023; os dados de teste vêm do seed.
- Votação da comunidade.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Recusar existe no MVP? Com motivo? (proposta: sim, motivo obrigatório guardado no `audit_logs` e em `data.rejectionReason`, sem mudar o DER) | Sim, com motivo obrigatório, guardado no `audit_logs` e em `data.rejectionReason`, sem mudar o DER | `64`, FA 5–6; ADR-051, item 3 |
| L2 | Editar antes de aprovar? (proposta: não; aprova como veio, e ajustes depois pela Gestão de Catálogo) | Não: aprova como veio; ajustes depois pela Gestão de Catálogo | `64`, FP 8 |
| L3 | Aprovar categoria: onde fica o vínculo, se não há `category_id`? (proposta: id da categoria criada em `data.createdCategoryId`) | Id da categoria criada em `data.createdCategoryId` | ADR-051, item 3 |
| L4 | Avisar o solicitante? (proposta: sim, uma `notifications` do tipo `CATALOG_REQUEST`) | Sim, uma `notifications` do tipo `CATALOG_REQUEST` | `64`, FP 9 e FA 6; ADR-051, item 2 |
| L5 | Corrigir o caso de uso 64 (texto do caso 63 nas pré-condições e nos passos 3, 7 e 8; acrescentar recusar) | Corrigido: pré-condições, passos 3, 7 e 8, e a recusa acrescentada | `64` |
