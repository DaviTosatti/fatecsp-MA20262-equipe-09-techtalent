// fMetas
let
    Origem = stg_Metas_Bruto,
    ColunasMeses = List.RemoveItems(Table.ColumnNames(Origem),{"Cod_Orgao","Orgao","Fonte"}),
    MetasAusentes = List.Combine(List.Transform(Table.ToRecords(Origem),(r)=>List.Transform(List.Select(ColunasMeses,(c)=>Record.Field(r,c)=null),(c)=>[Cod_Orgao=r[Cod_Orgao],AnoMes=c]))),
    SemNulos = if not List.IsEmpty(MetasAusentes) then error Error.Record("MetaAusente","Planejamento contém meta não preenchida antes do despivotamento.",MetasAusentes) else Origem,
    SemNome = Table.RemoveColumns(SemNulos,{"Orgao"}),
    Despivotada = Table.UnpivotOtherColumns(SemNome,{"Cod_Orgao","Fonte"},"AnoMes","Meta_Original"),
    ComNumero = Table.AddColumn(Despivotada,"Meta_Contratacoes",each fnNumero([Meta_Original],"pt-BR"),type nullable number),
    Invalidas = Table.SelectRows(ComNumero,each [Meta_Contratacoes]=null or [Meta_Contratacoes]<0 or [Meta_Contratacoes]<>Number.RoundDown([Meta_Contratacoes])),
    Validadas = if not Table.IsEmpty(Invalidas) then error Error.Record("MetaInvalida","Planejamento contém quantidade ausente, fracionária ou negativa.",Invalidas) else ComNumero,
    Tipos = Table.TransformColumnTypes(Validadas,{{"Cod_Orgao",type text},{"Fonte",type text},{"AnoMes",type text},{"Meta_Contratacoes",Int64.Type}}),
    ComMes = Table.AddColumn(Tipos,"Mes_Inicio",each #date(Number.FromText(Text.Start([AnoMes],4)),Number.FromText(Text.End([AnoMes],2)),1),type date),
    Selecionada = Table.SelectColumns(ComMes,{"Fonte","Cod_Orgao","AnoMes","Meta_Contratacoes","Mes_Inicio"}),
    Ordenada = Table.Sort(Selecionada,{{"Cod_Orgao",Order.Ascending},{"Mes_Inicio",Order.Ascending}})
in Ordenada
