# ADR-074 — Preferências de aviso por evento

- **Status:** Proposto (aguardando validação do PO)
- **Data:** 2026-11-28
- **Decisores:** Daniel Andrade, na especificação da CCD053 (Visualizar Notificações)
- **Complementa:** ADR-051 (item 2: tipos de notificação) e ADR-058 (canais: site e e-mail, sem push)

## Contexto

O EA-053-01 pede que o cliente escolha, por tipo de aviso, se recebe no site e por e-mail. O frame `1160-41305`
(Configurações) desenha duas chaves gerais, "In-App (Central & Sino)" e "E-mail", e seis eventos em três grupos, com
"Restaurar Padrões" e "Salvar Preferências". O DER não tem onde gravar essa escolha, e nenhuma regra diz quem a respeita
quando uma notificação é criada.

## Decisão

1. **Tabela `notification_preferences`**, uma linha por usuário e evento (`user_id`, `event`, `in_app`, `email`), com
   índice único em (`user_id`, `event`). O enum `notification_event` tem os seis eventos do Figma (`ORDER_UPDATES`,
   `PAYOUT_RELEASED`, `GROUP_INVITES`, `DIRECT_MESSAGES`, `CATALOG_RELEASES`, `CATALOG_REQUESTS`) e `ALL`, que guarda as
   duas chaves gerais.
2. **Sem linha, tudo ligado.** O padrão é receber nos dois canais; "Restaurar Padrões" apaga as escolhas do usuário
   (soft delete das linhas).
3. **Cada tipo de notificação aponta para um evento** no enum de tipos do domínio `notifications` (ADR-051, item 2):
   `NEW_MESSAGE` → `DIRECT_MESSAGES`, `CATALOG_REQUEST` → `CATALOG_REQUESTS`; os tipos de pedido, repasse, convite e
   lançamento de álbum entram com as stories que os criam. `GLOBAL`, `SELLER_PENDING` e `SELLER_REVIEW` não têm evento:
   são avisos da plataforma e da conta, e só a chave geral os desliga.
4. **O `notify()` respeita o site.** Com o canal do site desligado (no evento ou na chave geral), a notificação não é
   gravada nem emitida pelo Socket.IO. O e-mail continua com a story que manda e-mail, que lê a mesma preferência antes
   de enviar.

## Alternativas consideradas

- **Colunas em `profiles`**: doze colunas booleanas numa tabela de outro módulo, e cada evento novo pediria migration.
- **`jsonb` em `users`**: sem validação no banco e sem como consultar quem desligou um evento.
- **Os cinco tipos do EA-053-01**: a tela ficaria diferente do frame, que é o contrato visual (ADR-060).

## Consequências

- O DER fica com 49 tabelas, 86 FKs e 27 enums, nos três formatos e no diagrama de classes.
- Toda story que cria um tipo novo de notificação diz a qual evento ele pertence.
- A tela Configurações passa a existir com os blocos de aviso (CCD053); a CCD051 e a CCD052 acrescentam o resto.

## Referências

- `docs/Casos-De-Uso/escopo-adicional.md` (EA-053-01) · `docs/Casos-De-Uso/53-visualizar-notificacoes.md`
- `specs/CCD053-visualizar-notificacoes/spec.md` (L10)
- Figma `1160-41305`
