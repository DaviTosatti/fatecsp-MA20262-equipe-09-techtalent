// dAno
// Grão anual da fonte salarial, sem atribuir uma data diária fictícia.
let
    Origem = Table.SelectColumns(fSalarios, {"Ano"}),
    AnosUnicos = Table.Distinct(Origem),
    Ordenados = Table.Sort(AnosUnicos, {{"Ano", Order.Ascending}}),
    Tipos = Table.TransformColumnTypes(Ordenados, {{"Ano", Int64.Type}})
in
    Tipos
