-- ============================================================================
-- techtalent_conferencia.sql
-- Conferencia de volume, integridade relacional, fontes e auditoria.
-- Resultado esperado: diferencas zero para as referencias da versao documentada.
-- ============================================================================

PRAGMA foreign_keys;

-- K1) Batimento com as referencias publicadas nas Etapas 2 e 3.
SELECT 'Vagas aceitas' AS indicador, 232 AS referencia,
       (SELECT COUNT(*) FROM tb_fato_vagas) AS banco,
       (SELECT COUNT(*) FROM tb_fato_vagas) - 232 AS diferenca
UNION ALL
SELECT 'Posicoes reportadas', 260,
       (SELECT SUM(quantidade) FROM tb_fato_vagas),
       (SELECT SUM(quantidade) FROM tb_fato_vagas) - 260
UNION ALL
SELECT 'IDs distintos por fonte', 122,
       (SELECT COUNT(*) FROM (
           SELECT fonte, id_vaga FROM tb_fato_vagas
           WHERE id_vaga IS NOT NULL GROUP BY fonte, id_vaga
       )),
       (SELECT COUNT(*) FROM (
           SELECT fonte, id_vaga FROM tb_fato_vagas
           WHERE id_vaga IS NOT NULL GROUP BY fonte, id_vaga
       )) - 122
UNION ALL
SELECT 'Observacoes salariais', 6599,
       (SELECT COUNT(*) FROM tb_fato_salarios),
       (SELECT COUNT(*) FROM tb_fato_salarios) - 6599
UNION ALL
SELECT 'Metas mensais simuladas', 12,
       (SELECT COUNT(*) FROM tb_fato_metas),
       (SELECT COUNT(*) FROM tb_fato_metas) - 12
UNION ALL
SELECT 'Soma das metas simuladas', 31,
       (SELECT SUM(meta_contratacoes) FROM tb_fato_metas),
       (SELECT SUM(meta_contratacoes) FROM tb_fato_metas) - 31
UNION ALL
SELECT 'Registros rejeitados', 8,
       (SELECT COUNT(*) FROM tb_rejeitado),
       (SELECT COUNT(*) FROM tb_rejeitado) - 8
UNION ALL
SELECT 'Cargos de vagas', 45,
       (SELECT COUNT(*) FROM tb_dim_cargo),
       (SELECT COUNT(*) FROM tb_dim_cargo) - 45
UNION ALL
SELECT 'Orgaos e empresas', 31,
       (SELECT COUNT(*) FROM tb_dim_orgao),
       (SELECT COUNT(*) FROM tb_dim_orgao) - 31
UNION ALL
SELECT 'Cargos salariais', 132,
       (SELECT COUNT(*) FROM tb_dim_cargo_salarios),
       (SELECT COUNT(*) FROM tb_dim_cargo_salarios) - 132
UNION ALL
SELECT 'Paises', 89,
       (SELECT COUNT(*) FROM tb_pais),
       (SELECT COUNT(*) FROM tb_pais) - 89
UNION ALL
SELECT 'Anos salariais', 5,
       (SELECT COUNT(*) FROM tb_dim_ano),
       (SELECT COUNT(*) FROM tb_dim_ano) - 5
UNION ALL
SELECT 'Dias no calendario', 365,
       (SELECT COUNT(*) FROM tb_dim_calendario),
       (SELECT COUNT(*) FROM tb_dim_calendario) - 365;

-- K2) Integridade referencial; resultado esperado = nenhuma linha.
PRAGMA foreign_key_check;

-- K3) FKs orfas; todas as ocorrencias devem ser 0.
SELECT 'Vagas sem cargo' AS teste, COUNT(*) AS ocorrencias
FROM tb_fato_vagas v LEFT JOIN tb_dim_cargo c ON c.cod_cargo = v.cod_cargo
WHERE c.cod_cargo IS NULL
UNION ALL
SELECT 'Vagas sem orgao', COUNT(*)
FROM tb_fato_vagas v LEFT JOIN tb_dim_orgao o ON o.cod_orgao = v.cod_orgao
WHERE o.cod_orgao IS NULL
UNION ALL
SELECT 'Vagas fora do calendario', COUNT(*)
FROM tb_fato_vagas v LEFT JOIN tb_dim_calendario d ON d.data = v.data_publicacao
WHERE d.data IS NULL
UNION ALL
SELECT 'Salarios sem cargo', COUNT(*)
FROM tb_fato_salarios s LEFT JOIN tb_dim_cargo_salarios c ON c.cod_cargo_salarial = s.cod_cargo_salarial
WHERE c.cod_cargo_salarial IS NULL
UNION ALL
SELECT 'Salarios sem pais da empresa', COUNT(*)
FROM tb_fato_salarios s LEFT JOIN tb_pais p ON p.cod_pais = s.cod_pais_empresa
WHERE p.cod_pais IS NULL
UNION ALL
SELECT 'Salarios sem pais de residencia', COUNT(*)
FROM tb_fato_salarios s LEFT JOIN tb_pais p ON p.cod_pais = s.cod_pais_residencia
WHERE p.cod_pais IS NULL
UNION ALL
SELECT 'Salarios sem ano', COUNT(*)
FROM tb_fato_salarios s LEFT JOIN tb_dim_ano a ON a.ano = s.ano
WHERE a.ano IS NULL
UNION ALL
SELECT 'Metas sem orgao', COUNT(*)
FROM tb_fato_metas m LEFT JOIN tb_dim_orgao o ON o.cod_orgao = m.cod_orgao
WHERE o.cod_orgao IS NULL
UNION ALL
SELECT 'Metas sem mes', COUNT(*)
FROM tb_fato_metas m LEFT JOIN tb_dim_calendario d ON d.data = m.mes_inicio
WHERE d.data IS NULL;

-- K4) Chaves vazias/duplicadas. Resultado esperado = 0 ocorrencias.
SELECT 'ID_Registro_FaseI vazio em vagas' AS teste, COUNT(*) AS ocorrencias
FROM tb_fato_vagas WHERE id_registro_fase1 IS NULL OR TRIM(id_registro_fase1) = ''
UNION ALL
SELECT 'ID_Registro_FaseI duplicado em vagas', COUNT(*) FROM (
    SELECT id_registro_fase1 FROM tb_fato_vagas GROUP BY id_registro_fase1 HAVING COUNT(*) > 1
)
UNION ALL
SELECT 'ID_Registro_FaseI vazio em salarios', COUNT(*)
FROM tb_fato_salarios WHERE id_registro_fase1 IS NULL OR TRIM(id_registro_fase1) = ''
UNION ALL
SELECT 'ID_Registro_FaseI duplicado em salarios', COUNT(*) FROM (
    SELECT id_registro_fase1 FROM tb_fato_salarios GROUP BY id_registro_fase1 HAVING COUNT(*) > 1
);

-- K5) Conferencia da preservacao dos rejeitados.
-- Todos os contadores de erro abaixo devem ser zero.
SELECT
    COUNT(*) AS total_rejeitados,
    SUM(CASE WHEN dados_originais_json IS NULL OR json_valid(dados_originais_json) <> 1
             THEN 1 ELSE 0 END) AS json_invalidos,
    SUM(CASE WHEN motivo_rejeicao IS NULL OR TRIM(motivo_rejeicao) = ''
             THEN 1 ELSE 0 END) AS sem_motivo,
    SUM(CASE WHEN id_vaga_original IS NOT
                  json_extract(dados_originais_json, '$.ID_Vaga_Original')
             THEN 1 ELSE 0 END) AS divergencias_id_vaga_original,
    SUM(CASE WHEN quantidade_original IS NOT
                  json_extract(dados_originais_json, '$.Quantidade_Original')
             THEN 1 ELSE 0 END) AS divergencias_quantidade_original
FROM tb_rejeitado;

-- K5.1) Inspecao integral dos dados originais de cada rejeitado.
SELECT
    id_rejeitado,
    arquivo_origem,
    linha_origem,
    id_vaga_original,
    quantidade_original,
    motivo_rejeicao,
    dados_originais_json
FROM tb_rejeitado
ORDER BY id_rejeitado;

-- K6) Cobertura de vagas por fonte.
SELECT fonte, COUNT(*) AS publicacoes,
       SUM(quantidade) AS posicoes,
       COUNT(DISTINCT id_vaga) AS ids_distintos
FROM tb_fato_vagas
GROUP BY fonte
ORDER BY fonte;

-- K7) Calendario: deve cobrir 365 dias entre 01/01 e 31/12/2026.
SELECT MIN(data) AS primeira_data,
       MAX(data) AS ultima_data,
       COUNT(*) AS dias,
       (julianday(MAX(data)) - julianday(MIN(data)) + 1) - COUNT(*) AS falhas_continuidade
FROM tb_dim_calendario;

-- K8) Referencia didatica para vagas SIMULADO BRL/Mensal.
-- Deve reproduzir os valores documentados na Etapa 3 para a versao atual.
SELECT
    ROUND(SUM(v.quantidade * c.salario_ref), 2) AS referencia_sim_brl_mensal,
    ROUND(SUM(v.quantidade * v.salario_min), 2) AS limite_minimo_sim_brl_mensal
FROM tb_fato_vagas v
JOIN tb_dim_cargo c ON c.cod_cargo = v.cod_cargo
WHERE v.fonte = 'SIMULADO'
  AND v.moeda = 'BRL'
  AND v.periodicidade = 'Mensal'
  AND v.moeda = c.moeda_ref
  AND v.periodicidade = c.periodicidade_ref
  AND c.salario_ref > 0;


-- K9) Regressao do indicador de habilidades para NYC.
-- Referencia verificada na versao atual: 225 publicacoes, 70 sem informacao,
-- percentual de 31,11%. Diferencas esperadas = 0.
SELECT
    'NYC - publicacoes' AS indicador,
    225 AS referencia,
    COUNT(*) AS banco,
    COUNT(*) - 225 AS diferenca
FROM vw_vagas_habilidades
WHERE fonte = 'NYC'
UNION ALL
SELECT
    'NYC - sem habilidades informadas',
    70,
    SUM(sem_habilidades_informadas),
    SUM(sem_habilidades_informadas) - 70
FROM vw_vagas_habilidades
WHERE fonte = 'NYC'
UNION ALL
SELECT
    'NYC - percentual sem informacao',
    31.11,
    ROUND(100.0 * SUM(sem_habilidades_informadas) / NULLIF(COUNT(*), 0), 2),
    ROUND(100.0 * SUM(sem_habilidades_informadas) / NULLIF(COUNT(*), 0), 2) - 31.11
FROM vw_vagas_habilidades
WHERE fonte = 'NYC';
-- K9-FIM)
