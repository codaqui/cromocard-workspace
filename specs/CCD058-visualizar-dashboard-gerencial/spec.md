# CCD058 — Visualizar Dashboard Gerencial

- **Status:** Planejada
- **Fase:** MVP
- **User story:** #333 `CCD058-Visualizar Dashboard Gerencial` · responsável Lucca Rocha · Sprint 06
- **Caso de uso:** [58-visualizar-dashboard-gerencial.md](../../docs/Casos-De-Uso/58-visualizar-dashboard-gerencial.md)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO)

## Objetivo

> Como Administrador eu quero visualizar KPIs (total de usuários, cartas cadastradas, novos cadastros), relatórios no
> painel e cadastros dos vendedores.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN` recebe os dados (`authorize('ADMIN')`); sem token `401`, outro papel `403` | Permissão | `58`, Pré-condições; ADR-005, item 4; ADR-011 |
| R2 | A tela fica em `/backoffice` (home do BackOffice), com `RequireRole role="ADMIN"` | Tela | ADR-038; ADR-043 |
| R3 | O menu do BackOffice tem "Dashboard", que abre a tela | Ação | `58`, FP 1 |
| R4 | Ao abrir, a tela carrega os dados da API | Ação | `58`, FP 2 |
| R5 | KPI total de usuários | Campo | user-stories.md §8 |
| R6 | KPI cartas cadastradas | Campo | user-stories.md §8 |
| R7 | KPI novos cadastros no período | Campo | user-stories.md §8 |
| R8 | Relatório no painel: gráfico da evolução de novos cadastros | Tela | user-stories.md §8 ("relatórios no painel") |
| R9 | Lista dos cadastros de vendedores recentes | Tela | user-stories.md §8 ("cadastros dos vendedores") |
| R10 | Filtro de período | Campo | `58`, FP 5 |
| R11 | O filtro vai para a API e os indicadores são recalculados | Regra | `58`, FP 6–7 |
| R12 | Sem dados, a tela informa que não existem dados para apresentação | Estado | `58`, FA 1–2 |
| R13 | Filtro sem dados informa que não foram encontrados dados para os filtros selecionados | Mensagem | `58`, FA 3–4 |
| R14 | As contagens ignoram registros excluídos | Regra | ADR-015, item 5 |
| R15 | Datas trafegam em ISO 8601 UTC; o frontend aplica o fuso | Regra | ADR-011 |
| R16 | A tela trata carregando e erro | Estado | `.claude/rules/frontend.md` |

## Critérios de aceite

- **CA1** (R1–R7, R14) — **Dado** um admin logado, **quando** abre o Dashboard, **então** vê total de usuários,
  cartas cadastradas e novos cadastros dos últimos 30 dias, sem contar excluídos.
- **CA2** (R10, R11) — **Dado** o Dashboard aberto, **quando** escolhe 7 dias, **então** os KPIs, o gráfico e a lista
  são recalculados para o período.
- **CA3** (R8) — **Dado** cadastros em vários meses, **quando** abre o Dashboard, **então** o gráfico mostra a
  quantidade por mês, separando clientes e vendedores.
- **CA4** (R9) — **Dado** vendedores cadastrados, **quando** abre o Dashboard, **então** a lista mostra os mais
  recentes com nome, e-mail e data, paginada.
- **CA5** (R12) — **Dado** o banco sem usuários nem cartas, **quando** abre o Dashboard, **então** a tela mostra
  "Não existem dados para apresentação".
- **CA6** (R13) — **Dado** um período sem cadastros, **quando** filtra, **então** a tela mostra "Não foram
  encontrados dados para os filtros selecionados".
- **CA7** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama a API do dashboard, **então** recebe `403`.
- **CA8** (R16) — **Dado** a API fora do ar, **quando** abre o Dashboard, **então** a tela mostra o erro com "tentar
  de novo".

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `users` | `role`, `created_at`, `deleted_at` | KPIs, gráfico e lista de vendedores |
| `cards` | `id`, `deleted_at` | KPI cartas cadastradas (catálogo global) |

## Telas (Figma)

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Administração - dashboard geral | [208-1240](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=208-1240) | R3, R5–R10 | ⚠️ Divergente |
| Dashboard - filtro de 7 dias | [247-2499](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=247-2499) | R10, R11 | não conferida (frame pesado travou o Chrome) |

- **Fora da documentação no Figma** (ver L2 e L3): card de escrow em R$, taxa de autenticação, conversão KYC, score
  de reputação e volume anunciado, e as ações "Validar Cadastro", "Notificar Lojista" e "Logs" na tabela de
  vendedores, com o painel "Validar Cadastro" (246-1201), o modal "Notificar lojista" (246-2038) e a confirmação
  (252-1375).
- O botão "Exportar Dados" leva à tela de Relatórios (CCD063).

## Fora do escopo

- Credenciamento de vendedor (painel "Validar Cadastro", notificar pendência) — não está na documentação nem no DER.
- Indicadores do marketplace (escrow, volume anunciado, reputação) — fase Futuro Marketplace.
- Exportação — CCD063.

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Como contar cada KPI? (proposta: usuários não excluídos de todos os papéis menos ADMIN; cartas do catálogo `cards`; novos cadastros = `users.created_at` no período) | Usuários não excluídos de todos os papéis menos ADMIN; cartas de `cards`; novos cadastros por `users.created_at` no período | `58`, FP 2–3 |
| L2 | O credenciamento de vendedor do Figma entra no MVP? (proposta: não; a lista mostra só os vendedores recentes, com "Ver informações" levando à Gestão de Usuários) | Não entra no MVP: a lista mostra os vendedores recentes, com "Ver informações" levando à Gestão de Usuários. O credenciamento virou a CCD094 (escopo adicional) | `58`, FP 3; CCD094 |
| L3 | Os KPIs de marketplace do Figma ficam fora? (proposta: sim) | Ficam fora do MVP; viraram a CCD097 (escopo adicional) | CCD097 |
| L4 | Períodos do filtro (proposta: Hoje, 7 dias, 30 dias — padrão — e 1 ano, mais intervalo de datas; fuso de São Paulo para cortar o dia) | Hoje, 7 dias, 30 dias (padrão) e 1 ano, mais intervalo de datas; o dia é cortado pelo horário de Brasília | `58`, FP 5–6 |
| L5 | Como contar as cartas (R6) enquanto o domínio de catálogo não existe? | Decisão do PO (Lucca, 30/10/2026): `totalCards` é `number \| null` e vem `null` até a CCD061 expor `countCards()` na service do catálogo; o dashboard não lê a tabela `cards` direto (ADR-001). A tela mostra "—" com a dica "Disponível com o catálogo", e o `isEmpty` (R12) considera só os usuários enquanto isso | revisão do backend#16 e do frontend#7 |
| L6 | No filtro sem cadastros (R13/CA6), o que acontece com os KPIs? | Decisão do PO (Lucca, 30/10/2026): os KPIs continuam na tela (o total de usuários é geral; os do período mostram 0). O gráfico e a lista de vendedores mostram "Não foram encontrados dados para os filtros selecionados" | revisão do frontend#7 |
| L7 | No intervalo personalizado, quem corta o dia pelo horário de Brasília? | Decisão do PO (Lucca, 30/10/2026): o frontend converte o início e o fim do dia em Brasília para ISO 8601 UTC (fim do dia em `.999`, sem offset fixo) e o backend só valida o intervalo, como pede o R15. Os períodos nomeados (`period`) são cortados pelo backend | revisão do backend#16 e do frontend#7 |
