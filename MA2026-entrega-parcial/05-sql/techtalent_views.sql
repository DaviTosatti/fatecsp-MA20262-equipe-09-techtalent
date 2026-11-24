-- ============================================================================
-- techtalent_views.sql
-- Camada de consumo para a Etapa 7 (Power BI), espelhando o modelo estrela
-- documentado na Etapa 3. Execute depois da DDL e da carga.
-- ============================================================================

PRAGMA foreign_keys = ON;

DROP VIEW IF EXISTS auditoria_rejeitados;
DROP VIEW IF EXISTS fato_metas;
DROP VIEW IF EXISTS fato_salarios;
DROP VIEW IF EXISTS fato_vagas;
DROP VIEW IF EXISTS dim_ano;
DROP VIEW IF EXISTS dim_pais_residencia;
DROP VIEW IF EXISTS dim_pais_empresa;
DROP VIEW IF EXISTS dim_cargo_salarios;
DROP VIEW IF EXISTS dim_tempo;
DROP VIEW IF EXISTS dim_orgao;
DROP VIEW IF EXISTS dim_cargo;

CREATE VIEW dim_cargo AS
SELECT
    cod_cargo AS Cod_Cargo,
    cargo AS Cargo,
    categoria AS Categoria,
    salario_ref AS Salario_Ref,
    moeda_ref AS Moeda_Ref,
    periodicidade_ref AS Periodicidade_Ref
FROM tb_dim_cargo;

CREATE VIEW dim_orgao AS
SELECT cod_orgao AS Cod_Orgao, orgao AS Orgao
FROM tb_dim_orgao;

CREATE VIEW dim_tempo AS
SELECT
    data AS Data,
    ano AS Ano,
    mes AS Mes,
    nome_mes AS NomeMes,
    mes_abrev AS MesAbrev,
    ano_mes AS AnoMes,
    mes_inicio AS Mes_Inicio,
    trimestre AS Trimestre,
    dia_semana AS DiaSemana,
    nome_dia AS NomeDia,
    fim_de_semana AS FimDeSemana,
    feriado AS Feriado
FROM tb_dim_calendario;

CREATE VIEW dim_cargo_salarios AS
SELECT
    cod_cargo_salarial AS Cod_Cargo_Salarial,
    cargo AS Cargo
FROM tb_dim_cargo_salarios;

CREATE VIEW dim_pais_empresa AS
SELECT cod_pais AS Cod_Pais, pais AS Pais
FROM tb_pais;

CREATE VIEW dim_pais_residencia AS
SELECT cod_pais AS Cod_Pais, pais AS Pais
FROM tb_pais;

CREATE VIEW dim_ano AS
SELECT ano AS Ano
FROM tb_dim_ano;

CREATE VIEW fato_vagas AS
SELECT
    fonte AS Fonte,
    fonte_dados AS Fonte_Dados,
    arquivo_origem AS Arquivo_Origem,
    linha_origem AS Linha_Origem,
    id_registro_fase1 AS ID_Registro_FaseI,
    linha_fase1 AS Linha_FaseI,
    id_vaga AS ID_Vaga,
    cod_orgao AS Cod_Orgao,
    orgao AS Orgao,
    cod_cargo AS Cod_Cargo,
    cargo AS Cargo,
    titulo AS Titulo,
    categoria AS Categoria,
    tipo_publicacao AS Tipo_Publicacao,
    quantidade AS Quantidade,
    salario_min AS Salario_Min,
    salario_max AS Salario_Max,
    amplitude_salarial AS Amplitude_Salarial,
    ponto_medio_faixa AS Ponto_Medio_Faixa,
    moeda AS Moeda,
    periodicidade AS Periodicidade,
    data_publicacao AS Data_Publicacao,
    hora_atendimento_tratada AS Hora_Atendimento_Tratada,
    mes_publicacao AS Mes_Publicacao,
    atualizacao AS Atualizacao,
    limite_candidatura AS Limite_Candidatura,
    modalidade AS Modalidade,
    vinculo AS Vinculo,
    localidade AS Localidade,
    localidade_detalhe AS Localidade_Detalhe,
    horario_jornada AS Horario_Jornada,
    descricao AS Descricao,
    requisitos AS Requisitos,
    habilidades AS Habilidades,
    observacao_qualidade AS Observacao_Qualidade,
    id_cenario AS ID_Cenario
FROM tb_fato_vagas;

CREATE VIEW fato_salarios AS
SELECT
    fonte AS Fonte,
    arquivo_origem AS Arquivo_Origem,
    linha_origem AS Linha_Origem,
    id_registro_fase1 AS ID_Registro_FaseI,
    linha_fase1 AS Linha_FaseI,
    cod_cargo_salarial AS Cod_Cargo_Salarial,
    cargo AS Cargo,
    experiencia AS Experiencia,
    vinculo AS Vinculo,
    modalidade AS Modalidade,
    ano AS Ano,
    cod_pais_residencia AS Cod_Pais_Residencia,
    pais_residencia AS Pais_Residencia,
    cod_pais_empresa AS Cod_Pais_Empresa,
    pais_empresa AS Pais_Empresa,
    porte AS Porte,
    salario AS Salario,
    moeda AS Moeda,
    salario_usd AS Salario_USD,
    periodicidade AS Periodicidade,
    observacao AS Observacao
FROM tb_fato_salarios;

CREATE VIEW fato_metas AS
SELECT
    fonte AS Fonte,
    cod_orgao AS Cod_Orgao,
    ano_mes AS AnoMes,
    mes_inicio AS Mes_Inicio,
    meta_contratacoes AS Meta_Contratacoes
FROM tb_fato_metas;

CREATE VIEW auditoria_rejeitados AS
SELECT
    base AS Base,
    fonte AS Fonte,
    arquivo_origem AS Arquivo_Origem,
    linha_origem AS Linha_Origem,
    id_registro_fase1 AS ID_Registro_FaseI,
    id_vaga AS ID_Vaga,
    cod_orgao AS Cod_Orgao,
    cod_cargo AS Cod_Cargo,
    motivo_rejeicao AS Motivo_Rejeicao
FROM tb_rejeitado;
