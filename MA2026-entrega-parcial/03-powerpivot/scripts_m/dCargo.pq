// dCargo
// Referência à tabela salva da Etapa 2; preserva registros e campos.
let
    Origem = cad_Etapa2{[Item = "dCargo", Kind = "Table"]}[Data],
    Tipos = Table.TransformColumnTypes(Origem, {
        {"Fonte", type text},
        {"Cod_Cargo", type text},
        {"Codigo_Origem", type text},
        {"Cargo", type text},
        {"Categoria", type text},
        {"Salario_Ref", Currency.Type},
        {"Moeda_Ref", type text},
        {"Periodicidade_Ref", type text},
        {"Chave_Cargo", type text}
    }, "pt-BR")
in
    Tipos
