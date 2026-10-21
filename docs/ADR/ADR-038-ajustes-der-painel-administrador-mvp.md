# ADR-038 — Ajustes no DER para o Painel Administrador do MVP

- **Status:** Aceito (validado pelo PO em 21/10/2026)
- **Data:** 2026-10-21
- **Decisores:** Lucca Rocha (PO da Sprint 06), equipe CromoCard

## Contexto

O protótipo do Painel Administrador no Figma (telas `administração - *`) tem mais
funcionalidades do que os casos de uso CCD058–CCD066 e do que o DER suporta. A
comparação levantou 21 requisitos que só existem no design. Parte deles cabe no
DER atual; outra parte exigiria tabelas novas.

O prazo também mudou: o projeto termina na **Sprint 08 (27/11/2026)**, sem sprint
de folga. A última semana fica reservada para estabilização e apresentação, o que
deixa cerca de quatro semanas de construção. O Painel Administrador entra na
Sprint 06 junto com a fundação (autenticação), então cada tabela nova pesa no
caminho crítico.

Telas do Figma que pedem dados novos:

| Tela | Dado pedido | Situação no DER |
|---|---|---|
| Gestão de usuários / adicionar usuário | telefone, nome de usuário (@), último acesso | não existe em `users` |
| Configurações — Módulo 2 (categorias) | slug, ordem de exibição | não existe em `categories` |
| Fila de solicitações — botão "Recusar" | motivo da recusa | não existe em `catalog_requests` |
| Notificações — agendamento e status | `scheduled_at`, status de envio | não existe em `global_notifications` |
| Relatórios — histórico de exportações | tabela de exportações | não existe |
| Validar cadastro de lojista | documentos, dados bancários, status de análise | não existe |
| Usuários — CPF, IP do último acesso | CPF, IP | não existe |

## Decisão

1. **Adicionar colunas, sem criar tabela nem enum novo:**

   | Tabela | Coluna | Tipo | Regra |
   |---|---|---|---|
   | `users` | `phone` | `varchar(20)` | opcional |
   | `users` | `username` | `varchar(30)` | opcional, único |
   | `users` | `last_login_at` | `timestamptz` | gravado a cada login bem-sucedido |
   | `categories` | `slug` | `varchar(100)` | obrigatório, único, gerado a partir do nome |
   | `categories` | `display_order` | `integer` | obrigatório, padrão `0` |
   | `catalog_requests` | `rejection_reason` | `varchar(255)` | preenchido quando `status = REJECTED` |

2. **Histórico de exportações sai de `audit_logs`.** Cada exportação gera um
   registro com `action = 'EXPORT_REPORT'` e os parâmetros em `details`. A tela de
   histórico lê esses registros; não há tabela `report_exports`.
3. **Notificação global é enviada na hora.** Sem agendamento: `global_notifications`
   não ganha `scheduled_at` nem status. O `created_at` é o momento do envio.
4. **Exclusão de usuário continua sendo soft delete (ADR-015).** O texto da tela
   que fala em "exclusão irreversível" deve ser trocado por "Excluir usuário (pode
   ser restaurado por um administrador)".
5. **Ficam fora do MVP:** validação de lojistas (documentos, dados bancários,
   pendência cadastral), votação da comunidade em solicitações, KPIs financeiros
   e de marketplace no dashboard, agendamento de notificações, exportação em PDF,
   fixar categoria no topo, CPF e IP do usuário. As telas continuam no Figma como
   visão de futuro.

## Alternativas consideradas

- **Implementar o Figma inteiro.** Exigiria ao menos quatro tabelas novas
  (verificação de lojista, documentos, exportações, votos) e um enum de status de
  notificação, além de depender do marketplace, que está fora do MVP (ADR-027).
  Não cabe até a Sprint 08.
- **Guardar telefone e @ em `profiles`.** `profiles` é o perfil público do
  cliente; o administrador cadastra e filtra usuários pela conta. Manter os campos
  em `users` evita um join em toda listagem do painel.
- **Guardar o CPF.** É dado pessoal sensível (LGPD) e nenhum caso de uso precisa
  dele. Descartado.
- **Tabela `report_exports`.** Duplicaria o que `audit_logs` já registra (ADR-034).

## Consequências

- O DER segue com 44 tabelas, 77 FKs e 22 enums. Os seis arquivos foram
  atualizados juntos: `03-der-completo.dbml`, `01-diagrama-entidades.dbml`,
  `schema-cromocard.sql`, `schema-cromocard-sem-enums.sql`, `03-der-completo.puml`
  e `01-diagrama-entidades.puml`. Os `.svg` continuam desatualizados.
- `users` já existe no backend: as três colunas entram numa migration própria
  (`npm run db:migrate -- --name add_admin_fields_to_users_table`). `categories` e
  `catalog_requests` nascem já com as colunas novas.
- `slug` único com soft delete: recriar uma categoria com o mesmo nome restaura a
  linha excluída (regra do ADR-015), em vez de falhar por duplicidade.
- O login (CCD004) passa a atualizar `last_login_at`.
- Se o marketplace entrar depois do MVP, a validação de lojistas precisa de um
  ADR próprio.

## Referências

- Figma: arquivo `43K7rTPJQNIOroQ4j09YTP`, telas `administração - *`
- Casos de uso: CCD058, CCD059, CCD060, CCD061, CCD063, CCD064, CCD065, CCD066
- ADR-015 (soft delete), ADR-027 (marketplace no MVP), ADR-034 (trilha de auditoria)
