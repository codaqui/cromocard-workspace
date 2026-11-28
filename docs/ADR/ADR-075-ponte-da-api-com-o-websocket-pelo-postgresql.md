# ADR-075 — Ponte da API com o WebSocket pelo PostgreSQL

- **Status:** Proposto (aguardando validação do PO)
- **Data:** 2026-11-28
- **Decisores:** Daniel Andrade, na especificação da CCD053 (Visualizar Notificações)
- **Complementa:** ADR-012 (Socket.IO) e ADR-055 (contêineres `api` e `ws`)

## Contexto

A API HTTP (`api`, `src/server.ts`) e o servidor Socket.IO (`ws`, `src/ws-server.ts`) rodam em contêineres separados
(ADR-055). As notificações do disparo global (CCD060), das solicitações ao catálogo e do cadastro de vendedor são
gravadas no processo da `api`, mas só o `ws` tem as conexões dos navegadores. A CCD053 pede que toda notificação nova
chegue em tempo real (`notification:new` na room `user:<id>`, ADR-012). Os ADRs 007 e 012 previam um adapter do Redis
só para ter mais de uma instância do `ws`.

## Decisão

1. **Adapter do PostgreSQL.** O `ws` usa `@socket.io/postgres-adapter` e a `api` usa `@socket.io/postgres-emitter`.
   Os dois falam pelo `LISTEN/NOTIFY` do PostgreSQL que o projeto já tem, no canal `socket.io`.
2. **A `api` emite pela room.** Um `NotificationPublisher` no domínio `notifications` recebe o emitter por injeção e
   emite `notification:new` nas rooms `user:<id>` depois de gravar (persistência primeiro, ADR-012). No `ws`, o mesmo
   publisher usa o próprio `io`.
3. **Tabela técnica `socket_io_attachments`** (`id bigserial`, `created_at`, `payload bytea`), criada por migration e
   declarada no `schema.prisma` com `@@ignore`. O adapter guarda nela só os eventos acima de 8 KB e apaga as linhas
   antigas a cada 30 s. Ela não é dado de negócio: fica fora do DER, como a `_prisma_migrations`, e é exceção ao soft
   delete (ADR-015) e ao UUID v7 (ADR-014).
4. **Falha não derruba a gravação.** Se o emitter falhar, a notificação continua gravada e aparece ao abrir a central;
   o erro vai para o log.

## Alternativas consideradas

- **Redis com `@socket.io/redis-adapter`:** é o caminho mais comum, mas exige um contêiner novo em homologação e
  produção, com volume, senha e runbook, só para isso.
- **O `ws` consultar o banco a cada poucos segundos:** sem dependência nova, mas com atraso e consulta constante.
- **Só emitir o que nasce no `ws`:** o disparo global e os avisos do catálogo ficariam sem tempo real.

## Consequências

- O `ws` pode ter mais de uma instância sem mudança, porque o adapter já sincroniza as rooms.
- O pool do `pg` usado pelo adapter conta nas conexões do PostgreSQL: uma conexão fixa para o `LISTEN` no `ws` e as do
  emitter na `api`.
- Testes de integração do tempo real rodam com o adapter contra o PostgreSQL de teste.

## Referências

- `specs/CCD053-visualizar-notificacoes/spec.md` (L16) · ADR-007 · ADR-012 · ADR-055
- https://socket.io/docs/v4/postgres-adapter/
