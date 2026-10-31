# Diagrama de Classes — CromoCard

Modelo de classes (orientado a objetos) derivado do **DER** (`docs/Diagramas/DER/`) e dos
**Casos de Uso** (`docs/Casos-De-Uso/`). Ferramenta: [LikeC4](https://likec4.dev) ("C4
Playground") — cole `cromocard-diagrama-classes.v2.c4` em <https://likec4.dev/playground>.

**49 classes + 27 enumerações**, organizadas nos mesmos 8 módulos do DER, para manter
rastreabilidade 1:1 entre modelo de dados e modelo de classes. Além delas, `Cliente`, `Vendedor` e
`Administrador` especializam `Usuário` (ADR-035), somando 52 elementos `class` no arquivo.

Os identificadores são UUID v7 (ADR-014). As colunas de tempo `created_at`, `updated_at` e `deleted_at`
existem em toda tabela (ADR-015 e ADR-016) e só aparecem nas classes quando têm significado de negócio
(ex.: `dataCriacao`, `dataCadastro`).

## Versões nesta pasta

| Arquivo | O que é |
|---|---|
| `historico/cromocard-diagrama-classes.v1.c4` | Versão original do time (16 classes, sem relações) — mantida só como histórico. **Não usar.** |
| `cromocard-diagrama-classes.v2.c4` | Versão atual, corrigida e completa — é esta que deve ser aberta no Playground e apresentada. |

Cada versão é um projeto LikeC4 próprio (`likec4.config.json`), para que os dois arquivos, que usam os mesmos
nomes de elementos, não se misturem. Para validar a versão atual com o layout:
`npx likec4 validate -p diagrama-classes docs/`.

Os autorrelacionamentos (categoria pai, mensagem que responde a outra) ficam nas `observacoes` de `Categoria`,
`MensagemGrupo` e `Mensagem`, porque o LikeC4 não desenha a relação de um elemento com ele mesmo.

## Por que foi refeito

A v1 (histórico) tinha três problemas que geravam retrabalho:

1. **Cobertura parcial:** só 16 classes, quase só a fatia do Marketplace. Faltavam Usuários/Perfil,
   Catálogo, Coleção, Comunidade, Chat Pessoal, Notificações e Moderação/Administração inteiros.
2. **Sem nenhuma relação entre classes** — nem herança, nem associação. Um diagrama de classes sem
   relações não comunica a estrutura do domínio, só uma lista de campos.
3. **Divergências do DER:** `Vendedor` tinha um atributo `reputacao` que não existe em nenhuma
   tabela do banco; `Pedido`/`ItemPedido` modelavam um carrinho multi-item, mas no DER cada
   pedido (`orders`) referencia um único anúncio (`listings`); não existe item de pedido.

Este arquivo corrige os três pontos. As decisões de modelagem tomadas na correção (herança de
tipos de usuário, granularidade 1:1 com o DER, notação de relacionamento) estão documentadas como
ADR — ver `docs/ADR/ADR-035-*.md` a `ADR-037-*.md`.

## Estrutura das views

| View | Conteúdo |
|---|---|
| `heranca_usuarios` | Só a hierarquia Usuário → Cliente/Vendedor/Administrador — destaque da decisão da ADR-035 |
| `modulo1` a `modulo8` | Uma view por módulo do DER, com as classes do módulo + as classes de outros módulos que ele referencia (para a relação fazer sentido isolada) |
| `visao_geral_completa` | Todas as 79 classes e enumerações juntas (52 classes + 27 enumerações) — **só para conferência**, não para apresentar. Use as views por módulo na banca, do mesmo jeito que o DER usa 01/02/03 separados em vez de um único diagrama gigante. |

## Legenda de relacionamento

O LikeC4 não tem notação UML nativa de classe (sem seta de herança/composição/agregação prontas),
então as relações usam um rótulo textual, no padrão `<multiplicidade origem> -- <multiplicidade
destino> : <papel>`:

| Rótulo | Significado |
|---|---|
| `herda de (generalização)` | Herança/generalização — a seta vai da subclasse para a superclasse |
| `1 -- 1` | Associação um-para-um |
| `N -- 1` | Associação muitos-para-um (a leitura inversa é `1 -- N`) |
| `0..1 -- N` | Um lado opcional (0 ou 1) associado a muitos |
| `: compõe` | Composição — o lado sem esse rótulo não existe sem o outro (ex.: `FotoCarta` não existe sem `Carta`) |
| `: alvo (conforme tipo)` | Alvo polimórfico (ver `Favorito` e `Denuncia`) — só uma das relações listadas é preenchida por instância, conforme a coluna discriminadora (`tipo` / `tipoAlvo`) |

## Herança de tipos de usuário

`Usuario` é a superclasse; `Cliente`, `Vendedor` e `Administrador` a especializam. No banco
(DER) isso é **uma única tabela** `users` com a coluna `role` (enum `user_role`) como discriminador
— um padrão de mapeamento conhecido como *Single Table Inheritance*. O diagrama de classes mantém
a herança porque o **comportamento** de cada papel é bem diferente (métodos exclusivos de
Vendedor e Administrador), mesmo a persistência sendo uma tabela só. Ver ADR-035 para o racional
completo e para quando cada relação do diagrama aponta para `Usuario` (genérico) versus para
`Vendedor`/`Administrador` (papel específico).

## Rastreabilidade

Todas as 49 classes correspondem 1:1 às tabelas do DER (o `refresh_tokens` não tem classe) — a mesma tabela de rastreabilidade
classe → caso de uso já existente em `docs/Diagramas/DER/README.md` (seção "Rastreabilidade") vale
também para este diagrama, bastando trocar `snake_case` da tabela pelo nome da classe em
PascalCase em português, com o glossário PT → EN do `README.md` do DER (ex.: `collection_cards` →
`ColecaoCarta`).
