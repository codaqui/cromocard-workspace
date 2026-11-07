# Topologia de ambientes e requisitos do servidor

**Estado atual da infraestrutura em 05/11/2026.** As decisões estão no
[ADR-055](../ADR/ADR-055-topologia-de-ambientes-e-implantacao.md), no
[ADR-056](../ADR/ADR-056-runner-de-deploy-por-repositorio.md) (runner por repositório e deploy do frontend) e no
[ADR-057](../ADR/ADR-057-imagens-publicas-no-ghcr.md) (imagens públicas). A operação está nos
[runbooks](runbooks.md) e o que já mudou, no [histórico](historico.md).

Marcas: ✅ evidência direta (código, API do GitHub, run do Actions ou saída de comando) · 🟡 relatado pela
infraestrutura, sem saída de comando · ⚠️ a confirmar.

Por segurança, este documento não traz IPs, e-mails, nomes de contas do servidor nem nomes de buckets. Eles
ficam no registro interno da infraestrutura.

## Resumo

| Área | Situação |
|---|---|
| Homologação | **No ar completa desde 05/11**: `postgres`, `api`, `ws`, `web`, `cloudflared` e `ts-hml-db`. Últimos deploys: backend `de50bd3` (PR #18) e frontend `2aefd84` (PR #8 do frontend), em 05/11 ✅ |
| Produção | **Nunca publicada.** A `main` do backend (`f1eeae3`) e a do frontend (`e63021c`) só têm o commit inicial ✅ |
| CI | Verde nos dois apps; todos os jobs hospedados em `ubuntu-24.04` ✅ |
| Deploy | Dois runners no servidor, um por repositório (ADR-056), com trava `flock` comum por ambiente ✅ |
| Proteção de branch | Rulesets no backend, no frontend e no workspace ✅ |
| Login com Google em hml | Desligado: `GOOGLE_CLIENT_ID` vazio, sem a variável no Environment `hml` do backend ✅ |
| Observabilidade | Projeto `cromocard-ops` (Dozzle e Uptime Kuma) rodando 🟡; **sem alertas automáticos** (decisão de 23/10) |
| Backup | Diário às 03:00 🟡; primeiro dump de hml em 16/10 ✅; restauração nunca testada |
| Acesso | SSH só com chave e só pela VPN; a equipe usa só o Tailscale e o GitHub |

## Requisitos do planejamento × servidor

| Requisito | Servidor | Situação |
|---|---|---|
| 4 núcleos | AMD FX-6100, 3 módulos × 2 threads = 6 | Atende |
| 8 GB de RAM | 15 GiB + swap de 4 GiB | Atende |
| SSD de 120 GB ou mais | 1 HDD de 931,5 GB, rotacional | **Não atende**; risco aceito até a decisão sobre o SSD |
| Ubuntu Server 24.04 LTS | Ubuntu 24.04.5 LTS | Atende |
| Cabo de rede e IP fixo local | Sim | Atende |
| Nobreak | Não confirmado | ⚠️ |

## Servidor

| Item | Valor |
|---|---|
| Hostname e nó no Tailscale | `cromocard-srv`, `tag:server` ✅ |
| CPU | AMD FX-6100, 6 threads; tem AVX, **não tem AVX2**: usar imagens base x86-64-v2 (Debian ou Alpine oficiais) |
| Memória | 15 GiB; swap 4 GiB; `vm.swappiness=10` |
| Disco | 1 HDD de 931,5 GB, partição única `/`; escalonador `mq-deadline` |
| Sistema | Ubuntu 24.04.5 LTS, fuso `America/Sao_Paulo`, suspensão desativada |

### Contas

| Conta | sudo | Grupo `docker` | Uso |
|---|---|---|---|
| Administradores (Lucas e Duarte) | Sim | Não, de propósito: Docker só pelo `deploy` ✅ | Administração por SSH com chave |
| `deploy` | Não ✅ | Sim ✅ | Os dois runners, backup e dono de `/srv/cromocard` |

### Acesso, firewall e manutenção

| Item | Valor |
|---|---|
| SSH | Só chave; `PermitRootLogin no`, `PasswordAuthentication no` e lista fechada de usuários ✅ |
| `ufw` | Entrada negada; só SSH pela interface do Tailscale e a porta UDP do Tailscale 🟡 |
| `fail2ban` | Ativo, jail `sshd` 🟡 |
| `unattended-upgrades` | Ativo. Reboot automático ⚠️ |
| SMART | `PASSED` em 06/10; o `smartd` só alerta localmente |
| Portas em escuta | SSH, Tailscale e DNS local. **Nenhuma porta publicada pelo Docker**: nenhum serviço dos Compose tem `ports:` ✅ |
| Roteador | ⚠️ Confirmar que não há encaminhamento de porta nem UPnP para o servidor |

## Ambientes

Arquivos em `infra/` do backend. Cada ambiente é um projeto Compose separado em `/srv/cromocard/<env>`, com
rede, banco e `.env` próprios. Limites de memória: [ADR-055, orçamento](../ADR/ADR-055-topologia-de-ambientes-e-implantacao.md#orçamento-de-memória).

| Serviço | Imagem | Porta interna | Redes | Homologação | Produção |
|---|---|---|---|---|---|
| `postgres` | `postgres:18-alpine`, volume `pgdata` em `/var/lib/postgresql` | 5432 | `data` | Rodando ✅ | — |
| `migrate` | imagem da API, `prisma migrate deploy` | — | `data` | Roda a cada deploy e termina | — |
| `api` | `ghcr.io/codaqui/cromocard-api:${BACKEND_TAG}` | 3000 (`/health`) | `edge`, `data` | Rodando, *healthy* ✅ | — |
| `ws` | `ghcr.io/codaqui/cromocard-ws:${BACKEND_TAG}` | 3001 (`/health`) | `edge`, `data` | Rodando ✅ | — |
| `web` | `ghcr.io/codaqui/cromocard-web:${FRONTEND_TAG}` (nginx sem root; inclui o BackOffice, ADR-038) | 8080 | `edge` | Rodando desde 05/11 ✅ | — |
| `cloudflared` | `cloudflare/cloudflared:${CLOUDFLARED_VERSION}` | — | `edge` | Rodando ✅ | — |
| `ts-hml-db` (só hml) | `tailscale/tailscale:${TAILSCALE_VERSION}`, `tag:hml-db` | repassa 5432 | `data`, `ts-egress` | Rodando, limite de 128M ✅ | não existe |

- **`FRONTEND_TAG`:** quem grava é o deploy do frontend (ADR-056). O deploy do backend só preserva o valor.
  Sem `FRONTEND_TAG` no `.env`, o deploy do backend grava `FRONTEND_TAG=sem-frontend` e acrescenta
  `compose.sem-frontend.yml`, que tira o `web` (modo sem frontend, que valeu em hml até 05/11 e vale em prod
  até o primeiro release do frontend) ✅.
- **`env.js`:** o `web` gera o arquivo na subida com `API_URL` e `GOOGLE_CLIENT_ID` do `.env` (ADR-045). Hoje
  em hml: `API_URL` = `https://hml-api.cromocard.com.br` e `GOOGLE_CLIENT_ID` vazio, então o botão do Google não
  aparece ✅.
- **`hml-ws`** responde 404 na raiz, o que é esperado: o `ws` só responde `/health`.
- **Redes:** `edge` tem internet; `data` é `internal: true`. Homologação e produção não se enxergam. Faixa do
  Docker: `10.200.0.0/16` em redes `/24`.
- **Hardening:** todos os serviços com `restart: unless-stopped` e `no-new-privileges` (âncora `x-hardening`).

## Docker no servidor

| Item | Valor |
|---|---|
| Pacotes | `docker-ce` 29.8.2 e Compose v5.6.0 do repositório oficial (inventário de 06/10) |
| `/etc/docker/daemon.json` | Logs `json-file` 10 MB × 3, `live-restore: true`, `default-address-pools` `10.200.0.0/16` em `/24` 🟡 |
| Pastas | `/srv/cromocard/{hml,prod,ops,backups}`, dono `deploy`, 750 ✅ |
| `.env` de hml | Regravado a cada deploy do backend com `umask 077` (600, dono `deploy`); o do frontend só troca a linha `FRONTEND_TAG` ✅. **Não edite à mão:** o próximo deploy apaga a mudança |
| Trava de deploy | `/srv/cromocard/<env>/.deploy.lock` (`flock`, espera até 900 s), usada pelos dois deploys ao mexer no `.env` e nos containers ✅ |
| Tags no ar | `.deployed-tag` e `.previous-tag` (backend); `.deployed-web-tag` e `.previous-web-tag` (frontend) ✅ |
| `.env` de prod | Nasce no primeiro deploy de produção |
| `.env` do ops | `/srv/cromocard/ops/.env` (600, dono `deploy`), com `TS_AUTHKEY_OPS` e `TAILSCALE_VERSION` 🟡 |
| Volumes que **nunca** podem ser apagados | `pgdata` de hml, `cromocard-hml_ts-hml-db-state`, `cromocard-ops_ts-ops-state`, `cromocard-ops_kuma-data` |
| Limpeza | O deploy apaga imagens sem uso há mais de 7 dias |

## Rede e acesso

### Cloudflare

Domínio `cromocard.com.br` (Registro.br), zona na Cloudflare com *Always Use HTTPS*, TLS mínimo 1.2 e
WebSockets ligados 🟡. Dois túneis, um `cloudflared` por ambiente, cada um com `TUNNEL_TOKEN` próprio ✅.

| Túnel | Hostname | Serviço |
|---|---|---|
| `cromocard-prod` | `cromocard.com.br` | `http://web:8080` |
| `cromocard-prod` | `api.cromocard.com.br` | `http://api:3000` |
| `cromocard-prod` | `ws.cromocard.com.br` | `http://ws:3001` |
| `cromocard-hml` | `hml.cromocard.com.br` | `http://web:8080` |
| `cromocard-hml` | `hml-api.cromocard.com.br` | `http://api:3000` |
| `cromocard-hml` | `hml-ws.cromocard.com.br` | `http://ws:3001` |

Nenhum registro A aponta para o IP residencial. `admin.` e `hml-admin.` foram removidos em 16/10 ✅.

### Tailscale

| Nó | Função |
|---|---|
| `cromocard-srv` | Servidor, `tag:server`. **Não usa MagicDNS:** nomes da VPN não resolvem nele ✅ |
| `cromocard-hml-db` | Sidecar `ts-hml-db`, `tag:hml-db`; repassa a 5432 para o `postgres` de hml |
| `cromocard-ops` | Container `ts-ops`, `tag:ops`; Dozzle na 8080 e Uptime Kuma na 3001 🟡 |

| Grupo | Quem | Alcança |
|---|---|---|
| `infra` | Lucas e Duarte | O servidor |
| `dev` | Back, front, QA e PO | `tag:hml-db:5432` e `tag:ops:8080,3001` |
| `tag:server` | O próprio servidor | Só `tag:ops:3001` (aviso do backup ao Kuma) 🟡 |

## GitHub, CI e deploy

### Repositórios

| Repositório | Branches | Proteções |
|---|---|---|
| `codaqui/cromocard-backend` (público) | `develop` → hml; `main` (padrão) → prod | Secret scanning, push protection e Dependabot ligados; `GITHUB_TOKEN` só leitura; aprovação de workflows de `all_external_contributors`. **Rulesets** na `develop` e na `main`: PR, 1 aprovação, os cinco status checks, sem apagar a branch, sem force-push, sem bypass; `main` só *merge commit*, `develop` *merge commit* ou *squash* ✅ API |
| `codaqui/cromocard-frontend` (público) | `develop` → hml; `main` (padrão) → prod | Secret scanning, push protection e Dependabot ligados; `GITHUB_TOKEN` só leitura; aprovação de workflows de `all_external_contributors`. **Rulesets** na `develop` e na `main`: PR, 1 aprovação, sem apagar a branch, sem force-push; `main` só *merge commit*. Status check exigido: só "Formatação, lint, tipos, testes e build" (fase 1 do ADR-056; a fase 2 acrescenta o gitleaks e a imagem `web`) ✅ API (05/11) |
| `codaqui/cromocard-workspace` (público) | `development` (padrão) e `main` | Secret scanning e push protection ligados; rulesets na `development` (PR e 1 aprovação) e na `main` (também só *merge commit*) ✅ API (05/11). Backend e frontend como submódulos em `apps/` |

### Workflows do backend

| Workflow | O que faz |
|---|---|
| `ci.yml` | Em todo push e PR: lint, `prisma validate` e testes unitários; integração com PostgreSQL 18; gitleaks e Trivy fixados por digest; imagens `api` e `ws` com checagem de não-root e push para o GHCR com o SHA. Em push na `develop`, chama o deploy de hml |
| `deploy.yml` | Único workflow no runner `[self-hosted, cromocard-deploy]`. hml: `workflow_call` do `ci.yml`. prod: push na `main`, com o `HEAD^2` do merge commit, que precisa estar na `develop`, e aprovação. Rollback manual: `workflow_dispatch`. O job `avisar` (aviso por `TEAM_WEBHOOK`) ainda está no arquivo, mas sai com a decisão 18 do ADR-055; sem o secret, só registra um aviso |
| `compose-validate.yml` | `config -q` em hml e prod (com e sem frontend) e no ops; só roda com mudanças em `infra/**` |
| `env-check.yml` | Manual: confere os nomes de um Environment sem imprimir valores |
| `dependabot.yml` | npm, Docker e Actions, semanal, PRs para a `develop` |

- **Runners hospedados:** 8 jobs em `ubuntu-24.04` na PR #10 (antes `ubuntu-latest`).
- **Trava:** desde a PR #18, o `deploy.yml` pega a trava `flock` do ambiente ao gravar o `.env`, ao subir e no
  rollback, e na subida refaz a lista de arquivos do Compose com o `FRONTEND_TAG` atual ✅.
- **Rollback manual e `env-check` indisponíveis hoje:** o *Run workflow* só aparece quando o arquivo está na
  branch padrão, e a `main` só tem o commit inicial ✅.
- **Deploys:** 10 em hml até 05/11, 9 verdes. O de 29/10 (`b37e59b`) falhou ao baixar as imagens, por timeout de
  rede até o `ghcr.io`, antes de mexer em qualquer container; o seguinte passou. O rollback automático nunca
  rodou ✅.

### Workflows do frontend

| Workflow | O que faz |
|---|---|
| `ci.yml` | Em todo push e PR: formatação, lint, tipos, testes e build; gitleaks; imagem `web` com checagem de não-root, Trivy e push para o GHCR com o SHA. Em push na `develop`, chama o deploy de hml |
| `deploy.yml` | Roda no runner `[self-hosted, cromocard-deploy]` do frontend. Mesmos gatilhos do backend (hml por `workflow_call`, prod pelo `HEAD^2` do merge na `main`, rollback por `workflow_dispatch`). Confere se o backend já criou o ambiente, baixa a imagem, troca só a linha `FRONTEND_TAG` do `.env` com a trava e sobe só o `web` (`--no-deps`); healthcheck no site e no `/env.js` (`WEB_URL`); rollback por `.previous-web-tag` |

- **Imagem:** `nginxinc/nginx-unprivileged:1.30-alpine` com `apk upgrade` no build (CVEs do Trivy) ✅.
- **Deploys:** 1 em hml (05/11), verde ✅.

### Pacotes no GHCR

`cromocard-api`, `cromocard-ws` e `cromocard-web`, todos **públicos** (ADR-057): baixam sem login, e o deploy
mantém o login por precaução. Um pacote público não volta a ser privado. A retenção continua pendente ✅.

### Environments e runner

| Item | Estado |
|---|---|
| Environment `hml` (backend) | Deploy de `develop` e `main`; sem revisores. Sem `GOOGLE_CLIENT_ID` nem as variáveis `MAIL_*` ✅ |
| Environment `prod` (backend) | Só a `main`; revisores Daniel e Lucas; *Prevent self-review*; sem bypass de administrador ✅ |
| Environments `hml` e `prod` (frontend) | Criados em 31/10 com as mesmas regras do backend: `prod` só da `main`, revisores Daniel e Lucas, *Prevent self-review* e sem bypass. Só a variável `WEB_URL` ✅ |
| Secret de repositório | Nenhum, nos dois apps ✅ |
| Runner do backend | `cromocard-srv`, registrado no repositório do backend, label `cromocard-deploy`, roda como `deploy` ✅. Sem limite de memória |
| Runner do frontend | `cromocard-srv-frontend`, registrado no repositório do frontend, mesma label, online ✅; usuário `deploy` e pasta `/home/deploy/actions-runner-frontend` 🟡 (ADR-056) |

## Observabilidade

| Item | Estado |
|---|---|
| Projeto | `cromocard-ops` em `/srv/cromocard/ops`, fora do pipeline; arquivo `infra/compose.ops.yml` 🟡 |
| Serviços | `ts-ops`, `docker-socket-proxy` (só leitura, rede interna), `dozzle` (só `cromocard-hml`), `uptime-kuma` |
| Dozzle | `http://cromocard-ops:8080` pela VPN; só homologação. Logs de produção: só `docker logs` no servidor (LGPD) |
| Uptime Kuma | `http://cromocard-ops:3001` pela VPN; página de status `/status/cromocard`; conta no Bitwarden |
| Monitores | Previstos seis (API, WS e Web de prod; API e WS de hml; Backup diário). Criado: *Backup diário* (Push) 🟡 |
| Alertas | **Nenhum**, por decisão da equipe em 23/10: o Kuma não manda notificação e o deploy não avisa canal. Acompanhe o Actions e o painel do Kuma |
| Monitor externo | Não existe: se o servidor cair, o Kuma cai junto |

## Backup

| Item | Estado |
|---|---|
| Script | `/usr/local/bin/cromocard-backup` (**ainda não versionado**) |
| O que faz | Para cada ambiente publicado: `pg_dump -Fc`, criptografia com `age`, 7 cópias diárias e 4 semanais em `/srv/cromocard/backups/<env>/`, `rclone copy` para o Backblaze B2 e aviso ao Kuma ✅ |
| Agendamento | `cromocard-backup.timer`: 03:00, `RandomizedDelaySec=15min`, `Persistent=true` ✅ |
| Chaves | Pública no servidor; privada fora dele, no gerenciador de senhas da infraestrutura 🟡 |
| Destino externo | Bucket privado no B2, chave restrita ao bucket 🟡; retenção externa ⚠️ |
| Último backup | hml em 16/10 ✅; prod pulado (não publicado) |
| Fora do backup | Volume `cromocard-ops_kuma-data` |
| Restauração | **Nunca testada** |
