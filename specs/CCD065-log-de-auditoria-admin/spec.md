# CCD065 — Log de Auditoria Admin

- **Status:** Planejada
- **Fase:** MVP
- **User story:** #340 `CCD065-Log de Auditoria Admin` · responsável Gabriel Nascimento · Sprint 07
- **Caso de uso:** [65-log-de-auditoria-admin.md](../../docs/Casos-De-Uso/65-log-de-auditoria-admin.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO); reaprovada em 2026-11-12, depois da revisão do Figma do painel admin

## Objetivo

> Como Administrador eu quero ver um log do sistema registrando qual moderador apagou um grupo ou baniu um usuário para
> ter controle de segurança das ações da minha equipe.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401`/`403` | Permissão | `65`, Pré-condições; ADR-005, item 4 |
| R2 | Tela em `/backoffice/logs`, item "Logs" do menu | Tela | `65`, FP 1; ADR-038 |
| R3 | Lista das ações administrativas de todos os admins, paginada | Tela | `65`, FP 2; user-stories.md §8; ADR-011 |
| R4 | Cada registro mostra a data e hora (DD/MM/AAAA HH:MM, horário de Brasília), quem fez e o IP, a ação, o alvo (ID encurtado) e o motivo | Campo | `65`, FP 2 (L4); DBML `audit_logs` |
| R5 | Filtros opcionais, processados na API | Ação | `65`, FP 3–5 |
| R6 | "Ver detalhes" abre o painel lateral com responsável, IP, data e hora, ação (rótulo e código), alvo (ID completo), motivo e `details` | Tela | `65`, FP 6–7 |
| R7 | Pesquisa sem resultados informa que nenhum registro foi encontrado | Estado | `65`, FA 1–4 |
| R8 | O log não tem edição nem exclusão e continua legível se o admin ou a entidade forem excluídos | Regra | ADR-015, item 4 e Consequências |
| R9 | A tela trata carregando e erro | Estado | `.claude/rules/frontend.md` |
| R10 | Ações vêm de uma lista fechada no `AuditLogService` e aparecem com rótulo em português | Campo | `65`, FP 5; ADR-051, item 4 |

## Critérios de aceite

- **CA1** (R3, R4) — **Dado** ações registradas por dois admins, **quando** abre Logs, **então** vê as duas, das mais
  recentes para as mais antigas, com quem fez, ação, alvo, motivo e data.
- **CA2** (R5) — **Dado** a lista, **quando** filtra por admin, tipo de ação e período, **então** só aparecem os
  registros correspondentes.
- **CA3** (R6) — **Dado** um registro, **quando** o admin abre, **então** vê os detalhes completos.
- **CA4** (R7) — **Dado** um filtro sem resultados, **quando** aplica, **então** a tela mostra "Nenhum registro
  encontrado" e o botão "Extrair Logs" fica desabilitado.
- **CA5** (R8) — **Dado** um registro de um admin depois excluído, **quando** abre Logs, **então** o registro aparece
  com o nome dele.
- **CA6** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama a rota, **então** recebe `403`.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `audit_logs` | `admin_id`, `action`, `entity_type`, `entity_id`, `details`, `created_at` | fundação; gravado pelo `AuditLogService` |
| `users` | `name`, `email` do admin (inclusive excluído) | — |

## Telas (Figma)

Conferidas em 12/11/2026, depois do ajuste do Figma à documentação. Links: `https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=<frame>`.

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Logs do sistema | `228-2395` | R2–R5, R8 | ✅ Bate |
| Detalhes do registro (painel lateral) | `749-624` | R6 | ✅ Bate |
| Nenhum registro encontrado | `849-383` | R7 | ✅ Bate |

- "Extrair Logs", a variação do total, os filtros rápidos e o IP são da CCD102.

## Fora do escopo

- Gravar os registros: cada story de ação grava pelo `AuditLogService` da fundação.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Filtros (proposta: admin, tipo de ação, tipo de entidade, período e busca por ID do alvo) | Administrador, tipo de ação, tipo de entidade, período e ID do alvo | `65`, FP 3 |
| L2 | Exportar logs, que está no Figma e não na documentação (proposta: fora do MVP) | Fora do MVP; virou a CCD102 (escopo adicional) | CCD102 |
| L3 | Valores de `action` (proposta: lista fechada no `AuditLogService`, por exemplo `USER_SUSPENDED`, `GROUP_DELETED`, `CATALOG_REQUEST_APPROVED`, com rótulos em pt-BR no frontend) | Lista fechada no `AuditLogService`, com rótulos em português no frontend | `65`, FP 5; ADR-051, item 4 |
| L4 | Formato da data e cabeçalho da tela (o Figma usava ISO 8601 com milissegundos e um botão "Sair" só nesta tela) | DD/MM/AAAA HH:MM no horário de Brasília; cabeçalho igual ao das outras telas do admin. Decisão do PO (Daniel, 12/11/2026), na revisão do Figma | `65`, FP 2 |
