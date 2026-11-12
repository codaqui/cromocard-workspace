# CCD066 — Configurações Globais

- **Status:** Planejada
- **Fase:** MVP
- **User story:** #341 `CCD066-Configurações Globais` · responsável Gabriel Nascimento · Sprint 07
- **Caso de uso:** [66-configuracoes-globais.md](../../docs/Casos-De-Uso/66-configuracoes-globais.md) (passos 6–7 e o FA com colunas e números trocados)
- **Atores:** Administrador · **Pré-condições:** autenticado com papel `ADMIN`
- **Data:** 2026-10-21 · **Autor:** Daniel Andrade
- **Aprovação:** 2026-10-22, Daniel Andrade (PO); reaprovada em 2026-11-12, depois da revisão do Figma do painel admin

## Objetivo

> Como Administrador eu quero configurar o banner da Home, categorias padrão e templates de notificações da plataforma.

## Requisitos

| ID | Requisito | Tipo | Origem |
|---|---|---|---|
| R1 | Só `ADMIN`; `401`/`403` | Permissão | `66`, Pré-condições; ADR-005, item 4 |
| R2 | Tela em `/backoffice/configuracoes`, item "Configurações" do menu | Tela | `66`, FP 1; ADR-038 |
| R3 | O sistema mostra as configurações e os valores atuais, lidos de `global_settings` | Tela | `66`, FP 2–4; DBML `global_settings` |
| R4 | Cada módulo tem "Salvar" e "Cancelar" próprios (sem botão global); o sistema valida antes de salvar | Ação | `66`, FP 2 e FP 5–7 (L6) |
| R5 | Ao salvar, grava o valor, `updated_by_id` e `updated_at` | Regra | `66`, FP 8; DBML |
| R6 | Mensagem de configurações atualizadas | Mensagem | `66`, FP 9 |
| R7 | Valor inválido é apontado e validado de novo após corrigir (`400`) | Mensagem | `66`, FA 1–4; ADR-011 |
| R8 | Cancelar descarta as alterações | Ação | `66`, FA 5–6 |
| R9 | Configurar o banner da Home | Ação | user-stories.md §8 |
| R10 | Definir as categorias padrão (`categories.is_default`) | Ação | user-stories.md §8; DBML `categories.is_default` |
| R11 | Módulo de templates de notificação: lista (nome, título e começo do texto), novo, editar (modal com nome, título até 120 e texto até 500) e excluir | Ação | `66`, FP 2 e FP 5; user-stories.md §8 |
| R16 | Módulo de metas: meta mensal de novos cadastros (CCD096) e meta de votos das sugestões de categoria (CCD103, `catalog.voting_goal`) | Campo | `66`, FP 2 (L7); `96`, FA 5–6; `103`, FP 7 |
| R17 | Verso padrão de cada franquia na linha da categoria padrão ("Trocar verso" / "Enviar verso"), em `catalog.default_backs` | Campo | `66`, FP 2 (L8); CCD106 R9 |
| R12 | A imagem do banner vai pelo `StorageProvider` | Regra | ADR-009 |
| R13 | Só categorias não excluídas aparecem | Regra | ADR-015, item 5 |
| R14 | Alterar configuração grava `audit_logs` | Regra | ADR-034 |
| R15 | Leitura pública do banner em `GET /api/v1/settings/public/home.banner`, sem autenticação | Regra | `66`, FP 8; ADR-051, item 1 |

## Critérios de aceite

- **CA1** (R3, R9) — **Dado** o banner configurado, **quando** abre Configurações, **então** vê a pré-visualização e
  os campos título, subtítulo, texto do botão, link, imagem e "exibir banner".
- **CA2** (R4–R6, R12, R14) — **Dado** o formulário do banner, **quando** altera o título, troca a imagem e confirma,
  **então** a API grava, registra quem alterou e o log, e a tela confirma.
- **CA3** (R7) — **Dado** um link inválido, **quando** salva, **então** a API responde `400` e a tela aponta o campo.
- **CA4** (R10, R13) — **Dado** as categorias, **quando** marca duas como padrão e salva, **então** `is_default` muda
  só nelas.
- **CA5** (R8) — **Dado** alterações não salvas, **quando** cancela, **então** os valores anteriores voltam.
- **CA6** (R1) — **Dado** um token de `CUSTOMER`, **quando** chama a rota de escrita, **então** recebe `403`.

## Dados

| Tabela | Colunas usadas | Observação |
|---|---|---|
| `global_settings` | `key`, `value` (JSON serializado), `description`, `updated_by_id` | fundação; chaves criadas pelo seed |
| `categories` | `is_default`, `deleted_at` | fundação; CRUD é da CCD061 |

## Telas (Figma)

Conferidas em 12/11/2026, depois do ajuste do Figma à documentação. Links: `https://www.figma.com/proto/43K7rTPJQNIOroQ4j09YTP/CromoCard?node-id=<frame>`.

| Tela | Frame | Requisitos | Veredito |
|---|---|---|---|
| Configurações Globais (4 módulos) | `228-3048` | R3, R4, R9–R11, R16, R17 | ✅ Bate |
| Link do banner inválido | `859-661` | R7 | ✅ Bate |
| Banner atualizado | `859-1068` | R6 | ✅ Bate |
| Editar template | `859-1479` | R11 | ✅ Bate |

- A ordem, o "Fixado no topo" e o selo das categorias são da CCD104.

## Fora do escopo

- Exibir o banner na Home — CCD001 (esta story deixa a leitura pública pronta, ver L3).
- Criar categoria — CCD061 (o módulo 2 tem o link "Gerenciar categorias no Catálogo").

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
