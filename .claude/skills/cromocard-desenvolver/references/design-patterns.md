# Design Patterns no CromoCard

Usado pela `/cromocard-desenvolver` (ao escrever) e pela `/cromocard-revisor` (ao revisar). A Parte 1 traz os padrões da
arquitetura do projeto. As Partes 2 a 4 cobrem os 23 padrões do catálogo GoF.

Os exemplos com `arquivo:linha` são do código real, levantados em 2026-11-09 da `develop` do backend e da
`feature/layouts-figma` do frontend. O que está como **Cenário** ainda não existe e mostra onde o padrão caberia.

## Como aplicar

- **Parte 1 é obrigatória.** Código que foge dela é achado.
- **Partes 2 a 4 respondem a um problema.** A falta de um padrão só é defeito quando o problema dele está no código.
- **Padrão sem problema também é achado.** Interface com uma implementação que nunca vai variar, factory de uma linha ou
  camada que só repassa chamada é Generalidade Especulativa.
- Em TypeScript, prefira a forma leve: função, mapa e closure antes de hierarquia de classes.

Ao escrever: antes de criar `if` por tipo, classe nova ou integração, procure aqui o padrão daquele problema.
Ao revisar: aponte padrão que falta ou que sobra, com **Problema**, **Por que é ruim** e **Sugestão**.

## Parte 1. Padrões da arquitetura do projeto

| Padrão | O que é | Exemplo real | Reprova quando |
|---|---|---|---|
| **Repository** | Isola o acesso ao banco atrás de métodos do domínio | `domains/users/users.repository.ts` | Prisma fora do repository; leitura sem `notDeleted` |
| **Injeção de dependência** | A dependência chega pelo construtor | `users.service.ts:45` | `new` de repository ou provider dentro da service |
| **Composition Root** | Um único lugar monta o grafo de objetos | `domains/users/users.module.ts:10` | Montagem espalhada fora do `.module.ts` |
| **Service Layer** | Regra de negócio numa camada própria | `domains/users/users.service.ts` | Regra no controller ou no repository |
| **Value Object** | Valor sem identidade, comparado pelo conteúdo | `DateRange` em `shared/utils/time-zone.ts:3` | Dinheiro ou status soltos com regra espalhada |
| **Container e Apresentação** | Página busca o dado, componente desenha | `EditNameForm.tsx` recebe `onSubmit` por props | Componente visual chamando query ou API |
| **Hook customizado** | Lógica reutilizável fora do componente | `features/users/hooks/useEditNameForm.ts` | Formulário ou efeito complexo dentro do componente |
| **Query Key Factory** | Chaves de cache geradas num lugar só | `usersKeys` em `features/users/users.queries.ts:6` | Chave escrita à mão no componente |
| **Null Object** | Implementação que não faz nada, no lugar de `null` | `DisabledGoogleVerifier` em `lib/google.ts:35` | `if (provider)` repetido em quem usa |

## Parte 2. Padrões de criação

### Factory Method
**O que é.** Uma função decide qual implementação criar, e quem chama só conhece a interface.
**Real.** `createStorageProvider` (`providers/storage/storage.factory.ts:10`), `createGoogleVerifier` (`lib/google.ts:41`).
**Use quando** a implementação depende de ambiente ou configuração. **Não use** com uma implementação só e sem variação à vista.

### Abstract Factory
**O que é.** Cria uma família de objetos que precisam combinar entre si.
**Cenário.** Stripe e Mercado Pago, cada um com cobrança, reembolso e validação de webhook que não se misturam.
**Use quando** houver famílias de verdade. **Não use** se uma Factory Method simples resolver.

### Builder
**O que é.** Monta um objeto complexo passo a passo.
**Real, de biblioteca.** Schemas Zod (`shared/validators/reason.ts:6`).
**Cenário.** Consulta dos relatórios gerenciais (CCD063), com muitos filtros opcionais.
**Use quando** houver muitas combinações opcionais. **Não use** para objeto de poucos campos.

### Prototype
**O que é.** Cria um objeto novo copiando um existente.
**Cenário.** Duplicar Carta (CCD105): a cópia parte da carta original, com id novo e sem o `deleted_at`.
**Use quando** copiar for mais claro que preencher tudo. **Não use** cópia rasa em dado com listas aninhadas, como as fotos da carta.

### Singleton
**O que é.** Uma única instância compartilhada.
**Real.** Em módulo: `prisma` (`lib/prisma.ts`), `mailProvider` (`providers/mail/mail.factory.ts:29`), `accessTokenStore`.
**Use quando** o recurso precisar ser único. **Não use** para esconder dependência: o import direto fica no `.module.ts`, e a service recebe pelo construtor.

## Parte 3. Padrões estruturais

### Adapter
**O que é.** Traduz uma API externa para a interface que o projeto espera.
**Real.** `NodemailerMailProvider` (`providers/mail/nodemailer.mail-provider.ts:33`), `GoogleAuthLibraryVerifier`, `toApiError` (`lib/api-error.ts:55`).
**Use quando** integrar qualquer serviço externo (ADR-009). **Reprova** biblioteca externa chamada direto da service.

### Bridge
**O que é.** Separa duas dimensões que variam independentes.
**Cenário.** Tipo de notificação × canal (no app, e-mail), sem criar uma classe para cada combinação.
**Use quando** as duas dimensões crescerem. **Não use** com uma dimensão fixa.

### Composite
**O que é.** Trata itens e grupos de itens do mesmo jeito, em árvore.
**Real.** Árvore de rotas (`app/router.tsx:22`, `features/admin/admin.routes.ts`).
**Cenário.** `categories`, que é hierárquica no DER.
**Use quando** houver árvore de profundidade variável.

### Decorator
**O que é.** Embrulha um objeto com a mesma interface, somando um comportamento.
**Cenário.** `CachedZipCodeProvider` em volta do provider de CEP, ou um logger em volta do `MailProvider`.
**Use quando** o acréscimo for transversal e opcional. **Não use** quando a mudança pertencer à própria classe.

### Facade
**O que é.** Uma entrada simples para um subsistema complexo.
**Real.** Objeto `api` (`lib/http.ts:84`) sobre o Axios; o `index.ts` de cada feature; a service exportada pelo `.module.ts`.
**Use quando** outro módulo precisar de pouco de um subsistema grande. **Não use** como camada que só repassa tudo.

### Flyweight
**O que é.** Compartilha objetos imutáveis e caros, em vez de recriar.
**Real.** `Intl.NumberFormat` e `Intl.DateTimeFormat` em módulo (`features/admin/dashboard/dashboard.format.ts:3`).
**Use quando** o objeto for caro e sem estado, em lista grande ou render frequente.

### Proxy
**O que é.** Um substituto que controla o acesso ao objeto real.
**Real.** Rotas com `lazy` (`components/UnderConstructionPage/underConstructionRoute.ts:17`) adiam o carregamento; o interceptor em `lib/http.ts:63` põe o token.
**Use quando** houver carga adiada, controle de acesso ou cache transparente.

## Parte 4. Padrões comportamentais

### Chain of Responsibility
**O que é.** A requisição passa por uma sequência de tratadores, e cada um decide se segue.
**Real.** Middlewares do Express (`domains/users/users.routes.ts:11`); `toAppError` (`shared/errors/error-handler.ts:14`).
**Use quando** houver etapas independentes e ordenadas.

### Command
**O que é.** Uma ação vira um objeto, que pode ser passado, guardado ou enfileirado.
**Real.** `actions` do `UserMenu` (`app/layouts/AdminLayout/AdminLayout.tsx:43`), com `onSelect`.
**Cenário.** Agendar Notificação Global (CCD100).
**Use quando** a ação precisar ser adiada, enfileirada ou desfeita.

### Interpreter
**O que é.** Avalia uma linguagem própria por uma gramática.
**No CromoCard.** Sem uso. Filtros vêm por parâmetros validados com Zod.
**Não use**: criar uma linguagem de busca própria não se justifica neste projeto.

### Iterator
**O que é.** Percorre uma coleção sem expor como ela é guardada.
**Real.** Nativo: `for…of`, `map`, `filter`.
**Cenário.** Paginação por cursor do chat e das notificações (ADR-011).
**Reprova** expor `skip` e `take` para fora do repository.

### Mediator
**O que é.** Um ponto central coordena as partes, que não se conhecem.
**Cenário.** Rooms do Socket.IO (ADR-012) entre os participantes; uma página coordenando filtros e tabela.
**Use quando** muitos componentes precisarem conversar. **Não use** como objeto que concentra toda a regra.

### Memento
**O que é.** Guarda um estado para restaurar depois, sem expor o interior do objeto.
**Cenário.** Salvar Rascunho de Carta (CCD106).
**Use quando** houver desfazer ou rascunho. **Cuidado:** token e dado sensível não entram em rascunho no `localStorage`.

### Observer
**O que é.** Quem se interessa é avisado da mudança, sem o emissor conhecê-lo.
**Real.** TanStack Query; `onUnauthorized` (`lib/http.ts:22`), com um ouvinte só.
**Cenário.** Eventos `dominio:acao` do Socket.IO.
**Use quando** um fato interessar a vários. **Reprova** `useEffect` copiando dado da API para `useState`, porque o Query já avisa.

### State
**O que é.** O comportamento muda conforme o estado, e as transições válidas ficam explícitas.
**Cenário.** `order_status`: `AWAITING_PAYMENT` → `PAID` → `SHIPPED` → `DELIVERED` ou `CANCELED`, num mapa de transições.
**Use quando** houver fluxo com transições proibidas. **Reprova** `if` de status espalhado permitindo pular etapa.

### Strategy
**O que é.** Algoritmos intercambiáveis atrás da mesma forma.
**Real.** `mailProviderByDriver`, `strengthRules` (`passwordStrength.ts:1`), `render` do `DataTableColumn` (`components/DataTable/DataTable.tsx:8`), `createTransport` no `NodemailerOptions`.
**Use quando** houver `if` por tipo que cresce. Em TypeScript, normalmente um mapa ou uma função por parâmetro basta.

### Template Method
**O que é.** Um esqueleto fixo com etapas que variam.
**Cenário.** Exportar Relatórios (CCD063): buscar, formatar e registrar, variando o formato. Prefira uma função que recebe a etapa variável.
**Não use** herança só para reaproveitar código.

### Visitor
**O que é.** Acrescenta operações sobre tipos diferentes sem alterar esses tipos.
**Cenário.** `reports` tem alvos polimórficos (ADR-032). Um `Record<target_type, função>` resolve com menos código.
**Não use** enquanto um mapa por tipo for suficiente.

## Sinal no código → padrão

| Sinal | Padrão |
|---|---|
| `if` por tipo ou driver que cresce | Strategy |
| Biblioteca externa direto na service | Adapter |
| Implementação escolhida por ambiente | Factory Method |
| `if (provider)` repetido | Null Object |
| Status com transições proibidas | State |
| Copiar registro com tudo dentro | Prototype |
| Ação que precisa de fila ou agendamento | Command |
| Efeito extra em volta de um provider | Decorator |
| Um evento interessa a vários | Observer |

## Modelo de achado

```
`domains/marketplace/orders/orders.service.ts:40` (Design Patterns: State)
Problema: `ship` e `cancel` testam o status em `if` separados, e nada impede cancelar um pedido entregue.
Por que é ruim: uma transição proibida pode passar, e toda etapa nova exige mexer em vários métodos.
Sugestão: crie o mapa `allowedTransitions: Record<OrderStatus, OrderStatus[]>` e valide antes de gravar.
```

Exemplo ilustrativo.
