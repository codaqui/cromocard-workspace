# ADR-072 — Token fixo do Melhor Envio no sandbox

- **Status:** Proposto (aguardando validação do PO)
- **Data:** 2026-11-25
- **Decisores:** Felipe Consulim (PO), na revisão do backend codaqui/cromocard-backend#43
- **Complementa:** ADR-067 (item 2)

## Contexto

O item 2 do ADR-067 define a autenticação no Melhor Envio por OAuth2: a conta da plataforma autoriza o app uma vez, o
`access_token` vale 30 dias, o refresh vale 45 dias e "a renovação automática fica no plano". O plano da CCD072 (Comprar)
não trata da renovação, e o `ShippingProvider` do PR #43 usa um `MELHOR_ENVIO_TOKEN` fixo, vindo do secret do ambiente.

Para renovar sozinho, o backend precisaria guardar o token novo em algum lugar que sobreviva ao deploy. O DER não tem
tabela para isso, e o `.env` é regravado a cada deploy a partir do Environment do GitHub. O projeto roda só em
homologação, no sandbox do Melhor Envio, sem envio real.

## Decisão

1. **Token fixo no sandbox.** Na fatia mínima do marketplace, o backend usa um token do sandbox gerado no painel do
   Melhor Envio, guardado no secret `MELHOR_ENVIO_TOKEN` do Environment do backend.
2. **Renovação à mão.** Antes de o token vencer, alguém do time gera outro no painel, troca o secret e refaz o deploy. O
   passo a passo fica em `docs/Infraestrutura/runbooks.md` (`MELHOR_ENVIO_TOKEN`).
3. **Falha visível.** Token vencido faz a cotação responder `502 SHIPPING_PROVIDER_ERROR` (L12 da CCD072), e o log da
   `api` registra a falha do Melhor Envio com o status HTTP, sem o token.
4. **Renovação automática depois.** O fluxo OAuth2 com refresh do ADR-067 volta a valer quando houver produção, com uma
   decisão sobre onde guardar o token renovado.

## Alternativas consideradas

- **Renovação automática agora:** exige uma tabela ou um cofre para o token renovado e uma task nova, sem ganho real
  enquanto só existe o sandbox.
- **Guardar o token renovado no `.env` do servidor:** o deploy regrava o arquivo e o token se perde.

## Consequências

- Alguém precisa lembrar de renovar o token a cada 30 dias. Se esquecer, o checkout de homologação mostra o erro do frete
  até a troca.
- O código do `ShippingProvider` não muda quando a renovação automática chegar: só a origem do token.
- Se o PO recusar este ADR, a renovação automática vira requisito da CCD072, com uma task e uma decisão de armazenamento.

## Referências

- ADR-067 (item 2), ADR-009, ADR-055
- `specs/CCD072-comprar/plano.md` (Decisões técnicas)
- Revisão do backend codaqui/cromocard-backend#43
