| Nome do Caso de Uso | Configurações Globais |
|---|---|
| Finalidade/Objetivo | Permitir que o administrador configure parâmetros gerais que afetam o funcionamento da plataforma. |
| Atores | Administrador |
| Pré Condições | O administrador deve estar autenticado e possuir permissão para alterar as configurações globais. |

### Fluxo Principal

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador acessa a opção "Configurações Globais". |  |
|  | 2. O sistema apresenta as configurações disponíveis. |
| 3. O administrador seleciona uma configuração. |  |
|  | 4. O sistema apresenta os valores atuais da configuração. |
| 5. O administrador altera os valores desejados. |  |
|  | 6. O sistema valida as informações inseridas. |
| 7. O administrador confirma as alterações. |  |
|  | 8. O sistema salva as novas configurações. |
|  | 9. O sistema confirma que as configurações foram atualizadas. |

### Fluxo Alternativo

| Ações do Ator | Ações do Sistema |
|---|---|
| 1. O administrador informa um valor inválido para uma configuração. |  |
|  | 2. O sistema identifica o valor inválido e informa o administrador. |
| 3. O administrador corrige o valor. |  |
|  | 4. O sistema realiza novamente a validação. |
| 5. O administrador cancela as alterações. |  |
|  | 6. O sistema descarta as alterações e mantém as configurações anteriores. |

### Regras de Negócio

| Código | Regra |
|---|---|
| RN01 | **Módulo 1 — Banner da Home.** Campos: exibir banner (sim/não), título (até 80 caracteres), subtítulo (até 200), texto do botão (até 30), link do botão (URL `http` ou `https`) e imagem (PNG, JPG ou WEBP, até 4 MB, 1920×600). Cada campo é uma chave em `global_settings` (`home.banner.*`). |
| RN02 | O banner é lido pela Home pública (CCD001) sem autenticação; com "exibir banner" desligado, a Home não mostra o bloco. |
| RN03 | **Módulo 2 — Categorias padrão.** Criar, editar, remover (soft delete) e reordenar as categorias exibidas no menu e na vitrine. |
| RN04 | O `slug` da categoria é gerado a partir do nome (minúsculas, sem acentos, espaços viram hífen) e é único. Recriar uma categoria removida com o mesmo nome restaura a linha (ADR-015). |
| RN05 | A ordem de exibição é guardada em `display_order`; mover para cima ou para baixo troca a ordem com a categoria vizinha. |
| RN06 | Não é possível remover uma categoria que tenha álbuns ou cartas ativos. |
| RN07 | Cada alteração salva gera um registro em `audit_logs` (`SETTINGS_UPDATED` ou `CATEGORY_*`). |

### Critérios de Aceite (MVP)

- [ ] Módulo 1: editar os campos do banner com pré-visualização e salvar (RN01).
- [ ] Módulo 1: endpoint público que devolve o banner ativo para a Home (RN02).
- [ ] Módulo 2: listar categorias na ordem de `display_order`, com nome, slug e quantidade de cartas.
- [ ] Módulo 2: adicionar, editar, remover e reordenar categorias (RN03 a RN06).
- [ ] Mensagens de validação por campo; cancelar descarta as alterações.
- [ ] Cada alteração aparece no Log de Auditoria (CCD065).

### Fora do Escopo do MVP

Templates de notificação (não existem no Figma), fixar categoria no topo e hierarquia
editável de subcategorias. Decisão no ADR-038.

### Referências

- Figma: `administração - configurações da plataforma`
- DER: `global_settings`, `categories.slug`, `categories.display_order` (ADR-038)
