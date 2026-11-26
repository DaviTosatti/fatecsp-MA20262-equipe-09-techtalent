-- ============================================================================
-- techtalent_consultas.sql
-- Consultas analiticas da Etapa 5.
-- NYC, SAL e SIMULADO representam fontes diferentes e nao devem ser misturadas
-- sem considerar grão, moeda, periodicidade e natureza dos registros.
-- ============================================================================

-- C1) Ranking de cargos por publicacoes e posicoes anunciadas.
-- ID_Vaga pode repetir em publicacoes internas/externas; mostramos metricas
-- distintas para nao confundir publicacao com identificador de vaga.
SELECT
    fonte,
    categoria,
    cod_cargo,
    cargo,
    COUNT(*) AS qtd_publicacoes,
    SUM(quantidade) AS posicoes_reportadas,
    COUNT(DISTINCT id_vaga) AS ids_vaga_distintos
FROM tb_fato_vagas
GROUP BY fonte, categoria, cod_cargo, cargo
ORDER BY fonte, posicoes_reportadas DESC, qtd_publicacoes DESC, cargo;

-- C2) Ranking exploratorio por palavra/expressao completa.
-- Pontuacao e tratada como separador: "Excel" corresponde a "MS-Excel",
-- mas nao a "excellent". A busca nao e uma taxonomia/NLP validado.
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
    COUNT(DISTINCT v.id_registro_fase1) AS publicacoes_com_mencao
FROM vw_vagas_habilidades v
CROSS JOIN palavras_chave p
WHERE v.sem_habilidades_informadas = 0
  AND instr(' ' || v.habilidades_busca || ' ', ' ' || lower(trim(p.termo)) || ' ') > 0
GROUP BY v.fonte, p.palavra
ORDER BY v.fonte, publicacoes_com_mencao DESC, habilidade_pesquisada;

-- C2.1) Cobertura da coluna Habilidades por fonte.
-- Numerador e denominador usam a mesma classificacao de vw_vagas_habilidades.
-- Para a versao atual dos dados, NYC deve apresentar 70 de 225 (31,11%).
SELECT
    fonte,
    COUNT(*) AS publicacoes,
    SUM(sem_habilidades_informadas) AS publicacoes_sem_habilidades_informadas,
    ROUND(
        100.0 * SUM(sem_habilidades_informadas) / NULLIF(COUNT(*), 0),
        2
    ) AS pct_sem_informacao
FROM vw_vagas_habilidades
GROUP BY fonte;

-- C3) Distribuicao dos salarios historicos por cargo, experiencia e ano.
-- A periodicidade da fonte historica nao foi confirmada. Nao misturar com NYC.
SELECT
    ano,
    cod_cargo_salarial,
    cargo,
    experiencia,
    COUNT(*) AS qtd_observacoes,
    ROUND(AVG(salario_usd), 2) AS media_informada_usd,
    MIN(salario_usd) AS minimo_informado_usd,
    MAX(salario_usd) AS maximo_informado_usd
FROM tb_fato_salarios
WHERE salario_usd IS NOT NULL AND salario_usd > 0
GROUP BY ano, cod_cargo_salarial, cargo, experiencia
ORDER BY ano, media_informada_usd DESC;

-- C4) Faixas salariais de anuncios NYC por cargo e periodicidade.
-- A moeda da fonte NYC deve permanecer como informada/nao informada no CSV.
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
FROM tb_fato_vagas
WHERE fonte = 'NYC'
  AND (salario_min IS NOT NULL OR salario_max IS NOT NULL)
GROUP BY cod_cargo, cargo, moeda, periodicidade
ORDER BY qtd_publicacoes DESC, cargo;

-- C5) Posicoes anunciadas SIMULADO versus metas ficticias por empresa/mes.
-- Agrega publicacoes antes do JOIN para nao multiplicar a meta.
-- O resultado nao representa contratacoes realizadas.
WITH posicoes_simuladas AS (
    SELECT
        cod_orgao,
        substr(data_publicacao, 1, 7) AS ano_mes,
        SUM(quantidade) AS posicoes_anunciadas
    FROM tb_fato_vagas
    WHERE fonte = 'SIMULADO'
    GROUP BY cod_orgao, substr(data_publicacao, 1, 7)
)
SELECT
    m.cod_orgao,
    o.orgao,
    m.ano_mes,
    COALESCE(p.posicoes_anunciadas, 0) AS posicoes_anunciadas,
    m.meta_contratacoes AS meta_planejada,
    COALESCE(p.posicoes_anunciadas, 0) - m.meta_contratacoes AS diferenca,
    ROUND(100.0 * COALESCE(p.posicoes_anunciadas, 0) / NULLIF(m.meta_contratacoes, 0), 2) AS pct_da_meta
FROM tb_fato_metas m
JOIN tb_dim_orgao o ON o.cod_orgao = m.cod_orgao
LEFT JOIN posicoes_simuladas p
       ON p.cod_orgao = m.cod_orgao
      AND p.ano_mes = m.ano_mes
ORDER BY m.ano_mes, o.orgao;

-- C6) Perfil das publicacoes por fonte e tipo.
SELECT
    fonte,
    tipo_publicacao,
    COUNT(*) AS qtd_publicacoes,
    SUM(quantidade) AS posicoes_reportadas,
    COUNT(DISTINCT id_vaga) AS ids_vaga_distintos
FROM tb_fato_vagas
GROUP BY fonte, tipo_publicacao
ORDER BY fonte, qtd_publicacoes DESC;

-- C7) Auditoria: rejeitados agrupados por motivo.
SELECT
    base,
    motivo_rejeicao,
    COUNT(*) AS qtd_rejeitados
FROM tb_rejeitado
GROUP BY base, motivo_rejeicao
ORDER BY base, qtd_rejeitados DESC, motivo_rejeicao;
