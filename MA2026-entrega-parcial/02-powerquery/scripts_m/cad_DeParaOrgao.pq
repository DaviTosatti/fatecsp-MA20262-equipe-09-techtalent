// cad_DeParaOrgao
let
    Reais = Table.SelectColumns(Table.SelectRows(dOrgao,each [Fonte]="NYC"),{"Chave_Orgao","Cod_Orgao"}),
    Simulados = cad_Etapa1{[Item="Tab_DePara_Empresas_Simuladas",Kind="Table"]}[Data],
    ComChave = Table.AddColumn(Simulados,"Chave_Orgao",each "SIMULADO|" & fnChave([Nome_Origem]),type text),
    Renomeada = Table.RenameColumns(ComChave,{{"Codigo_Empresa","Cod_Orgao"}}),
    Selecionados = Table.SelectColumns(Renomeada,{"Chave_Orgao","Cod_Orgao"}),
    Combinada = Table.Combine({Reais,Selecionados}),
    Verificada = if Table.RowCount(Combinada)<>List.Count(List.Distinct(Combinada[Chave_Orgao])) then error "Chave repetida no de-para de órgãos." else Combinada
in Verificada
