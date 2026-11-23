# Plano — CCD005 Acessar Central de Ajuda (FAQ)

> Plano feito com a spec em Rascunho, a pedido do Daniel (22/11/2026): revisar depois que o PO decidir as lacunas.

- **Spec:** [spec.md](spec.md), em Rascunho (lacunas L1–L8 pendentes)
- **Repositórios:** frontend (lido da branch `feature/336-remove-tipo-categoria`); backend sem mudança
- **Data:** 2026-11-22 · **Autor:** Daniel Andrade

## Solução

Duas páginas públicas e estáticas, sem chamada à API: a Central de ajuda (`/ajuda`) e o Como funciona (`/como-funciona`).
Pela proposta da L1, tópicos, perguntas e respostas ficam num arquivo de conteúdo do frontend; a busca filtra as perguntas
de todos os tópicos sem diferenciar maiúsculas e acentos (depende da L5); cada pergunta é um cartão que abre e fecha, com
várias abertas ao mesmo tempo (depende da L7). "Enviar e-mail" é um link `mailto:` com o endereço do suporte de uma
configuração do frontend (depende da L3). O Como funciona tem as abas "Quero comprar" e "Quero vender" e o "Quanto custa?"
com "Criar conta grátis". O cliente logado vê as mesmas páginas, no `SiteShell` com o menu dele.

## Dependências

- **CCD001:** menu do visitante (Como funciona, Central de ajuda), rodapé e `paths.howItWorks`. Se esta story vier antes,
  ela mesma cria o caminho e os itens.
- **CCD003:** página de cadastro (`/cadastro`, já existe), destino de "Criar conta grátis".
- **Conteúdo (L2):** o texto das perguntas e respostas dos 6 tópicos vem do PO; sem ele, só "Primeiros passos" tem o texto
  do Figma.

## Dados

Nenhuma tabela e nenhuma rota (R13; L1). O endereço do suporte é a variável `SUPPORT_EMAIL` da configuração do frontend
(ADR-045), lida como as outras em `src/config/env.ts` (`window.__ENV__` em produção, `VITE_SUPPORT_EMAIL` no
desenvolvimento) — depende da L3.

## Contrato da API

Nenhum endpoint: o conteúdo é estático (R13).

## Backend — `apps/cromocard-backend`

Sem mudança.

## Frontend — `apps/cromocard-frontend`

Feature `src/features/public/` (criada pela CCD001), no modelo de `src/features/users/` (ADR-040).

| Arquivo | O que muda | Requisitos |
|---|---|---|
| `src/config/env.ts` · `.env.example` · o `env.js` de runtime do container | `SUPPORT_EMAIL` (depende da L3) | R8 |
| `src/routes/paths.ts` | `howItWorks: '/como-funciona'` (se a CCD001 não criou) | R9 |
| `public/help/help.content.ts` | os 6 tópicos na ordem do R4 e as perguntas de cada um, com links internos só onde a resposta pedir (depende das L2 e L4) | R4, R5 |
| `public/help/help.search.ts` + `.spec.ts` | normaliza (NFD, sem acentos, minúsculas) e filtra pergunta e resposta em todos os tópicos | R6 |
| `public/help/components/HelpTopics/` | lista de tópicos com "Primeiros passos" selecionado, frame `1112-6843` | R4 |
| `public/help/components/FaqItem/` | cartão fechado com "+", aberto com a resposta e "−"; selecionar de novo recolhe (depende da L7), frame `1112-6843` | R5 |
| `public/help/components/HelpSearchField/` | "Busque por “pagamento”, “frete”, “álbum”..." e o aviso sem resultado no estilo do vazio `1112-4356` (depende da L5) | R6 |
| `public/help/components/SupportCard/` | "Não encontrou o que procurava?" e "Enviar e-mail" (`mailto:`); os textos de prazo e horário só se a L6 aprovar, frame `1112-6843` | R7, R8 |
| `public/help/pages/HelpCenterPage/` | "CENTRAL DE AJUDA", "Como podemos ajudar?", "Busque uma dúvida ou escolha um tópico.", tópicos, perguntas e o cartão do suporte, frame `1112-6843` | R1–R8, R14 |
| `public/how-it-works/how-it-works.content.ts` | passos, "Suas garantias", "Por que vender aqui" e os textos do R10–R12 | R10–R12 |
| `public/how-it-works/components/HowItWorksSteps/` · `GuaranteeList/` · `PricingCard/` | 4 passos, garantias e "Quanto custa?" (0% "para comprar", 5% "por venda", "Criar conta grátis" → `/cadastro`), frames `1112-6532` e `1160-2268` | R10–R12 |
| `public/how-it-works/pages/HowItWorksPage/` | "COMO FUNCIONA", "Como a CromoCard funciona" e as abas com `Tabs` ("Quero comprar" aberta), frames `1112-6532` e `1160-2268` | R9–R14 |
| `public/public.routes.ts` · `src/features/users/users.routes.ts` | `/ajuda` e `/como-funciona` no `PublicLayout`; sai o `underConstructionRoute` de `/ajuda` | R1, R2, R9 |

- **Rotas:** `/ajuda` e `/como-funciona`, públicas.
- **Estados:** sem carregando nem erro (sem API); vazio da busca com `EmptyState`.
- **Componentes reaproveitados de `src/components/`:** `Tabs`, `TextField`, `Button`, `EmptyState`, `Icon`.

## Testes

| Critério | O que o teste verifica | Onde |
|---|---|---|
| CA1 | "Central de ajuda" no menu abre a página com "Primeiros passos" e perguntas fechadas; abrir troca o sinal para "−" | `HelpCenterPage.spec.tsx` · `FaqItem.spec.tsx` |
| CA2 | "Pagamentos" mostra só as perguntas dele e fica destacado | `HelpTopics.spec.tsx` |
| CA3 | "frete" filtra as perguntas | `help.search.spec.ts` · `HelpCenterPage.spec.tsx` |
| CA4 | "Enviar e-mail" tem `href="mailto:<SUPPORT_EMAIL>"` | `SupportCard.spec.tsx` |
| CA5 | logado, mesmo conteúdo com o menu do cliente | `HelpCenterPage.spec.tsx` · `HowItWorksPage.spec.tsx` |
| CA6, CA7 | "Quero comprar" aberta com passos, garantias e 0%/5%; "Quero vender" com os passos do vendedor | `HowItWorksPage.spec.tsx` |
| CA8 | "Criar conta grátis" abre `/cadastro` | `PricingCard.spec.tsx` |
| CA9 | nenhuma chamada ao `apiClient` ao montar o Como funciona | `HowItWorksPage.spec.tsx` (espião no cliente HTTP) |
| CA10–CA13 | print em 1280 px igual aos frames `1112-6843`, `1112-6532` e `1160-2268`; sem quebra em 375/768/1024 px | validação no navegador do `/cromocard-desenvolver` (ADR-060, item 5) |

## Dependências e riscos

- Sem o texto do PO (L2), as perguntas dos outros 5 tópicos ficam vazias: a T2 só fecha com o conteúdo.
- A L8 (narrativa fala em "trocas") não muda o código; muda só a user story.

## Decisões técnicas

- Conteúdo estático tipado (`help.content.ts`) em vez de tabela, pela proposta da L1: o DER não tem tabela de FAQ e o admin
  não edita o conteúdo.
- O e-mail do suporte é configuração de ambiente (ADR-045), não código, para mudar sem novo build.
