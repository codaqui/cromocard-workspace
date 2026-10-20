# ADR-045 — Configuração em runtime e imagem Docker do frontend

- **Status:** Aceito
- **Data:** 2026-10-17
- **Decisores:** Equipe CromoCard

## Contexto

O Vite embute as variáveis `VITE_*` no JavaScript na hora do build. Se a URL da API entrar no
build, cada ambiente (homologação e produção) precisa de uma imagem própria, e a imagem testada em
homologação não é a mesma que vai para produção. O backend já lê e valida a configuração num lugar
só (ADR-018).

## Decisão

### Leitura da configuração

- `import.meta.env` só pode aparecer em `src/config/env.ts` (regra `no-restricted-syntax` do
  ESLint). O resto do app importa `env` de `@/config/env`.
- O `env.ts` valida as variáveis com Zod. Com configuração inválida, o app não sobe e mostra o
  erro.
- Variáveis: `API_URL` (sem o `/api/v1`) e `DEV_ACCESS_TOKEN` (só em dev, ADR-043).

### URL da API em runtime

- O `index.html` carrega `/env.js` antes do app. Esse arquivo define `window.__ENV__`.
- No container, o script `docker/write-env.sh` grava a `API_URL` do ambiente no `env.js` na subida.
  Sem `API_URL`, o container não sobe.
- `window.__ENV__.API_URL` tem prioridade sobre `VITE_API_URL`. Em dev, o `public/env.js` é vazio, e
  vale o `.env`.
- **A mesma imagem roda em homologação e produção.**

### Imagem

- Build em dois estágios: `node:24-alpine` gera o `dist/`, e `nginxinc/nginx-unprivileged` serve
  os arquivos, sem root, na porta 8080.
- O nginx devolve o `index.html` para qualquer URL desconhecida (rotas do SPA). Cache: `/assets/*`
  imutável por 1 ano (nomes com hash), `index.html` com `no-cache` e `env.js` com `no-store`.

## Alternativas consideradas

- **`VITE_API_URL` no build:** uma imagem por ambiente, o que quebra o "build uma vez, publica em
  todo lugar".
- **Servir o frontend pelo Express do backend:** acopla os deploys dos dois repositórios
  (ADR-026).
- **Servidor Node (`serve`, `vite preview`):** mais pesado que o nginx e sem as regras de cache.

## Consequências

- Trocar a URL da API é só reiniciar o container com outra `API_URL`, sem build novo.
- **Tudo o que chega ao navegador é público**, seja no bundle ou no `env.js`. Nenhum segredo pode
  virar variável do frontend.
- Variável nova no frontend = adicionar no schema do `env.ts`, no `write-env.sh` (se for de
  runtime), no `.env.example` e na tabela do README.

## Referências

- ADR-018, ADR-026, ADR-043
- `apps/cromocard-frontend/src/config/env.ts`, `docker/`, `index.html`
