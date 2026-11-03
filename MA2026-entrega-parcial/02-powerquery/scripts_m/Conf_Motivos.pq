// Conf_Motivos
let
    Agrupada = Table.Group(Rejeitados,{"Base","Fonte","Motivo"},{{"Linhas",each Table.RowCount(_),Int64.Type}}),
    Ordenada = Table.Sort(Agrupada,{{"Base",Order.Ascending},{"Fonte",Order.Ascending},{"Linhas",Order.Descending},{"Motivo",Order.Ascending}})
in Ordenada
