# ADR-038 — Web e BackOffice num único SPA, separados por rota e papel

- **Status:** Aceito
- **Data:** 2026-10-17
- **Decisores:** Equipe CromoCard
- **Substitui parcialmente:** ADR-021 (a separação entre Aplicação Web e Painel BackOffice; o app mobile continua separado)

## Contexto

O ADR-021 propôs três aplicações cliente com codebases separadas: Aplicação Web, Aplicativo Mobile e
Painel BackOffice. Ao montar o esqueleto do frontend, ficou claro que a Web e o BackOffice teriam a
mesma stack (ADR-039), o mesmo cliente HTTP, o mesmo login (a mesma tabela `users`, com o papel em
`user_role`), os mesmos componentes visuais e a mesma equipe de seis pessoas. Dois repositórios
duplicariam configuração, CI, imagem Docker, componentes e a camada de sessão.

## Decisão

Um único SPA (`cromocard-frontend`) atende as três áreas da web:

| Área | Quem | Rotas | Layout | Guard |
|---|---|---|---|---|
| Pública | Visitante | `/` e páginas abertas | `PublicLayout` | nenhum |
| Cliente | `CUSTOMER` e `SELLER` | `/profile`, coleção, grupos… | `CustomerLayout` | `RequireAuth` |
| BackOffice | `ADMIN` | `/backoffice/*` | `AdminLayout` | `RequireRole role="ADMIN"` |

- Os layouts ficam em `src/app/layouts/`, e os guards em `src/routes/guards/` (ADR-043).
- As rotas das features são carregadas sob demanda (`lazy` do React Router): quem nunca abre o
  BackOffice não baixa o código dele.
- Depois do login, cada papel cai na sua área (`homePathByRole` em `src/routes/paths.ts`).
- Uma feature que atende as duas áreas exporta as rotas separadas, por exemplo `usersRoutes` e
  `usersBackofficeRoutes`, e o `router.tsx` pendura cada lista no layout certo.
- **Os guards do frontend só controlam a navegação.** Quem autoriza é a API (`authorize(...roles)`
  no backend). Nenhuma regra de acesso pode depender apenas do frontend.
- O Aplicativo Mobile continua sendo um app separado (ADR-023).

## Alternativas consideradas

- **Dois SPAs em repositórios separados (ADR-021):** isolam o deploy, mas duplicam o esqueleto, o
  CI, a imagem, os componentes e o cliente HTTP, e exigem compartilhar o cookie do refresh token
  entre dois domínios.
- **Monorepo com dois apps e um pacote compartilhado** (npm workspaces, Turborepo): resolve a
  duplicação, mas traz uma ferramenta de build que o MVP não precisa.

## Consequências

- Um repositório, uma imagem e um pipeline. Componentes e tokens servem às três áreas.
- Uma release do BackOffice sobe junto com a área do cliente. O risco é mitigado pelo CI e pela
  homologação.
- Se o BackOffice crescer a ponto de precisar de deploy próprio, um ADR novo pode separá-lo. A
  estrutura por feature (ADR-040) facilita essa separação.
- Pendente: o C4 nível 2 (`docs/Diagramas/Diagramas-C4/02-containers.puml`) ainda mostra
  "Aplicação Web" e "Painel BackOffice" como containers separados.

## Referências

- ADR-021, ADR-023, ADR-043
- `apps/cromocard-frontend/src/app/router.tsx`, `src/routes/paths.ts`
