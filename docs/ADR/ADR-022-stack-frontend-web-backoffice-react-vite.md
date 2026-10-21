# ADR-022 — Stack de frontend para Web e BackOffice: React + Vite

- **Status:** Substituído por ADR-039
- **Data:** 2026-09-29
- **Decisores:** Equipe CromoCard

## Contexto

O C4 Nível 2 define a **Aplicação Web** e o **Painel BackOffice** como SPAs construídos com
"React + Vite" (`docs/Diagramas/Diagramas-C4/02-containers.puml`). É a stack usada por
visitantes/clientes (Web) e administradores (BackOffice).

## Decisão

Usar React como biblioteca de UI e Vite como bundler/dev server para as duas SPAs (Web e
BackOffice), consumindo a API REST via JSON/HTTPS com JWT no header `Authorization`.

## Alternativas consideradas

- **Next.js** — ganharia SSR/SSG (relevante para SEO do painel público, que hoje é SPA puro).
- **Angular** ou **Vue** — outros frameworks componentizados.
- **Create React App** — tooling mais antigo e sem manutenção ativa, descartado frente ao Vite.

## Consequências

**Positivas**
- Build e HMR rápidos (Vite), produtividade alta para a equipe.
- Ecossistema React amplo (bibliotecas, exemplos, curva de aprendizado da equipe).

**Negativas / riscos**
- Sem SSR: páginas públicas (Home, busca, detalhes de carta/anúncio) não são pré-renderizadas,
  o que pode prejudicar SEO e compartilhamento em redes sociais do painel público (visitante).

## Referências

- `docs/Diagramas/Diagramas-C4/02-containers.puml`
- `CLAUDE.md` (tabela de containers)
