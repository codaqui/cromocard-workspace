# Runbooks da infraestrutura

Um runbook por tarefa recorrente. Os procedimentos que já estão no repositório do backend não são repetidos
aqui: cada seção aponta para o arquivo de lá (`apps/cromocard-backend/...`) e só acrescenta o que falta ou
mudou. Estado atual: [topologia.md](topologia.md).

📝 marca um procedimento que nunca foi executado. ⚠️ marca o que ainda não tem procedimento.

> [!CAUTION]
> Nunca coloque valores de segredo em documentos, issues, PRs ou no chat. O repositório e os logs do Actions
> são públicos.

## Índice

1. [Verificar a saúde](#verificar-a-saúde)
2. [Deploy](#deploy)
3. [Rollback](#rollback)
4. [Quando o deploy falha](#quando-o-deploy-falha)
5. [Segredos e rotação](#segredos-e-rotação)
6. [Adicionar um serviço](#adicionar-um-serviço)
7. [Atualizar imagens e versões](#atualizar-imagens-e-versões)
8. [Banco de homologação](#banco-de-homologação)
9. [Backup e restauração](#backup-e-restauração)
10. [Runner self-hosted](#runner-self-hosted)
11. [Projeto ops (Dozzle e Uptime Kuma)](#projeto-ops-dozzle-e-uptime-kuma)
12. [Acesso ao servidor e armadilhas](#acesso-ao-servidor-e-armadilhas)

## Verificar a saúde

**De fora (qualquer pessoa):**

```bash
curl -fsS https://hml-api.cromocard.com.br/health      # {"status":"ok"}
```

| Resposta | Significado |
|---|---|
| `hml-api /health` = 200 | API de hml no ar, túnel funcionando |
| `hml-ws` = 404 na raiz | Esperado: o `ws` só responde `/health` |
| `hml.cromocard.com.br` = 502 | Esperado no modo sem frontend |

Pela VPN: página de status em `http://cromocard-ops:3001/status/cromocard` e logs de hml em
`http://cromocard-ops:8080`.

**No servidor (só a infraestrutura).** Os administradores não usam Docker direto: entre como `deploy`.

```bash
sudo -iu deploy
cd /srv/cromocard/hml
docker compose -p cromocard-hml -f docker-compose.yml -f compose.hml.yml -f compose.sem-frontend.yml ps
cat .deployed-tag            # SHA no ar
docker stats --no-stream $(docker ps -q --filter "label=com.docker.compose.project=cromocard-hml")
```

Outras conferências:

```bash
sudo ufw status verbose; systemctl is-active fail2ban
tailscale status
systemctl list-timers cromocard-backup.timer
```

No GitHub, *Settings → Actions → Runners* deve mostrar `cromocard-srv` como **Idle** ou **Active**.

## Deploy

Fonte: `.github/workflows/ci.yml`, `deploy.yml`, `infra/README.md` e `docs/ONBOARDING.md` (seção 5) do backend.

| Evento | Ambiente | Tag (`BACKEND_TAG`) | Aprovação |
|---|---|---|---|
| Merge na `develop`, depois do CI verde | `hml` | SHA desse push | Só a do PR |
| Merge `develop → main` com *Create a merge commit* | `prod` | `HEAD^2` do merge commit, que precisa estar na `develop` | PR + revisor do Environment `prod`, nunca quem disparou |
| *Actions → deploy → Run workflow* | escolhido | SHA informado | Em `prod`, sim |

**Homologação:** automático. Acompanhe em *Actions → CI* o job *Deploy em hml*. O aviso "Sem imagem do
frontend no .env: subindo sem o web" é esperado enquanto o frontend não for implantado.

**Produção (release):**

1. Com hml validada pelo QA, abra um PR da `develop` para a `main`, com título `release: <resumo>`.
2. Espere o CI verde e 1 aprovação (exigidos pelo ruleset da `main`).
3. Faça o merge com **Create a merge commit**; o ruleset da `main` não oferece outro método. O deploy usa o
   segundo pai do merge commit.
4. Em *Actions → deploy*, a execução fica em *Waiting*. Um revisor do Environment `prod` clica em **Review
   deployments** e aprova.
5. Confira: `curl -fsS https://api.cromocard.com.br/health`.
6. Depois do **primeiro** deploy de produção, rode o backup à mão e confira o arquivo de prod
   ([Backup](#backup-e-restauração)).

O que o job faz no servidor: copia `infra/` do mesmo commit para `/srv/cromocard/<env>/`, regrava o `.env`
(`umask 077`, preservando o `FRONTEND_TAG`), valida com `config -q`, baixa `api` e `ws` do GHCR, guarda
`.deployed-tag` em `.previous-tag`, sobe o `postgres`, roda o `migrate`, `up -d --remove-orphans`, espera o
`api` *healthy* e a `HEALTH_URL` responder 200 (até 30 × 5 s), grava `.deployed-tag`, apaga imagens sem uso
há mais de 7 dias e faz logout. O Compose só recria os serviços que mudaram.

## Rollback

**Automático:** se a migration, a subida ou o healthcheck falharem, o job volta o `BACKEND_TAG` para o valor
de `.previous-tag` e sobe de novo. O job fica vermelho, e **ninguém é avisado**: não há alertas automáticos,
então quem fez o merge confere o Actions. 📝 Nunca foi provocado: nenhum deploy falhou até 23/10.

Limites: não há para onde voltar no primeiro deploy de um ambiente, e **migrations já aplicadas não voltam**.

**Manual** (`docs/ONBOARDING.md`, seção 6, e `infra/README.md` do backend):

> [!WARNING]
> Indisponível até o primeiro release: o *Run workflow* só aparece quando o `deploy.yml` está na branch
> padrão (`main`), e a `main` só tem o commit inicial.

1. Descubra a tag anterior (SHA completo, 40 caracteres): no job *Definir ambiente e tag* da última execução
   boa, pelo Git (`git log origin/main --merges --first-parent -n 5` e `git rev-parse <merge>^2`) ou no
   servidor (`cat /srv/cromocard/prod/.previous-tag`).
2. *Actions → deploy → Run workflow*: **Use workflow from** `main`, ambiente e tag.
3. Em produção, aprove como num release.
4. Confira o `/health` e avise a equipe.
5. Corrija a `develop` com `git revert` num PR, senão o próximo merge publica o defeito de novo.

## Quando o deploy falha

| Sintoma no job | Causa | O que fazer |
|---|---|---|
| *Deploy em hml* parado em *Queued* | Runner offline (o GitHub desiste depois de 24 h) | [Runner](#runner-self-hosted); depois, *Re-run* do CI |
| `O push em main não é um merge commit` | Release com *Squash* ou *Rebase* | Nada mudou em produção. Refaça com *Create a merge commit* |
| `Tag inválida` | `workflow_dispatch` com SHA curto | Use os 40 caracteres |
| `O commit <tag> não está na develop` | Produção recebendo algo que não passou por hml | Leve o commit para a `develop` primeiro |
| `Variável HEALTH_URL não cadastrada no Environment.` | Falta a variável | Cadastrar no Environment |
| Falha em *Validar Compose* | `.env` sem algum nome obrigatório ou erro de sintaxe | Conferir os nomes ([Segredos](#segredos-e-rotação)) |
| `Healthcheck falhou (api: …)` + `Voltando o backend para a versão anterior` | A versão nova não ficou *healthy* | O rollback já voltou; leia os logs (Dozzle ou `docker logs`) e corrija na `develop` |
| `Não existe versão anterior para voltar (primeiro deploy?)` | Falhou sem `.previous-tag` | Nada foi revertido: corrija e faça novo deploy |
| Falha em *Migrations e subida* | Migration com erro | A imagem volta, a migration não. Corrija com uma migration nova, compatível |
| *Waiting* em `prod` | Aguardando revisor | Um revisor que não disparou o deploy aprova |
| `Secret TEAM_WEBHOOK não cadastrado: aviso não enviado.` | Job `avisar`, que ainda está no `deploy.yml` mas sai com a decisão 18 do ADR-055 | Esperado: não há alertas automáticos. O aviso não indica problema; a falha real está no job *Deploy* |

**CI vermelho no Trivy sem mudança no código:** um CVE novo numa dependência da imagem (HIGH ou CRITICAL com
correção). Atualize a dependência dentro da faixa do `package.json` (`npm update <pacote>`), confira com
`npm ls <pacote>` e commite o `package-lock.json`. Foi o que aconteceu com `zod` e `body-parser` em 23/10.

O `migrate` é removido a cada deploy, então a saída dele fica no log do job em *Actions*.

## Segredos e rotação

Procedimento principal: **`docs/runbooks/segredos.md` do backend** (onde cada segredo fica, conferência dos
nomes e rotação de `POSTGRES_PASSWORD`, `JWT_SECRET`, `TUNNEL_TOKEN` e `TS_AUTHKEY`). Os nomes de todas as
variáveis estão no `infra/validacao.env.example`.

Antes de começar: **no Git Bash, `gh secret set` interativo falha com "Função incorreta".** Use a interface do
GitHub, o PowerShell ou `winpty gh secret set NOME ...`. O valor nunca vai no lugar do nome.

"Refazer o deploy" significa: em hml, *Re-run all jobs* no último run do CI da `develop` ou um novo merge na
`develop`; em prod, o mesmo com o run da `main` ou o *Run workflow* depois do primeiro release.

Se um segredo vazar: **rotacionar primeiro**, avisar a equipe, só depois limpar o rastro.

Complementos ao `segredos.md`:

O `TEAM_WEBHOOK` citado no `segredos.md` e no `infra/README.md` do backend **não é mais usado**: a equipe
descartou os alertas automáticos em 23/10 (decisão 18 do ADR-055). Não cadastre esse secret.

### `TS_AUTHKEY_OPS` (nó `cromocard-ops`)

Só vale no primeiro registro e expira em até 90 dias depois de gerada; só é preciso trocar se o volume
`cromocard-ops_ts-ops-state` for apagado. Gere em *Tailscale → Settings → Keys* (*Pre-approved* ligado;
*Reusable* e *Ephemeral* desligados) e grave com o editor, não com `echo`:

```bash
sudo -iu deploy
cd /srv/cromocard/ops && umask 077 && nano .env
# TS_AUTHKEY_OPS=tskey-auth-XXXX
```

Depois de registrar, desligue o *Key expiry* da máquina `cromocard-ops`. O IP do nó muda: atualize o
`KUMA_PUSH_URL`.

### `KUMA_PUSH_URL`

1. Copie a URL do monitor *Push* no Kuma e troque o nome `cromocard-ops` pelo IP Tailscale do nó
   (`tailscale ip -4 cromocard-ops`): o servidor não usa MagicDNS.
2. Grave no override do serviço:

   ```bash
   sudo systemctl edit cromocard-backup.service
   # [Service]
   # Environment=KUMA_PUSH_URL=http://<IP do cromocard-ops>:3001/api/push/<token>?status=up&msg=OK&ping=
   ```

3. Rode o serviço e veja o monitor ficar verde. `curl "$KUMA_PUSH_URL"` no terminal não funciona: a variável
   só existe para o serviço.

O servidor só alcança o Kuma com a regra `tag:server → tag:ops:3001` na política do Tailscale.

### Chave do Backblaze B2 (`rclone`)

Se vazar: revogue em *Application Keys*, crie outra (só o bucket do backup, *Read and Write*) e refaça o
remoto:

```bash
sudo -iu deploy rclone config             # remoto remote-backup, tipo b2, keyID e applicationKey
sudo -iu deploy rclone lsd remote-backup:  # deve listar só o bucket
```

### Chave do `age`

⚠️ Sem procedimento de rotação. A privada fica no gerenciador de senhas da infraestrutura; o servidor guarda
só a pública em `/srv/cromocard/backups/age-recipient.txt` (uma linha, começando com `age1`). **Perder a
chave privada inutiliza todos os backups**, e os backups antigos continuam presos à chave com que foram
criptografados.

## Adicionar um serviço

É uma mudança de código: PR para a `develop` do backend.

1. Declare o serviço em `infra/docker-compose.yml` com `<<: *hardening`. Âncoras YAML não atravessam
   arquivos: se o serviço existir só num override, copie a âncora para ele.
2. **Nada de `ports:`.** O tráfego público entra pelo `cloudflared`, e o Docker ignora o `ufw` para portas
   publicadas.
3. Redes: `edge` se precisa de internet ou do túnel; `data` se fala com o banco.
4. Limites de CPU e memória em `compose.hml.yml` e `compose.prod.yml`, e o orçamento do ADR-055 revisto.
5. Valide localmente (o `compose-validate` repete no PR):

   ```bash
   cd infra
   for e in hml prod; do
     docker compose -p cromocard-$e --env-file validacao.env.example \
       -f docker-compose.yml -f compose.$e.yml config -q && echo "$e OK"
   done
   ```

6. Variável nova: cadastrar nos dois Environments e acrescentar ao `.env` gerado pelo `deploy.yml`, ao
   `env-check.yml` e ao `validacao.env.example`.
7. Imagem própria do backend: o `deploy.yml` só baixa `api` e `ws`; acrescente o serviço lá.
8. Hostname público: rota nova no túnel do ambiente (*Zero Trust → Networks → Tunnels*), um nível de
   subdomínio só.

## Atualizar imagens e versões

| O quê | Como |
|---|---|
| Dependências npm, imagens do `Dockerfile` e Actions | PRs semanais do Dependabot na `develop`; passam pelo CI |
| `cloudflared` e Tailscale de hml | Variáveis `CLOUDFLARED_VERSION` e `TAILSCALE_VERSION` dos Environments; o próximo deploy usa a versão nova |
| Tailscale do ops | A mesma versão de hml, em `/srv/cromocard/ops/.env` |
| Dozzle, Uptime Kuma e proxy | Trocar a tag no `compose.ops.yml` (PR) e reinstalar o ops |
| Trivy e gitleaks | Fixados por digest no `ci.yml` (`TRIVY_IMAGE`, `GITLEAKS_IMAGE`) |
| Runners do GitHub | `runs-on: ubuntu-24.04` nos jobs hospedados. Trocar de versão é uma PR que muda os 8 jobs juntos; o job `deploy` continua em `[self-hosted, cromocard-deploy]` |
| Node | `node:24-alpine` no `Dockerfile`, `NODE_VERSION` no `ci.yml`, `.nvmrc` e `engines` |
| PostgreSQL (versão maior) | ⚠️ Sem procedimento. O caminho seguro é backup e restauração; nunca voltar ao caminho antigo do volume |

A CPU não tem AVX2: use imagens base x86-64-v2 (Debian ou Alpine oficiais).

## Banco de homologação

Fonte: `docs/ONBOARDING.md` do backend. Pré-requisitos: convite do Tailscale no grupo `dev` e o item do banco
de homologação no Bitwarden.

```bash
psql -h cromocard-hml-db -p 5432 -U cromocard_hml cromocard_hml
```

- Mudança de estrutura só por migration, nunca à mão.
- Só dados fictícios (LGPD). Nunca restaurar dump de produção em hml.
- **Nunca `docker compose down -v` em hml:** apaga o banco e a identidade do `cromocard-hml-db` no Tailscale.
- O banco de produção não tem acesso pela VPN.

## Backup e restauração

**Conferir:**

```bash
systemctl list-timers cromocard-backup.timer          # próxima execução às 03:00 (+ até 15 min)
sudo journalctl -u cromocard-backup.service -n 20
sudo -iu deploy rclone ls remote-backup:<bucket>
sudo -iu deploy rclone size remote-backup:<bucket>    # limite gratuito do B2: 10 GB
```

No Kuma, o monitor *Backup diário* fica verde depois de cada execução (25 h de tolerância).

**Rodar à mão:** `sudo systemctl start cromocard-backup.service` e confira o `journalctl`. Enquanto prod não
for publicado, o log avisa que pulou `cromocard-prod`.

**Desligar:** `sudo systemctl disable --now cromocard-backup.timer`. Enquanto estiver desligado, não há backup.

**Se falhar:** o script termina com erro antes do aviso ao Kuma, e o monitor fica vermelho depois de 25 h.

**Restauração** — 📝 nunca testada. Num container descartável no PC, nunca no banco de hml. Baixe o arquivo
pelo site do B2 (pasta `hml/daily/`):

```powershell
age -d -i cromocard-backup.key -o restore.dump cromocard-hml-AAAA-MM-DD.dump.age
docker run -d --name restore-test -e POSTGRES_PASSWORD=teste postgres:18-alpine
Start-Sleep 10
docker cp restore.dump restore-test:/tmp/restore.dump
docker exec restore-test pg_restore -U postgres -d postgres --create --no-owner --no-acl /tmp/restore.dump
docker exec restore-test psql -U postgres -l
docker rm -f restore-test; Remove-Item restore.dump, cromocard-hml-*.dump.age
```

No Windows PowerShell 5, o `|` entre programas corrompe arquivo binário: por isso o dump é descriptografado
para arquivo e copiado com `docker cp`. Dump de produção tem dados pessoais: apague tudo no fim.

## Runner self-hosted

Runner `cromocard-srv`, registrado no repositório do backend, label `cromocard-deploy`, unit
`actions.runner.codaqui-cromocard-backend.cromocard-srv.service`.

**Conferir:**

```bash
cd /home/deploy/actions-runner
sudo ./svc.sh status
ps -o user= -p $(pgrep -f Runner.Listener)    # deve retornar deploy
```

**Reinstalar**, com alguém que tenha admin no repositório gerando o token em *Settings → Actions → Runners →
New self-hosted runner* (expira em 1 h):

```bash
sudo -iu deploy
mkdir -p ~/actions-runner && cd ~/actions-runner
# baixar o pacote com os comandos exatos da página do GitHub (versão e checksum)
./config.sh --url https://github.com/codaqui/cromocard-backend --token <TOKEN> \
  --name cromocard-srv --labels cromocard-deploy --unattended
exit
cd /home/deploy/actions-runner
sudo ./svc.sh install deploy && sudo ./svc.sh start && sudo ./svc.sh status
```

**Remover:** `sudo ./svc.sh stop && sudo ./svc.sh uninstall` e `./config.sh remove --token <TOKEN>`.

Regras que não mudam: só o `deploy.yml` usa `runs-on: [self-hosted, cromocard-deploy]`, e ele nunca tem
gatilho `pull_request` ou `pull_request_target`.

## Projeto ops (Dozzle e Uptime Kuma)

Procedimento principal: **`docs/runbooks/observabilidade.md` do backend**. Correção que ainda não está lá: na
política do Tailscale, a regra do backup é **`tag:server → tag:ops:3001`** (o runbook do backend ainda cita o
nó `homeserver`, que não existe mais).

- O `curl` do runbook baixa o `compose.ops.yml` da `develop`, não de um commit fixo. Para desfazer uma
  atualização, volte o arquivo anterior e rode `up -d`.
- Para parar: `docker compose -p cromocard-ops down`, **nunca com `-v`** (apaga a identidade do nó e os
  monitores).
- A primeira pessoa que abrir o painel do Kuma depois do primeiro `up -d` vira admin: faça isso logo depois
  da instalação e guarde a conta no Bitwarden.

## Acesso ao servidor e armadilhas

**Entrar:** só a infraestrutura, por SSH com chave, pelo Tailscale (`ssh <usuário>@cromocard-srv` ou pelo IP
Tailscale do nó). Pela LAN não entra.

**Nova pessoa na equipe** (`docs/ONBOARDING.md`): acesso ao repositório pelo Daniel; convite no Tailscale
(grupo `dev`) e item do Bitwarden pelo Lucas. Ninguém da equipe ganha SSH.

**Nova pessoa na infraestrutura:** a pessoa gera a chave no computador dela e envia só o `.pub`; confirme por
voz e instale:

```bash
sudo install -d -m 700 -o <usuário> -g <usuário> /home/<usuário>/.ssh
echo 'ssh-ed25519 AAAA... <usuário>@cromocard' | sudo tee /home/<usuário>/.ssh/authorized_keys > /dev/null
sudo chown <usuário>:<usuário> /home/<usuário>/.ssh/authorized_keys
sudo chmod 600 /home/<usuário>/.ssh/authorized_keys
```

Depois, inclua o usuário no `AllowUsers` de `/etc/ssh/sshd_config.d/01-cromocard-hardening.conf` e aplique
com `sudo sshd -t && sudo systemctl restart ssh`, sem fechar a sessão atual.

**Armadilhas já encontradas:**

- Os administradores não usam Docker direto: `sudo -iu deploy`. Variáveis definidas antes não passam para
  esse shell novo.
- O `deploy` não tem sudo. Dentro dele, rode os comandos sem `sudo -u deploy`.
- `sudo ls /srv/cromocard/*` falha para um administrador: o `*` é expandido antes do `sudo`, e ele não lista a
  pasta 750.
- `docker stats` não aceita `--filter`: passe os IDs com `$(docker ps -q --filter ...)`.
- `systemctl show -p Environment` mostra a variável entre aspas; uma variável de `Environment=` existe só para
  o serviço.
- O servidor não usa MagicDNS: nomes da VPN não resolvem nele, e um nó só aparece no `tailscale status` se a
  política permitir a conversa.
- `ls *.age` com `set -euo pipefail` derruba o script quando a pasta está vazia; use `find`.
- O Compose só recria os serviços que mudaram: num deploy normal, `postgres`, `cloudflared` e `ts-hml-db`
  continuam de pé.
