# ADR-057 — Imagens públicas no GHCR

- **Status:** Proposto (aguardando validação do PO)
- **Data:** 2026-10-31
- **Decisores:** Lucas Oliveira Lima (proposta); validação: Felipe Consulim (PO)
- **Substitui parcialmente:** ADR-055, decisão 7 (só a visibilidade: "Os pacotes nascem privados"). O resto da
  decisão 7 continua: GHCR como registro, nome `ghcr.io/codaqui/cromocard-<serviço>:<sha>`, login do runner com o
  `GITHUB_TOKEN` do job (`packages: read`) e logout no fim, e o plano B com artifact e `docker load`.

## Contexto

O ADR-055 decidiu que os pacotes do GHCR nasceriam privados e deixou "visibilidade e retenção dos pacotes no GHCR"
como pendência. Em 31/10/2026, ao preparar o deploy do frontend (ADR-056), conferimos que os três pacotes estão
**públicos**: sem login, o registro emite um token anônimo e lista as tags do `cromocard-api` (40), do
`cromocard-ws` (40) e do `cromocard-web` (1).

A documentação do GitHub diz que *"Once you make a package public, you cannot make it private again."* Voltar para
privado exigiria apagar e recriar os três pacotes, o que traz estes conflitos:

- **Versões perdidas:** as 81 versões publicadas somem do registro. O rollback automático e o manual fazem
  `docker compose pull` da tag anterior e deixam de funcionar até existirem duas versões novas.
- **Risco de nascerem públicos de novo:** a regra de criação de pacotes da organização só o owner da `codaqui`
  enxerga, e ela (ou alguém) já deixou os três públicos.
- **Acesso perdido:** a permissão de leitura do `cromocard-backend` no `cromocard-web` (*Manage Actions access*)
  precisaria ser refeita.
- **Owner talvez necessário:** apagar um pacote pode exigir um owner.

Os repositórios do backend e do frontend já são públicos (ADR-026, ADR-055), e as imagens só contêm o que sai deles.

## Decisão

1. **Mantenha públicos os pacotes `cromocard-api`, `cromocard-ws` e `cromocard-web` no GHCR.**
2. **Nunca coloque segredo dentro de uma imagem.** Configuração e segredos entram só na hora de subir o
   container: o `.env` do ambiente, gerado pelo deploy a partir dos Environments do GitHub (ADR-055, decisão 16),
   e o `env.js` do frontend, gerado na subida (ADR-045). Dockerfiles não usam `ARG` nem `ENV` com segredo, e o
   build não copia `.env` (os `.dockerignore` já excluem). O gitleaks e o Trivy do CI continuam obrigatórios.
3. **Mantenha o login no GHCR nos dois `deploy.yml`.** Com os pacotes públicos, ele não é necessário para baixar
   as imagens, mas deixa o pipeline pronto para um pacote privado e não custa nada.
4. **Decida a visibilidade ao criar um pacote novo.** Como um pacote público não volta a ser privado, um pacote
   que precise ser privado deve ser criado assim desde o primeiro push, com a permissão de leitura dada aos
   repositórios que fazem o deploy.

## Alternativas consideradas

- **Apagar e recriar os pacotes como privados**, para seguir o ADR-055 ao pé da letra: traz os conflitos do
  contexto (perda das versões e do rollback, risco de nascerem públicos de novo, acesso refeito e possível
  necessidade de um owner) para proteger imagens feitas de código que já é público.
- **Tornar privado só o pacote do frontend:** não é possível pelo mesmo motivo, porque o `cromocard-web` também
  já nasceu público.

## Consequências

**Fica mais fácil**

- Nada muda no pipeline: CI e deploys seguem como estão.
- Qualquer pessoa da equipe, ou da banca, pode baixar e rodar as imagens sem token.
- O deploy do backend baixa o `web` mesmo sem a permissão de *Manage Actions access* do ADR-056.

**Fica mais difícil ou é risco aceito**

- Qualquer pessoa vê as dependências e as versões de cada imagem, as mesmas do `package-lock.json` público.
- Uma imagem antiga com vulnerabilidade conhecida continua disponível para download. As imagens novas passam pelo
  Trivy, e a retenção continua pendente.
- Um segredo que entre numa imagem por engano fica público. A decisão 2 e o gitleaks reduzem esse risco.

**O que precisa ser feito**

- Atualizar `docs/Infraestrutura/topologia.md` (pacotes no GHCR: públicos) quando este ADR for aceito.
- Decidir a retenção dos pacotes (por exemplo, apagar as versões antigas que nenhum ambiente usa). A pendência do
  ADR-055 continua só para a retenção.

## Referências

- ADR-018, ADR-026, ADR-045, ADR-055, ADR-056
- Documentação do GitHub: *Configuring a package's access control and visibility*
  (https://docs.github.com/en/packages/learn-github-packages/configuring-a-packages-access-control-and-visibility)
- `apps/cromocard-backend/.github/workflows/ci.yml` e `deploy.yml`; `apps/cromocard-frontend/.github/workflows/`;
  `apps/cromocard-frontend/docker/`
