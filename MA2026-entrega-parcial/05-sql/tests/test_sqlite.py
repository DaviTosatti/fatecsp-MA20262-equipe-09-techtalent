"""Smoke tests dos scripts SQLite da Etapa 5.

Executar com:
    python -m unittest discover -s tests -v

Os testes usam dados sintéticos minimos; nao substituem a carga real dos CSVs.
"""

from __future__ import annotations

import importlib.util
import json
import sqlite3
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PREP_PATH = ROOT / "techtalent_preparar_rejeitados.py"

spec = importlib.util.spec_from_file_location("preparar_rejeitados", PREP_PATH)
prep = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(prep)


def execute(connection: sqlite3.Connection, filename: str) -> None:
    connection.executescript((ROOT / filename).read_text(encoding="utf-8"))


def extract_query_section(filename: str, start_marker: str, end_marker: str) -> str:
    """Extrai uma consulta delimitada por comentarios do arquivo SQL real."""
    content = (ROOT / filename).read_text(encoding="utf-8")
    section = content.split(start_marker, 1)[1].split(end_marker, 1)[0]
    # O marcador esta no comentario de titulo; descarta o restante dessa linha.
    section = section.split("\n", 1)[1] if "\n" in section else ""
    sql_lines = [
        line for line in section.splitlines()
        if not line.lstrip().startswith("--")
    ]
    return "\n".join(sql_lines).strip().rstrip(";")


class TechTalentSQLiteTests(unittest.TestCase):
    def setUp(self) -> None:
        self.db = sqlite3.connect(":memory:")
        self.db.row_factory = sqlite3.Row
        self.db.execute("PRAGMA foreign_keys = ON")
        execute(self.db, "techtalent_ddl.sql")
        self.populate_staging()

    def tearDown(self) -> None:
        self.db.close()

    def populate_staging(self) -> None:
        self.db.execute(
            """INSERT INTO stg_vagas (
                Fonte,Fonte_Dados,Arquivo_Origem,Linha_Origem,ID_Registro_FaseI,
                Linha_FaseI,ID_Vaga,Cod_Orgao,Orgao,Cod_Cargo,Cargo,Titulo,
                Categoria,Tipo_Publicacao,Quantidade,Salario_Min,Salario_Max,
                Amplitude_Salarial,Ponto_Medio_Faixa,Moeda,Periodicidade,
                Data_Publicacao,Hora_Atendimento_Tratada,Mes_Publicacao,
                Atualizacao,Limite_Candidatura,Modalidade,Vinculo,Localidade,
                Localidade_Detalhe,Horario_Jornada,Descricao,Requisitos,
                Habilidades,Observacao_Qualidade,ID_Cenario
            ) VALUES (
                'SIMULADO','teste','vagas.xlsx','2','SIM-VAG-001','2','CEN-001',
                'SIM-E01','Empresa Teste','SIM-C01','Analista de dados',
                'Analista de dados','Dados','Simulado (acadêmico)','1',
                '10000','10000','0','10000','BRL','Mensal','2026-03-03',
                '07:45:00','2026-03-01','2026-03-03','','Remoto',
                'Tempo integral','Localidade simulada','Localidade simulada',
                '07:45','Descrição','Requisitos','SQL, Python','','SIM-001'
            )"""
        )
        self.db.execute(
            """INSERT INTO stg_salarios (
                Fonte,Arquivo_Origem,Linha_Origem,ID_Registro_FaseI,Linha_FaseI,
                Cod_Cargo_Salarial,Cargo,Experiencia,Vinculo,Modalidade,Ano,
                Cod_Pais_Residencia,Pais_Residencia,Cod_Pais_Empresa,Pais_Empresa,
                Porte,Salario,Moeda,Salario_USD,Periodicidade,Observacao
            ) VALUES (
                'SAL','salarios.xlsx','2','SAL-001','2','C047','Engenheiro de dados',
                'Intermediário','Integral','Remoto','2024','P087','Estados Unidos',
                'P087','Estados Unidos','Médio','148100','USD','148100',
                'Não confirmada','Sem periodicidade confirmada'
            )"""
        )
        self.db.execute(
            "INSERT INTO stg_cargo VALUES (?, ?, ?, ?, ?, ?)",
            ("SIM-C01", "Analista de dados", "Dados", "10000", "BRL", "Mensal"),
        )
        self.db.execute(
            "INSERT INTO stg_orgao VALUES (?, ?)", ("SIM-E01", "Empresa Teste")
        )
        self.db.execute(
            "INSERT INTO stg_metas VALUES (?, ?, ?, ?, ?)",
            ("SIMULADO", "SIM-E01", "2026-03", "2026-03-01", "1"),
        )

        original = {
            "ID_Vaga_Original": "VAGA-ORIGINAL-42",
            "Quantidade_Original": "0",
            "Titulo_Original": "Analista de Dados",
            "Requisitos_Original": "SQL; Python\nExperiencia em dados",
            "Campo_Extra_Original": "  valor sem trim  ",
            "Motivo": "Quantidade zero",
        }
        columns = {
            "base": None, "fonte": None, "arquivo": None, "linha": None,
            "id_vaga": "ID_Vaga_Original",
            "quantidade": "Quantidade_Original",
            "motivo": "Motivo",
        }
        prepared = prep.make_record(original, columns, "Vagas")
        self.db.execute(
            """INSERT INTO stg_rejeitados (
                base,fonte,arquivo_origem,linha_origem,id_vaga_original,
                quantidade_original,motivo_rejeicao,dados_originais_json
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)""",
            (
                prepared["Base"], prepared["Fonte"], prepared["Arquivo_Origem"],
                prepared["Linha_Origem"], prepared["ID_Vaga_Original"],
                prepared["Quantidade_Original"], prepared["Motivo_Rejeicao"],
                prepared["Dados_Originais_JSON"],
            ),
        )
        self.db.commit()

    def test_ddl_reexecution_does_not_delete_staging_rows_or_views(self) -> None:
        execute(self.db, "techtalent_views.sql")
        before = self.db.execute("SELECT COUNT(*) FROM stg_rejeitados").fetchone()[0]
        before_views = self.db.execute(
            "SELECT COUNT(*) FROM sqlite_master WHERE type = 'view'"
        ).fetchone()[0]
        execute(self.db, "techtalent_ddl.sql")
        after = self.db.execute("SELECT COUNT(*) FROM stg_rejeitados").fetchone()[0]
        after_views = self.db.execute(
            "SELECT COUNT(*) FROM sqlite_master WHERE type = 'view'"
        ).fetchone()[0]
        self.assertEqual(before, 1)
        self.assertEqual(after, before)
        self.assertEqual(after_views, before_views)

    def test_full_pipeline_and_rejected_preservation(self) -> None:
        execute(self.db, "techtalent_carga.sql")
        execute(self.db, "techtalent_views.sql")
        execute(self.db, "techtalent_consultas.sql")
        execute(self.db, "techtalent_conferencia.sql")

        self.assertEqual(self.db.execute("SELECT COUNT(*) FROM tb_fato_vagas").fetchone()[0], 1)
        self.assertEqual(self.db.execute("SELECT COUNT(*) FROM tb_fato_salarios").fetchone()[0], 1)
        self.assertEqual(self.db.execute("SELECT COUNT(*) FROM tb_fato_metas").fetchone()[0], 1)
        self.assertEqual(self.db.execute("SELECT COUNT(*) FROM tb_rejeitado").fetchone()[0], 1)
        self.assertEqual(self.db.execute("PRAGMA foreign_key_check").fetchall(), [])

        rejected = self.db.execute(
            """SELECT id_vaga_original,quantidade_original,motivo_rejeicao,
                      dados_originais_json
               FROM tb_rejeitado"""
        ).fetchone()
        self.assertEqual(rejected[0], "VAGA-ORIGINAL-42")
        self.assertEqual(rejected[1], "0")
        self.assertEqual(rejected[2], "Quantidade zero")
        raw = json.loads(rejected[3])
        self.assertEqual(raw["ID_Vaga_Original"], "VAGA-ORIGINAL-42")
        self.assertEqual(raw["Quantidade_Original"], "0")
        self.assertEqual(raw["Campo_Extra_Original"], "  valor sem trim  ")

        audit_view = self.db.execute("SELECT * FROM auditoria_rejeitados").fetchone()
        self.assertEqual(audit_view[5], "VAGA-ORIGINAL-42")
        self.assertEqual(json.loads(audit_view[8]), raw)

    def test_nyc_missing_skills_marker_matches_70_of_225(self) -> None:
        execute(self.db, "techtalent_carga.sql")
        execute(self.db, "techtalent_views.sql")

        # Regressao baseada na distribuicao conferida para a base atual de NYC:
        # 70 registros com o marcador Power Query "Não informado" e 155 com
        # habilidades textuais preenchidas.
        rows = []
        for index in range(225):
            skill_text = "Não informado" if index < 70 else "Python, SQL"
            rows.append((
                "NYC",
                f"NYC-REG-{index + 1:03d}",
                "SIM-E01",
                "Empresa Teste",
                "SIM-C01",
                "Analista de dados",
                "NYC",
                1,
                "2026-03-03",
                skill_text,
            ))
        self.db.executemany(
            """INSERT INTO tb_fato_vagas (
                fonte, id_registro_fase1, cod_orgao, orgao, cod_cargo, cargo,
                tipo_publicacao, quantidade, data_publicacao, habilidades
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
            rows,
        )

        coverage_sql = extract_query_section(
            "techtalent_consultas.sql", "-- C2.1)", "-- C3)"
        )
        coverage_rows = self.db.execute(coverage_sql).fetchall()
        nyc = next(row for row in coverage_rows if row["fonte"] == "NYC")
        self.assertEqual(nyc["publicacoes"], 225)
        self.assertEqual(nyc["publicacoes_sem_habilidades_informadas"], 70)
        self.assertEqual(nyc["pct_sem_informacao"], 31.11)

        skills_sql = extract_query_section(
            "techtalent_consultas.sql", "-- C2)", "-- C2.1)"
        )
        skills_rows = self.db.execute(skills_sql).fetchall()
        nyc_counts = {row["habilidade_pesquisada"]: row["publicacoes_com_mencao"]
                      for row in skills_rows if row["fonte"] == "NYC"}
        self.assertEqual(nyc_counts["Python"], 155)
        self.assertEqual(nyc_counts["SQL"], 155)

        conference_sql = extract_query_section(
            "techtalent_conferencia.sql", "-- K9)", "-- K9-FIM)"
        ) if "-- K9-FIM)" in (ROOT / "techtalent_conferencia.sql").read_text(encoding="utf-8") else ""
        if conference_sql:
            checks = self.db.execute(conference_sql).fetchall()
            self.assertTrue(all(row["diferenca"] == 0 for row in checks))

    def test_load_is_repeatable_without_duplicate_final_rows(self) -> None:
        execute(self.db, "techtalent_carga.sql")
        first = self.db.execute("SELECT COUNT(*) FROM tb_rejeitado").fetchone()[0]
        execute(self.db, "techtalent_carga.sql")
        second = self.db.execute("SELECT COUNT(*) FROM tb_rejeitado").fetchone()[0]
        self.assertEqual(first, 1)
        self.assertEqual(second, first)
        self.assertEqual(self.db.execute("SELECT COUNT(*) FROM stg_rejeitados").fetchone()[0], 1)


class PrepareRejectedTests(unittest.TestCase):
    def test_preserves_all_fields_and_values_in_json(self) -> None:
        original = {
            "ID_Vaga_Original": "V-42",
            "Quantidade_Original": "0",
            "Campo_Adicional_Original": "  texto  ",
            "Motivo": "Quantidade zero",
        }
        columns = {
            "base": None, "fonte": None, "arquivo": None, "linha": None,
            "id_vaga": "ID_Vaga_Original",
            "quantidade": "Quantidade_Original",
            "motivo": "Motivo",
        }
        result = prep.make_record(original, columns, "Vagas")
        self.assertEqual(json.loads(result["Dados_Originais_JSON"]), original)
        self.assertEqual(result["ID_Vaga_Original"], "V-42")
        self.assertEqual(result["Quantidade_Original"], "0")

    def test_requires_original_id_quantity_and_reason(self) -> None:
        with self.assertRaises(ValueError):
            prep.find_column(["ID_Vaga", "Quantidade", "Motivo"], ["ID_Vaga_Original"])


if __name__ == "__main__":
    unittest.main(verbosity=2)
