# ADR-061 — Chaves de configuração das metas e dos versos padrão

- **Status:** Proposto (aguardando validação do PO)
- **Data:** 2026-11-16
- **Decisores:** Gabriel Nascimento (proposta); validação: Felipe Consulim (PO)
- **Substitui parcialmente:** ADR-051, item 1 (só a lista de chaves criadas pelo seed: "`home.banner` e
  `notification.templates`"). O resto do item 1 continua: uma chave por configuração, `value` em JSON validado por
  um schema Zod por chave e leitura pública só de `home.banner`.

## Contexto

O ADR-051, item 1, fixou as chaves de `global_settings` criadas pelo seed em `home.banner` e `notification.templates`.
Na revisão do Figma da CCD066 (L7 e L8 da spec), as metas da CCD096 e da CCD103 e o verso padrão de cada franquia
(CCD106) passaram a ser editados na tela de Configurações Globais, nos módulos 4 e 2. A L10 decidiu criar essas chaves
já na CCD066, mesmo com as stories que leem os valores ainda por fazer. Elas foram implementadas no backend
(codaqui/cromocard-backend#28) sem registro num ADR.

## Decisão

1. Crie pelo seed mais três chaves em `global_settings`, cada uma com o próprio schema Zod em
   `src/domains/admin/settings/setting-schemas.ts`:

   | Chave | `value` | Valor do seed | Quem lê |
   |---|---|---|---|
   | `dashboard.monthly_signup_goal` | inteiro de 1 a 1.000.000, ou `null` para "sem meta" | `4000` | CCD096 |
   | `catalog.voting_goal` | inteiro de 1 a 1.000.000, obrigatório | `200` | CCD103 |
   | `catalog.default_backs` | objeto `{ [id da categoria]: URL http ou https }`, só com as categorias que têm verso | `{}` | CCD106 |

2. Grave essas chaves só pela CCD066: as metas pelo `PATCH /api/v1/admin/settings/goals` e os versos pelo
   `PATCH /api/v1/admin/settings/default-categories`, cada um numa transação com o `audit_logs` (ADR-034). As outras
   stories só leem.
3. Não abra leitura pública dessas chaves: a única chave pública continua `home.banner`.
4. Mantenha o seed idempotente: num banco que já existe, ele cria as chaves que faltam e não sobrescreve as que já
   estão lá.

## Alternativas consideradas

- **Colunas próprias** (as metas numa tabela do dashboard, o verso em `categories.default_back_url`): mais explícitas,
  mas mudam o DER e viram migration para valores que só a tela de Configurações edita.
- **Constantes no código:** sem tabela nem tela, mas o administrador não conseguiria mudar as metas nem os versos, o
  que contraria a L7 e a L8 da CCD066.
- **Uma chave só para as duas metas:** uma gravação a menos, mas mistura dados de duas stories (CCD096 e CCD103) que
  leem cada meta separadamente.

## Consequências

- O DER não muda: as chaves novas usam a tabela `global_settings` como o ADR-051 já previa.
- A CCD096, a CCD103 e a CCD106 leem os valores pelo serviço de configurações, sem criar as próprias chaves.
- A lista de chaves válidas fica no código (`SETTING_KEYS` e os schemas), testada. Uma chave nova entra na spec da
  própria story e em `SETTING_KEYS` e nos schemas, com teste; só pede ADR se mudar o formato do `value`, a leitura
  pública ou a auditoria.
- Quando este ADR for aceito, o status do ADR-051 passa a `Aceito; item 1 substituído parcialmente pelo ADR-061`, e a
  linha dele no índice é atualizada.

## Referências

- ADR-051 (colunas flexíveis do BackOffice), ADR-034 (trilha de auditoria)
- Spec `specs/CCD066-configuracoes-globais/` (R16–R18, L7, L8, L10, L14, L15)
- Backend: `src/domains/admin/settings/setting-schemas.ts`, `database/seeds/data/global-settings.json`
