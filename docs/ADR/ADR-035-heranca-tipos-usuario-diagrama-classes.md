# ADR-035 — Herança de tipos de usuário no diagrama de classes (Single Table Inheritance)

- **Status:** Aceito (validado pelo PO em 29/10/2026, na revisão da issue #2)
- **Data:** 2026-09-29
- **Decisores:** Equipe CromoCard

## Contexto

O DER modela usuários em **uma única tabela** `usuario`, com a coluna `tipo_usuario` (enum:
`CLIENTE`, `VENDEDOR`, `ADMINISTRADOR`) como discriminador — não existem tabelas `cliente`,
`vendedor` ou `administrador` separadas. Já os Casos de Uso e o C4 tratam Cliente, Vendedor e
Administrador como atores com comportamentos claramente distintos (ex.: só Vendedor cria anúncio;
só Administrador aprova solicitações e dispara notificação global).

A primeira versão do diagrama de classes (`blank.c4`) já esboçava `Usuário`, `Cliente`,
`Administrador` e `Vendedor` como classes separadas, mas sem declarar a relação de herança entre
elas — ficavam quatro classes soltas, sem deixar claro se era herança, composição ou coincidência
de nome.

## Decisão

Modelar `Cliente`, `Vendedor` e `Administrador` como subclasses de `Usuario` no diagrama de
classes (herança/generalização), mesmo a persistência sendo uma única tabela com discriminador —
um mapeamento conhecido como **Single Table Inheritance**. Relações de outras classes que, no
DER, apontam para `usuario.id` continuam apontando para a classe genérica `Usuario` no diagrama,
**exceto** quando a regra de negócio restringe claramente o papel (ex.: `Anuncio.vendedor` e
`Pedido.vendedor` apontam para `Vendedor`; `LogAuditoria.admin` e `NotificacaoGlobal.admin`
apontam para `Administrador`).

## Alternativas consideradas

- **Sem herança**: uma única classe `Usuario` com um atributo `tipo` e todos os métodos juntos
  (dos três papéis) — mais fiel à tabela única do DER, mas mistura métodos que nunca coexistem na
  mesma instância (um Cliente nunca chama `aprovarSolicitacaoCadastro()`).
- **Class Table Inheritance**: uma tabela por subtipo (`cliente`, `vendedor`, `administrador`)
  ligada a `usuario` por FK 1:1 — mudaria o DER já validado, fora de escopo desta ADR.
- **Composição por papel** (`Usuario` tem uma lista de "papéis") — mais flexível para usuários que
  acumulam papéis, mas o DER usa um único enum exclusivo por usuário, então essa flexibilidade não
  reflete a regra atual.

## Consequências

**Positivas**
- O diagrama expressa o comportamento específico de cada papel sem alterar o DER já validado.
- Deixa explícito, via tipo, uma regra de negócio que a tabela única não mostra (só Vendedor pode
  ter um Anúncio, por exemplo).

**Negativas / riscos**
- Divergência de forma entre DER (tabela única) e diagrama de classes (três subclasses) precisa
  estar documentada (este ADR) para não parecer inconsistência na banca.
- Ao implementar (Prisma/Node), a herança do diagrama de classes deve virar validação na camada de
  aplicação (ex.: `tipo_usuario === 'VENDEDOR'` antes de permitir criar anúncio), já que o banco
  não impõe isso via schema.

## Referências

- `docs/Diagrama-de-Classe/cromocard-diagrama-classes.v2.c4` (Cliente, Vendedor e Administrador herdam de Usuário)
- `docs/Diagramas/DER/dbdiagram.io/03-der-completo.dbml` (tabela `users`, enum `user_role`)
- `Apresentacao-Banca/plano-apresentacao-banca.md` (item 7 — padronização de atores)
