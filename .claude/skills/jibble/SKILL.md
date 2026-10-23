---
name: jibble
description: Registra, consulta e concilia as horas do time do CromoCard no Jibble pelo Playwright (MCP `playwright-figma`, perfil que guarda o login) — bater ponto, lançar horas numa Task do Azure, ver o timesheet e, principalmente, alinhar as horas do Jibble com o Trabalho concluído das Tasks no board. Use quando pedirem para bater ponto, apontar ou lançar horas, ver quanto alguém trabalhou ou deixar o Azure em dia com o Jibble.
argument-hint: "sincronizar [desde DD/MM] · horas [hoje|semana|sprint] · entrada|pausa|volta|saida [AB#id] · lancar <h:mm> <AB#id> [data]"
---

Executa `$ARGUMENTS` no Jibble pelo navegador do MCP `playwright-figma`. O Jibble não tem MCP que funcione no Claude
Code (o login OAuth do `mcp.jibble.io` recusa o endereço de retorno do Claude Code), então a skill usa a sessão da
própria pessoa no Jibble web.

## Regras

- **Só a conta de quem está usando.** Leia e grave só as horas da pessoa logada.
- **Senha nunca.** O Claude não digita senha nem faz o login: a pessoa entra na janela do Chrome que o Playwright
  abriu.
- **Escrita confirma antes.** No Jibble (ponto, registro manual, edição) e no Azure (horas, estado, Task nova), mostre
  o que vai gravar e espere o "sim". `entrada`, `pausa`, `volta` e `saida` pedidos nesta chamada já são a confirmação.
  Pedir para sincronizar autoriza gravar no Azure o que a tabela aprovada mostrar.
- **Horas no Azure em horas.minutos**, como o time grava: 1h11 vira `1.11` no Trabalho concluído (não `1.18`). Ao somar
  o que já está no board, leia assim também.
- **Task fechada tem hora.** Toda Task `Closed` precisa de Trabalho concluído; se foi criada e fechada, alguém
  trabalhou nela. Uma Task fechada sem hora é a primeira pista do que falta apontar.
- Fuso `America/Sao_Paulo`; datas em `DD/MM`.

## 1. Abrir o Jibble

1. `browser_navigate` para `https://web.jibble.io/timesheets` e `browser_wait_for` uns 5 segundos.
2. Se a página for de login (Jibble ou Google), peça para a pessoa entrar na janela do Chrome do Playwright e avisar.
   O perfil do `playwright-figma` guarda o login; das próximas vezes abre direto.
3. A sessão fica no `localStorage`, na chave `oidc.user:https://identity.prod.jibble.io:spa.client` (`access_token`).
   O id da pessoa é o claim `prsid` do token. Nunca mostre nem salve o token.

## 2. Ler as horas

Leia pela API que a própria tela usa, com `browser_evaluate` e `fetch` autenticado pelo token da sessão. Salve o
resultado com `filename` em `.playwright-mcp/` (fica fora do git) em vez de trazer para a conversa:

```
GET https://time-tracking.prod.jibble.io/v1/TimeEntries
    ?$expand=activity,project
    &$filter=personId eq <prsid> and time ge <AAAA-MM-DD>T00:00:00Z
    &$orderby=time asc&$top=500&$skip=<n>
Authorization: Bearer <access_token>
```

Cada registro tem `type` (`In` ou `Out`), `time`, `localTime`, `activity.name`, `project.name` e `note`. Junte cada
`In` com o `Out` seguinte para formar as sessões (início, fim, duração, atividade, projeto e nota). Um `In` sem `Out`
é a sessão aberta: não aponte, avise.

## 3. Sincronizar com o Azure (`sincronizar [desde DD/MM]`)

1. Leia as sessões do Jibble desde a data (padrão: início da sprint atual, pelo `mcp__azure-devops__work`).
2. Leia as Tasks da pessoa no Azure (`mcp__azure-devops__wit_query`): estado, Trabalho concluído, datas de ativação e
   fechamento e a cerimônia ou user story pai.
3. Case cada sessão com uma Task, nesta ordem de pista:
   - nota ou atividade com o título da Task (`Apontamento Daniel`, `Criar diagrama de entidades (DER)`);
   - cerimônia do dia (`Planning`, `Daily`, `Review`) → o `Apontamento <Nome>` filho da cerimônia em `#89 Reuniões`;
   - commits e PRs da pessoa naquele dia (`git log --author` no workspace e nos apps), que trazem o `AB#`;
   - data de ativação ou fechamento da Task.
   Uma sessão pode cobrir mais de uma Task, e uma Task pode somar várias sessões.
4. Monte a tabela: data, sessão do Jibble, duração, o que foi feito, Task proposta, horas hoje → horas depois. Sessão
   sem Task certa vira proposta de Task nova, filha da user story ou da cerimônia do assunto.
5. Com a aprovação, grave com `mcp__azure-devops__wit_work_item_write`: some no Trabalho concluído (não apague o que já
   está lá) e feche a Task se o trabalho terminou. Ao fechar uma Task que saiu de `New`, deixe o Trabalho restante
   vazio: o board recusa valor nele nessa transição (`TF401320 … InvalidNotEmpty`).
6. Confira no fim: nenhuma Task `Closed` sem hora e o total do Azure ao lado do total do Jibble (diferença de poucos
   minutos é arredondamento).

## 4. Ponto e registro manual

Pela interface do Jibble web (`browser_snapshot` para achar o botão, `browser_click` e `browser_type`), não pela API:

| Pedido | Na tela |
|---|---|
| `entrada [AB#id]` | Botão de entrada; projeto **CromoCard** (ou o que a pessoa usa) e nota `AB#<id> <título da Task>` |
| `pausa` / `volta` / `saida` | Botões de pausa e saída; na saída, mostre o total do dia |
| `lancar <h:mm> <AB#id> [data]` | Folhas de Ponto → adicionar registro manual no dia; confirme antes |
| `horas [hoje\|semana\|sprint]` | Leia pela seção 2 e mostre por dia e por Task |

Leia o título da Task com `mcp__azure-devops__wit_work_item` para a nota. Se o botão ou o campo não estiver onde a
tela mostra, pare e descreva o que viu em vez de clicar no escuro.

## 5. Responder

- Sincronizar: a tabela do que foi gravado, as Tasks novas com o `#id`, o total Jibble × Azure e o que ficou de fora
  (sessão aberta, sessão sem Task).
- Ponto: o que foi registrado, o horário e o total do dia.
