// Rejeitados_Salarios
let
    Origem = stg_Salarios_Bruto,
    SemPar = Table.NestedJoin(Origem,{"Arquivo_Origem","Linha_Origem"},fSalarios,{"Arquivo_Origem","Linha_Origem"},"Aceita",JoinKind.LeftAnti),
    Originais = Table.RemoveColumns(SemPar,{"Aceita"}),
    ComRegistro = Table.NestedJoin(Originais,{"Arquivo_Origem","Linha_Origem"},proc_Salarios[Descartes],{"Arquivo_Origem","Linha_Origem"},"Diagnostico",JoinKind.LeftOuter),
    ComMotivo = Table.ExpandTableColumn(ComRegistro,"Diagnostico",{"Motivo"},{"Motivo"}),
    Verificada = if Table.RowCount(ComMotivo)<>Table.RowCount(Originais) or List.Contains(ComMotivo[Motivo],null) then error "O diagnóstico não corresponde a cada rejeição salarial." else ComMotivo,
    ComBase = Table.AddColumn(Verificada,"Base",each "Salários",type text)
in ComBase
