# Importação dos dados para a staging

Este roteiro explica como preparar as tabelas `stg_*` antes de executar `techtalent_carga.sql`.

## 1. Arquivos de origem já existentes no repositório

Use os dados limpos da Etapa 2, não as bases brutas:

- `MA2026-entrega-parcial/02-powerquery/dados_limpos/fVagas.csv` — 232 publicações aceitas, 36 colunas.
- `MA2026-entrega-parcial/02-powerquery/dados_limpos/fSalarios.csv` — 6.599 observações, 21 colunas.

Os arquivos são UTF-8 com BOM, separados por vírgula, com datas ISO e números decimais com ponto, conforme o README da Etapa 2.

## 2. Exports necessários da pasta de trabalho da Etapa 2

A pasta de trabalho `TechTalent_02_PowerQuery.xlsx` também contém as tabelas `dCargo`, `dOrgao`, `fMetas` e `Rejeitados`. Exporte essas tabelas para CSV, usando os campos abaixo. Para simplificar a importação, use a ordem indicada e salve com UTF-8.

### 2.1 `stg_cargo`

Exporte da tabela `dCargo` estas seis colunas, nesta ordem:

```text
Cod_Cargo,Cargo,Categoria,Salario_Ref,Moeda_Ref,Periodicidade_Ref
```

A dimensão é carregada diretamente do cadastro tratado da Etapa 2, preservando também cargos que não precisem ser reconstruídos a partir das linhas da fato.

### 2.2 `stg_orgao`

Exporte da tabela `dOrgao` estas duas colunas, nesta ordem:

```text
Cod_Orgao,Orgao
```

### 2.3 `stg_metas`

Exporte da tabela `fMetas` estas cinco colunas, nesta ordem:

```text
Fonte,Cod_Orgao,AnoMes,Mes_Inicio,Meta_Contratacoes
```

Mantenha `Fonte = SIMULADO`. `Mes_Inicio` deve ser o primeiro dia do mês no formato `YYYY-MM-01`. Não converta metas em contratações realizadas.

### 2.4 `stg_rejeitados` — formato corrigido

**Não exporte `Rejeitados` como se tivesse o mesmo esquema de `fVagas`.** A consulta de rejeitados conserva colunas da origem com seus próprios nomes, como `ID_Vaga_Original` e `Quantidade_Original`. A exportação original atual possui 51 colunas; o script não fixa essa quantidade: ele preserva dinamicamente todos os cabeçalhos e valores presentes no CSV.

1. Exporte a tabela/consulta `Rejeitados` inteira diretamente para CSV. Não renomeie, remova ou reordene colunas; mantenha `ID_Vaga_Original`, `Quantidade_Original`, o motivo e todas as demais colunas originais.
2. Execute o preparador a partir da pasta `05-sql`:

   ```bash
   python techtalent_preparar_rejeitados.py \
     --input caminho/Rejeitados.csv \
     --output csv/stg_rejeitados.csv \
     --base Vagas
   ```

3. O script exige `ID_Vaga_Original`, `Quantidade_Original` e uma coluna de motivo (`Motivo`, `Motivo_Rejeicao` ou `Diagnostico`). Se um desses campos estiver ausente, a execução para e mostra os cabeçalhos encontrados, em vez de produzir uma carga parcial.
4. O preparador gera um CSV intermediário com oito campos na ordem esperada pela staging:

   ```text
   Base,Fonte,Arquivo_Origem,Linha_Origem,ID_Vaga_Original,Quantidade_Original,Motivo_Rejeicao,Dados_Originais_JSON
   ```

5. `Dados_Originais_JSON` contém todos os campos e valores de cada linha original, com os nomes originais dos cabeçalhos. Isso inclui outras colunas `*_Original` e campos adicionais que venham a ser incluídos na consulta futuramente. Os valores originais não são convertidos nem corrigidos.
6. Importe `csv/stg_rejeitados.csv` na tabela existente `stg_rejeitados`. Não edite o conteúdo do JSON e não converta `Quantidade_Original` em número: até mesmo valores inválidos precisam permanecer disponíveis para auditoria.

Na versão atual do conjunto de dados, são esperados oito rejeitados. O total é conferido pela consulta K1 e a preservação integral pelo bloco K5/K5.1 de `techtalent_conferencia.sql`.

## 3. Importação no DB Browser for SQLite

1. Crie `techtalent.db` e execute `techtalent_ddl.sql`.
2. Importe cada CSV **para a tabela de staging existente** correspondente: `stg_vagas`, `stg_salarios`, `stg_cargo`, `stg_orgao`, `stg_metas` e `stg_rejeitados`.
3. Confirme que a primeira linha foi interpretada como cabeçalho e que o separador é vírgula.
4. Confira as contagens da staging:
   - `stg_vagas`: 232 linhas;
   - `stg_salarios`: 6.599 linhas;
   - `stg_cargo`: 45 linhas;
   - `stg_orgao`: 31 linhas;
   - `stg_metas`: 12 linhas;
   - `stg_rejeitados`: 8 linhas.
5. Execute `techtalent_carga.sql` e verifique o resumo de linhas ao final.

> Se o DB Browser oferecer criar uma tabela nova durante a importação, não substitua a tabela `stg_*` já criada pelo DDL. Selecione a tabela existente para inserir os registros. Não altere a ordem dos campos.

## 4. Conversões

Os dados numéricos são convertidos no script de carga usando `CAST` depois de transformar texto vazio em `NULL`. O script não troca ponto e vírgula decimal porque os CSVs limpos da Etapa 2 foram publicados com ponto decimal.

- Datas: `YYYY-MM-DD`.
- Números: ponto decimal, sem separador de milhar.
- Campos opcionais vazios: `NULL`.
- Textos longos de descrição, requisitos, habilidades e observação: preservados como texto.
- Rejeitados: preservados como texto, sem casts ou FKs.

## 5. Verificação

Depois de executar carga, views e conferência:

- Todas as diferenças de K1 devem ser zero.
- `PRAGMA foreign_key_check` não deve retornar linhas.
- Os testes K3 e K4 devem retornar zero ocorrências.
- O calendário deve cobrir 365 dias de 01/01/2026 a 31/12/2026.
- A consulta K8 deve reproduzir R$ 48.000 de referência simulada BRL/mês e R$ 45.500 de limite mínimo anunciado, conforme a documentação da Etapa 3.
- A consulta K9 deve apresentar, para NYC, 225 publicações, 70 sem habilidades informadas e 31,11%.
- A consulta K10 deve apresentar 18 anúncios NYC com `Excel` como palavra completa; ocorrências de `excellent` não devem ser contadas.
- Na conferência K5, `json_invalidos`, `sem_motivo`, `divergencias_id_vaga_original` e `divergencias_quantidade_original` devem ser zero.

Se algum batimento falhar, não corrija diretamente os dados da tabela final. Confira o export da Etapa 2, corrija a etapa de origem e refaça a carga.

## 6. DDL e banco local

O DDL atualizado usa `CREATE TABLE IF NOT EXISTS` e `CREATE INDEX IF NOT EXISTS`; não contém `DROP TABLE` nem `DROP VIEW`. Executá-lo outra vez não apaga tabelas, views ou dados. As views são criadas/atualizadas somente por `techtalent_views.sql`.

Atenção: `IF NOT EXISTS` não altera uma tabela que já existe. Se o seu arquivo SQLite local foi criado com uma versão anterior do DDL, cujo esquema de `stg_rejeitados`/`tb_rejeitado` era diferente, preserve o arquivo antigo como backup e crie um novo banco SQLite para a estrutura atualizada. Reimporte os CSVs de origem e execute o fluxo novamente. Não existe migração automática do esquema antigo.
