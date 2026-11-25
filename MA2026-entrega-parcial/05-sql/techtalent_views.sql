-- ============================================================================
-- techtalent_views.sql
-- Views para consumo analitico e futura conexao com o Power BI.
-- A view auditoria_rejeitados expoe os campos originais e o JSON integral.
-- ============================================================================

DROP VIEW IF EXISTS auditoria_rejeitados;
DROP VIEW IF EXISTS vw_vagas_habilidades;
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


-- Classifica ausencia de habilidades em um unico lugar para evitar divergencia
-- entre C2 (busca de termos) e C2.1 (percentual sem informacao).
-- O Power Query da equipe grava o literal "Não informado". A normalizacao
-- remove a variacao de maiusculas/minusculas e o til de "ã" antes da comparacao.
CREATE VIEW vw_vagas_habilidades AS
WITH valores_normalizados AS (
    SELECT
        id_registro_fase1,
        fonte,
        habilidades,
        replace(
            replace(lower(trim(coalesce(habilidades, ''))), 'ã', 'a'),
            'Ã', 'a'
        ) AS habilidades_normalizadas
    FROM tb_fato_vagas
)
SELECT
    id_registro_fase1,
    fonte,
    habilidades,
    CASE
        WHEN habilidades_normalizadas = ''
          OR habilidades_normalizadas IN (
                'nao informado',
                'nao informada',
                'nao informados',
                'nao informadas',
                'habilidade nao informada',
                'habilidades nao informadas'
          )
          OR instr(habilidades_normalizadas, 'habilidade nao informada') > 0
        THEN 1
        ELSE 0
    END AS sem_habilidades_informadas
FROM valores_normalizados;

CREATE VIEW auditoria_rejeitados AS
SELECT
    id_rejeitado AS ID_Rejeitado,
    base AS Base,
    fonte AS Fonte,
    arquivo_origem AS Arquivo_Origem,
    linha_origem AS Linha_Origem,
    id_vaga_original AS ID_Vaga_Original,
    quantidade_original AS Quantidade_Original,
    motivo_rejeicao AS Motivo_Rejeicao,
    dados_originais_json AS Dados_Originais_JSON
FROM tb_rejeitado;
