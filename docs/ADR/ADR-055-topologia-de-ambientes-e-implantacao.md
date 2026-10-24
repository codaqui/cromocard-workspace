# ADR-055 — Topologia de ambientes e implantação no servidor próprio

- **Status:** Proposto (aguardando validação do PO)
- **Data:** 2026-10-23
- **Decisores:** Lucas (infraestrutura) e Duarte (automação); validação: Daniel (PO)

## Contexto

O épico de infraestrutura (tasks T0 a T9) precisava entregar um servidor com dois ambientes isolados
(homologação e produção), CI no GitHub e deploy automatizado, sem acesso manual ao servidor no dia a dia, e
pronto para migrar para a nuvem com o mínimo de retrabalho.

O servidor disponível é uma máquina própria da equipe, ligada por cabo numa rede residencial: AMD FX-6100
(6 threads, sem AVX2, só x86-64-v2), 15 GiB de RAM, um HDD de 931 GB e Ubuntu 24.04 LTS. No inventário de
02/10 ela tinha serviços pessoais expostos e o firewall desligado; tudo isso foi removido antes da implantação.

O backend (`codaqui/cromocard-backend`) e o frontend (`codaqui/cromocard-frontend`) são repositórios
públicos e independentes (ADR-026). A pasta `infra/` e os workflows ficam no backend. As decisões abaixo
foram tomadas entre 03/10 e 23/10 e já estão no código e na configuração do GitHub, com uma exceção: a
fixação em `ubuntu-24.04` (decisão 8) está em revisão na PR #10 do backend. O estado atual está em
[`docs/Infraestrutura/topologia.md`](../Infraestrutura/topologia.md).

## Decisão

### Plataforma e ambientes

1. **Servidor dedicado ao CromoCard**, com hostname e nó do Tailscale `cromocard-srv`. O HDD único é um
   risco aceito; a recomendação é um SSD de 240 GB para sistema, Docker e volumes, com o HDD para backups
   locais (compra depende do PO).
2. **Tudo em container com Docker Compose.** Um `infra/docker-compose.yml` base e os overrides
   `compose.hml.yml` e `compose.prod.yml`, rodando como projetos separados (`cromocard-hml`,
   `cromocard-prod`) em `/srv/cromocard/<env>`, cada um com rede, banco e `.env` próprios. Backend e
   frontend publicam com tags próprias: `BACKEND_TAG` (`api`, `ws`, `migrate`) e `FRONTEND_TAG` (`web`).
   Ferramentas internas ficam no projeto `cromocard-ops`, fora do pipeline. Todo serviço tem
   `restart: unless-stopped`, `no-new-privileges` e limites de CPU e memória, e **nenhum publica porta no
   host**.
3. **Duas redes por ambiente.** `edge` liga `cloudflared`, `web`, `api` e `ws`. `data` é `internal: true`
   (sem internet) e liga `api`, `ws`, `postgres`, `migrate` e, só em homologação, o sidecar `ts-hml-db`.
   Homologação e produção não se enxergam. O Docker usa `default-address-pools` em `10.200.0.0/16`, com
   redes `/24`.
4. **Um PostgreSQL 18 por ambiente** (`postgres:18-alpine`, exigido pelo `uuidv7()` do ADR-014), com o
   volume montado em `/var/lib/postgresql` e sem porta no host. O serviço `migrate` usa a imagem da API e
   roda `prisma migrate deploy` antes de cada subida.
5. **Daemon Docker** com logs `json-file` de 10 MB × 3 arquivos e `live-restore: true`.

### Build, registro e entrega

6. **O servidor não compila.** O GitHub Actions faz o build multi-stage, com usuário não-root, e roda o
   Trivy, que **reprova vulnerabilidades HIGH ou CRITICAL que tenham correção**. As imagens são publicadas
   com a tag do SHA do commit. Imagens base só oficiais Debian ou Alpine (a CPU é x86-64-v2); o backend usa
   `node:24-alpine`.
7. **Registro de imagens: GHCR**, em `ghcr.io/codaqui/cromocard-<serviço>:<sha>`. Os pacotes nascem
   privados; o runner autentica com o `GITHUB_TOKEN` do job (`packages: read`) e faz logout no fim. O plano
   B (artifact + `docker load`) fica como contingência.
8. **Testes nos runners do GitHub, fixados em `ubuntu-24.04`; deploy num runner self-hosted.** Os jobs
   hospedados não usam `ubuntu-latest`, para que uma troca de imagem do GitHub não mude o ambiente do
   Gitleaks, do Trivy e do build sem aviso. Só o `deploy.yml` roda no servidor, num runner com label
   `cromocard-deploy`, executado pelo usuário `deploy`, com conexão só de saída. Hoje o runner está
   registrado **no repositório do backend**; quando o frontend fizer deploy, ele passa para um grupo da
   organização restrito a backend e frontend.
9. **Estratégia de ambientes.** Merge na `develop` publica em homologação automaticamente (o `ci.yml`
   chama o `deploy.yml` por `workflow_call`). Merge na `main` publica em produção depois da aprovação de um
   revisor do Environment `prod`, com *Prevent self-review*. Produção recebe **a mesma imagem testada em
   homologação** (`HEAD^2` do merge commit, que precisa estar na `develop`); por isso o release
   `develop → main` usa *Create a merge commit*. Se o `/health` falhar depois da subida, o deploy volta
   sozinho para a tag anterior.
10. **Proteção de branch por rulesets** na `develop` e na `main` do backend: PR obrigatório, 1 aprovação
    (a aprovação cai se entrar commit novo), os cinco status checks do CI (`Lint, prisma validate e testes
    unitários`, `Testes de integração (PostgreSQL)`, `Scan de segredos (gitleaks)`,
    `Imagem api (build, Trivy, GHCR)` e `Imagem ws (build, Trivy, GHCR)`), sem apagar a branch, sem
    force-push e sem bypass. A `main` aceita só *merge commit*; a `develop`, *merge commit* e *squash*.
11. **Frontend com configuração em runtime**, conforme o ADR-045: a mesma imagem `web` serve os dois
    ambientes.

### Exposição e acesso

12. **Exposição pública só pelo Cloudflare Tunnel.** Um túnel e um `cloudflared` por ambiente, com
    `TUNNEL_TOKEN` próprio. Nenhuma porta aberta no roteador e nenhum registro A para o IP residencial. Um
    nível de subdomínio, coberto pelo certificado gratuito:

    | Serviço | Produção | Homologação | Destino no túnel |
    |---|---|---|---|
    | Aplicação Web (inclui o BackOffice, ADR-038) | `cromocard.com.br` | `hml.cromocard.com.br` | `http://web:8080` |
    | API REST | `api.cromocard.com.br` | `hml-api.cromocard.com.br` | `http://api:3000` |
    | Tempo real (WebSocket) | `ws.cromocard.com.br` | `hml-ws.cromocard.com.br` | `http://ws:3001` |

13. **Acesso interno só pelo Tailscale.** O servidor tem `tag:server` e só o grupo `infra` o alcança. O
    grupo `dev` acessa apenas `tag:ops` (Dozzle e Uptime Kuma) e `tag:hml-db` (PostgreSQL de homologação,
    pelo sidecar). O servidor alcança só `tag:ops:3001`, para o backup avisar o Kuma. O Dozzle mostra só
    logs de homologação; logs de produção ficam restritos à infraestrutura (LGPD).
14. **Hardening do host.** SSH só com chave, sem root e sem senha, para uma lista fechada de usuários. O
    `ufw` nega toda entrada e libera só o SSH pela interface do Tailscale e a porta UDP do Tailscale.
    `fail2ban` e `unattended-upgrades` ativos. Nada do servidor é publicado na internet por fora do túnel.

### Segurança, segredos, dados e monitoramento

15. **Usuário `deploy` no grupo `docker`**, o que equivale a root no host. É um risco aceito, porque o
    runner precisa controlar os containers. Mitigações: o runner só atende o `deploy.yml`, que não tem
    gatilho `pull_request`; workflows de colaboradores externos exigem aprovação; os Environments restringem
    as branches; o `GITHUB_TOKEN` é só leitura por padrão.
16. **Segredos nos Environments `hml` e `prod`**, com valores diferentes; `prod` só aceita a `main` e exige
    revisor, sem bypass de administrador. O `.env` de cada ambiente é gerado pelo pipeline com `umask 077`;
    `DATABASE_URL` é montado pelo Compose; senhas de banco só hexadecimais (entram na URL do Prisma). Secret
    scanning com push protection, `gitleaks` no CI e Dependabot ativos. Como os logs do Actions são
    públicos, nenhum workflow imprime o `.env`. Rotação em `docs/runbooks/segredos.md` do backend.
17. **Backup diário** (03:00) dos bancos com `pg_dump`, por um serviço e um timer do systemd executados como
    `deploy`, criptografado com `age`. O servidor tem só a chave pública. Ficam 7 cópias diárias e 4
    semanais no servidor, e o `rclone copy` envia para um bucket privado do Backblaze B2, com chave restrita a
    esse bucket. A restauração é testada num container descartável, nunca no banco de homologação, que só
    tem dados fictícios (LGPD). O fim de cada backup avisa um monitor *Push* do Uptime Kuma.
18. **Sem alertas automáticos.** Não há aviso de falha num canal da equipe: nem o webhook do deploy
    (`TEAM_WEBHOOK`) nem as notificações do Uptime Kuma. Uma falha de deploy aparece como job vermelho no
    Actions (o rollback automático continua valendo), e a saúde dos ambientes e do backup é acompanhada no
    painel e na página de status do Kuma, pela VPN. O job `avisar` do `deploy.yml`, que dependia do
    `TEAM_WEBHOOK`, sai do workflow.

### Orçamento de memória

| Grupo | Serviços e limite | Total |
|---|---|---|
| Sistema + Docker | Ubuntu, dockerd | ~1,0 GB |
| Produção | postgres 1,5 GB · api 768 MB · ws 384 MB · web 128 MB · cloudflared 64 MB | ~2,8 GB |
| Homologação | postgres 768 MB · api 512 MB · ws 256 MB · web 96 MB · cloudflared 64 MB · ts-hml-db 128 MB | ~1,8 GB |
| Ops | runner ~512 MB (estimativa, sem limite) · ts-ops 128 MB · docker-socket-proxy 32 MB · dozzle 64 MB · uptime-kuma 256 MB | ~1,0 GB |
| Folga | cache de disco (importante com HDD), cache do PostgreSQL e picos de deploy | ~8,4 GB (mínimo 2 GB) |

Os limites são os de `infra/compose.prod.yml`, `compose.hml.yml` e `compose.ops.yml`. O `migrate` roda e
termina antes de a API subir, por isso não entra na soma.

## Alternativas consideradas

- **Usar a segunda máquina da rede (2 núcleos, 7,2 GB):** abaixo do mínimo do planejamento.
- **Encaminhamento de porta no roteador:** expõe o IP residencial e exige TLS e firewall próprios.
- **Build das imagens no servidor:** consome a CPU da máquina e complica o rollback.
- **Artifact + `docker load` como padrão:** o GHCR foi liberado na organização; fica como contingência.
- **Repositório privado:** no plano Team, revisores obrigatórios em Environments de repositório privado
  exigem GitHub Enterprise.
- **`ubuntu-latest` nos jobs hospedados:** acompanha a imagem nova do GitHub sem revisão; em 19/10 passou a
  ser o Ubuntu 26.
- **Proteção de branch clássica no lugar de rulesets:** não permite métodos de merge diferentes por branch.
- **Manter a IA local de outro projeto no servidor com teto de memória:** o orçamento não fechava com folga;
  foi removida em 08/10.
- **Backup no OneDrive:** o token do `rclone` dá acesso à conta inteira e não há ciclo de vida.
- **Alertas num canal do Discord** (webhook no job `avisar` do deploy e notificações do Uptime Kuma):
  planejados até 23/10 e descartados pela equipe nessa data.

## Consequências

**Fica mais fácil**

- Ambientes isolados por rede e por recursos: homologação não derruba produção.
- Nenhuma porta aberta para a internet; o IP residencial fica oculto.
- Rollback simples: subir a tag anterior, já construída e testada.
- Migrar para a nuvem é instalar Docker numa VM, copiar os mesmos arquivos, restaurar o backup e apontar o
  túnel.
- Nenhuma mudança entra na `develop` ou na `main` sem revisão e sem CI verde.

**Fica mais difícil ou é risco aceito**

- HDD único, sem redundância: PostgreSQL mais lento e risco de perda local, mitigado pelo backup externo.
- Servidor único, sem alta disponibilidade. O Uptime Kuma cai junto com o host, e não há monitor externo.
- **Ninguém é avisado de uma falha** (decisão 18): deploy vermelho, rollback automático ou backup atrasado
  só aparecem para quem abrir o Actions ou o Kuma.
- O usuário `deploy` tem poder de root no host (decisão 15).
- Runner self-hosted em repositório público, que a GitHub desaconselha; o risco fica limitado pelas
  decisões 8 e 15.
- Logs do Actions são públicos: qualquer descuido ao imprimir variáveis expõe configuração.
- Um CVE novo numa dependência reprova o CI até a dependência subir, mesmo sem mudança no código.

**O que precisa ser feito ou decidido**

- O ADR-013 e a regra de git preveem a branch `homolog` (e `development` nos apps); os apps usam `develop` e
  `main`, e homologação sai da `develop`. A equipe precisa decidir se mantém isso (e ajusta o ADR-013) ou se
  cria a `homolog`.
- Remover o job `avisar` do `deploy.yml` e as menções ao `TEAM_WEBHOOK` no backend (`infra/README.md` e
  comentário do `ci.yml`) (decisão 18).
- Visibilidade e retenção dos pacotes no GHCR.
- Compra do SSD e nova data de entrega (PO).
- Runner na organização quando o frontend fizer deploy (exige um owner da codaqui).
- `JWT_EXPIRES_IN`: a API ainda não lê a variável (token fixo em 15 min, ADR-005).

## Referências

- ADR-005, ADR-013, ADR-014, ADR-018, ADR-019, ADR-026, ADR-038, ADR-045
- [`docs/Infraestrutura/`](../Infraestrutura/README.md): visão geral, topologia, runbooks e histórico
- `apps/cromocard-backend/infra/` (Compose e `README.md`), `.github/workflows/` (`ci.yml`, `deploy.yml`,
  `compose-validate.yml`, `env-check.yml`), `docs/runbooks/` e `docs/ONBOARDING.md`
