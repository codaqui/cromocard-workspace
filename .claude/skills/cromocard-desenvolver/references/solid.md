# SOLID no CromoCard

Usado pela `/cromocard-desenvolver` (ao escrever) e pela `/cromocard-revisor` (ao revisar). Os exemplos com `arquivo:linha`
são do código real, levantados em 2026-11-09 da `develop` do backend e da `feature/layouts-figma` do frontend. Se a linha
tiver mudado, procure pelo nome. O que está marcado como **ilustrativo** não existe no projeto.

Ao escrever: todo código novo segue os cinco princípios. O que violar, arrume antes de concluir a tarefa.
Ao revisar: aponte a violação com **Problema**, **Por que é ruim** e **Sugestão**.

## S: Responsabilidade Única

**O que diz.** Uma classe, função ou componente tem um único motivo para mudar, ou seja, atende a um só assunto.

**Por que importa.** Quando assuntos diferentes moram juntos, mexer em um arrisca quebrar o outro, e os testes precisam
montar dependências que nem são do caso testado.

**Exemplo real que segue.** `apps/cromocard-backend/src/domains/users/users.controller.ts:12` só traduz HTTP:

```ts
list = async (req: Request, res: Response): Promise<void> => {
  const { items, meta } = await this.usersService.list(listUsersQuerySchema.parse(req.query));
  paginated(res, items, meta);
};
```

No frontend, `features/users/hooks/useEditNameForm.ts` cuida da lógica do formulário e
`features/users/components/EditNameForm/EditNameForm.tsx` só desenha. O componente nem sabe que a API existe.

**Exemplo real a melhorar.** `domains/auth/auth.service.ts` tem 406 linhas, oito dependências (`AuthServiceDeps`, linha
88) e quatro assuntos na mesma classe: sessão (`login`, `refresh`, `logout`), cadastro (`register`, `verifyEmail`,
`resendVerification`), senha (`forgotPassword`, `resetPassword`) e Google (`loginWithGoogle`). Trocar a regra de expiração
do link de senha obriga a abrir a mesma classe que emite a sessão.

**Como detectar.** Complete a frase "esta classe muda quando…". Se aparecer "ou", são dois motivos. Outros sinais:
dependências usadas só por parte dos métodos, nome com "E" ou "Manager", componente que busca dado e também desenha.

**Como arrumar.** Separe por assunto (`SessionService`, `RegistrationService`, `PasswordResetService`), cada um com só as
dependências que usa, e monte no `.module.ts`.

## O: Aberto para Extensão, Fechado para Modificação

**O que diz.** Para acrescentar um caso novo, você adiciona código, em vez de alterar o que já funciona.

**Por que importa.** Cada `if` novo numa função antiga pode quebrar os casos anteriores e espalha a mesma mudança.

**Exemplo real que segue.** `providers/mail/mail.factory.ts:12`: um driver novo é uma entrada a mais no mapa, e o
`Record` faz o TypeScript exigir todos os drivers.

```ts
const mailProviderByDriver: Record<typeof env.MAIL_DRIVER, () => MailProvider> = {
  memory: () => new InMemoryMailProvider(),
  // ethereal e smtp
};
```

Também seguem: `features/auth/components/PasswordStrength/passwordStrength.ts:1` (regra nova é um item na lista),
`src/routes.ts:17` (domínio novo é um item em `sharedModules`) e `features/users/users.labels.ts:5` (mapa por `UserRole`).

**O que não fazer (ilustrativo).** Cada método de pagamento novo reabre esta função:

```ts
if (method === 'PIX') return pixFee(total);
if (method === 'BOLETO') return boletoFee(total);
```

**Como detectar.** `if` ou `switch` sobre tipo, status ou papel que cresce a cada caso, principalmente se o mesmo teste
aparece em mais de um arquivo.

**Como arrumar.** Mapa `Record<Tipo, …>` ou interface com uma implementação por caso. Dois casos estáveis não precisam
disso: o ganho aparece quando a lista cresce.

## L: Substituição de Liskov

**O que diz.** Quem usa uma interface ou classe base precisa funcionar igual com qualquer implementação, sem saber qual é.

**Por que importa.** Se uma implementação surpreende, quem chama começa a testar o tipo concreto, e a abstração deixa de
proteger.

**Exemplo real que segue.** `lib/google.ts:35`: sem `GOOGLE_CLIENT_ID`, a implementação desligada devolve `null`, que é
um resultado previsto pelo contrato, e o `AuthService` não precisa saber qual verificador recebeu.

```ts
export class DisabledGoogleVerifier implements GoogleIdTokenVerifier {
  verify(): Promise<GoogleProfile | null> {
    return Promise.resolve(null);
  }
}
```

Também seguem: `InMemoryMailProvider` e `NodemailerMailProvider` com o mesmo `send`; `Modal` e `Drawer`, que aceitam as
mesmas `OverlayDialogProps`; e `UserNotFoundError`, que continua sendo tratado como `AppError` pelo `errorHandler`.

**O que não fazer (ilustrativo).** Um storage em que `delete` lança "não implementado", ou um `findById` que devolve
`null` numa implementação e lança erro em outra.

**Como detectar.** `instanceof` em quem usa a abstração, método vazio ou que lança "not implemented", subclasse que exige
mais ou devolve menos que a base.

**Como arrumar.** Ajuste a implementação ao contrato. Se ela não consegue cumprir, a interface está grande demais (veja
o princípio I).

## I: Segregação de Interface

**O que diz.** Quem usa uma dependência não deve ser obrigado a conhecer métodos de que não precisa.

**Por que importa.** Interface menor deixa o falso de teste menor e diminui o acoplamento entre domínios.

**Exemplo real que segue.** `domains/admin/dashboard/dashboard.service.ts:8`: o dashboard declara só o que usa do domínio
de usuários, e não o `UsersService` inteiro.

```ts
export interface DashboardUsers {
  countMembers(): Promise<number>;
  signupsByMonth(query: SignupsQuery): Promise<MonthlySignups[]>;
  listSellersCreatedWithin(range: DateRange, pagination: PaginationQuery): Promise<Paginated<SellerSummary>>;
}
```

Também seguem: `AuthUsers` (`auth.service.ts:66`), `ExpiredTokensCleaner` (`jobs/cleanup-expired-tokens.job.ts`, um método
só) e `EditNameFormProps`, que recebe só o necessário.

**O que não fazer (ilustrativo).** Um componente de lista que recebe o `user` inteiro para mostrar só o nome, ou um
domínio que tipa a dependência com a classe completa da service de outro.

**Como detectar.** Falso de teste com métodos vazios, props repassadas sem uso, dependência tipada com a classe concreta
inteira.

**Como arrumar.** Declare a interface no lado de quem consome, com o nome do papel (`DashboardUsers`).

## D: Inversão de Dependência

**O que diz.** Regra de negócio depende de abstração. Os detalhes (banco, e-mail, relógio) são entregues de fora.

**Por que importa.** A service fica testável sem banco e o provedor troca sem mexer na regra. Aqui é regra de arquitetura
(ADR-004 e ADR-009): `new` só no `.module.ts` ou nas factories.

**Exemplo real que segue.** `domains/users/users.service.ts:45` recebe a interface, e `domains/users/users.module.ts:10`
é o único lugar que conhece o Prisma:

```ts
const usersRepository = new PrismaUsersRepository(prisma);
const usersService = new UsersService(usersRepository);
```

O detalhe vale até para o relógio: `DashboardServiceDeps` recebe `now: () => Date` (`dashboard.service.ts:24`), e o teste
controla a data.

**Exemplo real a melhorar (menor).** `auth.service.ts:3` importa o tipo `GoogleLink` de `users.service`, prendendo o
contrato de `auth` à service de outro domínio. Vale declarar esse tipo junto da interface `AuthUsers`. As funções puras
de `lib/` usadas direto na mesma service (`hashPassword`, `signAccessToken`) são uma escolha aceita, porque não dependem
de serviço externo em tempo de teste.

**Como detectar.** `new` de repository ou provider dentro de service, `import { prisma }` em service ou controller,
`Date.now()` em regra que precisa de teste, `process.env` fora do `env.ts`.

**Como arrumar.** Receba pelo construtor, tipado por interface, e monte no `.module.ts`.

## Modelo de achado

```
`domains/orders/orders.service.ts:18` (SOLID: D)
Problema: a service cria `new PrismaOrdersRepository()` dentro do método.
Por que é ruim: o teste passa a precisar de banco e a regra fica presa ao Prisma.
Sugestão: receba `OrdersRepository` pelo construtor e faça o `new` no `orders.module.ts`.
```

Exemplo ilustrativo.
