# CCD066 — Configurações Globais

- **Status:** Em implementação
- **Fase:** MVP
- **User story:** #341 `CCD066-Configurações Globais` · responsável Gabriel Nascimento · Sprint 07
- **Caso de uso:** [66-configuracoes-globais.md](../../docs/Casos-De-Uso/66-configuracoes-globais.md) (passos 6–7 e o FA com colunas e números trocados)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade · revisada em 2026-11-15 por Gabriel Nascimento (L9–L19) e em 2026-11-16, na análise do Figma para o frontend (L20–L23)
- **Aprovação:** 2026-10-22, Daniel Andrade (PO); reaprovada em 2026-11-12, depois da revisão do Figma do painel admin; reaprovada em 2026-11-15 com as decisões L9–L19, Gabriel Nascimento (o Daniel confirma no PR do workspace); reaprovada em 2026-11-16 com as decisões L20–L23, Gabriel Nascimento

## Objetivo

> Como Administrador eu quero configurar o banner da Home, categorias padrão e templates de notificações da plataforma.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401`/`403` | Permissão | `66`, Pré-condições; ADR-005, item 4 |
| R2 | Tela em `/backoffice/configuracoes`, item "Configurações" do menu | Tela | `66`, FP 1; ADR-038 |
| R3 | O sistema mostra as configurações e os valores atuais, lidos de `global_settings` | Tela | `66`, FP 2–4; DBML `global_settings` |
| R4 | Cada módulo tem "Salvar" e "Cancelar" próprios (sem botão global), exceto o de templates, em que cada template é salvo no próprio formulário e excluído pela lista; o sistema valida antes de salvar | Ação | `66`, FP 2 e FP 5–7 (L6, L16) |
| R5 | Ao salvar, grava o valor, `updated_by_id` e `updated_at` | Regra | `66`, FP 8; DBML |
| R6 | Mensagem de configurações atualizadas, uma por módulo, no formato do aviso "Banner atualizado" | Mensagem | `66`, FP 9 (L23) |
| R7 | Valor inválido é apontado e validado de novo após corrigir (`400` com o campo em `details`); o link do botão do banner começa com `https://` | Mensagem | `66`, FP 6, FA 1–4 (L12); ADR-011 |
| R8 | Cancelar descarta as alterações | Ação | `66`, FA 5–6 |
| R9 | Configurar o banner da Home | Ação | user-stories.md §8 |
| R10 | Definir as categorias padrão (`categories.is_default`): pode ser padrão qualquer categoria raiz (sem pai) não excluída; salvar o módulo troca o conjunto inteiro, e as que ficam de fora voltam a `false` | Ação | user-stories.md §8; `66`, FP 2; DBML `categories.is_default` (L9, L14) |
| R11 | Módulo de templates de notificação: lista (nome, título e começo do texto), novo, editar (modal com nome, título até 120 e texto até 500) e excluir com confirmação; cada template tem um `id` e o nome não se repete | Ação | `66`, FP 2, FP 5–6, FA 7–8; user-stories.md §8 (L16) |
| R16 | Módulo de metas: meta mensal de novos cadastros (`dashboard.monthly_signup_goal`, inteiro a partir de 1 ou vazio para "sem meta") e meta de votos das sugestões de categoria (`catalog.voting_goal`, inteiro a partir de 1, obrigatória), gravadas juntas | Campo | `66`, FP 2 e FP 6 (L7, L15); `96`, FA 3–6; `103`, FP 7 |
| R17 | Verso padrão de cada franquia na linha da categoria padrão ("Trocar verso" / "Enviar verso"), em `catalog.default_backs` (mapa do id da categoria para a URL da imagem), gravado junto com as categorias padrão | Campo | `66`, FP 2 (L8, L14); CCD106 L2 |
| R12 | As imagens do banner e dos versos vão pelo `StorageProvider` (`/uploads`), e o valor guarda a URL; o banner sobe na pasta `banners` e o verso padrão na pasta `cards` | Regra | ADR-009 (L22) |
| R13 | Só categorias não excluídas aparecem e podem ser padrão | Regra | ADR-015, item 5 |
| R14 | Alterar configuração grava `audit_logs` com os valores antes e depois: `SETTING_UPDATED` (banner, templates e metas) e `DEFAULT_CATEGORIES_UPDATED` (categorias padrão e versos), `entity_type` `SETTING` | Regra | `66`, FP 8; ADR-034; ADR-051, itens 4–5 (L13) |
| R15 | Leitura pública do banner em `GET /api/v1/settings/public/home.banner`, sem autenticação: devolve o banner mesmo desligado (`enabled: false`), e outra chave responde `404` | Regra | `66`, FP 8; ADR-051, item 1 (L17) |
| R18 | O seed cria as chaves `dashboard.monthly_signup_goal` (4000), `catalog.voting_goal` (200) e `catalog.default_backs` (vazio), e grava o link do banner com `https://` | Regra | `66`, FP 2 (L7, L8, L10, L12); ADR-051, item 1 |
| R19 | O título e o texto dos templates aceitam `{campo}` como texto comum, sem validação própria | Regra | `66`, FP 5 (L18) |
| R20 | A imagem do banner é WEBP ou PNG de até 4 MB, com 1920×600 como tamanho recomendado (não bloqueia outra dimensão) | Regra | `66`, FP 6 (L21) |

## Critérios de aceite

- **CA1** (R3, R9) — **Dado** o banner configurado, **quando** abre Configurações, **então** vê a pré-visualização e
  os campos título, subtítulo, texto do botão, link, imagem e "exibir banner".
- **CA2** (R4–R6, R12, R14) — **Dado** o formulário do banner, **quando** altera o título, troca a imagem e confirma,
  **então** a API grava, registra quem alterou e o log com o antes e o depois, e a tela confirma.
- **CA3** (R7) — **Dado** um link inválido ou sem `https://`, **quando** salva, **então** a API responde `400` e a tela
  aponta o campo.
- **CA4** (R10, R13) — **Dado** as categorias, **quando** deixa duas como padrão e salva, **então** `is_default` fica
  `true` só nelas, e uma categoria excluída ou com pai é recusada.
- **CA5** (R8) — **Dado** alterações não salvas, **quando** cancela, **então** os valores anteriores voltam.
- **CA6** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama a rota de escrita, **então** recebe `403`.
- **CA7** (R11, R19) — **Dado** a lista de templates, **quando** cria um com `{álbum}` no título, **então** ele é gravado
  com um `id`; **quando** cria outro com o mesmo nome, **então** a API responde `400` no nome.
- **CA8** (R15) — **Dado** o banner desligado, **quando** a Home chama a leitura pública sem token, **então** recebe
  `200` com `enabled: false`; outra chave responde `404`.
- **CA9** (R16) — **Dado** o módulo de metas, **quando** deixa a meta mensal vazia e salva, **então** ela fica sem meta;
  **quando** deixa a meta de votos vazia, **então** a API responde `400` e nada é gravado.
- **CA10** (R10, R17) — **Dado** uma categoria padrão sem verso, **quando** envia o verso e salva o módulo, **então**
  `is_default` e `catalog.default_backs` são gravados juntos.
- **CA11** (R11) — **Dado** a lista de templates, **quando** clica em "Excluir", **então** a tela pede confirmação e só
  remove o template depois de confirmar.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `global_settings` | `key`, `value` (JSON serializado), `description`, `updated_by_id` | fundação; chaves criadas pelo seed (R18) |
| `categories` | `is_default`, `parent_category_id`, `deleted_at` | fundação; CRUD é da CCD061 |
| `audit_logs` | `admin_id`, `action`, `entity_type`, `entity_id`, `details` | fundação (ADR-034) |

## Telas (Figma)

Conferidas em 16/11/2026, sem mudança desde 15/11. Links: `https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=<frame>`.

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Configurações Globais (4 módulos) | `228-3048` | R3, R4, R9–R11, R16, R17, R20 | ✅ Bate, com as diferenças decididas na L9 e na L20 |
| Link do banner inválido | `859-661` | R7 | ✅ Bate |
| Banner atualizado | `859-1068` | R6 | ✅ Bate |
| Editar template | `859-1479` | R11, R19 | ✅ Bate |

- A ordem, o "Fixado no topo" e o selo das categorias são da CCD104.
- Diferença decidida (L9): o módulo 2 ganha "Adicionar categoria padrão" e remover na linha, no estilo do módulo, porque
  o frame não desenhou como marcar uma categoria como padrão.
- Diferença decidida (L20): a linha da categoria padrão mostra o nome, o verso e remover. A posição, a alça de arrastar,
  as setas, os selos ("Fixado no topo", "Em alta", "Padrão"), o slug e a quantidade de cartas ficam para a CCD104, e o
  botão "Salvar ordem" se chama "Salvar categorias" até lá.
- Sem frame (L23): a confirmação de excluir template usa o `ConfirmDialog`; "Novo template" usa o modal do `859-1479`;
  os avisos dos módulos 2 a 4 e o erro geral seguem o formato do `859-1068`.

## Fora do escopo

- Exibir o banner na Home — CCD001 (esta story deixa a leitura pública pronta, ver L3).
- Criar categoria — CCD061 (o módulo 2 tem o link "Gerenciar categorias no Catálogo").
- Trocar os `{campos}` dos templates pelo texto da pessoa — CCD060 (L18).
- Templates de pendência cadastral de vendedor (`seller.pending_templates`) — CCD095 (L19).
- Posição, arrastar, setas, selos, slug e quantidade de cartas das categorias padrão — CCD104 (L20).

## Lacunas e decisões

| ID | Pergunta | Decisão | Onde foi registrada |
|---|---|---|---|
| L1 | Chaves e formato (proposta: chaves `home.banner` e `notification.templates`, criadas pelo seed, com `value` em JSON validado por chave) | Chaves `home.banner` e `notification.templates`, criadas pelo seed, com `value` em JSON validado por chave | ADR-051, item 1 |
| L2 | O que é template de notificação? (proposta: modelos de título e conteúdo que a tela da CCD060 oferece para preencher; não existem no Figma, Gabriel desenha) | Modelos de título e conteúdo que a tela da CCD060 oferece para preencher; desenhados na revisão de 12/11/2026 (módulo 3 e `859-1479`) | `66`, FP 5 |
| L3 | Leitura pública do banner (proposta: `GET /api/v1/settings/public/home.banner` sem autenticação, para a CCD001) | `GET /api/v1/settings/public/home.banner`, sem autenticação, para a CCD001 | `66`, FP 8; ADR-051, item 1 |
| L4 | Ordenar categorias padrão (proposta: fora do MVP, porque exige coluna nova no DER) | Fora do MVP; virou a CCD104 (escopo adicional) | CCD104 |
| L5 | Corrigir o caso de uso 66 (colunas dos passos 6–7 e numeração do FA) | Corrigido: colunas dos passos 6–7 e numeração do FA | `66` |
| L6 | Salvar global ou por módulo? | Por módulo, com Salvar e Cancelar em cada um, porque cada módulo grava uma chave diferente. Decisão do PO (Daniel, 12/11/2026), na revisão do Figma | `66`, FP 2 |
| L7 | Onde ficam as metas da CCD096 e da CCD103? | Módulo 4, "Metas": meta mensal de novos cadastros (4.000) e meta de votos das sugestões (200). Decisão do PO (Daniel, 12/11/2026) | `66`, FP 2 |
| L8 | Onde se define o verso padrão de cada franquia (CCD106)? | Na linha da categoria, no módulo 2. Decisão do PO (Daniel, 12/11/2026) | `66`, FP 2 |
| L9 | O frame `228-3048` não mostra como marcar ou desmarcar uma categoria como padrão (R10, CA4) | Mantém o R10: o módulo 2 ganha "Adicionar categoria padrão" e remover na linha, no estilo do módulo. Decisão de Gabriel Nascimento, 15/11/2026 | `66`, FP 2; **Telas** |
| L10 | R16 e R17 entram agora, mesmo com as stories que leem os valores (CCD096, CCD103, CCD106) ainda por fazer? | Sim: o seed cria as três chaves com schema próprio, e as outras stories só leem. Decisão de Gabriel Nascimento, 15/11/2026 | R18 |
| L11 | `PATCH` ou `PUT` em `/admin/settings/:key` (o plano tinha os dois) | `PATCH`, como manda o ADR-011, trocando o `value` inteiro e devolvendo o recurso atualizado. Decisão de Gabriel Nascimento, 15/11/2026 | ADR-011; `plano.md` |
| L12 | Que link o banner aceita? (o frame `859-661` diz "começando com https://") | Só `https://`, como no Figma; o seed passa a gravar um link `https`. Decisão de Gabriel Nascimento, 15/11/2026 | `66`, FP 6 |
| L13 | Códigos de `audit_logs.action` das configurações | `SETTING_UPDATED` e `DEFAULT_CATEGORIES_UPDATED`, com `entity_type` `SETTING` e os valores antes e depois em `details`. Decisão de Gabriel Nascimento, 15/11/2026 | `66`, FP 8; ADR-051, itens 4–5 |
| L14 | Como gravar o módulo 2 (`is_default` e `catalog.default_backs`)? | Uma chamada por módulo, numa transação: troca o conjunto inteiro de categorias padrão e grava os versos. Só categorias raiz não excluídas. Decisão de Gabriel Nascimento, 15/11/2026 | `66`, FP 2; `plano.md` |
| L15 | Como gravar o módulo 4 e a meta "não configurada" (`96`, FA 3–4)? | Uma chamada, numa transação; a meta mensal vazia vira "sem meta" (`null`), a meta de votos é obrigatória. Decisão de Gabriel Nascimento, 15/11/2026 | `66`, FP 6 |
| L16 | O módulo de templates não tem Salvar e Cancelar no Figma; a lista não tinha `id` | Segue o Figma: o modal salva e a lista exclui na hora (com confirmação); cada template ganha um `id` e o nome não se repete. Decisão de Gabriel Nascimento, 15/11/2026 | `66`, FP 2, FP 6, FA 7–8 |
| L17 | O que a leitura pública devolve com o banner desligado? | `200` com o banner e `enabled: false`; a Home decide não exibir. Outra chave responde `404`. Decisão de Gabriel Nascimento, 15/11/2026 | `66`, FP 8 |
| L18 | O frame `859-1479` mostra `{campo}` nos templates, que a documentação não citava | Faz sentido: a CCD066 aceita `{campo}` como texto comum, e trocar os campos fica para a CCD060. Decisão de Gabriel Nascimento, 15/11/2026 | `66`, FP 5 |
| L19 | Os templates da CCD095 (`seller.pending_templates`) aparecem no módulo 3? | Não: ficam na CCD095, e o módulo 3 só edita `notification.templates`, como no frame. Decisão de Gabriel Nascimento, 15/11/2026 | **Fora do escopo** |
| L20 | O frame `228-3048` mostra no módulo 2 posição, arrastar, setas, selos, slug, quantidade de cartas e "Salvar ordem", que são da CCD104 (ainda Planejada) e que a API desta story não devolve | A CCD066 mostra só o que tem: nome, verso e remover; o resto entra com a CCD104, e o botão se chama "Salvar categorias" até lá, para não haver controle sem função. Decisão de Gabriel Nascimento, 16/11/2026 | **Telas**; **Fora do escopo** |
| L21 | O frame `228-3048` diz "Formatos WEBP, PNG (Máx 4MB • 1920×600)" e o `/uploads` aceita PNG, JPG ou WEBP | Segue o Figma: o banner aceita WEBP e PNG até 4 MB, e 1920×600 é só o tamanho recomendado. Decisão de Gabriel Nascimento, 16/11/2026 | `66`, FP 6; R20 |
| L22 | Em qual pasta do `/uploads` vai o verso padrão? (só existem `cards`, `albums` e `banners`) | Pasta `cards`, como os versos das cartas da CCD061, sem mudar o backend. Decisão de Gabriel Nascimento, 16/11/2026 | R12; `plano.md` |
| L23 | Estados sem frame: confirmação de excluir template, "Novo template", avisos dos módulos 2 a 4, erro geral e carregando | No estilo da tela: `ConfirmDialog`, o modal do `859-1479` com o título "Novo template" e avisos no formato do "Banner atualizado". Decisão de Gabriel Nascimento, 16/11/2026 | R6; **Telas**; CA11 |
