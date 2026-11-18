# ADR-064 — Teste de carga e de estresse da API com k6

- **Status:** Proposto (aguardando validação do PO)
- **Data:** 2026-11-18
- **Decisores:** Lucas (infraestrutura); validação: Felipe Consulim (PO)

## Contexto

A equipe precisa medir quanto a API aguenta antes da primeira publicação em produção e gerar métricas e
relatórios do teste. A meta definida é **1 milhão de escritas e 2 milhões de leituras por dia**. Não há outro
requisito de desempenho nos casos de uso nem ferramenta de teste de carga no projeto.

O ambiente limita como o teste pode ser feito (ADR-055 e `docs/Infraestrutura/topologia.md`):

- Um único servidor (AMD FX-6100, 6 threads, sem AVX2, HDD rotacional) roda homologação, as ferramentas de
  operação e, no futuro, produção.
- Nenhum serviço publica porta: o tráfego público chega só pelo Cloudflare Tunnel, pela internet residencial.
  Um teste pelo domínio público mede o uplink de casa e pode ser tratado pelo Cloudflare como ataque.
- Produção nunca foi publicada. Homologação é usada pelo time todo dia, e a restauração do backup nunca foi
  testada.
- A senha usa argon2id (`src/lib/password.ts`), caro em CPU e memória, e o login tem rate limit em memória de 5
  tentativas por minuto por IP (ADR-049).

O plano de execução está em `docs/Infraestrutura/teste-de-carga.md`.

## Decisão

1. **Use o k6** (Grafana Labs, código aberto) para os testes de carga: scripts em JavaScript versionados com o
   código, metas declaradas no script (`thresholds`), parada automática (`abortOnFail`) e o painel web
   exportado em HTML como relatório. Fixe a versão do binário e da imagem `grafana/k6`, registrada no
   `README.md` dos scripts.
2. **Os scripts ficam no backend**, em `apps/cromocard-backend/tests/load/`, junto da API e do `infra/`. Eles
   ficam fora do `npm test` e do CI; rodam sob demanda.
3. **Teste em duas fases:**
   - **Réplica de produção** (`docker-compose.yml` + `compose.prod.yml`, mesmas imagens de hml, banco
     descartável com dados gerados), onde rodam todos os tipos de teste, inclusive os que escrevem dados.
   - **Homologação**, numa janela combinada com o time e com merges congelados, com o k6 num container na rede
     `edge` de hml, batendo direto na `api`, sem passar pelo Cloudflare, limitado a 1 CPU e só com leituras.
   - **Projeto descartável no servidor** (`cromocard-carga`, rede, banco e volume próprios, limites de produção),
     na mesma janela, para medir as escritas no hardware real sem tocar nos dados de hml. É apagado no fim.
   - Nunca pelo domínio público e nunca em produção sem um novo ADR.
4. **Adote as metas da seção 5 do plano:**
   - vazão: a meta diária vira 11,6 escritas/s e 23,1 leituras/s em média e, com pico de 3× a média, **105 req/s
     (70 leituras + 35 escritas)**, sustentados sem fila; os testes usam vazão constante (`arrival-rate`), não
     número de usuários;
   - erros abaixo de 1% na carga normal;
   - p95 das leituras abaixo de 500 ms e p99 abaixo de 1 s;
   - p95 do login abaixo de 1,5 s;
   - p95 das escritas abaixo de 800 ms;
   - nenhum container derrubado por falta de memória;
   - parada automática com mais de 10% de erros ou p95 acima de 3 s.
5. **Credenciais de teste só por variável de ambiente**, vindas do cofre da equipe. O repositório é público.
6. **Cada execução gera** o painel HTML, o resumo em JSON e Markdown, os pontos brutos em CSV e a coleta do
   servidor e do banco. O relatório final, com a capacidade medida e as recomendações, fica no plano.

## Alternativas consideradas

- **Apache JMeter:** maduro e com interface gráfica, mas os planos são XML difíceis de revisar em PR e a JVM
  pesa no mesmo servidor da API.
- **Gatling:** bons relatórios HTML, mas exige a JVM e outra linguagem de script.
- **Artillery:** usa Node e YAML, próximo da stack, mas o próprio Node consome mais CPU por VU, o que pesa
  quando o gerador divide a máquina com a API.
- **Locust:** scripts em Python, uma linguagem a mais no projeto, e precisa de mais de um processo para gerar
  carga alta.
- **autocannon:** leve, mas mede um endpoint por vez, sem jornadas, sem metas e sem relatório.
- **Serviço em nuvem (Grafana Cloud k6, BlazeMeter):** a API não é alcançável de fora sem passar pelo
  Cloudflare, e o plano gratuito limita a carga.

## Consequências

- O time ganha um número de capacidade medido, as metas viram código e o teste pode ser repetido a cada
  mudança grande.
- Homologação fica indisponível ou lenta durante a janela, e os merges ficam congelados nesse tempo.
- A capacidade medida na réplica depende da máquina usada; a que vale é a do servidor (hml e o projeto descartável).
- Até existirem as rotas do cliente (coleção, chat, ofertas), as escritas do catálogo fazem o papel do volume de
  escrita. O teste é repetido quando elas entrarem.
- O dia comprimido (3 milhões de requisições em cerca de 8 h) só roda na réplica e cresce o banco em cerca de
  500 mil cartas.
- O gerador de volume precisa acompanhar o DER quando as tabelas do catálogo mudarem.
- As metas propostas aqui podem mudar depois da primeira medição; a mudança é um ADR novo.

## Referências

- `docs/Infraestrutura/teste-de-carga.md` (plano de execução)
- ADR-049 (rate limit) · ADR-019 (logs e `requestId`) · ADR-055 (topologia e limites dos containers)
- `apps/cromocard-backend/infra/compose.prod.yml` e `compose.hml.yml` · `apps/cromocard-backend/src/lib/password.ts`
