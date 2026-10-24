# Histórico da infraestrutura

Linha do tempo do que foi executado na infraestrutura, com quem fez e a evidência. O estado atual está em
[topologia.md](topologia.md); as decisões, no [ADR-055](../ADR/ADR-055-topologia-de-ambientes-e-implantacao.md).

| Marca | Significado |
|---|---|
| ✅ | Evidência direta: PR, commit, run do Actions, API do GitHub ou saída de comando |
| 🟡 | Relatado pela infraestrutura, sem saída de comando |
| ⚠️ | A confirmar |

Datas de 2026; horários em BRT (UTC−3). PRs sem repositório indicado são do `cromocard-backend`.

## Linha do tempo

### 26/09 a 02/10 — Planejamento e inventário

| Data | O que | Quem | Evidência |
|---|---|---|---|
| 26/09 | Épico dividido nas tasks T0 a T9; requisitos e checklist de segurança | Lucas e Duarte | Planejamento da infraestrutura |
| 02/10 | Inventário das duas máquinas disponíveis; escolhida a de 6 threads e 15 GiB, com IP fixo; a outra foi descartada | Lucas | 🟡 |
| 02/10 | Contrato de variáveis e rascunho do ADR de topologia | Lucas e Duarte | Hoje no ADR-055 |

### 03/10 a 09/10 — Servidor, Docker e acesso (T1 a T4)

| Data | O que | Quem | Evidência |
|---|---|---|---|
| 03/10 | Serviços pessoais removidos do servidor (Coder, Gitea, Nextcloud, Samba, Playit) | Lucas | 🟡 |
| 06/10 | Inventário do servidor | Lucas | ✅ saída de comandos |
| 06/10 | GHCR liberado na organização | Owner da codaqui | 🟡 |
| 06/10 | Base do sistema (suspensão desativada, `swappiness`), `ufw`, `fail2ban` e `unattended-upgrades` | Lucas | 🟡 |
| 06 a 09/10 | Chaves SSH, SSH só com chave, `deploy` no grupo `docker`, `daemon.json` | Lucas | 🟡; ✅ `sudo -iu deploy docker ps` em 09/10 |
| 08/10 | IA local de outro projeto (Ollama e três llama-server) desligada e removida | Lucas | 🟡 |
| 08/10 | Arquivos Compose de hml e prod | Lucas | ✅ commit `eef7e09` |
| 08 e 09/10 | `/srv/cromocard` criado (dono `deploy`, 750), com `hml`, `ops` e `prod` | Lucas | ✅ `ls -la` |
| 09/10 | Validação com imagens de teste | Lucas | 🟡 |
| 09/10 | Túneis `cromocard-hml` e `cromocard-prod` e rotas publicadas | Lucas | ✅ |
| 09/10 | Primeiros secrets e variáveis dos Environments (`TS_AUTHKEY`, `TAILSCALE_VERSION`, `TUNNEL_TOKEN`) | Lucas | ✅ datas do `gh secret list` e do `gh variable list` |
| 09/10 | Um token de túnel de hml foi exposto fora do GitHub e rotacionado | Lucas | ✅ exposição; 🟡 rotação |

### 10/10 a 13/10 — CI, repositórios e segredos (T5 e T6)

| Data | O que | Quem | Evidência |
|---|---|---|---|
| 10/10 | T5: esqueleto, `Dockerfile` e `ci.yml` | Duarte | ✅ commit `4d8f238` |
| 10 e 11/10 | Backend, frontend e workspace deixam de ser forks e passam a ser os repositórios oficiais da codaqui | Lucas | 🟡 |
| 12/10 | Segurança do backend (aprovação de workflows externos, token só leitura, secret scanning, push protection, Dependabot), Environments `hml` e `prod` e revisores | Lucas | ✅ API |
| 12/10 | `ufw` limpo: saem regras antigas e sobras de serviços removidos | Lucas | 🟡 |
| 12/10 22:54 | PR #1 (T3 e T5) mesclada na `develop` | Lucas | ✅ PR |
| 12/10 23:10 | Secrets e variáveis do contrato gravados | Lucas | ✅ datas do `gh secret list` e do `gh variable list` |
| 12/10 23:27 | PR #3 (T6: gitleaks, Dependabot, `env-check`, `segredos.md`) mesclada | Lucas | ✅ PR, commit `93c3dc0` |
| 13/10 | Conflitos do esqueleto com a infraestrutura resolvidos (Node 24, Prisma 7, PostgreSQL 18) | Lucas | ✅ commit `c087fb6` |
| 13/10 | T7: `deploy.yml` e override sem frontend | Duarte | ✅ commit `8e59ddc` |

### 14/10 — Merges, primeiro release frustrado e backup

| Hora | O que | Quem | Evidência |
|---|---|---|---|
| 10:31 | PR #2 (esqueleto) mesclada na `develop`, depois de `6721aab` corrigir o CI | Lucas | ✅ PR; run 38572449969 |
| 10:32 | PR #4 `develop → main` aberta e fechada sem merge; a `main` continua só com o commit inicial | Lucas | ✅ PR |
| 11:07 | Chave pública do `age` no servidor | Lucas | ✅ |
| 11:30 | Primeira execução do backup falha (não havia postgres de prod); depois do ajuste, pula os ambientes não publicados | Lucas | ✅ |
| 14/10 | Destino do backup no Backblaze B2; chave privada do `age` fora do servidor; OneDrive descartado | Lucas | 🟡 |
| 11:45 | PR #5 (T7) mesclada; o job *Deploy em hml* fica na fila, sem runner | Duarte (autor) e Lucas (merge) | ✅ PR; run 38583419029 |
| 19:58 | Backend e frontend viram submódulos do workspace (PR #3 do workspace) | Daniel | ✅ PR |

### 15/10 — Runner e primeiro deploy

| Hora | O que | Quem | Evidência |
|---|---|---|---|
| 00:38 | Runner `cromocard-srv` instalado pega o job da fila: **primeiro deploy de hml**, sem frontend | Lucas e Duarte | ✅ job *Deploy em hml* do run 38583419029 |
| 01:18 | T9 (observabilidade) na branch `infra/t9-observabilidade` | Duarte | ✅ commit `f768df0` |
| 15/10 | Decisão: o BackOffice deixa de ser o serviço `admin` e vira uma tela do `web` (hoje ADR-038) | Lucas, com a equipe | 🟡 |

### 16/10 — Admin removido, observabilidade e backup

| Hora | O que | Quem | Evidência |
|---|---|---|---|
| 15:43 | `CORS_ORIGIN` só com o site nos dois Environments | Lucas | ✅ data do `gh variable list` |
| 16/10 | Hostnames `admin.` e `hml-admin.` removidos da Cloudflare | Lucas | ✅ `dig` |
| 16:01 | PR #6 remove o serviço `admin` (`07fb240`); deploy em hml às 16:05 | Lucas | ✅ PR; run 38951863314 |
| 16:31 | PR #7: `ts-hml-db` com 128M (estava a 90% de 64M); deploy às 16:33 | Lucas | ✅ PR; run 38955505684 |
| 19:32 | PR #8 (T9: `compose.ops.yml`, `observabilidade.md`, `ONBOARDING.md`); merge `d864d7d`; deploy em hml às 19:34 | Duarte | ✅ PR; run 38976371114 |
| 16/10 | Projeto `cromocard-ops` instalado; conta do Kuma e monitor *Backup diário* (Push) | Duarte e Lucas | 🟡 |
| 16/10 | Regra do Tailscale `tag:server → tag:ops:3001`; no `KUMA_PUSH_URL`, o nome do nó trocado pelo IP Tailscale (o servidor não usa MagicDNS) | Lucas | 🟡 |
| 20:37 | Primeiro dump real de hml | Lucas | ✅ |
| 16/10 | Defeito no script (`ls *.age` com `pipefail`) corrigido com `find`; `curl` do Kuma com `-m 10 --retry 3` | Lucas | ✅ defeito; 🟡 correção |
| 16/10 | `cromocard-backup.timer` criado (03:00) e habilitado | Lucas | ✅ criação; 🟡 habilitado |

### 23/10 — CI, proteção de branch e documentação

| Hora | O que | Quem | Evidência |
|---|---|---|---|
| 23/10 | PR #10: os 8 jobs hospedados passam de `ubuntu-latest` para `ubuntu-24.04` (`fd99a94`). Os checks reprovaram no Trivy por dois CVEs HIGH novos, sem relação com o Ubuntu; `zod` 4.6.7 e `body-parser` 2.4.0 corrigem (`ef6b9a5`) e os checks ficam verdes | Lucas | ✅ PR #10; runs 40054461597 e 40054466977 |
| 23/10 | Alertas automáticos descartados: nem `TEAM_WEBHOOK` no deploy nem notificações no Uptime Kuma (o Discord chegou a ser escolhido e foi descartado no mesmo dia) | Lucas, com a equipe | Decisão 18 do ADR-055 |
| 23:34 | Rulesets do backend: `develop` e `main` com PR, 1 aprovação, os cinco status checks, sem apagar a branch, sem force-push e sem bypass; `main` só *merge commit* | Lucas | ✅ API, rulesets `25766870` e `25766871`; PR #10 passou a exigir revisão |
| 23/10 | ADR-055 e esta pasta `docs/Infraestrutura/` no workspace | Lucas | Este PR |

## O que deixou de valer

| O que valia | Até | O que vale agora | Evidência |
|---|---|---|---|
| Serviços pessoais no servidor | 03/10 | Servidor dedicado ao CromoCard | 🟡 |
| IA local (~10 GiB de memória) | 08/10 | Removida; a memória ficou para o CromoCard | 🟡 |
| Regras antigas do `ufw` | 12/10 | Só SSH pela interface do Tailscale e a porta UDP do Tailscale | 🟡 |
| Repositórios como fork; branch `Develop` | 10 e 11/10 | Repositórios oficiais na codaqui; `develop` | 🟡 |
| Node 22, Prisma 6 e PostgreSQL 16 | 13/10 | Node 24, Prisma 7 e PostgreSQL 18 | ✅ `c087fb6`, PR #2 |
| Deploy de hml por `workflow_run` | 14/10 | `workflow_call` a partir do `ci.yml` na `develop` | ✅ PR #5 |
| Backup no OneDrive | 14/10 | Backblaze B2 pelo `rclone` | 🟡 |
| Serviço `admin`, imagem `cromocard-admin` e hostnames `admin.` e `hml-admin.` | 16/10 | BackOffice como tela do `web`; 6 hostnames | ✅ PR #6 |
| `CORS_ORIGIN` com o site e o admin | 16/10 | Só o site | ✅ `gh variable list` |
| Limite de 64M do `ts-hml-db` | 16/10 | 128M | ✅ PR #7 |
| Nó do servidor no Tailscale chamado `homeserver` | 16/10 | `cromocard-srv`, `tag:server` | ✅ |
| `ubuntu-latest` nos jobs hospedados | 23/10 (PR #10) | `ubuntu-24.04` | ✅ PR #10 |
| Backend sem proteção de branch (PRs #6 a #8 mescladas pelo autor, sem revisão) | 23/10 | Rulesets na `develop` e na `main` | ✅ API |
| Plano de alertas no canal da equipe (`TEAM_WEBHOOK` no deploy e notificação do Kuma) | 23/10 | Sem alertas automáticos; acompanhamento pelo Actions e pelo painel do Kuma | Decisão 18 do ADR-055 |
