# CCD059 — Gestão de Usuários

- **Status:** Planejada
- **Fase:** MVP
- **User story:** #334 `CCD059-Gestão de Usuários` · responsável Felipe Consulim · Sprint 06
- **Caso de uso:** [59-gestao-de-usuarios.md](../../docs/Casos-De-Uso/59-gestao-de-usuarios.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO); reaprovada em 2026-11-12, depois da revisão do Figma do painel admin

## Objetivo

> Como Administrador eu quero criar, editar, suspender, excluir e alterar permissões de acesso de qualquer usuário da
> plataforma.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Todos os endpoints exigem `ADMIN`; `401`/`403` | Permissão | `59`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | Tela em `/backoffice/usuarios`, item "Usuários" do menu | Tela | `59`, FP 1; ADR-038 |
| R3 | Lista paginada de usuários, sem excluídos, com nome, e-mail, papel (Cliente, Vendedor ou Administrador), status (Ativo, Suspenso ou Bloqueado) e data de cadastro | Tela | `59`, FP 2 (L7); ADR-011; ADR-015, item 5 |
| R4 | Selecionar um usuário abre a página do usuário, com dados pessoais, contato, endereços, as ações administrativas já feitas sobre ele (lidas do `audit_logs`) e as opções de gerenciamento | Tela | `59`, FP 3–4 (L8) |
| R5 | Opção cadastrar novo usuário com nome, e-mail e papel | Ação | `59`, FP 3 e FP 5; user-stories.md §8; DBML `users` |
| R6 | Editar os dados de um usuário (`PATCH`) | Ação | `59`, FP 5; user-stories.md §8 |
| R7 | Alterar o papel (`CUSTOMER`, `SELLER`, `ADMIN`) | Ação | user-stories.md §8; DBML `user_role` |
| R8 | Suspender (`status = SUSPENDED`) e reativar (`ACTIVE`), como ações `POST` | Ação | user-stories.md §8; `59`, Finalidade; ADR-011 |
| R9 | Excluir com soft delete (`deleted_at`), respondendo `204` | Ação | user-stories.md §8; ADR-015, item 1 |
| R10 | E-mail único: criar ou editar com e-mail existente (inclusive excluído) responde `409` | Regra | DBML `users.email`; ADR-011; ADR-015, item 7 |
| R11 | Validação com erros por campo (`400`) e nova validação após corrigir | Regra | `59`, FP 6 e FA 1–4; ADR-006 |
| R12 | Mensagem de confirmação ao concluir | Mensagem | `59`, FP 8 |
| R13 | Cancelar volta à lista sem gravar | Ação | `59`, FA 5–6 |
| R14 | Suspender ou excluir grava `audit_logs` | Regra | ADR-034; user-stories.md §8 (Log de Auditoria) |
| R15 | Usuário suspenso ou excluído não loga nem renova token | Regra | ADR-005, item 6 (implementado na CCD004) |
| R16 | Busca por nome ou e-mail e filtros de papel e de status | Campo | `59`, FP 2 |
| R17 | O cadastro envia o convite com o link de definir senha; a conta nasce com o e-mail confirmado e o aceite dos termos fica para o primeiro acesso | Regra | `59`, FP 7; ADR-048, item 2 |
| R18 | O admin não suspende, exclui nem rebaixa a própria conta nem o último ADMIN ativo (`422`) | Regra | `59`, FA 7–8 |
| R19 | Suspender, reativar e excluir exigem motivo; suspender e excluir revogam os refresh tokens do usuário | Regra | `59`, FP 9–10 |

## Critérios de aceite

- **CA1** (R3) — **Dado** usuários cadastrados, **quando** abre Usuários, **então** vê a lista paginada com nome,
  e-mail, papel, status e data de cadastro, busca por nome ou e-mail e filtros de papel e status, sem os excluídos.
- **CA2** (R5, R10, R11, R12) — **Dado** o formulário de novo usuário, **quando** salva com dados válidos, **então** a
  API responde `201`, o usuário aparece na lista e recebe o convite; com e-mail existente, `409`.
- **CA3** (R6, R7) — **Dado** um usuário, **quando** o admin muda nome e papel, **então** a API responde `200` e a
  lista mostra o novo papel.
- **CA4** (R8, R14) — **Dado** um usuário ativo, **quando** o admin suspende informando o motivo, **então** o status
  vira `SUSPENDED`, as sessões dele são revogadas e o log registra a ação.
- **CA5** (R8) — **Dado** um usuário suspenso, **quando** o admin reativa, **então** o status volta a `ACTIVE`.
- **CA6** (R9, R14) — **Dado** um usuário, **quando** o admin confirma a exclusão digitando o texto de confirmação
  e o motivo, **então** `deleted_at` é preenchido, ele some da lista e o log registra.
- **CA7** (R18) — **Dado** o admin logado, **quando** tenta suspender, excluir ou rebaixar a si mesmo, **então** a API
  responde `422`.
- **CA8** (R13) — **Dado** um formulário aberto, **quando** cancela, **então** nada é gravado e volta à lista.
- **CA9** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama qualquer rota de gestão, **então** recebe `403`.
- **CA10** (R4) — **Dado** um usuário que teve o telefone editado por um admin, **quando** o admin abre a página dele,
  **então** vê os dados, os endereços e, em "Ações administrativas", a edição com quem fez e quando.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `users` | `name`, `email`, `role`, `status`, `email_verified`, `created_at`, `deleted_at` | já existe |
| `refresh_tokens` | `revoked_at` | revogar sessões ao suspender ou excluir (CCD004) |
| `password_reset_tokens` | — | convite do usuário criado pelo admin (CCD006) |
| `audit_logs` | `action`, `entity_type`, `entity_id`, `details` | fundação |

## Telas (Figma)

Conferidas em 11/11/2026, depois do ajuste do Figma à documentação. Links: `https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=<frame>`.

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Gestão de usuários | `208-1793` | R2, R3, R16 | ✅ Bate |
| Adicionar novo usuário | `276-1202` | R5, R17 | ✅ Bate |
| Adicionar novo usuário - erros de validação | `804-1188` | R10, R11 | ✅ Bate |
| Editar usuário | `804-1682` | R6, R7 | ✅ Bate |
| Operação concluída | `804-3283` | R12 | ✅ Bate |
| Página do usuário (cliente) | `649-1164` | R4, R8, R9 | ✅ Bate |
| Página do usuário (própria conta do admin) | `649-796` | R4, R18 | ✅ Bate |
| Reativar usuário | `804-2889` | R8 | ✅ Bate |
| Excluir usuário | `276-1735` | R9, R19 | ✅ Bate (a conta pode ser restaurada; motivo obrigatório) |

- Na lista, @, telefone, CPF, último acesso e IP são da CCD098; "Suspenso (7d)", "Bloqueado" e o modal de sanção, da
  CCD099; o selo "Em análise", da CCD094.

## Fora do escopo

- Restaurar usuário excluído pelo BackOffice; suspensão com prazo; CPF e IP.
- Itens do Figma antigo que não entram (decisão de 11/11/2026, `escopo-adicional.md` §3): cargos, equipes,
  departamentos e permissões por módulo do administrador, 2FA, sessões e dispositivos, observações internas sobre o
  usuário, nível, reputação e pedidos do cliente na página do usuário.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Campos extras do Figma (@usuário, telefone, CPF, último acesso, IP, status a mais)? (proposta: fora do MVP; mostrar nome, e-mail, papel, status e data de cadastro) | Fora do MVP: a lista mostra nome, e-mail, papel, status e data de cadastro. Os campos extras viraram a CCD098 (escopo adicional) | `59`, FP 2; CCD098 |
| L2 | Como o usuário criado pelo admin entra? (proposta: convite por e-mail com link de definir senha, reaproveitando o token da CCD006; nasce com e-mail confirmado e termos a aceitar no primeiro acesso) | Convite por e-mail com o link de definir senha (mesmo token da CCD006); a conta nasce com o e-mail confirmado e o aceite dos termos fica para o primeiro acesso | `59`, FP 7; ADR-048, item 2 |
| L3 | Suspender e excluir exigem motivo? (proposta: sim, guardado no `audit_logs`) | Sim, motivo obrigatório, guardado no `audit_logs` | `59`, FP 9–10; ADR-051, item 5 |
| L4 | Suspender e excluir revogam as sessões na hora? (proposta: sim, revoga os refresh tokens; o access de 15 min expira sozinho) | Sim: revoga os refresh tokens na hora; o access token de 15 minutos expira sozinho | `59`, FP 10 |
| L5 | Limites: o admin pode agir sobre si mesmo? Sobre o último ADMIN? (proposta: não, `422`) | Não pode agir sobre a própria conta nem sobre o último ADMIN ativo (`422`) | `59`, FA 7–8 |
| L6 | Filtros da lista (proposta: busca por nome ou e-mail, papel, status) | Busca por nome ou e-mail e filtros de papel e de status | `59`, FP 2 |
| L7 | Nome dos papéis e o "Em análise" do Figma na coluna de status | Papéis Cliente, Vendedor e Administrador; status só Ativo, Suspenso e Bloqueado; vendedor com credenciamento em análise ganha o selo "Em análise" ao lado do papel. Decisão do PO (Daniel, 11/11/2026), na revisão do Figma | `59`, FP 2 |
| L8 | O que a seleção do usuário abre? | A página do usuário (frames `649-1164` e `649-796`), com dados, contato, endereços, as ações administrativas sobre ele (do `audit_logs`) e as opções de gerenciamento. Decisão do PO (Daniel, 11/11/2026), na revisão do Figma | `59`, FP 4; EA-059-03 |
