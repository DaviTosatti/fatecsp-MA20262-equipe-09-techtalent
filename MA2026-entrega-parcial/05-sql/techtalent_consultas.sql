-- ============================================================================
-- techtalent_consultas.sql
-- Consultas analiticas da Etapa 5. Resultados devem ser interpretados conforme
-- fonte, periodo, moeda e unidade; NYC e uma amostra municipal, SIMULADO e ficticio.
-- ============================================================================

-- C1) Ranking de cargos por quantidade de publicacoes e posicoes anunciadas.
-- ID_Vaga pode repetir-se em publicacoes internas/externas; por isso mostramos
-- publicacoes e IDs distintos separadamente.
SELECT
    fonte,
    categoria,
    cod_cargo,
    cargo,
    COUNT(*) AS qtd_publicacoes,
    SUM(quantidade) AS posicoes_reportadas,
    COUNT(DISTINCT id_vaga) AS ids_vaga_distintos
FROM fato_vagas
GROUP BY fonte, categoria, cod_cargo, cargo
ORDER BY fonte, posicoes_reportadas DESC, qtd_publicacoes DESC, cargo;

-- C2) Frequencia de palavras-chave na coluna Habilidades.
-- Esta e uma busca textual controlada, nao uma extracao NLP nem uma taxonomia
-- validada. Conta no maximo uma ocorrencia por publicacao e termo.
WITH palavras_chave(palavra, termo) AS (
    VALUES
      ('SQL', 'sql'),
      ('Python', 'python'),
      ('Excel', 'excel'),
      ('Power BI', 'power bi'),
      ('JavaScript', 'javascript'),
      ('Git', 'git'),
      ('Testes', 'testes'),
      ('Windows', 'windows'),
      ('Linux', 'linux'),
      ('Redes de computadores', 'redes de computadores'),
      ('Nuvem', 'nuvem'),
      ('Atendimento técnico', 'atendimento técnico'),
      ('Manutenção de computadores', 'manutenção de computadores')
)
SELECT
    v.fonte,
    p.palavra AS habilidade_pesquisada,
    COUNT(DISTINCT v.ID_Registro_FaseI) AS publicacoes_com_mencao
FROM fato_vagas v
CROSS JOIN palavras_chave p
WHERE NULLIF(TRIM(v.habilidades), '') IS NOT NULL
  AND lower(v.habilidades) NOT LIKE '%habilidades não informadas%'
  AND instr(lower(v.habilidades), lower(p.termo)) > 0
GROUP BY v.fonte, p.palavra
ORDER BY v.fonte, publicacoes_com_mencao DESC, habilidade_pesquisada;

-- Complemento C2: cobertura da coluna Habilidades por fonte.
SELECT
    fonte,
    COUNT(*) AS publicacoes,
    SUM(CASE
          WHEN habilidades IS NULL OR TRIM(habilidades) = ''
            OR lower(habilidades) LIKE '%habilidades não informadas%'
          THEN 1 ELSE 0
        END) AS publicacoes_sem_habilidades_informadas,
    ROUND(100.0 * SUM(CASE
          WHEN habilidades IS NULL OR TRIM(habilidades) = ''
            OR lower(habilidades) LIKE '%habilidades não informadas%'
          THEN 1 ELSE 0
        END) / COUNT(*), 2) AS pct_sem_informacao
FROM fato_vagas
GROUP BY fonte;

-- C3) Distribuicao dos salarios historicos por cargo, experiencia e ano.
-- Salario_USD e o valor fornecido pela origem. Sua periodicidade nao foi confirmada.
-- Nao combinar com salarios de anuncios NYC ou com outras moedas.
SELECT
    ano,
    cod_cargo_salarial,
    cargo,
    experiencia,
    COUNT(*) AS qtd_observacoes,
    ROUND(AVG(salario_usd), 2) AS media_informada_usd,
    MIN(salario_usd) AS minimo_informado_usd,
    MAX(salario_usd) AS maximo_informado_usd
FROM fato_salarios
WHERE salario_usd IS NOT NULL AND salario_usd > 0
GROUP BY ano, cod_cargo_salarial, cargo, experiencia
ORDER BY ano, media_informada_usd DESC;

-- C4) Faixas salariais dos anuncios NYC por cargo e periodicidade.
-- A moeda NYC permanece 'Não informada'; valores de frequencias diferentes
-- nao devem ser somados nem convertidos sem uma regra externa validada.
SELECT
    cod_cargo,
    cargo,
    moeda,
    periodicidade,
    COUNT(*) AS qtd_publicacoes,
    COUNT(DISTINCT id_vaga) AS ids_vaga_distintos,
    ROUND(AVG(salario_min), 2) AS media_limite_minimo,
    ROUND(AVG(salario_max), 2) AS media_limite_maximo,
    ROUND(AVG(ponto_medio_faixa), 2) AS media_ponto_medio
FROM fato_vagas
WHERE fonte = 'NYC'
  AND (salario_min IS NOT NULL OR salario_max IS NOT NULL)
GROUP BY cod_cargo, cargo, moeda, periodicidade
ORDER BY qtd_publicacoes DESC, cargo;

-- C5) Posicoes anunciadas SIMULADO versus metas ficticias por empresa e mes.
-- Agregamos as publicacoes antes do JOIN para nao multiplicar a meta.
-- A razao e didatica; nao representa contratacoes realizadas.
WITH posicoes_simuladas AS (
    SELECT
        cod_orgao,
        substr(data_publicacao, 1, 7) AS ano_mes,
        SUM(quantidade) AS posicoes_anunciadas
    FROM fato_vagas
    WHERE fonte = 'SIMULADO'
    GROUP BY cod_orgao, substr(data_publicacao, 1, 7)
)
SELECT
    m.cod_orgao,
    o.orgao,
    m.AnoMes,
    COALESCE(p.posicoes_anunciadas, 0) AS posicoes_anunciadas,
    m.meta_contratacoes AS meta_planejada,
    COALESCE(p.posicoes_anunciadas, 0) - m.meta_contratacoes AS diferenca,
    ROUND(100.0 * COALESCE(p.posicoes_anunciadas, 0) / NULLIF(m.meta_contratacoes, 0), 2) AS pct_da_meta
FROM fato_metas m
JOIN dim_orgao o ON o.cod_orgao = m.cod_orgao
LEFT JOIN posicoes_simuladas p
       ON p.cod_orgao = m.cod_orgao
      AND p.ano_mes = m.AnoMes
ORDER BY m.AnoMes, o.orgao;

-- C6) Perfil das publicacoes por fonte e tipo de publicacao.
SELECT
    fonte,
    tipo_publicacao,
    COUNT(*) AS qtd_publicacoes,
    SUM(quantidade) AS posicoes_reportadas,
    COUNT(DISTINCT id_vaga) AS ids_vaga_distintos
FROM fato_vagas
GROUP BY fonte, tipo_publicacao
ORDER BY fonte, qtd_publicacoes DESC;
