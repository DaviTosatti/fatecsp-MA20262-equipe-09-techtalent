-- ============================================================================
-- techtalent_conferencia.sql
-- Conferencia da Etapa 5: volume, integridade, chaves e indicadores de referencia.
-- Execute as consultas separadamente no DB Browser for SQLite.
-- ============================================================================

PRAGMA foreign_keys;

-- K1) Batimento com as referencias documentadas na Etapa 2/3.
-- Diferenca deve ser zero. Referencias da versao atual do repositorio.
SELECT 'Vagas aceitas' AS indicador, 232 AS referencia,
       (SELECT COUNT(*) FROM tb_fato_vagas) AS banco,
       (SELECT COUNT(*) FROM tb_fato_vagas) - 232 AS diferenca
UNION ALL
SELECT 'Posicoes reportadas', 260,
       (SELECT SUM(quantidade) FROM tb_fato_vagas),
       (SELECT SUM(quantidade) FROM tb_fato_vagas) - 260
UNION ALL
SELECT 'IDs de vaga distintos por fonte', 122,
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
SELECT 'Total de metas planejadas', 31,
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

-- K2) Integridade referencial: resultado esperado = nenhuma linha.
PRAGMA foreign_key_check;

-- K3) FKs orfas e fatos sem correspondencia: todas as ocorrencias devem ser 0.
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
SELECT 'Salarios sem tb_pais da empresa', COUNT(*)
FROM tb_fato_salarios s LEFT JOIN tb_pais p ON p.cod_pais = s.cod_pais_empresa
WHERE p.cod_pais IS NULL
UNION ALL
SELECT 'Salarios sem tb_pais de residencia', COUNT(*)
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

-- K4) Chaves primarias vazias/duplicadas nas tabelas de origem e nas dimensoes.
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
)
UNION ALL
SELECT 'Cargo sem codigo', COUNT(*) FROM tb_dim_cargo WHERE cod_cargo IS NULL OR TRIM(cod_cargo) = ''
UNION ALL
SELECT 'Orgao sem codigo', COUNT(*) FROM tb_dim_orgao WHERE cod_orgao IS NULL OR TRIM(cod_orgao) = '';

-- K5) Verifica se os campos calculados da faixa salarial continuam consistentes.
-- A tolerancia de 1 centavo evita falsos positivos de representacao numerica.
SELECT COUNT(*) AS faixas_com_diferenca
FROM tb_fato_vagas
WHERE salario_min IS NOT NULL AND salario_max IS NOT NULL
  AND (
      amplitude_salarial IS NULL OR ponto_medio_faixa IS NULL
      OR ABS(amplitude_salarial - (salario_max - salario_min)) > 0.01
      OR ABS(ponto_medio_faixa - ((salario_min + salario_max) / 2.0)) > 0.01
  );

-- K6) Cobertura e dominios de referencia.
SELECT fonte, COUNT(*) AS publicacoes, SUM(quantidade) AS posicoes,
       COUNT(DISTINCT id_vaga) AS ids_distintos
FROM tb_fato_vagas
GROUP BY fonte
ORDER BY fonte;

SELECT base, COUNT(*) AS rejeitados
FROM tb_rejeitado
GROUP BY base;

SELECT moeda, periodicidade, COUNT(*) AS observacoes
FROM tb_fato_salarios
GROUP BY moeda, periodicidade
ORDER BY moeda, periodicidade;

-- K7) Continuidade do calendario: esperado 2026-01-01 a 2026-12-31, 365 dias.
SELECT MIN(data) AS primeira_data,
       MAX(data) AS ultima_data,
       COUNT(*) AS dias,
       (julianday(MAX(data)) - julianday(MIN(data)) + 1) - COUNT(*) AS falhas_continuidade
FROM tb_dim_calendario;

-- K8) Referencia didatica SIM em BRL/mensal; nao e custo realizado.
-- Deve reproduzir R$ 48.000 de referencia e R$ 45.500 de limite minimo,
-- conforme a documentacao da Etapa 3.
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
