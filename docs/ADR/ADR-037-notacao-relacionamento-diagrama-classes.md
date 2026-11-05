# ADR-037 — Notação de relacionamento no diagrama de classes (rótulo textual)

- **Status:** Aceito (validado pelo PO em 29/10/2026; a rejeição da revisão de 01/10 foi revista e a notação LikeC4 com rótulo textual foi mantida)
- **Data:** 2026-09-29
- **Decisores:** Equipe CromoCard

## Contexto

O diagrama de classes é feito em [LikeC4](https://likec4.dev) (a equipe chama de "C4
Playground"), uma ferramenta pensada para diagramas C4 (Contexto/Container/Componente), não para
UML de classes. Ela não tem seta nativa de herança (triângulo vazado), composição (losango
preenchido) ou agregação (losango vazado) — só a relação genérica `origem -> destino "rótulo"`.
Isso é a provável razão de a primeira versão do diagrama (`blank.c4`) não ter nenhuma relação: sem
uma notação óbvia disponível na ferramenta, as relações foram simplesmente omitidas.

## Decisão

Representar todas as relações do diagrama de classes com a seta genérica do LikeC4 e um **rótulo
textual padronizado**, no formato `<multiplicidade origem> -- <multiplicidade destino> : <papel>`,
com casos especiais:

- Herança: rótulo fixo `"herda de (generalização)"`, seta da subclasse para a superclasse.
- Composição: sufixo `": compõe"` (ex.: `FotoCarta -> Carta "N -- 1 : compõe"`).
- Alvo polimórfico: sufixo `": alvo (conforme tipo)"` nas várias relações opcionais que saem de
  `Favorito` e `Denuncia`.

A legenda completa está em `docs/Diagrama-de-Classe/README.md`.

## Alternativas consideradas

- **Definir `relationship` customizado no LikeC4** (`specification { relationship heranca { ... } }`)
  com estilo de linha/seta próprio — daria uma seta visualmente diferente para herança/composição,
  mas depende de propriedades de estilo (`head`, `line`, `color`) cujo conjunto de valores válidos
  não foi confirmado nesta análise; um valor inválido quebraria a renderização no Playground,
  gerando exatamente o retrabalho que esta refatoração busca evitar.
- **Trocar de ferramenta** (ex.: PlantUML com notação UML de classes nativa, como já é usado para
  o DER) — padronizaria a notação com o resto do projeto, mas descarta o trabalho já feito no
  LikeC4 e exigiria reaprender uma sintaxe nova; ficou fora do escopo desta rodada de refatoração.

## Consequências

**Positivas**
- Sintaxe mínima e comprovadamente válida no LikeC4 (a mesma usada nas relações `Rel(...)` que
  a equipe já não usa aqui, mas o `->` genérico é o recurso mais básico da linguagem).
- Rótulo textual é imediatamente legível mesmo por quem não conhece UML formalmente — adequado
  para uma apresentação de banca.

**Negativas / riscos**
- Não é notação UML "de verdade" — se o professor/PO exigir os símbolos gráficos padrão
  (triângulo, losango), será necessário revisitar a alternativa de `relationship` customizado ou
  trocar de ferramenta.
- Rótulos textuais longos podem poluir diagramas com muitas relações concentradas em um nó
  (ex.: `Usuario`, que recebe dezenas de relações) — mitigado por dividir em views por módulo
  (ver ADR-036).

## Referências

- `docs/Diagrama-de-Classe/cromocard-diagrama-classes.c4`
- `docs/Diagrama-de-Classe/README.md` (seção "Legenda de relacionamento")
