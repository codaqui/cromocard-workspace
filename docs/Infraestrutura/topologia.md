# Topologia de ambientes e requisitos do servidor

**Estado atual da infraestrutura em 23/10/2026.** As decisões estão no
[ADR-055](../ADR/ADR-055-topologia-de-ambientes-e-implantacao.md), a operação nos [runbooks](runbooks.md) e o que
já mudou no [histórico](historico.md).

Marcas: ✅ evidência direta (código, API do GitHub, run do Actions ou saída de comando) · 🟡 relatado pela
infraestrutura, sem saída de comando · ⚠️ a confirmar.

Por segurança, este documento não traz IPs, e-mails, nomes de contas do servidor nem nomes de buckets. Eles
ficam no registro interno da infraestrutura.

## Resumo

| Área | Situação |
|---|---|
| Homologação | **No ar** sem o frontend: `postgres`, `api`, `ws`, `cloudflared` e `ts-hml-db`. Último deploy: merge da PR #8 do backend (`d864d7d`), em 16/10 ✅ |
| Produção | **Nunca publicada.** A `main` do backend só tem o commit inicial (`f1eeae3`) ✅ |
| CI | Verde. Fixação em `ubuntu-24.04` e correção de dois CVEs do Trivy na PR #10 do backend, em revisão ✅ |
| Proteção de branch | Rulesets na `develop` e na `main` do backend desde 23/10 ✅ |
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
| `deploy` | Não ✅ | Sim ✅ | Runner, backup e dono de `/srv/cromocard` |

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
| `web` | `ghcr.io/codaqui/cromocard-web:${FRONTEND_TAG}` (inclui o BackOffice, ADR-038) | 8080 | `edge` | Não sobe: modo sem frontend ✅ | — |
| `cloudflared` | `cloudflare/cloudflared:${CLOUDFLARED_VERSION}` | — | `edge` | Rodando ✅ | — |
| `ts-hml-db` (só hml) | `tailscale/tailscale:${TAILSCALE_VERSION}`, `tag:hml-db` | repassa 5432 | `data`, `ts-egress` | Rodando, limite de 128M ✅ | não existe |

- **Modo sem frontend:** sem `FRONTEND_TAG` no `.env`, o deploy grava `FRONTEND_TAG=sem-frontend` e acrescenta
  `compose.sem-frontend.yml`, que tira o `web`. Por isso `hml.cromocard.com.br` responde 502 e `hml-ws`
  responde 404 na raiz; os dois são esperados ✅.
- **Redes:** `edge` tem internet; `data` é `internal: true`. Homologação e produção não se enxergam. Faixa do
  Docker: `10.200.0.0/16` em redes `/24`.
- **Hardening:** todos os serviços com `restart: unless-stopped` e `no-new-privileges` (âncora `x-hardening`).

## Docker no servidor

| Item | Valor |
|---|---|
| Pacotes | `docker-ce` 29.8.2 e Compose v5.6.0 do repositório oficial (inventário de 06/10) |
| `/etc/docker/daemon.json` | Logs `json-file` 10 MB × 3, `live-restore: true`, `default-address-pools` `10.200.0.0/16` em `/24` 🟡 |
| Pastas | `/srv/cromocard/{hml,prod,ops,backups}`, dono `deploy`, 750 ✅ |
| `.env` de hml | Regravado a cada deploy com `umask 077` (600, dono `deploy`) ✅ |
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
| `codaqui/cromocard-frontend` (público) | `develop` (esqueleto, CI e build da imagem desde a PR #1) e `main` (padrão) | Secret scanning, push protection e Dependabot **desligados**; sem rulesets ✅ API (23/10) |
| `codaqui/cromocard-workspace` (público) | `development` (padrão) e `main` | Igual ao frontend ✅ API (23/10). Backend e frontend como submódulos em `apps/` |

### Workflows do backend

| Workflow | O que faz |
|---|---|
| `ci.yml` | Em todo push e PR: lint, `prisma validate` e testes unitários; integração com PostgreSQL 18; gitleaks e Trivy fixados por digest; imagens `api` e `ws` com checagem de não-root e push para o GHCR com o SHA. Em push na `develop`, chama o deploy de hml |
| `deploy.yml` | Único workflow no runner `[self-hosted, cromocard-deploy]`. hml: `workflow_call` do `ci.yml`. prod: push na `main`, com o `HEAD^2` do merge commit, que precisa estar na `develop`, e aprovação. Rollback manual: `workflow_dispatch`. O job `avisar` (aviso por `TEAM_WEBHOOK`) ainda está no arquivo, mas sai com a decisão 18 do ADR-055; sem o secret, só registra um aviso |
| `compose-validate.yml` | `config -q` em hml e prod (com e sem frontend) e no ops; só roda com mudanças em `infra/**` |
| `env-check.yml` | Manual: confere os nomes de um Environment sem imprimir valores |
| `dependabot.yml` | npm, Docker e Actions, semanal, PRs para a `develop` |

- **Runners hospedados:** 8 jobs em `ubuntu-24.04` na PR #10 (antes `ubuntu-latest`).
- **Rollback manual e `env-check` indisponíveis hoje:** o *Run workflow* só aparece quando o arquivo está na
  branch padrão, e a `main` só tem o commit inicial ✅.
- **Deploys:** 4 em hml (15 e 16/10), todos verdes; o rollback automático nunca rodou ✅.
- **Pacotes no GHCR:** `cromocard-api` e `cromocard-ws` (visibilidade ⚠️).

### Environments e runner

| Item | Estado |
|---|---|
| Environment `hml` | Deploy de `develop` e `main`; sem revisores ✅ |
| Environment `prod` | Só a `main`; revisores Daniel e Lucas; *Prevent self-review*; sem bypass de administrador ✅ |
| Secret de repositório | Nenhum ✅ |
| Runner | `cromocard-srv`, registrado **no repositório** do backend, label `cromocard-deploy`, roda como `deploy` ✅ (usuário 🟡). Sem limite de memória |

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
