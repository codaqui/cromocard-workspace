# Teste de carga e de estresse da API (k6)

- **Situação:** plano proposto em 18/11/2026, aguardando a validação do PO junto com o
  [ADR-064](../ADR/ADR-064-teste-de-carga-com-k6.md) (ferramenta, alvos e metas).
- **Responsável:** Lucas (infraestrutura).
- **Onde ficam os scripts:** `apps/cromocard-backend/tests/load/` (a criar, depois da validação).

O plano diz o que medir, onde, em que ordem, com quais metas e o que entregar no fim. Os números do servidor e
dos ambientes vêm da [topologia](topologia.md) e do [ADR-055](../ADR/ADR-055-topologia-de-ambientes-e-implantacao.md).

## 1. Meta de volume

A meta é **1 milhão de escritas e 2 milhões de leituras por dia**:

| | Por dia | Média | Pico (3× a média) |
|---|---|---|---|
| Escritas | 1.000.000 | 11,6 req/s | 35 req/s |
| Leituras | 2.000.000 | 23,1 req/s | 70 req/s |
| Total | 3.000.000 | 34,7 req/s | **105 req/s** |

O fator de pico de 3× é uma proposta para o PO validar (ADR-064): o tráfego não se espalha igual pelas 24 horas.
Por isso os testes são definidos em **vazão** (requisições por segundo, executor `constant-arrival-rate` e
`ramping-arrival-rate` do k6), não em número de usuários.

## 2. Perguntas que o teste responde

1. A API sustenta o **pico de 105 req/s** (70 leituras + 35 escritas) dentro das metas de latência, no
   servidor atual? E a **média de 34,7 req/s** por horas seguidas?
2. O que quebra primeiro: a CPU da `api`, a memória da `api`, o PostgreSQL, o disco ou o pool de conexões?
3. Depois de um pico, a API volta ao normal sozinha, sem reinício de container?
4. Os limites do `compose.prod.yml` bastam para a primeira publicação em produção?
5. O banco aguenta crescer 1 milhão de registros por dia sem a latência subir com o tempo?

## 3. Escopo

| Entra | Fica fora, e por quê |
|---|---|
| A API REST (`api`): `/health`, login e refresh, catálogo e dashboard do BackOffice, configurações públicas e, só na réplica, as escritas do catálogo e a importação CSV | `ws`: hoje só responde `/health`; o Socket.IO entra no plano quando o chat existir |
| O PostgreSQL, como consequência da carga na API | `web`: é o nginx servindo arquivos estáticos e não é o gargalo provável |
| | O caminho Cloudflare e o uplink residencial: medem a internet de casa, não o servidor, e o Cloudflare pode tratar o teste como ataque |
| | Produção: nunca foi publicada |

Hoje a API só tem rotas de autenticação, de BackOffice e as configurações públicas: a Área Pública e a do
Cliente ainda não têm endpoints. O volume de escrita de 1 milhão por dia virá, na vida real, das ações dos
clientes (marcar cartas na coleção, mensagens, ofertas), que ainda não existem. Até lá, as **escritas do catálogo**
(cadastrar, editar e excluir carta) fazem esse papel: são as escritas que já existem, com validação, índice único,
auditoria (`audit_logs`, ADR-034) e transação. Quando as rotas do cliente existirem, elas entram na mistura e o
teste é repetido.

## 4. Ambientes, em duas fases

| | Fase 1: réplica de produção | Fase 2: homologação |
|---|---|---|
| Onde | Máquina da equipe, com `infra/docker-compose.yml` + `infra/compose.prod.yml` (`api` 1,5 CPU e 768 MB; `postgres` 2 CPU e 1,5 GB) | `cromocard-srv`, projeto `cromocard-hml` (`api` 1 CPU e 512 MB; `postgres` 1 CPU e 768 MB) |
| Imagens | As mesmas tags que estão em hml (`BACKEND_TAG` de `.deployed-tag`) | As que estão no ar |
| Como o k6 chega na API | Porta publicada só nesta réplica, por um override `tests/load/compose.carga.yml` | Container do k6 na rede `cromocard-hml_edge`, batendo direto em `http://api:3000`, **sem passar pelo Cloudflare** |
| Dados | Seed + gerador de volume (seção 6); pode escrever | Os dados de hml; **só leitura** |
| Testes | Todos (seção 7) | Só as leituras: fumaça, carga média, carga de pico, estresse até a primeira meta violada e pico repentino |
| Para quê | Achar o limite sem risco e repetir quantas vezes precisar | Confirmar no hardware real (FX-6100 sem AVX2, HDD rotacional) |

**Limitação da fase 1:** a réplica roda em outra CPU e outro disco. Ela compara versões e acha gargalos de
código; o número de capacidade que vale é o da fase 2.

**Limitação da fase 2:** como hml é só leitura, a meta de escrita (35 escritas/s no pico) não é confirmada no
hardware real, e escrita no HDD rotacional é justamente o ponto mais fraco do servidor. **Proposta, a validar
com o PO:** uma **fase 2b** no próprio servidor, com um projeto Compose descartável `cromocard-carga` (rede,
banco e volume próprios, os limites de produção e os mesmos dados gerados da réplica), apagado no fim da
janela. Ela mede leitura e escrita no hardware real sem tocar nos dados de hml. Cabe na memória: o servidor tem
15 GiB, e hml e o projeto de carga juntos reservam menos de 5 GiB.

**No servidor, o k6 divide a máquina com a API.** Ele roda com `--cpus 1 --memory 512m` (6 threads no total,
3,25 CPUs reservadas por hml), e o relatório registra o uso dele. Se ele passar de 80% da CPU dele, o resultado
mede o k6, não a API.

## 5. Metas (thresholds)

Não há requisito de desempenho nos casos de uso. Estas metas são a proposta do ADR-064 e valem quando o PO
validar:

| Métrica | Carga normal | Estresse |
|---|---|---|
| Vazão sustentada, sem fila (`dropped_iterations` = 0) | 105 req/s no pico (70 leituras + 35 escritas) e 34,7 req/s na média | Acima do pico, até a ruptura |
| Erros (`http_req_failed`), sem contar os `429` esperados do login | < 1% | < 5% |
| Leituras (listas, dashboard, configurações): p95 / p99 | < 500 ms / < 1 s | < 1,5 s / < 3 s |
| Login (argon2id): p95 | < 1,5 s | < 3 s |
| Escritas (só na réplica): p95 | < 800 ms | < 2 s |
| `checks` (status e corpo esperados) | > 99% | > 95% |
| Containers | Nenhum `OOMKilled` nem reinício; memória da `api` < 85% do limite | Nenhum reinício |

**Parada automática** (`abortOnFail`), para proteger hml: erros acima de 10% ou p95 acima de 3 s por 30 s
seguidos encerram o teste.

## 6. Dados de teste

- **Volume na réplica:** o seed tem só 12 cartas, e uma lista medida assim não diz nada. Um gerador SQL
  (`tests/load/data/generate-catalog.sql`, com `generate_series`) leva o catálogo à ordem de grandeza do
  protótipo: cerca de 180 mil cartas, 150 álbuns, 30 categorias e 1.000 usuários, respeitando os índices e o
  soft delete. A réplica nasce sempre do mesmo dump, para os resultados serem comparáveis.
- **Contas:** contas de administrador de teste, com a senha no cofre da equipe (nunca no repositório). Em hml,
  usar contas que já existem; nenhum cadastro novo.
- **Escritas:** cada carta criada pelo teste leva um prefixo no nome (ex.: `carga-`) e um número único por
  VU e iteração, para não bater no índice único (`album_id`, `number`). O `PATCH` e o `DELETE` só mexem nas cartas
  do próprio teste. No dia comprimido (teste 7), o banco cresce cerca de 500 mil cartas ativas (50% de criação,
  menos 10% de exclusão): o tamanho do banco e o `autovacuum` entram na coleta.
- **Token:** o access token dura 900 s (`JWT_ACCESS_TTL`). Teste mais longo renova com `POST /api/v1/auth/refresh`.
- **Rate limit do login:** 5 por minuto por IP (`src/domains/auth/auth.routes.ts`, ADR-049), em memória.
  - Em hml todos os VUs saem do mesmo IP: o login acontece **só no `setup()`**, poucas vezes, e o token é
    reaproveitado.
  - Na réplica, o cenário de login simula clientes diferentes com um `X-Forwarded-For` por VU
    (`TRUST_PROXY=1`, como em produção). Isso nunca é feito em hml.

## 7. Cenários e tipos de teste

### Mistura de requisições

A carga é gerada por dois cenários do k6 rodando juntos, cada um com a sua vazão: **leituras** (2/3) e
**escritas** (1/3), como na meta. Cada requisição leva a tag `name` (ex.: `catalog:list-cards`), para o
relatório separar a latência por rota.

| ID | Tipo | Rotas | Peso dentro do tipo | Onde |
|---|---|---|---|---|
| L1 | Leitura | `GET /api/v1/admin/catalog/cards` (página, filtro por franquia e álbum, busca por nome) | 45% | Todos |
| L2 | Leitura | `GET /api/v1/admin/catalog/albums` e `categories` | 20% | Todos |
| L3 | Leitura | `GET /api/v1/admin/catalog/rarities` e `languages` | 5% | Todos |
| L4 | Leitura | `GET /api/v1/admin/dashboard` e `/recent-sellers` | 15% | Todos |
| L5 | Leitura | `GET /api/v1/settings/public`, sem login | 15% | Todos |
| E1 | Escrita | `POST /api/v1/admin/catalog/cards` (carta nova, com álbum e número únicos) | 50% | Réplica e fase 2b |
| E2 | Escrita | `PATCH /api/v1/admin/catalog/cards/:id` (cartas criadas pelo próprio teste) | 40% | Réplica e fase 2b |
| E3 | Escrita | `DELETE /api/v1/admin/catalog/cards/:id` (cartas criadas pelo próprio teste) | 10% | Réplica e fase 2b |
| A1 | Login | `POST /api/v1/auth/login` | Cenário próprio (teste 8) | Réplica |

`GET /health` roda antes de cada teste, como linha de base. A importação CSV (`POST /cards/import`) entra num
teste à parte, porque uma requisição grava 100 linhas e distorce a contagem.

### Tipos de teste, na ordem

| # | Tipo | Vazão (leituras + escritas) | Duração | Onde | Responde |
|---|---|---|---|---|---|
| 1 | Fumaça | 1 + 1 req/s | 1 min | Todos | Os scripts e as metas funcionam? |
| 2 | Carga média | 23 + 12 req/s (34,7 req/s) | 15 min | Todos (hml só leituras) | A média do dia fica folgada? |
| 3 | Carga de pico | 70 + 35 req/s (105 req/s) | 15 min | Todos (hml só leituras) | **A meta:** o pico cabe nas latências, sem erro e sem fila? |
| 4 | Estresse | Degraus de 1×, 1,5×, 2×, 3× e 4× o pico (105 a 420 req/s), 3 min cada | ~16 min | Réplica e fase 2b; hml até a primeira meta violada | Quanta margem há acima do pico e o que satura primeiro? |
| 5 | Pico repentino | 34,7 → 210 req/s (2× o pico) em 10 s, mantém 1 min, volta para a média por 3 min | ~5 min | Todos | Aguenta um salto e se recupera sozinha? |
| 6 | Ponto de ruptura | `ramping-arrival-rate` de 35 a 600 req/s em 20 min, com parada em 5% de erros | até 20 min | Réplica e fase 2b | Qual a vazão máxima? |
| 7 | Dia comprimido | 1 milhão de escritas + 2 milhões de leituras no ritmo do pico (105 req/s) | ~8 h | Só réplica | O volume de um dia inteiro passa? A latência sobe à medida que o banco cresce? Há vazamento de memória ou uso de swap? |
| 8 | Login sob pressão | A1 sozinho, de 1 a 30 logins simultâneos | ~10 min | Só réplica | Quantos logins simultâneos cabem na memória da `api`? |

Os VUs são só o meio: o k6 aloca quantos precisar para manter a vazão (`preAllocatedVUs` e `maxVUs`). Se faltar
VU, ele conta `dropped_iterations`, e isso reprova a meta de vazão.

## 8. Hipóteses a confirmar

| # | Hipótese | Como confirmar |
|---|---|---|
| H1 | O argon2id usa os padrões da biblioteca (`src/lib/password.ts`): cerca de 64 MiB de memória por hash. Com 512 MB (hml) ou 768 MB (prod), poucos logins simultâneos podem derrubar a `api` por falta de memória **antes** de a CPU saturar | Teste 8 + `docker inspect` (`OOMKilled`, `RestartCount`) |
| H2 | Com o disco rotacional, as consultas que não acham a página no cache dominam o p99 | `pg_stat_database` (taxa de acerto do cache) + `iostat -x` (`await`, `%util`) |
| H3 | O pool do Prisma é dimensionado pelas CPUs do host, não pelo limite do container, e abre mais conexões do que 1 CPU aproveita | `pg_stat_activity` por estado durante o teste 4 |
| H4 | Com 1 CPU, o Node da `api` satura antes dos 105 req/s do pico, e a latência sobe em fila | `docker stats` × RPS nos testes 3 e 4 |
| H6 | Escrever 35 cartas/s no HDD rotacional, cada uma com o registro de auditoria, é o primeiro gargalo do pico, antes da CPU | `iostat -x` (`await`) e p95 das escritas × leituras nos testes 3 e 4 da fase 2b |
| H7 | Com o banco crescendo 500 mil cartas, as listas paginadas e a busca por nome ficam mais lentas ao longo do dia | p95 de L1 por hora no teste 7 |
| H5 | O `429` do login aparece em hml se o login sair do `setup` | Contagem de `429` por rota no resumo do k6 |

## 9. Métricas coletadas

| Origem | Métricas | Como |
|---|---|---|
| k6 (cliente) | Requisições por segundo (`http_reqs`); latência média, mediana, p90, p95, p99 e máxima (`http_req_duration`) por rota; tempo de espera do servidor (`http_req_waiting`); erros (`http_req_failed`) e contagem por status (`429`, `5xx`); `checks`; VUs; iterações; dados enviados e recebidos | Resumo do k6, CSV bruto e painel web |
| Containers | CPU %, memória (uso e limite), rede e disco de `api`, `postgres` e `k6`; `OOMKilled` e reinícios | `docker stats` a cada 5 s em CSV + `docker inspect` no fim |
| Servidor (só hml) | Carga, swap e espera de disco | `vmstat 5` e `iostat -x 5` (pacote `sysstat`) |
| PostgreSQL | Conexões por estado; commits e rollbacks; leituras de disco × do cache; `deadlocks`; arquivos temporários; consultas mais lentas | `pg_stat_activity` e `pg_stat_database` a cada 10 s; `pg_stat_statements` só na réplica (exige `shared_preload_libraries`) |
| API | Duração por rota e os `5xx` com `requestId` (ADR-019) | `docker logs` da `api` no intervalo do teste, contados por status |

## 10. Relatórios

Cada execução gera uma pasta `tests/load/results/<AAAA-MM-DD>-<ambiente>-<tipo>/` (fora do git, só os
resumos são versionados):

| Arquivo | Conteúdo |
|---|---|
| `report.html` | Painel do k6 exportado (`K6_WEB_DASHBOARD=true`, `K6_WEB_DASHBOARD_EXPORT`), com os gráficos de latência, vazão e erros no tempo |
| `summary.json` e `summary.md` | Resumo gerado pelo `handleSummary`, com as metas aprovadas ou reprovadas e a latência por rota |
| `raw.csv.gz` | Pontos brutos (`--out csv`), para gráficos próprios |
| `docker-stats.csv`, `vmstat.txt`, `iostat.txt`, `pg-*.csv` | Coleta do servidor e do banco |
| `contexto.md` | Data, ambiente, tags das imagens, versão do k6, dados usados e o que estava diferente |

O **relatório final** entra na seção 13 deste documento, com:

- uma tabela por teste: vazão pedida e alcançada (leituras e escritas), p95, p99, erros, fila (`dropped_iterations`), metas aprovadas e o recurso que saturou;
- os gráficos de latência × vazão, erros × vazão, CPU, memória e disco × tempo, e latência por hora no dia comprimido;
- a resposta à meta: o servidor sustenta ou não 1 milhão de escritas e 2 milhões de leituras por dia (105 req/s no pico), com a margem medida ou o quanto falta;
- as hipóteses confirmadas ou descartadas;
- as recomendações (ex.: parâmetros do argon2, `connection_limit` do Prisma, índices, limites do compose, o SSD).
  Cada uma vira uma Task ou um ADR.

## 11. Execução

### Antes (checklist)

- [ ] ADR-064 e este plano validados pelo PO.
- [ ] Versão do k6 fixada (binário e imagem `grafana/k6:<versão>`) e registrada no `contexto.md`.
- [ ] Tags das imagens anotadas; a réplica usa as mesmas de hml.
- [ ] Fase 2: janela combinada no grupo e **congelamento de merges na `develop` do backend e do frontend**
      durante a janela. Um deploy reinicia a `api` e invalida o teste.
- [ ] Fase 2: backup do dia concluído e `/health` de hml respondendo 200.
- [ ] Coleta (`docker stats`, `vmstat`, `iostat`, PostgreSQL) iniciada antes do k6.
- [ ] Teste de fumaça aprovado antes de qualquer outro.

### Fase 2 em hml: como o k6 roda no servidor

O Docker do servidor só é usado pelo usuário `deploy` (topologia). Um administrador entra pela VPN e roda:

```bash
sudo -u deploy docker run --rm --network cromocard-hml_edge --cpus 1 --memory 512m \
  -e BASE_URL=http://api:3000 -e K6_WEB_DASHBOARD=true \
  -e K6_WEB_DASHBOARD_EXPORT=/results/report.html \
  -v /srv/cromocard/carga:/scripts:ro -v /srv/cromocard/carga/results:/results \
  grafana/k6:<versão> run /scripts/scenarios/carga-pico.js
```

As credenciais de teste entram por `--env-file` lido do cofre na hora, nunca gravado nos scripts. Os comandos
exatos da réplica e da coleta ficam no `README.md` dos scripts e, depois da primeira execução, num runbook.

### Depois

- [ ] `/health` de hml em 200 e nenhum container reiniciado (`docker inspect`).
- [ ] Coleta parada e pasta de resultados copiada para fora do servidor.
- [ ] Aviso no grupo de que a janela terminou.
- [ ] Resultado registrado na seção 13.

## 12. Riscos e salvaguardas

| Risco | Salvaguarda |
|---|---|
| hml fica lenta ou cai para o time | Janela combinada, parada automática (`abortOnFail`), só leitura e degraus curtos |
| O teste derruba a `api` (falta de memória) | `restart: unless-stopped` já sobe de novo; o teste 8, que procura esse limite, só roda na réplica |
| Deploy no meio do teste | Congelamento de merges durante a janela |
| O k6 rouba CPU da API no servidor | `--cpus 1` e uso do k6 no relatório |
| Dados de hml alterados | Nenhuma escrita em hml; a escrita no servidor vai para o projeto descartável da fase 2b |
| O banco da réplica cresce e enche o disco | Coleta do tamanho do banco a cada 10 min no teste 7; a réplica é apagada no fim |
| Resultado da réplica tomado como capacidade real | A capacidade que vale é a do servidor, nas fases 2 e 2b (seção 4) |
| Senha de teste no repositório público | Credenciais só por variável de ambiente, vindas do cofre |

## 13. Resultados

Ainda não executado.

## 14. Tarefas sugeridas para o Azure

| # | Task | Entrega |
|---|---|---|
| 1 | Validar o ADR-064 e este plano com o PO | ADR `Aceito` |
| 2 | Criar os scripts k6, o gerador de dados, o override da réplica e os coletores em `tests/load/` | PR no backend |
| 3 | Executar a fase 1 (testes 1 a 8, com o dia comprimido) e registrar os resultados | Relatórios da réplica |
| 4 | Executar a fase 2 (hml, só leituras) e a fase 2b (projeto descartável no servidor, leituras e escritas) na janela combinada | Relatórios do servidor |
| 5 | Escrever o relatório final e abrir as Tasks ou os ADRs das recomendações | Seção 13 preenchida |

### Estrutura prevista dos scripts

```
apps/cromocard-backend/tests/load/
├── README.md                  versão do k6, como rodar cada fase e cada teste
├── config/thresholds.js       as metas da seção 5, num lugar só
├── lib/auth.js                login no setup e renovação do token
├── requests/                  L1 a L5, E1 a E3 e A1 (uma função por requisição, com a tag `name`)
├── scenarios/                 fumaca, carga-media, carga-pico, estresse, pico-repentino, ruptura, dia-comprimido, login
├── data/generate-catalog.sql  gerador de volume da réplica
├── compose.carga.yml          override da réplica (porta publicada, sem cloudflared)
├── collect/                   docker-stats.sh, pg-stats.sh
└── results/                   saída das execuções (no .gitignore)
```
