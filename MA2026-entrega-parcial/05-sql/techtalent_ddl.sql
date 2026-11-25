-- ============================================================================
-- techtalent_ddl.sql
-- Etapa 5 - Banco de Dados & SQL | TechTalent - Fatec SP 2026/2
-- SGBD: SQLite 3
--
-- SCRIPT DE ESTRUTURA (bootstrap).
-- - Cria as tabelas e indices com IF NOT EXISTS.
-- - NAO apaga tabelas nem dados ao ser executado novamente.
-- - IF NOT EXISTS nao altera uma tabela antiga: se voce ja criou o banco usando
--   uma versao anterior deste DDL, veja "docs/README.md" para recriar o banco
--   localmente com a estrutura atualizada, preservando antes os CSVs de origem.
--
-- Ordem: DDL -> importar CSVs nas tabelas stg_* -> carga -> views -> conferencia.
-- ============================================================================

PRAGMA foreign_keys = ON;

-- DDL nao remove nem recria objetos existentes; views sao gerenciadas em techtalent_views.sql.

-- ============================================================================
-- 1. STAGING
-- Os CSVs de origem sao importados aqui. As colunas de entrada sao TEXT para
-- que conversoes e validacoes ocorram somente no script de carga.
-- ============================================================================

CREATE TABLE IF NOT EXISTS stg_vagas (
    Fonte TEXT,
    Fonte_Dados TEXT,
    Arquivo_Origem TEXT,
    Linha_Origem TEXT,
    ID_Registro_FaseI TEXT,
    Linha_FaseI TEXT,
    ID_Vaga TEXT,
    Cod_Orgao TEXT,
    Orgao TEXT,
    Cod_Cargo TEXT,
    Cargo TEXT,
    Titulo TEXT,
    Categoria TEXT,
    Tipo_Publicacao TEXT,
    Quantidade TEXT,
    Salario_Min TEXT,
    Salario_Max TEXT,
    Amplitude_Salarial TEXT,
    Ponto_Medio_Faixa TEXT,
    Moeda TEXT,
    Periodicidade TEXT,
    Data_Publicacao TEXT,
    Hora_Atendimento_Tratada TEXT,
    Mes_Publicacao TEXT,
    Atualizacao TEXT,
    Limite_Candidatura TEXT,
    Modalidade TEXT,
    Vinculo TEXT,
    Localidade TEXT,
    Localidade_Detalhe TEXT,
    Horario_Jornada TEXT,
    Descricao TEXT,
    Requisitos TEXT,
    Habilidades TEXT,
    Observacao_Qualidade TEXT,
    ID_Cenario TEXT
);

CREATE TABLE IF NOT EXISTS stg_salarios (
    Fonte TEXT,
    Arquivo_Origem TEXT,
    Linha_Origem TEXT,
    ID_Registro_FaseI TEXT,
    Linha_FaseI TEXT,
    Cod_Cargo_Salarial TEXT,
    Cargo TEXT,
    Experiencia TEXT,
    Vinculo TEXT,
    Modalidade TEXT,
    Ano TEXT,
    Cod_Pais_Residencia TEXT,
    Pais_Residencia TEXT,
    Cod_Pais_Empresa TEXT,
    Pais_Empresa TEXT,
    Porte TEXT,
    Salario TEXT,
    Moeda TEXT,
    Salario_USD TEXT,
    Periodicidade TEXT,
    Observacao TEXT
);

CREATE TABLE IF NOT EXISTS stg_cargo (
    Cod_Cargo TEXT,
    Cargo TEXT,
    Categoria TEXT,
    Salario_Ref TEXT,
    Moeda_Ref TEXT,
    Periodicidade_Ref TEXT
);

CREATE TABLE IF NOT EXISTS stg_orgao (
    Cod_Orgao TEXT,
    Orgao TEXT
);

CREATE TABLE IF NOT EXISTS stg_metas (
    Fonte TEXT,
    Cod_Orgao TEXT,
    AnoMes TEXT,
    Mes_Inicio TEXT,
    Meta_Contratacoes TEXT
);

-- IMPORTANTE: Rejeitados nao tem o mesmo esquema de fVagas.
-- O CSV de origem deve passar por techtalent_preparar_rejeitados.py.
-- Dados_Originais_JSON guarda TODOS os cabecalhos e valores do registro
-- original, inclusive ID_Vaga_Original, Quantidade_Original e quaisquer
-- outras colunas *_Original. Os campos abaixo sao copias de consulta rapida.
CREATE TABLE IF NOT EXISTS stg_rejeitados (
    base TEXT,
    fonte TEXT,
    arquivo_origem TEXT,
    linha_origem TEXT,
    id_vaga_original TEXT,
    quantidade_original TEXT,
    motivo_rejeicao TEXT,
    dados_originais_json TEXT NOT NULL,
    CONSTRAINT ck_stg_rejeitados_json CHECK (json_valid(dados_originais_json))
);

-- ============================================================================
-- 2. DIMENSOES
-- ============================================================================

CREATE TABLE IF NOT EXISTS tb_dim_cargo (
    cod_cargo TEXT NOT NULL,
    cargo TEXT NOT NULL,
    categoria TEXT,
    salario_ref NUMERIC,
    moeda_ref TEXT,
    periodicidade_ref TEXT,
    CONSTRAINT pk_tb_dim_cargo PRIMARY KEY (cod_cargo),
    CONSTRAINT ck_tb_dim_cargo_codigo CHECK (length(trim(cod_cargo)) > 0),
    CONSTRAINT ck_tb_dim_cargo_salario CHECK (salario_ref IS NULL OR salario_ref >= 0)
);

CREATE TABLE IF NOT EXISTS tb_dim_orgao (
    cod_orgao TEXT NOT NULL,
    orgao TEXT NOT NULL,
    CONSTRAINT pk_tb_dim_orgao PRIMARY KEY (cod_orgao),
    CONSTRAINT ck_tb_dim_orgao_codigo CHECK (length(trim(cod_orgao)) > 0)
);

CREATE TABLE IF NOT EXISTS tb_dim_cargo_salarios (
    cod_cargo_salarial TEXT NOT NULL,
    cargo TEXT NOT NULL,
    CONSTRAINT pk_tb_dim_cargo_salarios PRIMARY KEY (cod_cargo_salarial),
    CONSTRAINT ck_tb_dim_cargo_salarios_codigo CHECK (length(trim(cod_cargo_salarial)) > 0)
);

CREATE TABLE IF NOT EXISTS tb_pais (
    cod_pais TEXT NOT NULL,
    pais TEXT NOT NULL,
    CONSTRAINT pk_tb_pais PRIMARY KEY (cod_pais),
    CONSTRAINT ck_tb_pais_codigo CHECK (length(trim(cod_pais)) > 0)
);

CREATE TABLE IF NOT EXISTS tb_dim_ano (
    ano INTEGER NOT NULL,
    CONSTRAINT pk_tb_dim_ano PRIMARY KEY (ano),
    CONSTRAINT ck_tb_dim_ano_intervalo CHECK (ano BETWEEN 2020 AND 2024)
);

CREATE TABLE IF NOT EXISTS tb_dim_calendario (
    data TEXT NOT NULL,
    ano INTEGER NOT NULL,
    mes INTEGER NOT NULL,
    nome_mes TEXT NOT NULL,
    mes_abrev TEXT NOT NULL,
    ano_mes TEXT NOT NULL,
    mes_inicio TEXT NOT NULL,
    trimestre TEXT NOT NULL,
    dia_semana INTEGER NOT NULL,
    nome_dia TEXT NOT NULL,
    fim_de_semana TEXT NOT NULL,
    feriado TEXT NOT NULL DEFAULT 'Não informado',
    CONSTRAINT pk_tb_dim_calendario PRIMARY KEY (data),
    CONSTRAINT ck_tb_dim_calendario_data CHECK (data BETWEEN '2026-01-01' AND '2026-12-31'),
    CONSTRAINT ck_tb_dim_calendario_mes CHECK (mes BETWEEN 1 AND 12),
    CONSTRAINT ck_tb_dim_calendario_dia_semana CHECK (dia_semana BETWEEN 1 AND 7),
    CONSTRAINT ck_tb_dim_calendario_fim_semana CHECK (fim_de_semana IN ('Sim', 'Não'))
);

-- ============================================================================
-- 3. FATOS E AUDITORIA
-- ============================================================================

CREATE TABLE IF NOT EXISTS tb_fato_vagas (
    fonte TEXT NOT NULL,
    fonte_dados TEXT,
    arquivo_origem TEXT,
    linha_origem INTEGER,
    id_registro_fase1 TEXT NOT NULL,
    linha_fase1 INTEGER,
    id_vaga TEXT,
    cod_orgao TEXT NOT NULL,
    orgao TEXT NOT NULL,
    cod_cargo TEXT NOT NULL,
    cargo TEXT NOT NULL,
    titulo TEXT,
    categoria TEXT,
    tipo_publicacao TEXT NOT NULL,
    quantidade INTEGER NOT NULL,
    salario_min NUMERIC,
    salario_max NUMERIC,
    amplitude_salarial NUMERIC,
    ponto_medio_faixa NUMERIC,
    moeda TEXT,
    periodicidade TEXT,
    data_publicacao TEXT NOT NULL,
    hora_atendimento_tratada TEXT,
    mes_publicacao TEXT,
    atualizacao TEXT,
    limite_candidatura TEXT,
    modalidade TEXT,
    vinculo TEXT,
    localidade TEXT,
    localidade_detalhe TEXT,
    horario_jornada TEXT,
    descricao TEXT,
    requisitos TEXT,
    habilidades TEXT,
    observacao_qualidade TEXT,
    id_cenario TEXT,
    CONSTRAINT pk_tb_fato_vagas PRIMARY KEY (id_registro_fase1),
    CONSTRAINT ck_tb_fato_vagas_fonte CHECK (fonte IN ('NYC', 'SIMULADO')),
    CONSTRAINT ck_tb_fato_vagas_id CHECK (length(trim(id_registro_fase1)) > 0),
    CONSTRAINT ck_tb_fato_vagas_quantidade CHECK (quantidade > 0),
    CONSTRAINT ck_tb_fato_vagas_data CHECK (data_publicacao BETWEEN '2026-01-01' AND '2026-12-31'),
    CONSTRAINT ck_tb_fato_vagas_salario_min CHECK (salario_min IS NULL OR salario_min >= 0),
    CONSTRAINT ck_tb_fato_vagas_salario_max CHECK (salario_max IS NULL OR salario_max >= 0),
    CONSTRAINT ck_tb_fato_vagas_faixa CHECK (salario_min IS NULL OR salario_max IS NULL OR salario_max >= salario_min),
    CONSTRAINT fk_tb_fato_vagas_orgao FOREIGN KEY (cod_orgao) REFERENCES tb_dim_orgao (cod_orgao),
    CONSTRAINT fk_tb_fato_vagas_cargo FOREIGN KEY (cod_cargo) REFERENCES tb_dim_cargo (cod_cargo),
    CONSTRAINT fk_tb_fato_vagas_data FOREIGN KEY (data_publicacao) REFERENCES tb_dim_calendario (data)
);

CREATE TABLE IF NOT EXISTS tb_fato_salarios (
    fonte TEXT NOT NULL,
    arquivo_origem TEXT,
    linha_origem INTEGER,
    id_registro_fase1 TEXT NOT NULL,
    linha_fase1 INTEGER,
    cod_cargo_salarial TEXT NOT NULL,
    cargo TEXT NOT NULL,
    experiencia TEXT,
    vinculo TEXT,
    modalidade TEXT,
    ano INTEGER NOT NULL,
    cod_pais_residencia TEXT NOT NULL,
    pais_residencia TEXT NOT NULL,
    cod_pais_empresa TEXT NOT NULL,
    pais_empresa TEXT NOT NULL,
    porte TEXT,
    salario NUMERIC,
    moeda TEXT,
    salario_usd NUMERIC,
    periodicidade TEXT,
    observacao TEXT,
    CONSTRAINT pk_tb_fato_salarios PRIMARY KEY (id_registro_fase1),
    CONSTRAINT ck_tb_fato_salarios_fonte CHECK (fonte = 'SAL'),
    CONSTRAINT ck_tb_fato_salarios_id CHECK (length(trim(id_registro_fase1)) > 0),
    CONSTRAINT ck_tb_fato_salarios_salario CHECK (salario IS NULL OR salario >= 0),
    CONSTRAINT ck_tb_fato_salarios_usd CHECK (salario_usd IS NULL OR salario_usd >= 0),
    CONSTRAINT fk_tb_fato_salarios_cargo FOREIGN KEY (cod_cargo_salarial) REFERENCES tb_dim_cargo_salarios (cod_cargo_salarial),
    CONSTRAINT fk_tb_fato_salarios_ano FOREIGN KEY (ano) REFERENCES tb_dim_ano (ano),
    CONSTRAINT fk_tb_fato_salarios_pais_residencia FOREIGN KEY (cod_pais_residencia) REFERENCES tb_pais (cod_pais),
    CONSTRAINT fk_tb_fato_salarios_pais_empresa FOREIGN KEY (cod_pais_empresa) REFERENCES tb_pais (cod_pais)
);

CREATE TABLE IF NOT EXISTS tb_fato_metas (
    fonte TEXT NOT NULL,
    cod_orgao TEXT NOT NULL,
    ano_mes TEXT NOT NULL,
    mes_inicio TEXT NOT NULL,
    meta_contratacoes INTEGER NOT NULL,
    CONSTRAINT pk_tb_fato_metas PRIMARY KEY (fonte, cod_orgao, ano_mes),
    CONSTRAINT ck_tb_fato_metas_fonte CHECK (fonte = 'SIMULADO'),
    CONSTRAINT ck_tb_fato_metas_mes CHECK (length(ano_mes) = 7 AND substr(ano_mes, 5, 1) = '-'),
    CONSTRAINT ck_tb_fato_metas_meta CHECK (meta_contratacoes >= 0),
    CONSTRAINT ck_tb_fato_metas_mes_inicio CHECK (mes_inicio = ano_mes || '-01'),
    CONSTRAINT fk_tb_fato_metas_orgao FOREIGN KEY (cod_orgao) REFERENCES tb_dim_orgao (cod_orgao),
    CONSTRAINT fk_tb_fato_metas_mes FOREIGN KEY (mes_inicio) REFERENCES tb_dim_calendario (data)
);

-- A linha rejeitada e guardada integralmente em JSON, e nao remodelada como
-- fVagas. Por design, nao existem FKs nesta tabela de auditoria.
CREATE TABLE IF NOT EXISTS tb_rejeitado (
    id_rejeitado INTEGER PRIMARY KEY AUTOINCREMENT,
    base TEXT,
    fonte TEXT,
    arquivo_origem TEXT,
    linha_origem TEXT,
    id_vaga_original TEXT,
    quantidade_original TEXT,
    motivo_rejeicao TEXT NOT NULL,
    dados_originais_json TEXT NOT NULL,
    CONSTRAINT ck_tb_rejeitado_json CHECK (json_valid(dados_originais_json))
);

-- ============================================================================
-- 4. INDICES
-- ============================================================================

CREATE INDEX IF NOT EXISTS ix_tb_fato_vagas_cargo_data ON tb_fato_vagas (cod_cargo, data_publicacao);
CREATE INDEX IF NOT EXISTS ix_tb_fato_vagas_orgao_data ON tb_fato_vagas (cod_orgao, data_publicacao);
CREATE INDEX IF NOT EXISTS ix_tb_fato_vagas_data ON tb_fato_vagas (data_publicacao);
CREATE INDEX IF NOT EXISTS ix_tb_fato_vagas_fonte ON tb_fato_vagas (fonte);
CREATE INDEX IF NOT EXISTS ix_tb_fato_salarios_cargo_ano ON tb_fato_salarios (cod_cargo_salarial, ano);
CREATE INDEX IF NOT EXISTS ix_tb_fato_salarios_pais_empresa ON tb_fato_salarios (cod_pais_empresa);
CREATE INDEX IF NOT EXISTS ix_tb_fato_salarios_pais_residencia ON tb_fato_salarios (cod_pais_residencia);
CREATE INDEX IF NOT EXISTS ix_tb_fato_metas_orgao_mes ON tb_fato_metas (cod_orgao, ano_mes);
CREATE INDEX IF NOT EXISTS ix_tb_rejeitado_id_vaga_original ON tb_rejeitado (id_vaga_original);
CREATE INDEX IF NOT EXISTS ix_tb_rejeitado_motivo ON tb_rejeitado (motivo_rejeicao);

-- Estrutura: SELECT type, name FROM sqlite_master
-- WHERE name NOT LIKE 'sqlite_%' ORDER BY type, name;
