# CCD058 — Visualizar Dashboard Gerencial

- **Status:** Rascunho
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
| R9 | Lista dos 5 cadastros de vendedores mais recentes, com "Ver informações" (abre o usuário na Gestão de Usuários) e o atalho "Ver todos" (abre a Gestão de Usuários filtrada em vendedores) | Tela | user-stories.md §8; `58`, FP 3 (L11) |
| R10 | Filtro de período | Campo | `58`, FP 5 |
| R11 | O filtro vai para a API e os indicadores são recalculados | Regra | `58`, FP 6–7 |
| R12 | Sem dados, a tela informa que não existem dados para apresentação | Estado | `58`, FA 1–2 |
| R13 | Filtro sem dados informa que não foram encontrados dados para os filtros selecionados | Mensagem | `58`, FA 3–4 |
| R14 | As contagens ignoram registros excluídos | Regra | ADR-015, item 5 |
| R15 | Datas trafegam em ISO 8601 UTC; o frontend aplica o fuso | Regra | ADR-011 |
| R16 | A tela trata carregando e erro | Estado | `.claude/rules/frontend.md` |
| R17 | Os indicadores são os mesmos em qualquer período (Hoje, 7 dias, 30 dias, 1 ano ou intervalo): o filtro só recalcula os valores | Regra | `58`, FP 3 (L10) |
| R18 | O gráfico agrupa os pontos por hora (Hoje), por dia (7 e 30 dias) ou por mês (1 ano, até os últimos 7 meses) | Regra | `96`, FP 5 (L12); L8 |

## Critérios de aceite

- **CA1** (R1–R7, R14) — **Dado** um admin logado, **quando** abre o Dashboard, **então** vê total de usuários,
  cartas cadastradas e novos cadastros dos últimos 30 dias, sem contar excluídos.
- **CA2** (R10, R11) — **Dado** o Dashboard aberto, **quando** escolhe 7 dias, **então** os KPIs, o gráfico e a lista
  são recalculados para o período.
- **CA3** (R8, R18) — **Dado** cadastros nos últimos 30 dias, **quando** abre o Dashboard, **então** o gráfico mostra a
  quantidade por dia, separando clientes e vendedores; no filtro de 1 ano, por mês (até 7 meses); no Hoje, por hora.
- **CA4** (R9) — **Dado** 8 vendedores cadastrados, **quando** abre o Dashboard, **então** a lista mostra os 5 mais
  recentes com nome, e-mail e data, sem paginação, e "Ver todos" abre a Gestão de Usuários filtrada em vendedores.
- **CA5** (R12) — **Dado** o banco sem usuários nem cartas, **quando** abre o Dashboard, **então** a tela mostra
  "Não existem dados para apresentação".
- **CA6** (R13) — **Dado** um período sem cadastros, **quando** filtra, **então** a tela mostra "Não foram
  encontrados dados para os filtros selecionados".
- **CA7** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama a API do dashboard, **então** recebe `403`.
- **CA8** (R16) — **Dado** a API fora do ar, **quando** abre o Dashboard, **então** a tela mostra o erro com "tentar
  de novo".
- **CA9** (R17) — **Dado** o Dashboard aberto, **quando** troca entre Hoje, 7 dias, 30 dias e 1 ano, **então** os
  cards de indicadores continuam os mesmos (total de usuários, cartas cadastradas e novos cadastros) e só os valores
  mudam.

## Dados

| Tabela | Colunas e enums usados | Observação |
|---|---|---|
| `users` | `role`, `created_at`, `deleted_at` | KPIs, gráfico e lista de vendedores |
| `cards` | `id`, `deleted_at` | KPI cartas cadastradas (catálogo global) |

## Telas (Figma)

Conferidas em 11/11/2026, depois do ajuste do Figma à documentação. Links:
`https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=<frame>`.

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Dashboard geral (30 dias) | `208-1240` | R3, R5–R11, R17, R18 | ✅ Bate |
| Dashboard - filtro de 7 dias | `247-2499` | R10, R11, R17, R18 | ✅ Bate |
| Dashboard - filtro Hoje | `247-3539` | R10, R11, R17, R18 | ✅ Bate |
| Dashboard - sem dados | `795-1174` | R12 | ✅ Bate |
| Dashboard - filtro sem dados | `795-1704` | R13 | ✅ Bate (L6: os KPIs gerais continuam, os do período mostram 0) |
| Dashboard - intervalo de datas | `795-3417` | R10, R15 | ✅ Bate |

- Os frames também mostram itens de outras specs: meta mensal e evolução de lojistas certificados (CCD096,
  `795-2234`), card financeiro e Livro Razão (CCD097, `795-2761`), credenciamento, filtro de status e "Analisar Fila"
  (CCD094, `795-3961`). Enquanto essas specs não entram, o MVP mantém o card "Composição dos cadastros" no lugar do
  card financeiro (L9).
- O botão "Exportar Dados" leva à tela de Relatórios (CCD063).

## Fora do escopo

- Credenciamento de vendedor (selo de status, "Validar Cadastro", "Analisar Fila", filtro de status) — CCD094.
- Meta mensal e linha de lojistas certificados — CCD096.
- Indicadores do marketplace (custódia, liquidado, garantia, Livro Razão, volume anunciado, reputação) — CCD097.
- Exportação — CCD063.
- Itens do Figma antigo que não entram (decisão de 11/11/2026, `escopo-adicional.md` §3): taxa de autenticação,
  taxa anti-fraude, "Logs" e "Notificar Lojista" na linha do vendedor, status com motivo e paginação da lista.

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
| L8 | Quantos meses o gráfico mostra (R8)? A spec não define, e o protótipo mostra 7 | Decisão do PO (Lucca, 06/11/2026): o gráfico mostra no máximo os últimos 7 meses do período, como o protótipo, e o subtítulo informa isso. Os KPIs continuam contando o período inteiro | revisão do frontend#7 |
| L9 | O que ocupa o espaço do card de escrow, que ficou fora do MVP (L3)? A spec não define | Card "Composição dos cadastros", com a proporção de clientes e vendedores entre os novos cadastros do período. Usa só dados que a API já devolve | frontend#7 |
| L10 | Os KPIs mudam conforme o período, como no Figma antigo (Hoje sem cartas, 7D com "Lojistas")? | Não: os quatro indicadores são os mesmos em qualquer período e o filtro só recalcula os valores. Decisão do PO (Daniel, 11/11/2026), na revisão do Figma | `58`, FP 3 |
| L11 | Quantos vendedores a lista mostra? | Os 5 cadastros mais recentes, com "Ver todos", que abre a Gestão de Usuários filtrada em vendedores. Decisão do PO (Daniel, 11/11/2026), na revisão do Figma | `58`, FP 3 |
| L12 | O gráfico de 30 dias agrupa por mês (L8) ou por dia (CCD096 FP 5)? | Por dia, como manda a CCD096 FP 5; a L8 (últimos 7 meses) vale só para o filtro de 1 ano. O frontend já implementado precisa de ajuste. Registrado na revisão do Figma de 11/11/2026 seguindo o caso de uso, que é a fonte da verdade (o Daniel delegou a forma do registro); confirmar ao reaprovar a spec | `96`, FP 5 |
