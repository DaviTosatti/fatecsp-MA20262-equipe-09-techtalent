// fSalarios
// Referência à tabela salva da Etapa 2; preserva registros e campos.
let
    Origem = cad_Etapa2{[Item = "fSalarios", Kind = "Table"]}[Data],
    Tipos = Table.TransformColumnTypes(Origem, {
        {"Fonte", type text},
        {"Arquivo_Origem", type text},
        {"Linha_Origem", Int64.Type},
        {"ID_Registro_FaseI", type text},
        {"Linha_FaseI", Int64.Type},
        {"Cod_Cargo_Salarial", type text},
        {"Cargo", type text},
        {"Experiencia", type text},
        {"Vinculo", type text},
        {"Modalidade", type text},
        {"Ano", Int64.Type},
        {"Cod_Pais_Residencia", type text},
        {"Pais_Residencia", type text},
        {"Cod_Pais_Empresa", type text},
        {"Pais_Empresa", type text},
        {"Porte", type text},
        {"Salario", Currency.Type},
        {"Moeda", type text},
        {"Salario_USD", Currency.Type},
        {"Periodicidade", type text},
        {"Observacao", type text}
    }, "pt-BR")
in
    Tipos
