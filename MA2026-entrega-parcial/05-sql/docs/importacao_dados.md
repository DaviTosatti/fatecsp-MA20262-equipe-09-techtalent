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

### 2.4 `stg_rejeitados`

Exporte os oito registros da tabela `Rejeitados`. O destino precisa conter `Base`, os 36 campos originais de `fVagas` na mesma ordem do arquivo `fVagas.csv` e, ao final, `Motivo_Rejeicao`:

```text
Base,Fonte,Fonte_Dados,Arquivo_Origem,Linha_Origem,ID_Registro_FaseI,Linha_FaseI,ID_Vaga,Cod_Orgao,Orgao,Cod_Cargo,Cargo,Titulo,Categoria,Tipo_Publicacao,Quantidade,Salario_Min,Salario_Max,Amplitude_Salarial,Ponto_Medio_Faixa,Moeda,Periodicidade,Data_Publicacao,Hora_Atendimento_Tratada,Mes_Publicacao,Atualizacao,Limite_Candidatura,Modalidade,Vinculo,Localidade,Localidade_Detalhe,Horario_Jornada,Descricao,Requisitos,Habilidades,Observacao_Qualidade,ID_Cenario,Motivo_Rejeicao
```

Se a coluna de motivo na consulta tiver outro cabeçalho (por exemplo, `Motivo`), renomeie-a para `Motivo_Rejeicao` no CSV exportado. Preserve o valor original de cada campo rejeitado; não tente corrigir quantidade, data, hora, cargo ou órgão durante a exportação. Os oito rejeitados documentados são de vagas; a base salarial não possui rejeitados na reconciliação da Etapa 2.

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

Se algum batimento falhar, não corrija diretamente os dados da tabela final. Confira o export da Etapa 2, corrija a etapa de origem e refaça a carga.
