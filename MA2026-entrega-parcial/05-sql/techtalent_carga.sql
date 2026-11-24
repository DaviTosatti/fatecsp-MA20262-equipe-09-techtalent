-- ============================================================================
-- techtalent_carga.sql
-- Carga reexecutavel: converte os campos da staging e popula as tabelas finais.
-- Pre-requisito: DDL executado e todas as tabelas stg_* importadas.
-- Formato esperado dos CSVs: UTF-8, virgula, datas ISO (YYYY-MM-DD), decimal com ponto.
-- ============================================================================

PRAGMA foreign_keys = ON;
BEGIN IMMEDIATE TRANSACTION;

-- Limpa somente as tabelas finais. A staging permanece preenchida para auditoria.
DELETE FROM tb_rejeitado;
DELETE FROM tb_fato_metas;
DELETE FROM tb_fato_salarios;
DELETE FROM tb_fato_vagas;
DELETE FROM tb_dim_ano;
DELETE FROM tb_pais;
DELETE FROM tb_dim_cargo_salarios;
DELETE FROM tb_dim_calendario;
DELETE FROM tb_dim_orgao;
DELETE FROM tb_dim_cargo;

-- ---------------------------------------------------------------------------
-- 1. Dimensoes derivadas dos dados aceitos e dos cadastros da Etapa 2
-- ---------------------------------------------------------------------------

INSERT INTO tb_dim_cargo (
    cod_cargo, cargo, categoria, salario_ref, moeda_ref, periodicidade_ref
)
SELECT
    TRIM(Cod_Cargo),
    MIN(TRIM(Cargo)),
    MIN(NULLIF(TRIM(Categoria), '')),
    MAX(CAST(NULLIF(TRIM(Salario_Ref), '') AS NUMERIC)),
    MAX(NULLIF(TRIM(Moeda_Ref), '')),
    MAX(NULLIF(TRIM(Periodicidade_Ref), ''))
FROM stg_cargo
WHERE NULLIF(TRIM(Cod_Cargo), '') IS NOT NULL
  AND NULLIF(TRIM(Cargo), '') IS NOT NULL
GROUP BY TRIM(Cod_Cargo);

INSERT INTO tb_dim_orgao (cod_orgao, orgao)
SELECT TRIM(Cod_Orgao), MIN(TRIM(Orgao))
FROM stg_orgao
WHERE NULLIF(TRIM(Cod_Orgao), '') IS NOT NULL
  AND NULLIF(TRIM(Orgao), '') IS NOT NULL
GROUP BY TRIM(Cod_Orgao);

INSERT INTO tb_dim_cargo_salarios (cod_cargo_salarial, cargo)
SELECT TRIM(Cod_Cargo_Salarial), MIN(TRIM(Cargo))
FROM stg_salarios
WHERE NULLIF(TRIM(Cod_Cargo_Salarial), '') IS NOT NULL
  AND NULLIF(TRIM(Cargo), '') IS NOT NULL
GROUP BY TRIM(Cod_Cargo_Salarial);

INSERT INTO tb_pais (cod_pais, pais)
SELECT cod_pais, MIN(pais)
FROM (
    SELECT TRIM(Cod_Pais_Empresa) AS cod_pais, TRIM(Pais_Empresa) AS pais
    FROM stg_salarios
    WHERE NULLIF(TRIM(Cod_Pais_Empresa), '') IS NOT NULL
      AND NULLIF(TRIM(Pais_Empresa), '') IS NOT NULL
    UNION ALL
    SELECT TRIM(Cod_Pais_Residencia), TRIM(Pais_Residencia)
    FROM stg_salarios
    WHERE NULLIF(TRIM(Cod_Pais_Residencia), '') IS NOT NULL
      AND NULLIF(TRIM(Pais_Residencia), '') IS NOT NULL
)
GROUP BY cod_pais;

INSERT INTO tb_dim_ano (ano)
SELECT DISTINCT CAST(TRIM(Ano) AS INTEGER)
FROM stg_salarios
WHERE NULLIF(TRIM(Ano), '') IS NOT NULL;

-- Calendario continuo de 01/01 a 31/12/2026; feriados nao informados.
WITH RECURSIVE dias(data) AS (
    SELECT '2026-01-01'
    UNION ALL
    SELECT date(data, '+1 day')
    FROM dias
    WHERE data < '2026-12-31'
)
INSERT INTO tb_dim_calendario (
    data, ano, mes, nome_mes, mes_abrev, ano_mes, mes_inicio,
    trimestre, dia_semana, nome_dia, fim_de_semana, feriado
)
SELECT
    data,
    CAST(strftime('%Y', data) AS INTEGER),
    CAST(strftime('%m', data) AS INTEGER),
    CASE CAST(strftime('%m', data) AS INTEGER)
        WHEN 1 THEN 'Janeiro' WHEN 2 THEN 'Fevereiro' WHEN 3 THEN 'Março'
        WHEN 4 THEN 'Abril' WHEN 5 THEN 'Maio' WHEN 6 THEN 'Junho'
        WHEN 7 THEN 'Julho' WHEN 8 THEN 'Agosto' WHEN 9 THEN 'Setembro'
        WHEN 10 THEN 'Outubro' WHEN 11 THEN 'Novembro' WHEN 12 THEN 'Dezembro'
    END,
    CASE CAST(strftime('%m', data) AS INTEGER)
        WHEN 1 THEN 'Jan' WHEN 2 THEN 'Fev' WHEN 3 THEN 'Mar'
        WHEN 4 THEN 'Abr' WHEN 5 THEN 'Mai' WHEN 6 THEN 'Jun'
        WHEN 7 THEN 'Jul' WHEN 8 THEN 'Ago' WHEN 9 THEN 'Set'
        WHEN 10 THEN 'Out' WHEN 11 THEN 'Nov' WHEN 12 THEN 'Dez'
    END,
    substr(data, 1, 7),
    date(data, 'start of month'),
    'T' || CAST(((CAST(strftime('%m', data) AS INTEGER) - 1) / 3) + 1 AS TEXT),
    ((CAST(strftime('%w', data) AS INTEGER) + 6) % 7) + 1,
    CASE CAST(strftime('%w', data) AS INTEGER)
        WHEN 0 THEN 'Domingo' WHEN 1 THEN 'Segunda-feira'
        WHEN 2 THEN 'Terça-feira' WHEN 3 THEN 'Quarta-feira'
        WHEN 4 THEN 'Quinta-feira' WHEN 5 THEN 'Sexta-feira'
        WHEN 6 THEN 'Sábado'
    END,
    CASE WHEN CAST(strftime('%w', data) AS INTEGER) IN (0, 6) THEN 'Sim' ELSE 'Não' END,
    'Não informado'
FROM dias;

-- ---------------------------------------------------------------------------
-- 2. Fato de vagas: preserva os 36 campos de fVagas
-- ---------------------------------------------------------------------------

INSERT INTO tb_fato_vagas (
    fonte, fonte_dados, arquivo_origem, linha_origem, id_registro_fase1,
    linha_fase1, id_vaga, cod_orgao, orgao, cod_cargo, cargo, titulo,
    categoria, tipo_publicacao, quantidade, salario_min, salario_max,
    amplitude_salarial, ponto_medio_faixa, moeda, periodicidade,
    data_publicacao, hora_atendimento_tratada, mes_publicacao, atualizacao,
    limite_candidatura, modalidade, vinculo, localidade, localidade_detalhe,
    horario_jornada, descricao, requisitos, habilidades, observacao_qualidade,
    id_cenario
)
SELECT
    TRIM(Fonte), NULLIF(TRIM(Fonte_Dados), ''), NULLIF(TRIM(Arquivo_Origem), ''),
    CAST(NULLIF(TRIM(Linha_Origem), '') AS INTEGER), TRIM(ID_Registro_FaseI),
    CAST(NULLIF(TRIM(Linha_FaseI), '') AS INTEGER), NULLIF(TRIM(ID_Vaga), ''),
    TRIM(Cod_Orgao), TRIM(Orgao), TRIM(Cod_Cargo), TRIM(Cargo),
    NULLIF(TRIM(Titulo), ''), NULLIF(TRIM(Categoria), ''), TRIM(Tipo_Publicacao),
    CAST(NULLIF(TRIM(Quantidade), '') AS INTEGER),
    CAST(NULLIF(TRIM(Salario_Min), '') AS NUMERIC),
    CAST(NULLIF(TRIM(Salario_Max), '') AS NUMERIC),
    CAST(NULLIF(TRIM(Amplitude_Salarial), '') AS NUMERIC),
    CAST(NULLIF(TRIM(Ponto_Medio_Faixa), '') AS NUMERIC),
    NULLIF(TRIM(Moeda), ''), NULLIF(TRIM(Periodicidade), ''),
    TRIM(Data_Publicacao), NULLIF(TRIM(Hora_Atendimento_Tratada), ''),
    NULLIF(TRIM(Mes_Publicacao), ''), NULLIF(TRIM(Atualizacao), ''),
    NULLIF(TRIM(Limite_Candidatura), ''), NULLIF(TRIM(Modalidade), ''),
    NULLIF(TRIM(Vinculo), ''), NULLIF(TRIM(Localidade), ''),
    NULLIF(TRIM(Localidade_Detalhe), ''), NULLIF(TRIM(Horario_Jornada), ''),
    NULLIF(Descricao, ''), NULLIF(Requisitos, ''), NULLIF(Habilidades, ''),
    NULLIF(Observacao_Qualidade, ''), NULLIF(TRIM(ID_Cenario), '')
FROM stg_vagas;

-- ---------------------------------------------------------------------------
-- 3. Fato salarial: preserva os 21 campos de fSalarios.
-- Salario_USD e mantido como veio da fonte; nao ha conversao cambial.
-- ---------------------------------------------------------------------------

INSERT INTO tb_fato_salarios (
    fonte, arquivo_origem, linha_origem, id_registro_fase1, linha_fase1,
    cod_cargo_salarial, cargo, experiencia, vinculo, modalidade, ano,
    cod_pais_residencia, pais_residencia, cod_pais_empresa, pais_empresa,
    porte, salario, moeda, salario_usd, periodicidade, observacao
)
SELECT
    TRIM(Fonte), NULLIF(TRIM(Arquivo_Origem), ''),
    CAST(NULLIF(TRIM(Linha_Origem), '') AS INTEGER), TRIM(ID_Registro_FaseI),
    CAST(NULLIF(TRIM(Linha_FaseI), '') AS INTEGER), TRIM(Cod_Cargo_Salarial),
    TRIM(Cargo), NULLIF(TRIM(Experiencia), ''), NULLIF(TRIM(Vinculo), ''),
    NULLIF(TRIM(Modalidade), ''), CAST(TRIM(Ano) AS INTEGER),
    TRIM(Cod_Pais_Residencia), TRIM(Pais_Residencia),
    TRIM(Cod_Pais_Empresa), TRIM(Pais_Empresa), NULLIF(TRIM(Porte), ''),
    CAST(NULLIF(TRIM(Salario), '') AS NUMERIC), NULLIF(TRIM(Moeda), ''),
    CAST(NULLIF(TRIM(Salario_USD), '') AS NUMERIC),
    NULLIF(TRIM(Periodicidade), ''), NULLIF(Observacao, '')
FROM stg_salarios;

-- ---------------------------------------------------------------------------
-- 4. Metas ficticias por empresa/mes
-- ---------------------------------------------------------------------------

INSERT INTO tb_fato_metas (fonte, cod_orgao, ano_mes, mes_inicio, meta_contratacoes)
SELECT
    TRIM(Fonte), TRIM(Cod_Orgao), TRIM(AnoMes), TRIM(Mes_Inicio),
    CAST(TRIM(Meta_Contratacoes) AS INTEGER)
FROM stg_metas;

-- ---------------------------------------------------------------------------
-- 5. Auditoria: registros rejeitados, sem conversao e sem FKs intencionais
-- ---------------------------------------------------------------------------

INSERT INTO tb_rejeitado (
    base, fonte, fonte_dados, arquivo_origem, linha_origem, id_registro_fase1,
    linha_fase1, id_vaga, cod_orgao, orgao, cod_cargo, cargo, titulo,
    categoria, tipo_publicacao, quantidade, salario_min, salario_max,
    amplitude_salarial, ponto_medio_faixa, moeda, periodicidade,
    data_publicacao, hora_atendimento_tratada, mes_publicacao, atualizacao,
    limite_candidatura, modalidade, vinculo, localidade, localidade_detalhe,
    horario_jornada, descricao, requisitos, habilidades, observacao_qualidade,
    id_cenario, motivo_rejeicao
)
SELECT
    COALESCE(NULLIF(TRIM(Base), ''), 'Vagas'), NULLIF(TRIM(Fonte), ''),
    NULLIF(TRIM(Fonte_Dados), ''), NULLIF(TRIM(Arquivo_Origem), ''),
    NULLIF(TRIM(Linha_Origem), ''), TRIM(ID_Registro_FaseI),
    NULLIF(TRIM(Linha_FaseI), ''), NULLIF(TRIM(ID_Vaga), ''),
    NULLIF(TRIM(Cod_Orgao), ''), NULLIF(TRIM(Orgao), ''),
    NULLIF(TRIM(Cod_Cargo), ''), NULLIF(TRIM(Cargo), ''),
    NULLIF(TRIM(Titulo), ''), NULLIF(TRIM(Categoria), ''),
    NULLIF(TRIM(Tipo_Publicacao), ''), NULLIF(TRIM(Quantidade), ''),
    NULLIF(TRIM(Salario_Min), ''), NULLIF(TRIM(Salario_Max), ''),
    NULLIF(TRIM(Amplitude_Salarial), ''), NULLIF(TRIM(Ponto_Medio_Faixa), ''),
    NULLIF(TRIM(Moeda), ''), NULLIF(TRIM(Periodicidade), ''),
    NULLIF(TRIM(Data_Publicacao), ''), NULLIF(TRIM(Hora_Atendimento_Tratada), ''),
    NULLIF(TRIM(Mes_Publicacao), ''), NULLIF(TRIM(Atualizacao), ''),
    NULLIF(TRIM(Limite_Candidatura), ''), NULLIF(TRIM(Modalidade), ''),
    NULLIF(TRIM(Vinculo), ''), NULLIF(TRIM(Localidade), ''),
    NULLIF(TRIM(Localidade_Detalhe), ''), NULLIF(TRIM(Horario_Jornada), ''),
    NULLIF(Descricao, ''), NULLIF(Requisitos, ''), NULLIF(Habilidades, ''),
    NULLIF(Observacao_Qualidade, ''), NULLIF(TRIM(ID_Cenario), ''),
    TRIM(Motivo_Rejeicao)
FROM stg_rejeitados;

COMMIT;

-- Conferencia rapida apos a carga:
SELECT 'tb_fato_vagas' AS tabela, COUNT(*) AS linhas FROM tb_fato_vagas
UNION ALL SELECT 'tb_fato_salarios', COUNT(*) FROM tb_fato_salarios
UNION ALL SELECT 'tb_fato_metas', COUNT(*) FROM tb_fato_metas
UNION ALL SELECT 'tb_rejeitado', COUNT(*) FROM tb_rejeitado;
