// Rejeitados_Vagas
let
    Origem = stg_Vagas_Bruto,
    SemPar = Table.NestedJoin(Origem,{"Arquivo_Origem","Linha_Origem"},fVagas,{"Arquivo_Origem","Linha_Origem"},"Aceita",JoinKind.LeftAnti),
    Originais = Table.RemoveColumns(SemPar,{"Aceita"}),
    ComRegistro = Table.NestedJoin(Originais,{"Arquivo_Origem","Linha_Origem"},proc_Vagas[Descartes],{"Arquivo_Origem","Linha_Origem"},"Diagnostico",JoinKind.LeftOuter),
    ComMotivo = Table.ExpandTableColumn(ComRegistro,"Diagnostico",{"Motivo"},{"Motivo"}),
    Verificada = if Table.RowCount(ComMotivo)<>Table.RowCount(Originais) or List.Contains(ComMotivo[Motivo],null) then error "O diagnóstico não corresponde a cada rejeição de vaga." else ComMotivo,
    ComBase = Table.AddColumn(Verificada,"Base",each "Vagas",type text)
in ComBase
