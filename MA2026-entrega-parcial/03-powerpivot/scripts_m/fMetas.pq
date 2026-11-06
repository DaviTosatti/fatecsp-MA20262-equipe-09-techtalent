// fMetas
// Referência à tabela salva da Etapa 2; preserva registros e campos.
let
    Origem = cad_Etapa2{[Item = "fMetas", Kind = "Table"]}[Data],
    Tipos = Table.TransformColumnTypes(Origem, {
        {"Fonte", type text},
        {"Cod_Orgao", type text},
        {"AnoMes", type text},
        {"Meta_Contratacoes", Int64.Type},
        {"Mes_Inicio", type date}
    }, "pt-BR")
in
    Tipos
