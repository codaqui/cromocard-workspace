# ADR-042 — Formulários e validação: React Hook Form + Zod

- **Status:** Aceito
- **Data:** 2026-10-17
- **Decisores:** Equipe CromoCard

## Contexto

O CromoCard tem muitos formulários (cadastro, perfil, endereço, carta, anúncio, grupo). O backend
valida tudo com Zod (ADR-006). O usuário precisa de feedback imediato no formulário, sem esperar a
resposta da API, e com as mesmas regras do backend.

## Decisão

- **React Hook Form** com `@hookform/resolvers/zod`.
- O schema fica em `<feature>.schemas.ts` e espelha o `<dominio>.validator.ts` do backend, com as
  mesmas regras (ex.: nome com `trim`, de 2 a 120 caracteres). O tipo de entrada sai do schema
  (`z.infer`).
- O Zod é importado sempre de `@/lib/zod`, que configura as mensagens padrão em pt-BR
  (`z.locales.ptBR()`). Mensagens específicas ficam no próprio schema.
- A ligação com o React Hook Form fica num hook da feature (`hooks/use<Nome>Form.ts`). O componente
  do formulário recebe `onSubmit`, `isSubmitting` e `errorMessage` por props e não conhece a API, o
  que permite testá-lo isolado.
- O erro devolvido pela API (`ApiError.message` e, quando houver, `details` por campo) aparece no
  formulário.
- `<form noValidate>`: quem valida é o Zod, não o navegador.

## Alternativas consideradas

- **Formik:** mais re-renderizações e menos manutenção ativa.
- **Formulário controlado com `useState`:** validação, erros e estado de envio escritos à mão em
  cada formulário.
- **Validar só no backend:** o feedback só chega depois de uma ida ao servidor.

## Consequências

- As regras de validação existem nos dois lados, de propósito. Se divergirem, vale a do backend,
  que é quem protege os dados. O frontend valida pela experiência do usuário.
- Uma mudança num validator do backend exige mudar o schema da feature no frontend.

## Referências

- ADR-006, ADR-040
- `apps/cromocard-frontend/src/features/users/users.schemas.ts`, `hooks/useEditNameForm.ts`
