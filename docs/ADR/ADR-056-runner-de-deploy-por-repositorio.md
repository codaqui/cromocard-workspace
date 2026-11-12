# ADR-056 — Um runner de deploy por repositório e deploy próprio do frontend

- **Status:** Proposto (aguardando validação do PO)
- **Data:** 2026-10-31
- **Decisores:** Lucas Oliveira Lima (proposta); validação: Felipe Consulim (PO)
- **Substitui parcialmente:** ADR-055, decisão 8 (só a frase sobre levar o runner para um grupo da organização
  quando o frontend fizer deploy)

## Contexto

Desde o primeiro deploy (15/10), homologação roda no modo sem frontend: o deploy do backend só sobe o serviço `web`
quando o `.env` do ambiente tem um `FRONTEND_TAG`, e ninguém nunca o gravou. Por isso `hml.cromocard.com.br`
responde 502, embora `hml-api` e `hml-ws` estejam no ar e o frontend já tenha telas na `develop` (login, cadastro e
recuperação de senha).

Faltam duas peças no repositório do frontend: o `ci.yml` só faz `docker build` da imagem `cromocard-web`, sem Trivy
e sem publicar no GHCR, e não existe workflow de deploy. O ADR-055 (decisão 8) previu que, quando o frontend
fizesse deploy, o runner `cromocard-srv` sairia do repositório do backend e iria para um grupo de runners da
organização. Registrar runner na organização exige um owner da `codaqui`, e a equipe não tem um owner disponível:
os integrantes são membros da organização e administradores dos repositórios. O administrador de um repositório
pode registrar runner nele, e uma mesma máquina pode rodar vários runners, cada um registrado num repositório.

O repositório do frontend também não tem as proteções que o ADR-055 exige do backend antes de um runner
self-hosted atender um repositório público (decisões 10, 15 e 16): hoje está sem rulesets, sem secret scanning e
sem Environments.

## Decisão

1. **Rode um runner self-hosted por repositório no `cromocard-srv`.** O runner atual continua registrado no
   `codaqui/cromocard-backend`. Um segundo runner, instalado numa pasta própria e como serviço próprio do systemd,
   é registrado no `codaqui/cromocard-frontend`. Os dois usam o label `cromocard-deploy`, rodam como o usuário
   `deploy` e só abrem conexões de saída. Cada repositório enxerga só o próprio runner.
2. **Proteja o repositório do frontend como o do backend antes de registrar o runner:**
   - rulesets na `develop` e na `main` com PR, 1 aprovação, os status checks do CI do frontend, sem apagar a
     branch, sem force-push e sem bypass; a `main` só com *merge commit*;
   - `GITHUB_TOKEN` só leitura por padrão e aprovação para workflows de contribuidores externos;
   - secret scanning com push protection e Dependabot ligados;
   - Environments `hml` (`develop` e `main`) e `prod` (só a `main`, com revisores, *Prevent self-review* e sem
     bypass de administrador).
3. **Publique a imagem `ghcr.io/codaqui/cromocard-web:<sha>` no CI do frontend** com o mesmo job do backend:
   build, checagem de usuário não-root, Trivy reprovando HIGH ou CRITICAL com correção e push ao GHCR, em runners
   `ubuntu-24.04`. Nenhuma imagem é publicada sem a qualidade (formatação, lint, tipos, testes e build) e o scan de
   segredos.
4. **Faça o deploy do frontend só trocar o `web`.** O `deploy.yml` do frontend troca a linha `FRONTEND_TAG` do
   `.env` do ambiente e sobe só o serviço `web` (`--no-deps`), com os arquivos Compose que o deploy do backend já
   copiou para `/srv/cromocard/<env>`. Depois confere se o site responde 200 (variável `WEB_URL` do Environment)
   e volta sozinho para a tag anterior se falhar. O `.env` continua sendo gerado pelo deploy do backend, que
   preserva o `FRONTEND_TAG`. Sem `.env` no ambiente (backend nunca implantado), o deploy do frontend falha.
5. **Use os mesmos gatilhos do ADR-055 (decisão 9):** merge na `develop` publica em homologação; merge na
   `main` publica em produção com o `HEAD^2` do merge commit, que precisa estar na `develop`, e aprovação do
   Environment `prod`; `workflow_dispatch` para rollback manual. O `deploy.yml` não tem gatilho `pull_request`.
6. **Não deixe os dois deploys mexerem no mesmo ambiente ao mesmo tempo.** Os passos que gravam o `.env` ou
   rodam `docker compose up`, nos dois repositórios, pegam uma trava `flock` em
   `/srv/cromocard/<env>/.deploy.lock`. O `concurrency` do GitHub não vale entre repositórios diferentes.

O resto do ADR-055 continua valendo.

## Alternativas consideradas

- **Runner num grupo da organização (ADR-055, decisão 8):** um runner só para os dois repositórios, mas exige um
  owner da `codaqui`. Continua possível depois: basta desregistrar os dois runners e registrar um no grupo, sem
  mudar os workflows.
- **O frontend aciona o deploy do backend** (`workflow_dispatch` ou `repository_dispatch` com a tag do frontend):
  não precisa de owner, mas exige um token pessoal ou um GitHub App com escrita no backend, guardado como secret
  no frontend. O token fica preso à conta de uma pessoa e os dois repositórios ficam acoplados.
- **Gravar o `FRONTEND_TAG` à mão no servidor:** resolve na hora, mas fica fora do pipeline, sem rollback e sem
  registro de quem publicou o quê.
- **Juntar backend e frontend num repositório só:** contraria o ADR-026.

## Consequências

**Fica mais fácil**

- Homologação mostra o frontend a cada merge na `develop`, sem depender de um owner da organização.
- Cada runner atende só um repositório: um problema num deles não afeta o outro.
- O frontend troca de versão sem reiniciar `api`, `ws` ou `postgres`.

**Fica mais difícil ou é risco aceito**

- Dois serviços de runner no servidor: cerca de 512 MB a mais estimados no grupo Ops do orçamento do ADR-055
  (de ~1,0 para ~1,5 GB); a folga cai de ~8,4 para ~7,9 GB.
- Dois runners para registrar e atualizar, com tokens de registro por repositório.
- Mais um repositório público atendido por runner self-hosted, com o mesmo risco aceito na decisão 15 do
  ADR-055, limitado pelas proteções da decisão 2 deste ADR.
- O pacote `cromocard-web` fica ligado ao repositório do frontend. O deploy do backend sobe o `web` com a imagem
  que já está no servidor; se ela precisar ser baixada de novo (servidor limpo), o repositório do backend precisa
  de acesso de leitura ao pacote (*Manage Actions access* nas configurações do pacote).

**O que precisa ser feito**

- Aplicar as proteções da decisão 2 no `codaqui/cromocard-frontend` e cadastrar a variável `WEB_URL` nos
  Environments.
- PR no frontend: job da imagem `web` no `ci.yml` e o `deploy.yml`.
- PR no backend: trava `flock` no `deploy.yml`.
- Instalar o segundo runner no servidor (infraestrutura) e conferir o primeiro deploy de homologação.
- Atualizar `docs/Infraestrutura/` (`topologia.md`, `runbooks.md` e `historico.md`) quando o frontend estiver no ar.

## Referências

- ADR-026, ADR-038, ADR-045, ADR-055
- `apps/cromocard-backend/.github/workflows/ci.yml` e `deploy.yml`; `apps/cromocard-backend/infra/`
- `apps/cromocard-frontend/.github/workflows/ci.yml` e `docker/` (`Dockerfile`, `nginx.conf`, `write-env.sh`)
- [`docs/Infraestrutura/topologia.md`](../Infraestrutura/topologia.md) e [`runbooks.md`](../Infraestrutura/runbooks.md)
