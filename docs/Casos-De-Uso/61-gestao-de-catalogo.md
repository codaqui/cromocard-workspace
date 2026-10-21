| Nome do Caso de Uso | Gestão de Catálogo |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador cadastre, edite e remova as cartas e os álbuns do catálogo global da plataforma. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado e possuir permissão para gerenciar o catálogo. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa a opção "Gestão de Catálogo". |  |
|  | 2. O sistema apresenta os itens cadastrados no catálogo. |
| 3. O administrador seleciona a opção de cadastrar, editar ou remover um item. |  |
|  | 4. O sistema apresenta o formulário ou as opções correspondentes. |
| 5. O administrador informa ou altera os dados do item. |  |
|  | 6. O sistema valida os dados informados. |
| 7. O administrador confirma a operação. |  |
|  | 8. O sistema registra a operação realizada. |
|  | 9. O sistema atualiza o catálogo e confirma a operação. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador informa dados inválidos. |  |
|  | 2. O sistema informa os dados que precisam ser corrigidos. |
| 3. O administrador corrige os dados. |  |
|  | 4. O sistema realiza novamente a validação. |
| 5. O administrador tenta remover um item que possui vínculos que impedem sua exclusão. |  |
|  | 6. O sistema impede a exclusão e informa o motivo. |

### Regras de Negócio

| Código | Regra |
|---|---|
| RN01 | Carta: nome, número, álbum, categoria (franquia), raridade e idioma são obrigatórios; descrição, imagem da frente e imagem do verso são opcionais. |
| RN02 | Álbum: título, categoria e ano são obrigatórios; editora, descrição, capa e total de cartas são opcionais. |
| RN03 | O número da carta é único dentro do mesmo álbum. |
| RN04 | Não é possível remover um álbum que ainda tenha cartas ativas (fluxo alternativo 5–6). |
| RN05 | Remover é soft delete (ADR-015); a carta ou o álbum deixa de aparecer no catálogo e nas buscas. |
| RN06 | Imagens: PNG, JPG ou WEBP, até 4 MB, enviadas pelo provider de storage (ADR-009). |
| RN07 | Toda criação, edição e remoção gera um registro em `audit_logs` (ADR-034). |
| RN08 | Raridades, idiomas e estados de conservação vêm de tabelas de apoio populadas por seed; não são editados nesta tela. |

### Critérios de Aceite (MVP)

- [ ] Lista paginada de cartas com imagem, nome, número, álbum, franquia e raridade.
- [ ] Busca por nome ou número e filtros por franquia (categoria), raridade e álbum.
- [ ] Cadastrar, editar e remover carta (RN01, RN03, RN05).
- [ ] Cadastrar, editar e remover álbum (RN02, RN04, RN05).
- [ ] Upload da imagem da frente, do verso e da capa do álbum (RN06).
- [ ] Mensagens de validação por campo no formulário.
- [ ] Cada operação aparece no Log de Auditoria (CCD065).

### Fora do Escopo do MVP

Importação em lote por CSV e indicadores de "custódia" e valor em R$. A gestão de categorias
fica no CCD066 (Módulo 2), como no Figma.

### Referências

- Figma: `administração - catalago`, `administração - cadastrar carta`
- DER: `cards`, `albums`, `categories`, `rarities`, `languages`
