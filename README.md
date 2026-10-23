# CromoCard — Workspace

Workspace da equipe do **CromoCard — Sistema de Gestão de Cartas Colecionáveis**: documentação
(casos de uso, DER, C4, ADRs), as specs do SDD e os dois apps como submódulos.

| Pasta | Conteúdo |
| --- | --- |
| `docs/` | **Fonte da verdade, só documentação:** ADRs, casos de uso e user stories, DER, diagramas C4, de classes e de atividades |
| `specs/` | SDD: spec, plano e tarefas de cada user story, derivados de `docs/` ([fluxo](specs/README.md)) |
| `apps/cromocard-backend` | API (submódulo de [codaqui/cromocard-backend](https://github.com/codaqui/cromocard-backend)) |
| `apps/cromocard-frontend` | SPA web e BackOffice (submódulo de [codaqui/cromocard-frontend](https://github.com/codaqui/cromocard-frontend)) |

Fluxo de branches, commits e PRs: [.claude/rules/git.md](.claude/rules/git.md) — o mesmo arquivo que o
Claude segue.

## Clonar

O backend e o frontend são **submódulos**: clone sempre com `--recurse-submodules`. Sem essa opção, as pastas
`apps/cromocard-backend` e `apps/cromocard-frontend` ficam vazias.

```bash
git clone --recurse-submodules https://github.com/codaqui/cromocard-workspace.git
```

Se você já clonou sem a opção, baixe os apps com:

```bash
git submodule update --init
```

Cada app é um repositório próprio: para trabalhar nele, entre na pasta (`cd apps/cromocard-backend`), troque para
a branch `develop` e siga o [fluxo de branches](.claude/rules/git.md).

## Claude Code e MCPs

O repositório já traz os MCPs do time no `.mcp.json`: **Azure DevOps** (board), **Figma**
(protótipo) e **Playwright** (navegador para testar os apps e ler o Figma e o Jibble). Cada pessoa faz o setup uma vez, com as
**próprias contas**. Nunca compartilhe nem commite o seu token.

### 1. Token do Azure DevOps

A organização `CromoCard` está numa conta Microsoft pessoal, então o login pelo navegador não
funciona. O MCP usa um token pessoal (PAT).

1. Crie o token em <https://dev.azure.com/CromoCard/_usersSettings/tokens> → **New Token**, na
   organização `CromoCard`, com os escopos **Work Items** (Read & write), **Project and Team**
   (Read), **Identity** (Read) e **Wiki** (Read).
2. Grave o token numa variável de ambiente, trocando o e-mail e o token pelos seus:

   Linux ou macOS (`~/.bashrc` ou `~/.zshrc`):

   ```bash
   export AZURE_DEVOPS_PAT="$(printf '%s' 'seu-email@exemplo.com:SEU_TOKEN' | base64 | tr -d '\n')"
   ```

   Windows (PowerShell, uma vez):

   ```powershell
   [Environment]::SetEnvironmentVariable("AZURE_DEVOPS_PAT", [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("seu-email@exemplo.com:SEU_TOKEN")), "User")
   ```

3. Abra um terminal novo antes de rodar o `claude`.

O MCP espera o **base64 de `email:token`**, não o token puro. Quando o token vencer, o board passa a
responder `401`: gere outro e troque na mesma variável.

### 2. Login no Figma

1. Tenha acesso ao [arquivo do protótipo](https://www.figma.com/design/43K7rTPJQNIOroQ4j09YTP) com
   seat **Full** ou **Dev** no time do Figma que é dono do arquivo. Peça o convite ao Daniel.
2. No Claude Code, rode `/mcp`, escolha `figma` → **Authenticate** e faça login no navegador.

O Figma limita as chamadas do MCP pelo plano do time dono do arquivo: cerca de 20 por mês no plano
Starter, 200 por dia no Education ou Professional
([detalhes](https://developers.figma.com/docs/figma-mcp-server/rate-limits-access/)). Por isso o dia a dia
usa o Chrome (passo 3) e o MCP fica de reserva.

### 3. Claude in Chrome (leitura das telas do Figma)

As skills analisam o protótipo por prints no navegador, sem a cota do MCP.

1. Instale a extensão [Claude in Chrome](https://chromewebstore.google.com/detail/claude/fcoeoabgfenejglbffodgkkbkcdhcgfn)
   e faça login nela com a mesma conta do Claude Code.
2. No Chrome, entre no Figma com a sua conta e abra o
   [protótipo](https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/Untitled?node-id=230-4748) uma vez.
3. No Claude Code, rode `/chrome` e marque **Enabled by default**.

Cuidados: deixe o Chrome **aberto** antes de rodar `/chrome` → *Reconnect* (sem nenhuma janela, ele abre e fecha
sozinho) e **não deixe o editor do Figma** (`/design/`) aberto numa aba enquanto o Claude usa o navegador — ele
trava a extensão.

### 4. Playwright (testar os apps no navegador)

O MCP `playwright` abre um Chrome próprio, controlado pelo Claude, para navegar no frontend rodando
(`npm run dev`), clicar, preencher formulários e ler o console e as requisições. Não precisa de conta nem
de token: só do **Google Chrome** instalado (se faltar, rode `npx playwright install chrome`).

- O navegador abre com perfil **isolado** (`--isolated`): começa sem login nem cookies a cada sessão e
  não mexe no seu Chrome nem no Claude in Chrome.
- Prints e arquivos gerados vão para `.playwright-mcp/`, que fica fora do git.

O MCP `playwright-figma` é um segundo Chrome do Playwright, só para o Figma (skill `/analisar-figma-playwright`).
Ele guarda um perfil próprio, então o login no Figma é feito **uma vez**: na primeira análise o Claude avisa, você
entra com a sua conta na janela do Chrome que ele abriu (se o Google bloquear o navegador automatizado, use
*Continuar com o e-mail*) e o login fica salvo. É uma alternativa ao Claude in Chrome (passo 3) que não depende da
extensão e traz os textos exatos de cada tela.

### 5. Login no Jibble (ponto e horas)

O Jibble é lido pelo mesmo Chrome do `playwright-figma` (o MCP oficial do Jibble não aceita o login do Claude Code).

1. Tenha uma conta na organização do time no [Jibble](https://web.jibble.io). Peça o convite ao Daniel.
2. Na primeira vez que usar a `/jibble`, o Claude abre o Jibble nesse Chrome: entre com a sua conta na janela (o
   Claude não digita senha). O login fica salvo no perfil.

Use pela skill `/jibble`: `/jibble sincronizar` alinha as horas do Jibble com as Tasks do Azure, e `/jibble horas
semana` mostra o seu timesheet.

### 6. Conferir

Rode `claude` **na raiz do workspace** (não dentro de `apps/`) e aceite o aviso de confiança da
pasta. O `/mcp` deve mostrar `azure-devops`, `figma`, `playwright` e `playwright-figma` conectados. Para
testar, peça *"liste meus work items no Azure"*, *"rode o whoami do Figma"*, *"/jibble horas hoje"* e *"abra o
http://localhost:5173 no Playwright"* (com o frontend rodando).

Leituras no board e no Figma são liberadas. Qualquer escrita (criar ou editar work item, mexer no
arquivo do Figma) pede confirmação. Na `/jibble`, toda escrita no Jibble ou no Azure mostra o que vai gravar e pede confirmação. No Playwright, navegar e interagir com a página é liberado; rodar
JavaScript arbitrário ou enviar arquivo da sua máquina pede confirmação.

### Skills do time

Cada user story passa pelo SDD ([ADR-047](docs/ADR/ADR-047-desenvolvimento-orientado-a-especificacao.md),
[fluxo e índice das specs](specs/README.md)):

```
/especificar CCD014 → PO aprova a spec → /planejar CCD014 → /implementar CCD014 backend|frontend → /revisar-codigo → /criar-pr
```

| Comando | Para quê |
| --- | --- |
| `/especificar CCD014 <link do frame>` | Escreve a spec da user story: requisitos com origem, critérios de aceite, telas e lacunas para o PO decidir |
| `/planejar CCD014` | Com a spec aprovada: plano técnico (dados, contrato da API, arquivos, testes) e lista de tarefas, com opção de criar as Tasks no Azure |
| `/implementar CCD014 backend` | Executa as tarefas no app, uma por vez, com os testes dos critérios de aceite |
| `/conferir-tarefa CCD014 <link do frame>` | Antes de implementar uma tela: confere se o Figma cobre o que a documentação pede e aponta onde está errado |
| `/analisar-figma-chrome <nome da tela ou link>` | Analisa uma tela do Figma por prints no Chrome e lista o que tem nela (sem gastar a cota do MCP) |
| `/analisar-figma-playwright <nome da tela ou link>` | Mesma análise pelo Playwright: print da tela inteira e os textos exatos, sem a extensão do Chrome (sem gastar a cota do MCP) |
| `/analisar-figma-mcp <nome da tela ou link>` | Mesma análise pelo MCP do Figma, para medidas e tokens (gasta a cota) |
| `/revisar-codigo` | Antes do PR: revisa a branch nos padrões do projeto e no que a tarefa pedia |
| `/criar-pr` | Abre o PR no padrão: commits com `AB#`, checagens do repo, push e template preenchido |
| `/jibble sincronizar` | Alinha as horas do Jibble com o Trabalho concluído das suas Tasks no Azure; também `horas semana`, `entrada AB#519`, `saida` e `lancar 1:30 AB#519` |

As skills, os agents e as regras por pasta ficam em `.claude/` e valem para todo mundo que abrir o Claude na raiz
do workspace.
