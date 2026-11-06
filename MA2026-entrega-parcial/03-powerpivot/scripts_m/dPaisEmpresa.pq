// dPaisEmpresa
// Referência à tabela salva da Etapa 2; preserva registros e campos.
let
    Origem = cad_Etapa2{[Item = "dPais", Kind = "Table"]}[Data],
    Tipos = Table.TransformColumnTypes(Origem, {
        {"Nome_Origem", type text},
        {"Cod_Pais", type text},
        {"Pais", type text},
        {"Chave_Pais", type text}
    }, "pt-BR")
in
    Tipos
