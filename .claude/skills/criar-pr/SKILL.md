---
name: criar-pr
description: Abre um Pull Request no padrão do CromoCard no workspace, no backend ou no frontend — confere a branch e os commits (Conventional Commits em pt-BR com AB#), roda as checagens do repo, grava com o Playwright a evidência de cada critério de aceite (GIF ou print da tela), faz push e cria o PR com o template preenchido, os critérios e as evidências, ligado ao work item do Azure.
argument-hint: "[backend|frontend|workspace] [#work-item]"
disable-model-invocation: true
---

Abre um PR com os argumentos `$ARGUMENTS` (todos opcionais). Invocar esta skill é o pedido para commitar, fazer
push e abrir o PR — mas nunca faça merge, nunca force push e nunca faça push direto numa branch fixa.

## 1. Repositório

| Repo | Caminho | GitHub | Base do PR |
|---|---|---|---|
| backend | `apps/cromocard-backend` | `codaqui/cromocard-backend` | `develop` |
| frontend | `apps/cromocard-frontend` | `codaqui/cromocard-frontend` | `develop` |
| workspace | `.` | `codaqui/cromocard-workspace` | `development` |

Sem o repo nos argumentos, veja onde está o trabalho (`git -C <caminho> status --short` e commits à frente da base).
Se houver em mais de um, pergunte. Cada app é um repositório próprio: rode tudo com `git -C <caminho>`.
PR de release (`develop`/`development` → `main`) só se o usuário pedir explicitamente.

## 2. Branch e tarefa

- Branches fixas: `main`, `homolog`, `develop`, `development`. Se estiver numa delas, não commite nela: proponha
  criar `feature/<id>-<descricao>` a partir da base (ou `fix/`, `docs/`, `chore/`, `infra/`), com a descrição em
  minúsculas, com hífens e sem acentos, e leve as mudanças para lá.
- Work item: argumento `#id`, número da branch ou `AB#` dos commits. Sem nenhum, pergunte — um PR = uma user story.
  Leia o título no Azure (`wit_work_item`, `action: get`, projeto `CromoCard`); se o board não responder, siga com
  o número que o usuário deu.

## 3. Commits

- Siga `.claude/rules/git.md`: formato, tipos, escopos, rodapé `AB#<id>`, um commit por mudança coerente, sem
  `Co-Authored-By`.
- Mostre o `git status`. Pergunte o que entra se houver arquivos que não parecem da tarefa. Adicione arquivo por
  arquivo — nunca `git add -A` ou `git add .` — e nunca `.env`, segredos ou arquivos gerados.
- Se commits já existentes na branch fugirem do padrão, avise; não reescreva o histórico sem o usuário pedir.

## 4. Checagens (antes do push)

| Repo | Rodar |
|---|---|
| backend | `npm run lint && npm run typecheck && npm run test:cov`; com o PostgreSQL local de pé, também `npm run test:integration` |
| frontend | `npm run format:check && npm run lint && npm run typecheck && npm test && npm run build` |
| workspace | Conferência manual: DER mudou nos três formatos (DBML, SQL, PlantUML)? ADR novo como `Proposto` e no índice? `.puml` alterado com o `.svg` exportado? Ponteiro de `apps/*` mudou de propósito? |

Se algo falhar, pare, mostre a saída e não abra o PR. Se a branch ainda não passou pelo `/revisar-codigo`,
pergunte se quer rodar antes.

## 5. Evidências dos critérios de aceite

A descrição de todo PR lista os critérios de aceite que ele cobre. O GIF ou o print da tela fazendo o critério
entra **só quando o PR tem tela para mostrar**: uma página nova ou alterada, um componente que já aparece numa
página, um fluxo que dá para clicar.

**Sem tela, não acione o Playwright.** Isso vale para o backend, o workspace e o frontend que só mexe em hooks,
configuração ou componentes que ainda não aparecem em página nenhuma. Nesses PRs, cada CA vai para a seção
"Critérios de aceite" com o teste que o prova (🧪). Pule os passos 2 a 6 abaixo.

1. **Critérios:** leia os `CA` da seção "Critérios de aceite" do `specs/<pasta>/spec.md` e fique só com os que
   este PR cobre (pelas tarefas do `tarefas.md`). Story técnica sem `spec.md`: use o "Pronto quando" de cada
   tarefa do `tarefas.md`. Sem spec nenhuma, use os critérios do work item no Azure; sem nenhum, pergunte quais
   fluxos mostrar. Separe os CAs que aparecem na tela dos que só os testes provam.
2. **Subir os apps:** o frontend (`npm run dev`, em background) e, se a tela chama a API, também o backend
   (`npm run dev`, com o PostgreSQL local de pé e os dados do seed: `npm run db:seed`, que é idempotente).
   Entre pela tela de login com as contas do seed, uma por papel (README do frontend, "Entrar no app"). Se o CA
   altera dados (cadastro, troca de senha), use uma conta criada só para a gravação, apague-a no fim e rode o
   `npm run db:seed` de novo para devolver as senhas das contas de teste.
3. **Gravar com o MCP `playwright`** (o Chrome isolado, nunca o `playwright-figma`):
   - `browser_resize` em 1440×900, a largura do Figma. Se o CA for de responsividade, use também 390×844.
   - Para cada CA, execute o fluxo do "quando" até aparecer o "então", com um `browser_take_screenshot` a cada passo
     visível: `filename: ".playwright-mcp/pr-evidencias/<branch-sem-barra>/ca<n>-<NN>.png"` (`NN` = 01, 02, …).
     O `filename` é relativo à raiz do workspace, não ao `--output-dir`: sem o prefixo `.playwright-mcp/`, que está no
     `.gitignore`, o print cai solto na raiz.
   - Um CA de estado parado (vazio, erro, permissão negada) fica num print só, `ca<n>.png`. Estado difícil de
     reproduzir na tela (carregando, erro 500) não vira gravação montada: marque como 🧪 e cite o teste que o cobre.
   - Mostre só os dados do seed: os repos são públicos. Nada de dado real, token, `.env` ou DevTools no print.
4. **Montar o GIF** (CA com mais de um print), com cerca de 1,5 s por passo:
   ```bash
   cd .playwright-mcp/pr-evidencias/<branch-sem-barra>
   ffmpeg -y -framerate 2/3 -i ca<n>-%02d.png \
     -vf "scale=1024:-1:flags=lanczos,split[a][b];[a]palettegen[p];[b][p]paletteuse" ca<n>.gif
   ```
   Sem o `ffmpeg`, monte com o Pillow (`python3 -c "import PIL"` diz se ele está instalado) e sugira instalar o
   `ffmpeg` uma vez: `sudo apt install ffmpeg`.
   ```bash
   python3 -c "import sys,glob; from PIL import Image; f=[Image.open(p).convert('RGB') for p in sorted(glob.glob(sys.argv[1]+'-[0-9][0-9].png'))]; f=[i.resize((1024, i.height*1024//i.width)) for i in f]; f[0].save(sys.argv[1]+'.gif', save_all=True, append_images=f[1:], duration=1500, loop=0)" ca<n>
   ```
   Vídeo (`.webm`/`.mp4`) não toca no corpo do PR por link, só GIF e PNG. Se o usuário quiser vídeo, ele arrasta o
   arquivo no PR pelo navegador.
5. **Publicar na branch órfã `pr-assets`** do app: ela guarda só as evidências, nunca entra em outra branch e não
   roda o CI, porque não tem `.github/workflows`. Use um worktree no scratchpad, para não mexer na branch da tarefa:
   ```bash
   APP=apps/cromocard-<app>; DIR=<scratchpad>/pr-assets-<app>
   if git -C $APP ls-remote --exit-code --heads origin pr-assets; then
     git -C $APP fetch origin pr-assets && git -C $APP worktree add -B pr-assets "$DIR" origin/pr-assets
   else
     git -C $APP worktree add --orphan -b pr-assets "$DIR"
   fi
   mkdir -p "$DIR/<branch>" && cp .playwright-mcp/pr-evidencias/<branch-sem-barra>/ca*.{gif,png} "$DIR/<branch>/"
   git -C "$DIR" add "<branch>" && git -C "$DIR" commit -m "chore: adiciona evidências de <branch>" -m "AB#<id>"
   git -C "$DIR" push origin pr-assets && git -C $APP worktree remove "$DIR"
   ```
   Copie só os GIFs e os prints únicos. Os prints que viraram GIF ficam de fora. O link de cada arquivo é
   `https://raw.githubusercontent.com/codaqui/cromocard-<app>/pr-assets/<branch>/ca<n>.gif`.
6. Pare os servidores que você subiu e feche o navegador (`browser_close`).

## 6. Push e PR

1. `git -C <caminho> push -u origin <branch>`.
2. Título: no estilo do commit principal (`feat(collection): marca carta como possuo`).
3. Corpo: preencha o template do repo — [templates/backend.md](templates/backend.md),
   [templates/frontend.md](templates/frontend.md) ou [templates/workspace.md](templates/workspace.md).
   Marque no checklist **só o que foi verificado de verdade**; o resto fica desmarcado com uma nota do porquê.
   No frontend, inclua o link do frame do Figma e o veredito do `/conferir-tarefa`, se houver.
   Se a tarefa tiver spec em `specs/` (ADR-047), preencha a seção **Spec** com o caminho, os requisitos que o
   PR cobre e as tarefas do `tarefas.md` que ele fecha; sem spec, escreva "sem spec salva".
   Na seção **Critérios de aceite**, um bloco por CA com o texto igual ao da spec, o status e a evidência do passo 5:
   ✅ demonstrado na tela, 🧪 coberto só por teste (diga qual) ou ⏳ fica para outro PR (diga qual). Nunca marque ✅
   sem a evidência.
4. Crie o PR:
   - Com o GitHub CLI autenticado (`gh auth status`): grave o corpo num arquivo temporário (`mktemp`) e rode
     `gh pr create --repo <GitHub> --base <base> --head <branch> --title "<título>" --body-file <arquivo>`.
   - Sem o `gh`: entregue o link `https://github.com/<GitHub>/compare/<base>...<branch>?expand=1` e o corpo pronto
     num bloco para colar. Sugira instalar uma vez: `sudo apt install gh` e `gh auth login`.
   - Para atualizar o corpo depois (por exemplo, com evidências novas), use
     `gh api -X PATCH repos/<GitHub>/pulls/<n> -F body=@<arquivo>`: o `gh pr edit` falha nestes repos por causa do
     Projects classic.

## 7. Fechar

Responda com o link do PR, as checagens que rodaram, os CAs com evidência e o que ficou pendente. Lembre: o merge
precisa de 1 aprovação de outra pessoa e do CI verde, e é feito com squash (regras de merge em
`.claude/rules/git.md`). Se o PR for de um app, lembre que depois do merge dá para atualizar o ponteiro do
submódulo no workspace (`git add apps/<app>` num PR do workspace).
