// dPais
let
    Fonte = cad_Etapa1{[Item="Tab_Paises",Kind="Table"]}[Data],
    Renomeada = Table.RenameColumns(Table.SelectColumns(Fonte,{"Nome_Origem","Codigo","Nome_Portugues"}),{{"Codigo","Cod_Pais"},{"Nome_Portugues","Pais"}}),
    Tipos = Table.TransformColumnTypes(Renomeada,{{"Nome_Origem",type text},{"Cod_Pais",type text},{"Pais",type text}}),
    ComChave = Table.AddColumn(Tipos,"Chave_Pais",each fnChave([Nome_Origem]),type text),
    Verificada = if Table.RowCount(ComChave)<>List.Count(List.Distinct(ComChave[Chave_Pais])) then error "Chave repetida de país." else ComChave
in Verificada
