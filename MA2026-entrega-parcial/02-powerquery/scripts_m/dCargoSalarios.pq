// dCargoSalarios
let
    Fonte = cad_Etapa1{[Item="Tab_Cargos",Kind="Table"]}[Data],
    Selecionada = Table.SelectColumns(Fonte,{"Nome_Origem","Codigo","Nome_Portugues"}),
    Renomeada = Table.RenameColumns(Selecionada,{{"Codigo","Cod_Cargo_Salarial"},{"Nome_Portugues","Cargo"}}),
    Tipos = Table.TransformColumnTypes(Renomeada,{{"Nome_Origem",type text},{"Cod_Cargo_Salarial",type text},{"Cargo",type text}}),
    ComChave = Table.AddColumn(Tipos,"Chave_Cargo",each fnChave([Nome_Origem]),type text),
    Verificada = if Table.RowCount(ComChave)<>List.Count(List.Distinct(ComChave[Chave_Cargo])) then error "Chave repetida de cargo salarial." else ComChave
in Verificada
