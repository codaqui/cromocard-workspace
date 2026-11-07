# Infraestrutura do CromoCard

Ponto de entrada da infraestrutura: onde o sistema roda, como o código chega lá e onde está cada
documento. As decisões (o porquê) estão no [ADR-055](../ADR/ADR-055-topologia-de-ambientes-e-implantacao.md),
no [ADR-056](../ADR/ADR-056-runner-de-deploy-por-repositorio.md) (runner por repositório e deploy do frontend) e
no [ADR-057](../ADR/ADR-057-imagens-publicas-no-ghcr.md) (imagens públicas no GHCR).

> [!IMPORTANT]
> Este repositório é **público**. Nenhum documento daqui guarda valores de segredo, IPs, e-mails ou nomes de
> contas do servidor. Segredos ficam nos Environments do GitHub e no cofre da equipe (Bitwarden).

## Situação em 05/11/2026

| Área | Situação |
|---|---|
| Homologação | No ar desde 15/10; **com o frontend desde 05/11** (`https://hml.cromocard.com.br`). Todo merge na `develop` de cada app implanta sozinho. Login com Google ainda desligado (falta o `GOOGLE_CLIENT_ID`) |
| Produção | Nunca publicada: a `main` do backend e a do frontend só têm o commit inicial |
| CI | Verde nos dois apps, em `ubuntu-24.04` |
| Proteção de branch | Rulesets no backend, no frontend e no workspace: PR, 1 aprovação e CI verde |
| Observabilidade | Dozzle e Uptime Kuma pela VPN. **Sem alertas automáticos** (decisão de 23/10): falhas aparecem no Actions e no painel do Kuma |
| Backup | Diário, criptografado, com cópia externa; a restauração ainda não foi testada |

Detalhes em [topologia.md](topologia.md).

## Visão geral

```mermaid
flowchart LR
    dev[Equipe] -- push / PR --> gh[GitHub Actions<br/>runners ubuntu-24.04]
    gh -- imagens api, ws e web<br/>com a tag do SHA --> ghcr[(GHCR, público)]
    gh -- deploy.yml de cada app --> runner[Dois runners self-hosted<br/>no servidor, um por app]
    runner -- pull --> ghcr
    runner -- trava flock --> hml[Projeto cromocard-hml]
    runner -- trava flock --> prod[Projeto cromocard-prod]
    usuario[Usuários] -- HTTPS --> cf[Cloudflare Tunnel]
    cf --> hml
    cf --> prod
    dev -- VPN Tailscale --> ops[cromocard-ops<br/>Dozzle e Uptime Kuma]
    dev -- VPN Tailscale --> hmldb[(PostgreSQL de hml)]
```

- **Nada entra pelo roteador.** O tráfego público chega pelo Cloudflare Tunnel (conexão de saída do
  servidor); a equipe chega pelo Tailscale.
- **O servidor não compila.** O CI faz o build, o scan (Trivy e gitleaks) e publica no GHCR; o servidor só
  baixa a imagem e sobe.
- **Homologação e produção são projetos Compose separados**, cada um com rede, banco e `.env` próprios.
- **Cada app implanta o seu pedaço.** O backend cuida do `.env`, do banco, da `api` e do `ws`; o frontend troca
  só o `FRONTEND_TAG` e sobe o `web`. Uma trava por ambiente impede os dois de mexerem ao mesmo tempo.

## Como o código chega aos ambientes

Vale igual para o backend e para o frontend, cada um no seu repositório:

| Evento no app | Ambiente | Aprovação |
|---|---|---|
| Merge na `develop` (com CI verde) | Homologação | Só a do PR |
| Merge `develop → main` com *Create a merge commit* | Produção, com a mesma imagem de homologação | PR + revisor do Environment `prod` |
| *Actions → deploy → Run workflow* | O escolhido (rollback manual) | Em produção, sim |

O passo a passo está nos [runbooks](runbooks.md#deploy).

## Documentos

| Documento | Para quê |
|---|---|
| [ADR-055](../ADR/ADR-055-topologia-de-ambientes-e-implantacao.md) | Decisões de topologia e implantação, e o porquê |
| [ADR-056](../ADR/ADR-056-runner-de-deploy-por-repositorio.md) | Um runner por repositório e o deploy do frontend |
| [ADR-057](../ADR/ADR-057-imagens-publicas-no-ghcr.md) | Imagens públicas no GHCR, sem segredo dentro da imagem |
| [topologia.md](topologia.md) | Estado atual: servidor, ambientes, rede, GitHub, observabilidade e backup |
| [runbooks.md](runbooks.md) | Como operar: saúde, deploy, rollback, falhas, segredos, backup, runner |
| [historico.md](historico.md) | O que foi feito, quando e por quem, com a evidência |

No repositório do backend (`apps/cromocard-backend`), onde fica o código da infraestrutura:

| Arquivo | Para quê |
|---|---|
| `infra/` e `infra/README.md` | Arquivos Compose de cada ambiente e do projeto ops |
| `.github/workflows/` | `ci.yml`, `deploy.yml`, `compose-validate.yml`, `env-check.yml` |
| `docs/ONBOARDING.md` | Primeiro acesso de quem entra na equipe (VPN, banco de hml, deploy) |
| `docs/runbooks/segredos.md` | Onde cada segredo fica e como trocar |
| `docs/runbooks/observabilidade.md` | Instalação do projeto ops e monitores do Uptime Kuma |

No repositório do frontend (`apps/cromocard-frontend`):

| Arquivo | Para quê |
|---|---|
| `docker/` | `Dockerfile` (nginx sem root), `nginx.conf` e `write-env.sh`, que gera o `env.js` na subida (ADR-045) |
| `.github/workflows/` | `ci.yml` (qualidade, gitleaks, imagem `web`) e `deploy.yml` (sobe só o `web`) |

## Quem faz o quê

| Área | Responsável |
|---|---|
| Servidor, rede, VPN, backup e segurança dos repositórios | Lucas |
| Pipeline (CI e deploy), Compose e observabilidade | Duarte |
| Repositórios, branches e aprovação de produção | Daniel (PO), com o Lucas |

Para pedir acesso à VPN ou ao banco de homologação, siga o `docs/ONBOARDING.md` do backend. SSH no servidor
é só para a infraestrutura.

## Regras que valem para todo mundo

- Toda mudança na `develop` e na `main` dos dois apps entra por PR, com 1 aprovação e CI verde.
- Release para produção só com *Create a merge commit*: o deploy usa o segundo pai do merge.
- Nenhum serviço publica porta (`ports:`) no Compose.
- Banco de homologação só com dados fictícios (LGPD). Nunca restaurar dump de produção em hml.
- Nunca `docker compose down -v` em homologação nem no projeto ops: apaga o banco, a identidade na VPN e os
  monitores.
- Segredo vazado: rotacionar primeiro, avisar a equipe, só depois limpar o rastro.
- Não há alertas automáticos: depois de um merge na `develop`, quem fez o merge confere o job *Deploy em hml*
  (backend) ou *Deploy do web em hml* (frontend) no Actions.
- Variável ou segredo novo vai no Environment do GitHub, nunca direto no `.env` do servidor: o deploy regrava o
  arquivo.
- Nenhum segredo dentro de imagem: os pacotes do GHCR são públicos (ADR-057).
