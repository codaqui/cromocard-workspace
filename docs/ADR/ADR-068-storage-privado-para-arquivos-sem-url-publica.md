# ADR-068 — Storage privado para arquivos sem URL pública

- **Status:** Proposto
- **Data:** 2026-11-22
- **Decisores:** Lucca Rocha (proposta, na CCD107); validação: PO
- **Complementa:** ADR-009 (storage via provider)

## Contexto

O ADR-009 colocou o storage atrás de um `StorageProvider` (local em dev, S3 depois). No driver local, tudo o que fica
na pasta `STORAGE_LOCAL_DIR` é servido em `/uploads`, sem autenticação: serve para imagens de cartas e banners, que
são públicas.

A CCD107 guarda por 90 dias os relatórios exportados pelo BackOffice (CCD063). Esses arquivos têm dados de cadastro
(nome, e-mail, papel) e só um administrador pode baixá-los, pela rota autenticada
`GET /api/v1/admin/reports/exports/:id/file` (spec CCD107, L3). Se ficassem na mesma pasta dos uploads, qualquer pessoa
com a chave do arquivo poderia baixá-lo por `/uploads`.

## Decisão

1. Arquivos sem URL pública ficam num **storage privado**, separado do público: no driver local, a pasta
   `STORAGE_LOCAL_PRIVATE_DIR` (padrão `storage-private`, no `.gitignore`), que nunca é servida por `/uploads`.
2. A factory de storage recebe a visibilidade (`public` ou `private`) e devolve o provider da pasta certa. Quando
   entrar o S3, o privado vira um bucket (ou prefixo) sem acesso público.
3. O `StorageProvider` ganha `read(key)`, que devolve o conteúdo ou `null` se o arquivo não existe. O arquivo privado só
   sai por rota autenticada, que lê o conteúdo e o devolve como download.
4. A configuração recusa a pasta privada igual à pública ou dentro dela.

## Alternativas consideradas

- **Mesma pasta, com um prefixo bloqueado no `/uploads`:** simples, mas depende de acertar a comparação de caminhos
  (maiúsculas no Windows, caracteres codificados na URL), e um erro expõe os arquivos.
- **Guardar o arquivo no banco (`bytea`):** sem pasta nova, mas pesa no banco e no backup para arquivos de até 90 dias.
- **Não guardar e gerar de novo no "Baixar":** era o plano original da CCD063; o PO decidiu que "Baixar" entrega o
  mesmo arquivo (CCD063, L6).

## Consequências

- Uma variável de ambiente nova (`STORAGE_LOCAL_PRIVATE_DIR`) e uma pasta a mais no volume do backend.
- Todo `StorageProvider` precisa implementar `read(key)`.
- Novos arquivos privados (ex.: documentos de vendedores) podem usar o mesmo storage.

## Referências

- ADR-009 (providers), ADR-053, item 9 (`report_exports`)
- `specs/CCD107-consultar-historico-de-relatorios/` (L3, L5)
