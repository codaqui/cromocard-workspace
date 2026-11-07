# ADR-059 — Provedor de e-mail por ambiente: Ethereal em homologação e Resend em produção

- **Status:** Proposto (aguardando validação do PO)
- **Data:** 2026-11-06
- **Decisores:** Lucas Oliveira Lima (proposta); validação: Daniel Andrade (PO)
- **Complementa:** ADR-009 (o `MailProvider` previa "SMTP real (ex.: Amazon SES, Resend)" sem escolher qual) e
  ADR-055 (os ambientes e o `.env` gerado pelo deploy).

## Contexto

A API envia e-mail em dois fluxos da autenticação: a confirmação do cadastro e a redefinição de senha (ADR-048).
O envio passa pelo `MailProvider` do ADR-009, com três drivers em `src/providers/mail/`:

| `MAIL_DRIVER` | O que faz |
|---|---|
| `ethereal` (padrão) | Cria uma caixa de testes do Nodemailer. **Nenhum e-mail é entregue**; a API registra no log `E-mail enviado (Ethereal)` com o `previewUrl` de cada mensagem |
| `smtp` | Entrega de verdade por um servidor SMTP (`MAIL_HOST`, `MAIL_PORT`, `MAIL_USER`, `MAIL_PASSWORD`) |
| `memory` | Só nos testes |

Em 06/11/2026, ao ligar o login com Google em homologação, a equipe viu a tela "Confirme seu e-mail" de um
cadastro com e-mail e senha e perguntou o que fazer sem um servidor SMTP. Hoje:

- **Homologação** usa o `ethereal`, porque o Environment `hml` não define `MAIL_DRIVER` e o Compose cai no padrão.
  O e-mail não chega à caixa de quem se cadastrou, mas o link aparece no log da `api`, que o grupo `dev` lê pelo
  Dozzle (ADR-055).
- **Produção** não pode subir assim: com `APP_ENV=production`, o `src/config/env.ts` recusa qualquer driver
  diferente de `smtp`. Antes do primeiro deploy de produção é preciso um provedor de verdade.
- O `deploy.yml` do backend já repassa `MAIL_DRIVER`, `MAIL_FROM`, `MAIL_HOST`, `MAIL_PORT` e `MAIL_USER` (variáveis)
  e `MAIL_PASSWORD` (secret) do Environment para o `.env`. **Não falta código, só a escolha e a configuração.**
- O transporte SMTP do `nodemailer.mail-provider.ts` não liga `secure`: funciona na porta 587 com STARTTLS, e a
  porta 465 (TLS direto) exigiria mudar o código.
- O domínio `cromocard.com.br` está na Cloudflare (ADR-055), onde ficam os registros DNS de SPF, DKIM e DMARC que
  qualquer provedor pede para os e-mails não caírem no spam.
- O volume esperado é pequeno: projeto acadêmico, com cadastros e redefinições de senha da equipe, do QA e da banca.

## Decisão

1. **Mantenha o Ethereal em homologação.** Não defina `MAIL_DRIVER` no Environment `hml` (ou defina `ethereal`).
   Para confirmar uma conta em hml, abra o Dozzle, o container `cromocard-hml-api-1`, busque
   `E-mail enviado (Ethereal)` e abra o `previewUrl`. Assim nenhum e-mail de teste sai para caixas reais.
2. **Use o Resend como provedor SMTP de produção**, no plano gratuito, pelo driver `smtp` que já existe:

   | Variável do Environment `prod` | Tipo | Valor |
   |---|---|---|
   | `MAIL_DRIVER` | variável | `smtp` |
   | `MAIL_HOST` | variável | `smtp.resend.com` |
   | `MAIL_PORT` | variável | `587` |
   | `MAIL_USER` | variável | `resend` |
   | `MAIL_PASSWORD` | **secret** | a API key do Resend, com permissão só de envio (*Sending access*) e restrita ao domínio |
   | `MAIL_FROM` | variável | `CromoCard <nao-responda@cromocard.com.br>` |

3. **Verifique o domínio `cromocard.com.br` no Resend** e crie na Cloudflare os registros que ele pedir (DKIM, SPF e
   o MX de retorno do subdomínio de envio), todos como *DNS only*, sem o proxy da Cloudflare. Crie também um
   registro DMARC (`_dmarc`) começando em `p=none`, para observar antes de endurecer.
4. **A conta do Resend é da organização, não de uma pessoa:** crie-a com um e-mail da equipe, guarde o acesso no
   Bitwarden e dê acesso a quem cuida da infraestrutura (ADR-055). **Em 07/11/2026 a conta ainda não existe e não há
   item dela no Bitwarden**; o item *CromoCard — Resend* é criado junto com a conta.
5. **Teste o SMTP antes da produção** pelo próprio Resend (envio de teste) e, se a equipe quiser, num deploy de hml
   com as mesmas variáveis por um dia, voltando ao Ethereal depois.

## Alternativas consideradas

- **Brevo (SMTP relay gratuito, 300 e-mails por dia):** limite diário maior que o do Resend. Fica como plano B,
  com a mesma configuração por variáveis (`smtp-relay.brevo.com`, porta 587), se o limite de 100 por dia do Resend
  apertar. Não foi a primeira escolha porque a conta passa por uma revisão de cadastro e o painel mistura
  marketing e transacional.
- **Amazon SES:** o mais barato em volume e já citado no ADR-009, mas exige conta na AWS com cartão, começa no
  *sandbox* (só envia para endereços verificados) e depende de um pedido de liberação para produção. Custo e passos
  demais para o volume do projeto.
- **Mailtrap:** o *Email Sandbox* gratuito guarda só 50 e-mails por mês, pouco para o QA em hml; o envio gratuito
  (4.000 por mês) é uma alternativa ao Resend, sem vantagem clara para o nosso caso.
- **SMTP de uma conta pessoal (Gmail com senha de app):** o remetente seria um endereço pessoal, não o do domínio,
  e a conta de uma pessoa ficaria presa à produção. Recusado.
- **SMTP real também em homologação:** os e-mails de teste chegariam a caixas reais e gastariam a cota do plano
  gratuito, sem ganho para o QA, que já tem o link no Dozzle.

## Consequências

**Fica mais fácil**

- Nada muda no código nem no `deploy.yml`: a troca de provedor é só de variáveis do Environment.
- Produção passa a poder subir (o `env.ts` deixa de recusar o driver).
- Homologação continua sem risco de mandar e-mail de teste para alguém de fora.

**Fica mais difícil ou é risco aceito**

- **Limites do plano gratuito do Resend:** 3.000 e-mails por mês e 100 por dia, um domínio. Acima disso o envio para
  até o dia seguinte, e o cadastro fica sem confirmação. Se acontecer, troque para o Brevo (plano B) ou para um plano
  pago.
- **O QA em hml depende do Dozzle** para ver os e-mails, e o Dozzle exige a VPN (grupo `dev` do Tailscale).
- **Os números dos planos mudam:** confira a página de preços do Resend antes de criar a conta.
- **O ADR-018 (Proposto) cita `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER` e `SMTP_PASS`**, mas o código usa os nomes
  `MAIL_*` deste ADR. Quando o 018 for revisado, use os nomes `MAIL_*`.

**O que precisa ser feito** (quando o PO aceitar)

1. Criar a conta do Resend com o e-mail da equipe e criar o item *CromoCard — Resend* no Bitwarden, que ainda não
   existe, com o login da conta e, depois do passo 3, a API key.
2. Adicionar o domínio no Resend e criar os registros DNS na Cloudflare; esperar o status *Verified*.
3. Criar a API key só de envio, restrita ao domínio.
4. No `codaqui/cromocard-backend`, Environment `prod`: as variáveis e o secret da tabela da decisão 2.
5. Registrar no `docs/Infraestrutura/historico.md` e no `runbooks.md` (como trocar a API key e o que fazer quando o
   limite diário estourar).

## Referências

- ADR-009 (providers), ADR-048 (tokens de e-mail), ADR-055 (ambientes, Dozzle e Cloudflare).
- Código: `src/providers/mail/` e `src/config/env.ts` do backend; `MAIL_*` em `.github/workflows/deploy.yml` e em
  `infra/docker-compose.yml`.
- Planos consultados em 06/11/2026: [Resend](https://resend.com/pricing), [Brevo](https://www.brevo.com/free-smtp-server/),
  [Mailtrap](https://docs.mailtrap.io/account-and-organization/billing/plans) e
  [Amazon SES](https://aws.amazon.com/ses/pricing/).
