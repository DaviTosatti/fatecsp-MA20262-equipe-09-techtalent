// Rejeitados
let
    Combinada = Table.Combine({Rejeitados_Vagas,Rejeitados_Salarios}),
    Ordenada = Table.Sort(Combinada,{{"Base",Order.Ascending},{"Fonte",Order.Ascending},{"Arquivo_Origem",Order.Ascending},{"Linha_Origem",Order.Ascending}}),
    PrimeiroRastreio = Table.ReorderColumns(Ordenada,{"Base","Fonte","Arquivo_Origem","Linha_Origem","ID_Registro_FaseI","Linha_FaseI","Motivo"})
in PrimeiroRastreio
