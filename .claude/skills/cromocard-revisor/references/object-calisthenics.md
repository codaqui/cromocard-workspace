# Object Calisthenics no CromoCard

Usado pela `/cromocard-desenvolver` (ao escrever) e pela `/cromocard-revisor` (ao revisar). São as nove regras de Jeff Bay,
adaptadas a TypeScript e React. Os exemplos com `arquivo:linha` são do código real, levantados em 2026-11-09 da `develop`
do backend e da `feature/layouts-figma` do frontend. O que está marcado como **ilustrativo** não existe no projeto.

As regras 1, 2 e 7 têm apoio do ESLint: não repita na revisão o que o lint já barra. As outras dependem de julgamento.

Ao escrever: siga as nove regras e arrume o que violar antes de concluir a tarefa.
Ao revisar: aponte com **Problema**, **Por que é ruim** e **Sugestão**.

## 1. Um nível de indentação por método

**O que diz.** Dentro de uma função, no máximo um nível de bloco. O ESLint exige `max-depth: 1`.

**Por que importa.** Cada nível a mais é uma condição a guardar na cabeça. Extrair o bloco interno dá nome ao que ele faz.

**Exemplo real.** `shared/middlewares/authorize.ts:6`, duas verificações lado a lado, sem aninhar. Em
`hooks/useOverlay.ts:16` a lógica de foco virou a função `keepFocusInside`, em vez de um bloco dentro do listener.

**Na revisão.** Callback dentro de callback não é pego pelo `max-depth`: `.map` dentro de `.map` com lógica pede extração.

**Como arrumar.** Extraia o bloco para uma função com nome, ou troque laço por `filter` e `map`.

## 2. Não use `else`

**O que diz.** Saia cedo da função, com cláusula de guarda.

**Por que importa.** O caminho principal fica reto e cada exceção se resolve na hora, sem acumular estado na leitura.

**Exemplo real.** Hoje não há nenhum `} else` em `src/` nos dois apps. `domains/auth/auth.service.ts:133`:

```ts
function assertCanSignIn(account: AccountCredentials): void {
  if (account.deletedAt) throw new AccountDeletedError();
  if (account.status !== 'ACTIVE') throw new AccountSuspendedError();
  if (!account.emailVerified) throw new EmailNotVerifiedError();
}
```

**Na revisão.** Ternário simples é aceito (`isSubmitting ? 'Salvando…' : 'Salvar'`). Ternário dentro de ternário é o
`else` disfarçado.

**Como arrumar.** Cláusula de guarda ou mapa por caso.

## 3. Encapsule primitivos e strings com regra

**O que diz.** Valor do domínio que tem regra própria merece tipo próprio. Sozinho, `string` aceita qualquer coisa.

**Por que importa.** O compilador passa a impedir troca de argumentos, e a regra do valor fica num lugar só.

**Exemplos reais que seguem.** `DateRange` (`shared/utils/time-zone.ts:3`), `PaginationQuery`, `UserRole` e `reasonSchema`
(`shared/validators/reason.ts:6`).

**Exemplos reais a melhorar.**

- `domains/users/users.service.ts:107`: `changePassword(id: string, passwordHash: string, tx?)`. Os dois `string` trocam de
  lugar sem erro de compilação, e o `id` poderia ser trocado por outro tipo de id.
- `auth.service.ts:135` e `:140` repetem o teste `status === 'ACTIVE'` em duas funções.
- `apps/cromocard-frontend/src/app/layouts/SiteShell/SiteShell.tsx:91` compara `role === 'ADMIN'` com a string solta.

**Atenção para o marketplace.** Dinheiro trafega como string decimal (ADR-011). Crie um tipo `Money` antes da primeira
conta, e nunca use `number` para preço.

**Exceções.** Primitivo sem regra (nome de exibição) continua primitivo. DTO da API e props simples não precisam de tipo.

**Como arrumar.** Tipo marcado ou união (`type PasswordHash = string & { readonly brand: unique symbol }`), função
predicado (`isActiveStatus`) ou objeto de valor.

## 4. Coleções de primeira classe

**O que diz.** Uma coleção com regra própria fica num tipo ou módulo só seu, sem mistura com outros dados.

**Por que importa.** A regra de filtrar, somar ou completar fica junto dos dados, em vez de repetida em quem usa a lista.

**Exemplo real que segue.** `features/auth/components/PasswordStrength/passwordStrength.ts:1`: a lista de regras e as
operações sobre ela moram no mesmo módulo. `Paginated<T>` (`shared/utils/pagination.ts:17`) reúne itens e metadados.

**Exemplo real a melhorar.** `MonthlySignups[]` tem operações em dois domínios: `withEmptyMonths` em
`users.service.ts:24` e `sumSignups` em `dashboard.service.ts:41`. Regra nova de cadastros mensais pode cair em qualquer
um dos dois.

**Como arrumar.** Módulo ou classe da coleção (`signups-history.ts`) com as operações juntas. Lista só repassada não
precisa disso.

## 5. Um ponto por linha

**O que diz.** Fale com o vizinho, e não com o vizinho do vizinho. É a Lei de Demeter.

**Por que importa.** Cada ponto a mais prende quem chama à estrutura interna de outro objeto.

**Exemplo real.** `domains/admin/dashboard/dashboard.service.ts:57` faz `this.deps.users.countMembers()`. O acesso a
`this.deps` conta como um passo só, então este caso é aceito. `lib/http.ts:87` faz `response.data.data` e também é aceito,
porque está justamente na borda que desembrulha a resposta para o resto do app.

**O que não fazer (ilustrativo).** `order.listing.seller.profile.displayName` num componente.

**Exceções.** APIs fluentes (Prisma, Zod, query builder, `filter().map()`), `styles.x`, `paths.backoffice.users`.

**Como arrumar.** Peça o dado pronto (`select` no repository, prop `sellerName`) ou crie o método no dono do dado.

## 6. Não abrevie

**O que diz.** O nome completo revela a intenção. Se o nome fica longo demais, a coisa talvez faça demais.

**Por que importa.** Abreviação obriga a abrir a implementação para entender a chamada.

**Exemplos reais.** `verifyPasswordInConstantTime`, `listSellersCreatedWithin`, `findCredentialsByEmailIncludingDeleted`.

**Exceções aceitas no projeto.** `req`, `res`, `tx` (transação do Prisma), `sub` (campo do JWT), `deps`, `id`.

**O que não fazer (ilustrativo).** `usr`, `cfg`, `tmp`, `data2`, `handleIt`.

**Como arrumar.** Use o nome inteiro, em inglês, com a palavra que a documentação do domínio usa.

## 7. Mantenha as entidades pequenas

**O que diz.** Funções e arquivos curtos. O ESLint exige `max-lines-per-function: 25`.

**Por que importa.** O que é pequeno cabe na cabeça, se testa com facilidade e costuma ter um assunto só.

**Exemplo real.** Quase todo arquivo de código dos dois apps tem até 180 linhas. As exceções são sinais: `auth.service.ts`
(406) e `users.repository.ts` (257).

**Na revisão.** Passar de 150 linhas num arquivo novo é sinal de olhar, não reprovação automática.

**Como arrumar.** Separe por assunto (veja o princípio S do [SOLID](solid.md)) e extraia subcomponentes, como o `DataTable`
faz com `DataTableHead` e `DataTableBody`.

## 8. No máximo duas variáveis de instância

**O que diz.** Uma classe guarda pouco estado. Adaptação do projeto: o `deps` conta pelos campos que tem dentro.

**Por que importa.** Cada campo multiplica as combinações de estado e costuma indicar outro assunto na mesma classe.

**Exemplos reais que seguem.** `UsersService` (um campo) e `AuthController` (dois).

**Exemplo real a melhorar.** `AuthService` usa um campo só, `deps`, com oito dependências dentro
(`auth.service.ts:88`). O objeto só esconde o excesso, e ele confirma o problema de responsabilidade do princípio S.

**Exceções.** Objeto de dados e erro (`AppError`). Em React, o análogo é o componente com `useState` demais, que pede um
hook próprio.

**Como arrumar.** Divida a classe, ou agrupe campos que andam juntos, como o `RefreshTokenTtl` (`auth.service.ts:83`).

## 9. Sem getters e setters que só expõem estado

**O que diz.** Diga ao objeto o que fazer, em vez de perguntar pelos dados e decidir do lado de fora.

**Por que importa.** A decisão fica ao lado dos dados, e não espalhada em quem consulta.

**Exemplo real a melhorar.** `assertCanSignIn` e `isActive` (`auth.service.ts:133` e `:139`) leem campos de
`AccountCredentials` para decidir o que o próprio conceito de conta deveria saber. Se mais regras de conta surgirem,
concentre-as num módulo `account` com `assertCanSignIn(account)`.

**Exceções.** Resultado do Prisma, DTO, props de React e armazenamentos simples, como o `accessTokenStore`
(`lib/access-token.ts:3`), que existe para guardar um valor.

**O que não fazer (ilustrativo).** Em outro arquivo, `if (order.getStatus() === 'PAID') order.setStatus('SHIPPED')`.

**Como arrumar.** Crie a operação com nome de negócio: `shipOrder(order)`.

## Modelo de achado

```
`features/marketplace/orders/orders.format.ts:12` (Object Calisthenics 3)
Problema: o preço é somado como `number`.
Por que é ruim: arredondamento de ponto flutuante gera centavos errados, e o ADR-011 define dinheiro como string decimal.
Sugestão: crie o tipo `Money` com `add` e use nas somas.
```

Exemplo ilustrativo.
