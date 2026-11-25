# TechTalent — Banco de Dados & SQL

Implementação inicial da Etapa de BD do Projeto Evolutivo de Dados da equipe 09 — Microinformática Aplicada, Fatec São Paulo, 2026/2.

O banco usa **SQLite 3** e mantém o modelo definido em `03-powerpivot/docs/modelo_relacional.md`. A ideia é persistir os dados tratados na Etapa 2, aplicar integridade relacional e disponibilizar views com a estrutura dimensional da Etapa 3.

> **Estado desta entrega:** scripts DDL, carga, consultas, views, conferência e documentação preparados. Não foi incluído um `techtalent.db` preenchido com dados fictícios de teste.

## Conteúdo

| Arquivo | Finalidade |
|---|---|
| `techtalent_ddl.sql` | Cria as tabelas de staging, dimensões, fatos, auditoria, restrições e índices. |
| `techtalent_carga.sql` | Converte os campos recebidos na staging e carrega as tabelas definitivas. Pode ser reexecutado. |
| `techtalent_consultas.sql` | Consultas analíticas C1–C6. |
| `techtalent_views.sql` | Views de dimensão e fato para consumo pelo Power BI. |
| `techtalent_conferencia.sql` | Batimento de volumes, integridade referencial, chaves, calendário e referências de negócio. |
| `docs/modelo_relacional.md` | Modelo relacional, grãos, chaves e decisões de modelagem. |
| `docs/importacao_dados.md` | Passo a passo para preparar e importar os dados tratados. |
| `csv/README.md` | Indica as fontes CSV canônicas e os exports locais necessários. |
| `evidencias/README.md` | Lista as evidências que devem ser anexadas após a carga real. |
| `docs/diagrama_er.mmd` / `docs/diagrama_er.png` | Diagrama ER em Mermaid e imagem para documentação. |
| `tests/test_sqlite.py` | Smoke tests em SQLite usando somente dados sintéticos mínimos. |

## Ordem de execução

1. Crie um banco novo chamado `techtalent.db` no DB Browser for SQLite.
2. Execute **uma vez** `techtalent_ddl.sql`.
3. Importe os dados para as tabelas `stg_*`, seguindo `docs/importacao_dados.md`.
4. Execute `techtalent_carga.sql`.
5. Execute `techtalent_views.sql`.
6. Execute as consultas de `techtalent_consultas.sql`.
7. Execute `techtalent_conferencia.sql` e salve as evidências em `evidencias/`.

O DDL é destrutivo: ele apaga e recria os objetos desta etapa. Não o execute novamente depois de carregar os dados sem fazer backup, pois as tabelas de staging e definitivas serão apagadas.

## Modelo e convenções

- As tabelas físicas usam o prefixo `tb_` para não conflitar com as views da camada analítica.
- As views públicas preservam os nomes do modelo da Etapa 3: `dim_cargo`, `dim_orgao`, `dim_tempo`, `dim_cargo_salarios`, `dim_pais_empresa`, `dim_pais_residencia`, `dim_ano`, `fato_vagas`, `fato_salarios` e `fato_metas`.
- `fato_vagas` preserva os 36 campos de `fVagas`; `fato_salarios` preserva os 21 campos de `fSalarios`.
- `ID_Vaga` não é chave primária: uma vaga pode gerar publicações internas e externas. A chave técnica é `ID_Registro_FaseI`.
- `dim_cargo` e `dim_cargo_salarios` permanecem independentes. Não existe correspondência validada entre as duas taxonomias.
- Um cadastro físico `tb_pais` atende aos dois papéis da fato salarial, por meio das FKs `cod_pais_empresa` e `cod_pais_residencia`. As duas views de papel são disponibilizadas separadamente.
- O calendário é gerado em SQL para 01/01/2026 a 31/12/2026. `Feriado` permanece `Não informado`.
- As metas são exclusivamente `SIMULADO`; anúncios não comprovam contratações realizadas.
- Nenhuma conversão cambial é aplicada. `Salario_USD` é preservado como fornecido pela fonte, e a periodicidade histórica permanece não confirmada.

## Preservação dos rejeitados

`Rejeitados` **não deve ser tratado como se tivesse o mesmo esquema de `fVagas`**. O CSV deve ser exportado diretamente da consulta original, mantendo todos os cabeçalhos e colunas `*_Original`.

O preparador Python cria os campos de consulta rápida e serializa todos os campos originais em JSON. Colunas adicionais que venham a existir na consulta também são preservadas automaticamente.

## Resultado esperado da conferência

Os valores abaixo são as referências documentadas nas Etapas 2 e 3 do repositório atual. Depois da carga, as diferenças devem ser zero:

| Indicador | Referência |
|---|---:|
| Vagas aceitas | 232 |
| Posições reportadas nos anúncios | 260 |
| IDs distintos por fonte | 122 |
| Observações salariais | 6.599 |
| Metas mensais simuladas | 12 |
| Soma das metas simuladas | 31 |
| Registros rejeitados | 8 |
| Cargos de vagas | 45 |
| Órgãos/empresas | 31 |
| Cargos salariais | 132 |
| Países | 89 |
| Anos salariais | 5 |
| Dias do calendário | 365 |

A conferência também deve apresentar `PRAGMA foreign_key_check` sem linhas, nenhum registro órfão e nenhuma duplicidade de chave.

## Limite da análise de habilidades

O campo `Habilidades` de `fVagas` é texto livre e parte dos anúncios não informa habilidades. A consulta C2 faz busca textual controlada por termos conhecidos; ela não representa uma extração completa de competências nem substitui uma taxonomia validada. Uma futura tabela associativa `habilidade` / `vaga_habilidade` deve ser criada somente depois de serem definidas as regras de extração e padronização.

## Compatibilidade e validação técnica

Os scripts foram executados em SQLite 3 com dados sintéticos mínimos para validar sintaxe, criação das tabelas, carga, views, consultas e conferência. A carga foi executada duas vezes para validar sua reexecução. Os mesmos testes podem ser repetidos com `python tests/test_sqlite.py` (somente biblioteca padrão do Python). Isso **não** substitui a execução com os CSVs reais nem a conferência dos quantitativos finais documentados acima.

Consulte `docs/importacao_dados.md` antes de importar. Além dos dois CSVs limpos já versionados, a staging recebe exports das tabelas `dCargo`, `dOrgao`, `fMetas` e `Rejeitados` da pasta de trabalho da Etapa 2.
