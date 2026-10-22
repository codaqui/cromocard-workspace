# CCD062 — Gestão de Comunidade

- **Status:** Planejada
- **Fase:** MVP
- **User story:** #337 `CCD062-Gestão de Comunidade` · responsável Lucas Oliveira Lima · Sprint 07
- **Caso de uso:** [62-gestao-de-comunidade.md](../../docs/Casos-De-Uso/62-gestao-de-comunidade.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO)

## Objetivo

> Como Administrador eu quero poder excluir, suspender grupos e moderar mensagens denunciadas na plataforma.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401`/`403` | Permissão | `62`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | Tela em `/backoffice/comunidades`, item "Comunidades" do menu | Tela | `62`, FP 1; ADR-038 |
| R3 | Lista paginada dos grupos existentes, sem excluídos | Tela | `62`, FP 2; ADR-015, item 5; ADR-011 |
| R4 | O admin seleciona um grupo e vê as informações e as opções | Tela | `62`, FP 3–4 |
| R5 | Suspender um grupo (`status = SUSPENDED`), como ação `POST` | Ação | user-stories.md §8; DBML `group_status`; ADR-011 |
| R6 | Excluir um grupo com soft delete (`204`); membros e mensagens somem pelo filtro | Ação | user-stories.md §8; ADR-015, itens 1 e 6 |
| R7 | Lista das mensagens de grupo denunciadas (`reports` com `target_type = GROUP_MESSAGE`) | Tela | user-stories.md §8; DBML `reports` |
| R8 | Excluir a mensagem denunciada (soft delete); a denúncia continua apontando para ela | Ação | user-stories.md §4 e §8; ADR-015 |
| R9 | Resolver (`RESOLVED`) ou descartar (`DISMISSED`) a denúncia, gravando `moderator_id` e `resolved_at` | Estado | DBML `report_status`, `moderator_id`, `resolved_at` |
| R10 | Confirmação antes de gravar e mensagem ao concluir | Ação | `62`, FP 7–9 |
| R11 | Cancelar sem alterar nada | Ação | `62`, FA 5–6 |
| R12 | Suspender, excluir e moderar gravam `audit_logs` | Regra | user-stories.md §8 (Log de Auditoria); ADR-034 (Proposto) |
| R13 | Reativar um grupo suspenso (`status = ACTIVE`); o grupo suspenso some de Explorar e fica só leitura para os membros | Ação | `62`, FP 4 e FP 8 |
| R14 | Indicadores: grupos ativos, mensagens dos últimos 7 dias e denúncias pendentes | Campo | `62`, FP 2 |

## Critérios de aceite

- **CA1** (R3) — **Dado** grupos ativos e suspensos, **quando** abre Comunidades, **então** vê a lista com nome,
  membros, status e ações, com busca e filtro de status.
- **CA2** (R5, R10, R12) — **Dado** um grupo ativo, **quando** o admin suspende com motivo, **então** o status vira
  `SUSPENDED`, a lista mostra "Suspenso" e o log registra.
- **CA3** (R13) — **Dado** um grupo suspenso, **quando** o admin reativa, **então** o status volta a `ACTIVE`.
- **CA4** (R6, R12) — **Dado** um grupo, **quando** o admin confirma a exclusão com motivo, **então** `deleted_at` é
  preenchido e ele some da lista.
- **CA5** (R7) — **Dado** denúncias pendentes de mensagens, **quando** abre a fila de moderação, **então** vê o
  autor, o grupo, o texto, o motivo e quem denunciou.
- **CA6** (R8, R9, R12) — **Dado** uma denúncia pendente, **quando** o admin remove a mensagem, **então** a mensagem
  ganha `deleted_at`, a denúncia fica `RESOLVED` com o moderador e o log registra.
- **CA7** (R9) — **Dado** uma denúncia pendente, **quando** o admin dispensa, **então** a denúncia fica `DISMISSED`
  e a mensagem continua.
- **CA8** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama a rota, **então** recebe `403`.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `groups` | `name`, `access_type`, `status`, `creator_id`, `deleted_at` | fundação |
| `group_members` | contagem de membros | fundação |
| `group_messages` | `content`, `author_id`, `group_id`, `deleted_at` | fundação |
| `reports` | `target_type`, `group_message_id`, `reason`, `description`, `status`, `moderator_id`, `resolved_at` | fundação |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| administração - comunidade | [220-3524](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=220-3524) | R3–R9 | ⚠️ Divergente |

- O Figma tem os indicadores (grupos ativos, mensagens monitoradas, alertas pendentes), a lista "Grupos & Guildas"
  com Suspender, Reativar e Excluir, e a "Fila de Moderação" com Dispensar Denúncia e Remover Mensagem.
- **Fora da documentação no Figma** (L4, L5): "Remover mensagem & advertir usuário", "Banir definitivamente" e "Banir
  temporariamente (3 dias)", contagem de advertências, status "Advertência", "volume negociado".

## Fora do escopo

- Criar e editar grupo pelo admin (o caso de uso cita; a user story não — L1).
- Banir ou advertir o autor pela fila (suspender usuário é da CCD059).
- Denúncias de perfil, usuário e anúncio.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | O caso de uso fala em criar e alterar grupos; a user story, em suspender, excluir e moderar. Qual vale? (proposta: a user story; corrigir o caso de uso 62) | Vale a user story: suspender, reativar, excluir e moderar. O caso de uso 62 foi corrigido | `62`, Finalidade e FP 3–13 |
| L2 | O que a suspensão bloqueia e se existe reativar (proposta: grupo suspenso some de Explorar e fica só leitura para os membros; reativar existe) | O grupo suspenso some de Explorar e fica só para leitura dos membros; reativar existe | `62`, FP 4 e FP 8 |
| L3 | Exige motivo? (proposta: sim, nas três ações, guardado no `audit_logs`) | Sim, nas três ações e na moderação, guardado no `audit_logs` | `62`, FP 5, FP 12 e FA 1–2; ADR-051, item 5 |
| L4 | Banir ou advertir o autor pela fila? (proposta: não no MVP; a fila tem um link "ver usuário" para a CCD059) | Não no MVP; a fila tem um link "ver usuário" para a CCD059. As sanções viraram a CCD099 (escopo adicional) | CCD099 |
| L5 | Indicadores do topo (proposta: grupos ativos, mensagens dos últimos 7 dias, denúncias pendentes) | Grupos ativos, mensagens dos últimos 7 dias e denúncias pendentes | `62`, FP 2 |
