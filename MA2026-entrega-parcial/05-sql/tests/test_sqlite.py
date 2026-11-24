"""Smoke tests dos scripts SQLite da Etapa de BD (somente dados sintéticos mínimos).

Execute na pasta 05-sql com:
    python tests/test_sqlite.py

Estes testes validam sintaxe, criação, carga reexecutável, views, consultas,
constraints e integridade referencial. Não substituem a conferência com os
CSV/exports reais publicados na Etapa 2.
"""

from pathlib import Path
import sqlite3
import unittest

ROOT = Path(__file__).resolve().parents[1]


def execute_script(connection: sqlite3.Connection, filename: str) -> None:
    connection.executescript((ROOT / filename).read_text(encoding="utf-8"))


def populate_staging(connection: sqlite3.Connection) -> None:
    connection.execute(
        """INSERT INTO stg_vagas (
            Fonte, Fonte_Dados, Arquivo_Origem, Linha_Origem,
            ID_Registro_FaseI, Linha_FaseI, ID_Vaga, Cod_Orgao, Orgao,
            Cod_Cargo, Cargo, Titulo, Categoria, Tipo_Publicacao, Quantidade,
            Salario_Min, Salario_Max, Amplitude_Salarial, Ponto_Medio_Faixa,
            Moeda, Periodicidade, Data_Publicacao, Hora_Atendimento_Tratada,
            Mes_Publicacao, Atualizacao, Limite_Candidatura, Modalidade, Vinculo,
            Localidade, Localidade_Detalhe, Horario_Jornada, Descricao,
            Requisitos, Habilidades, Observacao_Qualidade, ID_Cenario
        ) VALUES (
            'SIMULADO','origem','teste.xlsx','2','SIM-VAG-TESTE','2',
            'CEN-SIM-TESTE','SIM-E01','Empresa Teste','SIM-C01',
            'Analista de dados','Analista de dados','Dados',
            'Simulado (acadêmico)','1','10000','10000','0','10000','BRL',
            'Mensal','2026-03-03','07:45:00','2026-03-01','2026-03-03',
            NULL,'Remoto','Tempo integral','Localidade simulada',
            'Localidade simulada','Não informado','Descrição teste',
            'Requisitos teste','SQL, Python','','SIM-TESTE'
        )"""
    )
    connection.execute(
        """INSERT INTO stg_salarios (
            Fonte, Arquivo_Origem, Linha_Origem, ID_Registro_FaseI,
            Linha_FaseI, Cod_Cargo_Salarial, Cargo, Experiencia, Vinculo,
            Modalidade, Ano, Cod_Pais_Residencia, Pais_Residencia,
            Cod_Pais_Empresa, Pais_Empresa, Porte, Salario, Moeda,
            Salario_USD, Periodicidade, Observacao
        ) VALUES (
            'SAL','origem.xlsx','2','SAL-TESTE','2','C047',
            'Engenheiro de dados','Nível intermediário','Tempo integral',
            'Remoto','2024','P087','Estados Unidos','P087','Estados Unidos',
            'Médio','148100','USD','148100','Não confirmada',
            'Periodicidade não confirmada'
        )"""
    )
    connection.execute(
        "INSERT INTO stg_cargo VALUES (?, ?, ?, ?, ?, ?)",
        ("SIM-C01", "Analista de dados", "Dados", "10000", "BRL", "Mensal"),
    )
    connection.execute(
        "INSERT INTO stg_orgao VALUES (?, ?)", ("SIM-E01", "Empresa Teste")
    )
    connection.execute(
        "INSERT INTO stg_metas VALUES (?, ?, ?, ?, ?)",
        ("SIMULADO", "SIM-E01", "2026-03", "2026-03-01", "1"),
    )
    connection.execute(
        """INSERT INTO stg_rejeitados
           (Base, Fonte, ID_Registro_FaseI, Motivo_Rejeicao)
           VALUES ('Vagas', 'SIMULADO', 'SIM-VAG-REJ', 'Quantidade inválida')"""
    )
    connection.commit()


class TechTalentSqliteSmokeTests(unittest.TestCase):
    def setUp(self) -> None:
        self.connection = sqlite3.connect(":memory:")
        self.connection.execute("PRAGMA foreign_keys = ON")
        execute_script(self.connection, "techtalent_ddl.sql")
        populate_staging(self.connection)

    def tearDown(self) -> None:
        self.connection.close()

    def test_full_sql_pipeline(self) -> None:
        execute_script(self.connection, "techtalent_carga.sql")
        execute_script(self.connection, "techtalent_views.sql")
        execute_script(self.connection, "techtalent_consultas.sql")
        execute_script(self.connection, "techtalent_conferencia.sql")

        self.assertEqual(
            self.connection.execute("SELECT COUNT(*) FROM tb_fato_vagas").fetchone()[0], 1
        )
        self.assertEqual(
            self.connection.execute("SELECT COUNT(*) FROM tb_fato_salarios").fetchone()[0], 1
        )
        self.assertEqual(
            self.connection.execute("SELECT COUNT(*) FROM tb_fato_metas").fetchone()[0], 1
        )
        self.assertEqual(
            self.connection.execute("SELECT COUNT(*) FROM tb_rejeitado").fetchone()[0], 1
        )
        self.assertEqual(
            self.connection.execute("SELECT COUNT(*) FROM tb_dim_calendario").fetchone()[0], 365
        )
        self.assertEqual(self.connection.execute("PRAGMA foreign_key_check").fetchall(), [])
        self.assertEqual(self.connection.execute("SELECT COUNT(*) FROM fato_vagas").fetchone()[0], 1)

    def test_load_is_idempotent(self) -> None:
        execute_script(self.connection, "techtalent_carga.sql")
        first = self.connection.execute(
            "SELECT COUNT(*) FROM tb_fato_vagas"
        ).fetchone()[0]
        execute_script(self.connection, "techtalent_carga.sql")
        second = self.connection.execute(
            "SELECT COUNT(*) FROM tb_fato_vagas"
        ).fetchone()[0]
        self.assertEqual(first, second)
        self.assertEqual(second, 1)
        self.assertEqual(self.connection.execute("PRAGMA foreign_key_check").fetchall(), [])


if __name__ == "__main__":
    unittest.main(verbosity=2)
