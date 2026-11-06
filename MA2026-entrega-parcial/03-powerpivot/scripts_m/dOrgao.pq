// dOrgao
// Referência à tabela salva da Etapa 2; preserva registros e campos.
let
    Origem = cad_Etapa2{[Item = "dOrgao", Kind = "Table"]}[Data],
    Tipos = Table.TransformColumnTypes(Origem, {
        {"Fonte", type text},
        {"Cod_Orgao", type text},
        {"Orgao", type text},
        {"Chave_Orgao", type text}
    }, "pt-BR")
in
    Tipos
