# ADR-072 — Prints como evidência da denúncia do chat pessoal

- **Status:** Proposto (aguardando validação do PO)
- **Data:** 2026-11-26
- **Decisores:** Daniel Andrade, na CCD047 (Moderar Contatos Privados), lacunas L3 e L7
- **Complementa:** ADR-032 (alvo polimórfico de `reports`) e ADR-050 (upload de arquivos)

## Contexto

A denúncia feita pelo chat pessoal grava em `reports` o contato denunciado, o motivo e a descrição. Isso não basta para a
moderação decidir: a conversa é privada, e ninguém do BackOffice a vê. O protótipo (frame `1160-34298`) propunha
"Anexar as últimas 20 mensagens", mas o DBML não tem onde guardar essa ligação (`reports` não aponta para `messages`).

O Daniel decidiu que toda denúncia do chat precisa levar evidência, e que a evidência é o print que o próprio usuário
envia.

## Decisão

1. **Tabela nova `report_evidences`** (módulo 8, Moderação e Administração): `id`, `report_id` (FK para `reports`),
   `url`, `sort_order` e as colunas de tempo (ADR-016). Uma denúncia tem várias evidências; a evidência não existe sem a
   denúncia.
2. **De 1 a 3 prints, obrigatórios**, na denúncia feita pelo chat pessoal (`target_type = USER`). Sem print, a API
   responde `400`.
3. **Mesmas regras do ADR-050:** PNG, JPG ou WEBP até 4 MB cada, enviados no mesmo pedido da denúncia (`multipart`), no
   `StorageProvider` (pasta `report-evidences`); o banco guarda a URL. A denúncia e as evidências são gravadas na mesma
   transação.
4. **Quem vê:** só o denunciante (ao enviar) e o administrador, na Fila de moderação da Gestão de Comunidade (CCD062),
   que mostra as miniaturas no card da denúncia.
5. **Alcance:** as outras denúncias (perfil, anúncio, vendedor e mensagem de grupo) podem adotar a mesma tabela quando
   as suas specs decidirem; esta decisão não as obriga.

## Alternativas consideradas

- **Anexar as últimas 20 mensagens pelo servidor:** a prova não pode ser montada, mas exige ligar `reports` a `messages`
  (tabela associativa) e expor uma conversa privada inteira ao BackOffice. Ficou fora por decisão do Daniel.
- **Prints opcionais:** a denúncia sem evidência continuaria chegando à fila, sem como a moderação decidir.
- **Coluna JSON com as URLs em `reports`:** evita a tabela, mas foge do padrão do DER (as fotos do anúncio já usam
  `listing_photos`) e não guarda a ordem nem o soft delete por arquivo.

## Consequências

- O DER passa a 51 tabelas, com a FK `report_evidences.report_id → reports.id`; o diagrama de classes ganha
  `EvidenciaDenuncia`.
- A rota de denúncia do chat recebe `multipart/form-data`, com o limite de 4 MB por arquivo e no máximo 3 arquivos.
- Um print pode ser montado: a moderação decide olhando o print, o motivo e o histórico do usuário (advertências da
  CCD099).
