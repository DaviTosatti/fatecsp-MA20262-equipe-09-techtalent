#!/usr/bin/env python3
"""Prepara o CSV original de Rejeitados para importacao em stg_rejeitados.

Uso:
    python techtalent_preparar_rejeitados.py \
        --input caminho/Rejeitados.csv \
        --output csv/stg_rejeitados.csv \
        --base Vagas

O script preserva todas as colunas e valores recebidos na linha original em
Dados_Originais_JSON. ID_Vaga_Original, Quantidade_Original e motivo ficam
tambem em colunas proprias para consulta. Nenhum campo original e convertido
ou renomeado dentro do JSON.
"""

from __future__ import annotations

import argparse
import csv
import json
import re
import sys
import unicodedata
from pathlib import Path
from typing import Dict, Iterable, Optional

OUTPUT_FIELDS = [
    "Base",
    "Fonte",
    "Arquivo_Origem",
    "Linha_Origem",
    "ID_Vaga_Original",
    "Quantidade_Original",
    "Motivo_Rejeicao",
    "Dados_Originais_JSON",
]


def normalize_header(value: str) -> str:
    """Normaliza apenas para localizar colunas; nao altera o cabecalho original."""
    normalized = unicodedata.normalize("NFKD", value)
    normalized = "".join(ch for ch in normalized if not unicodedata.combining(ch))
    return re.sub(r"[^a-z0-9]", "", normalized.casefold())


def find_column(
    headers: Iterable[str], candidates: Iterable[str], *, required: bool = True
) -> Optional[str]:
    header_map = {normalize_header(header): header for header in headers}
    for candidate in candidates:
        found = header_map.get(normalize_header(candidate))
        if found is not None:
            return found
    if required:
        raise ValueError(
            "Coluna obrigatoria ausente. Esperava uma destas: "
            + ", ".join(candidates)
            + ". Cabecalhos encontrados: "
            + ", ".join(headers)
        )
    return None


def detect_delimiter(sample: str) -> str:
    try:
        return csv.Sniffer().sniff(sample, delimiters=",;\t|").delimiter
    except csv.Error:
        return ","


def read_source(path: Path):
    with path.open("r", encoding="utf-8-sig", newline="") as source:
        sample = source.read(8192)
        source.seek(0)
        reader = csv.DictReader(source, delimiter=detect_delimiter(sample))
        if not reader.fieldnames:
            raise ValueError("O CSV nao possui cabecalho.")
        if len(set(reader.fieldnames)) != len(reader.fieldnames):
            raise ValueError("O CSV possui nomes de colunas duplicados.")
        rows = list(reader)
        return list(reader.fieldnames), rows


def make_record(row: Dict[str, Optional[str]], columns: dict, default_base: str) -> dict:
    # Conservar a linha de origem completa. Campos vazios permanecem como "".
    raw_json = json.dumps(
        {name: value for name, value in row.items()},
        ensure_ascii=False,
        separators=(",", ":"),
    )

    def val(column: Optional[str], fallback: str = "") -> str:
        if column is None:
            return fallback
        value = row.get(column)
        return "" if value is None else value

    return {
        "Base": val(columns["base"], default_base) or default_base,
        "Fonte": val(columns["fonte"]),
        "Arquivo_Origem": val(columns["arquivo"]),
        "Linha_Origem": val(columns["linha"]),
        "ID_Vaga_Original": val(columns["id_vaga"]),
        "Quantidade_Original": val(columns["quantidade"]),
        "Motivo_Rejeicao": val(columns["motivo"]),
        "Dados_Originais_JSON": raw_json,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", required=True, type=Path, help="CSV exportado da consulta Rejeitados")
    parser.add_argument("--output", required=True, type=Path, help="CSV para importar em stg_rejeitados")
    parser.add_argument("--base", default="Vagas", help="Base usada se nao houver coluna Base")
    args = parser.parse_args()

    if not args.input.is_file():
        parser.error(f"Arquivo de entrada nao encontrado: {args.input}")

    try:
        headers, rows = read_source(args.input)
        columns = {
            "base": find_column(headers, ["Base"], required=False),
            "fonte": find_column(headers, ["Fonte", "Fonte_Dados"], required=False),
            "arquivo": find_column(headers, ["Arquivo_Origem", "Arquivo"], required=False),
            "linha": find_column(headers, ["Linha_Origem", "Linha"], required=False),
            "id_vaga": find_column(headers, ["ID_Vaga_Original"]),
            "quantidade": find_column(headers, ["Quantidade_Original"]),
            "motivo": find_column(headers, ["Motivo_Rejeicao", "Motivo", "Diagnostico"]),
        }

        args.output.parent.mkdir(parents=True, exist_ok=True)
        with args.output.open("w", encoding="utf-8-sig", newline="") as target:
            writer = csv.DictWriter(target, fieldnames=OUTPUT_FIELDS, delimiter=",")
            writer.writeheader()
            for row in rows:
                writer.writerow(make_record(row, columns, args.base))

        print(f"Linhas exportadas: {len(rows)}")
        print(f"Colunas originais preservadas por registro: {len(headers)}")
        print(f"Arquivo pronto para staging: {args.output}")
        if len(rows) != 8:
            print(
                "ATENCAO: a referencia publicada para esta versao e de 8 rejeitados. "
                "Confira se o CSV corresponde a mesma versao dos dados.",
                file=sys.stderr,
            )
        return 0
    except (OSError, csv.Error, ValueError) as error:
        print(f"Erro ao preparar rejeitados: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
