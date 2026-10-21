# Backlog — Sprint 06 (16/10 → 30/10): Fundação + Painel Administrador

> **Criado no Azure em 21/10/2026:** 43 tasks (#381 a #423), filhas das US #109, #333, #334, #336, #340 e #341,
> todas na Sprint 06 com responsável e estimativa. A descrição de cada task tem objetivo, arquivos, passo a passo,
> critério de pronto, dependências e como testar.
> Escopo e cortes: [ADR-038](../docs/ADR/ADR-038-ajustes-der-painel-administrador-mvp.md) · Critérios de aceite: `docs/Casos-De-Uso/` (CCD058, 059, 061, 065, 066).

**Janela:** 21/10 → 30/10 (9 dias) · **Planejado:** 130h em tasks.

## Esqueleto pronto nos repositórios

Antes das tasks, um PR de esqueleto em cada repositório (branch `feature/230-esqueleto-sprint-06`, revisão do Daniel) entrega:

- **Backend:** `schema.prisma` + 10 migrations (uma por tabela); domínios `auth`, `catalog/*`, `admin/*` e `uploads` com os
  9 arquivos do ADR-004 e as assinaturas prontas; tudo registrado no `routes.ts` e no Swagger. O que falta implementar responde `501`
  e os testes que faltam aparecem como `todo` no `npm test`.
- **Frontend:** menu do backoffice com os 9 módulos do Figma, rotas e `paths` registrados, contratos de API e tipos de cada
  feature, e páginas "Em construção" apontando para a US.
- Um `README.md` em cada pasta de domínio e de feature com as tasks daquela pasta, o dono e os arquivos.

## Horas por pessoa

| Pessoa | Tasks | Horas |
|---|---|---|
| Daniel | 9 | 27h |
| Felipe Consulim | 10 | 30h |
| Lucas | 8 | 27h |
| Felipe Broetto | 4 | 8h |
| Gabriel | 6 | 21h |
| Lucca | 6 | 17h |
| **Total** | **43** | **130h** |

## Como trabalhar nesta sprint

- Cada pessoa é dona de **uma User Story inteira** (back + front), do início ao PR.
- Branch `feature/<id-da-US>-<descricao>` a partir de `develop`, indicada em cada task.
- Jibble: atividade da US, com o número da task na nota, apontada no mesmo dia; no Azure, Completed Work e Remaining Work no mesmo dia.
- As tasks ⚠️ desbloqueiam os colegas: PR até **23/10** (auditoria, upload, categorias, auth e ConfirmDialog).

## US #109 — CCD004 Realizar Login (+ fundação de autenticação)

| Task | Título | Dono | h | Obs. |
|---|---|---|---|---|
| [#381](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/381) | [Back] Hash de senha com argon2 | Daniel | 2 |  |
| [#382](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/382) | [Back] AuthRepository com Prisma | Daniel | 3 |  |
| [#383](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/383) | [Back] AuthService: login, refresh com rotação e logout | Daniel | 4 | ⚠️ desbloqueia |
| [#384](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/384) | [Back] AuthController com cookie httpOnly | Daniel | 3 | ⚠️ desbloqueia |
| [#385](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/385) | [Back] AuthService.setupPassword (definir senha pelo link) | Daniel | 2 |  |
| [#386](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/386) | [Back] Testes da AuthService | Daniel | 3 |  |
| [#387](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/387) | [Back] Seed: administrador inicial e dados do catálogo | Daniel | 3 | ⚠️ desbloqueia |
| [#388](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/388) | [Front] Tela de Login | Daniel | 4 |  |
| [#389](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/389) | [Front] Renovar a sessão e sair | Daniel | 3 |  |

## US #334 — CCD059 Gestão de Usuários

| Task | Título | Dono | h | Obs. |
|---|---|---|---|---|
| [#390](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/390) | [Front] Componente compartilhado ConfirmDialog | Felipe Consulim | 2 | ⚠️ desbloqueia |
| [#391](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/391) | [Back] Provider de e-mail (Nodemailer + Ethereal) | Felipe Consulim | 2 |  |
| [#392](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/392) | [Back] UsersAdminRepository e filtros da lista | Felipe Consulim | 3 |  |
| [#393](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/393) | [Back] Cadastrar usuário e enviar link de definição de senha | Felipe Consulim | 4 |  |
| [#394](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/394) | [Back] Editar, suspender, reativar, excluir e restaurar usuário | Felipe Consulim | 4 |  |
| [#395](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/395) | [Back] Testes da gestão de usuários | Felipe Consulim | 3 |  |
| [#396](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/396) | [Front] Lista de usuários com filtros | Felipe Consulim | 3 |  |
| [#397](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/397) | [Front] Formulário de cadastrar e editar usuário | Felipe Consulim | 4 |  |
| [#398](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/398) | [Front] Ações: suspender, reativar, excluir e restaurar | Felipe Consulim | 3 |  |
| [#399](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/399) | [Front] Tela Definir senha | Felipe Consulim | 2 |  |

## US #336 — CCD061 Gestão de Catálogo

| Task | Título | Dono | h | Obs. |
|---|---|---|---|---|
| [#400](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/400) | [Back] Upload de imagens (LocalStorageProvider + POST /uploads) | Lucas | 4 | ⚠️ desbloqueia |
| [#401](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/401) | [Back] Raridades e idiomas (dados de apoio) | Lucas | 1 |  |
| [#402](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/402) | [Back] Álbuns: repository e service | Lucas | 3 |  |
| [#403](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/403) | [Back] Cartas: repository e service | Lucas | 4 |  |
| [#404](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/404) | [Back] Testes do catálogo e do upload | Lucas | 4 |  |
| [#405](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/405) | [Front] Página de cartas: lista e filtros | Lucas | 3 |  |
| [#406](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/406) | [Front] Formulário de carta com upload de frente e verso | Lucas | 4 |  |
| [#407](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/407) | [Front] Página de álbuns: lista e formulário | Lucas | 4 |  |
| [#408](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/408) | [Dados] JSON de raridades e idiomas | Felipe Broetto | 2 |  |
| [#409](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/409) | [Dados] JSON do catálogo de exemplo | Felipe Broetto | 3 |  |

## US #341 — CCD066 Configurações Globais

| Task | Título | Dono | h | Obs. |
|---|---|---|---|---|
| [#410](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/410) | [Back] Categorias: repository e service | Gabriel | 4 | ⚠️ desbloqueia |
| [#411](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/411) | [Back] Banner da Home: repository e service | Gabriel | 3 |  |
| [#412](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/412) | [Back] Testes de categorias e banner | Gabriel | 3 |  |
| [#413](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/413) | [Front] Ajustar o visual do backoffice ao Figma | Gabriel | 3 |  |
| [#414](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/414) | [Front] Configurações, Módulo 1: banner da Home | Gabriel | 4 |  |
| [#415](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/415) | [Front] Configurações, Módulo 2: categorias com reordenação | Gabriel | 4 |  |

## US #340 — CCD065 Log de Auditoria

| Task | Título | Dono | h | Obs. |
|---|---|---|---|---|
| [#416](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/416) | [Back] AuditLogsService: record, list e detalhe | Lucca | 3 | ⚠️ desbloqueia |
| [#417](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/417) | [Back] Testes da AuditLogsService | Lucca | 2 |  |
| [#418](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/418) | [Front] Tela de logs com filtros e detalhe | Lucca | 4 |  |

## US #333 — CCD058 Dashboard Gerencial

| Task | Título | Dono | h | Obs. |
|---|---|---|---|---|
| [#419](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/419) | [Back] DashboardService: indicadores por período | Lucca | 2 |  |
| [#420](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/420) | [Back] Testes da DashboardService | Lucca | 2 |  |
| [#421](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/421) | [Front] Tela do dashboard com filtro de período | Lucca | 4 |  |
| [#422](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/422) | [QA] Roteiro de teste manual do Painel Admin | Felipe Broetto | 2 |  |
| [#423](https://dev.azure.com/CromoCard/CromoCard/_workitems/edit/423) | [QA] Revisar os textos das telas do admin | Felipe Broetto | 1 |  |

## Ordem e dependências

```
Dia 1-2 (21-23/10)  ── PR do esqueleto · #416 auditoria · #400 upload · #390 ConfirmDialog · #383/#384 auth · #387 seed
Dia 3-6 (24-28/10)  ── back e front de cada US em paralelo · #410 categorias até 24/10
Dia 7-8 (29-30/10)  ── testes, PRs, correções, roteiro de teste (#422) e Review da Sprint 06
```

## Fica para a Sprint 07 ou depois

CCD060 Notificação Global · CCD062 Gestão de Comunidade (depende de Grupos, S8) ·
CCD063 Exportar Relatórios · CCD064 Aprovar Solicitações (depende do cliente pedir, S7).
