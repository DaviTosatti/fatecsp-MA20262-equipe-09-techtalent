// dCargoSalarios
// Referência à tabela salva da Etapa 2; preserva registros e campos.
let
    Origem = cad_Etapa2{[Item = "dCargoSalarios", Kind = "Table"]}[Data],
    Tipos = Table.TransformColumnTypes(Origem, {
        {"Nome_Origem", type text},
        {"Cod_Cargo_Salarial", type text},
        {"Cargo", type text},
        {"Chave_Cargo", type text}
    }, "pt-BR")
in
    Tipos
