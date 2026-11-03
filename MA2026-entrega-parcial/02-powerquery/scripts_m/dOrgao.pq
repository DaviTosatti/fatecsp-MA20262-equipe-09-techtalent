// dOrgao
let
    Reais = Table.SelectRows(stg_Vagas_Bruto,each [Fonte]="NYC" and fnChave([Orgao_Original])<>null and fnChave([Orgao_Original])<>""),
    Selecionados = Table.SelectColumns(Reais,{"Orgao_Original"}),
    Limpos = Table.TransformColumns(Selecionados,{{"Orgao_Original",each fnLimparTexto(Text.From(_)),type text}}),
    ComChave = Table.AddColumn(Limpos,"Chave_Orgao",each "NYC|" & fnChave([Orgao_Original]),type text),
    Unicos = Table.Distinct(Table.Buffer(Table.Sort(ComChave,{{"Orgao_Original",Order.Ascending}})),{"Chave_Orgao"}),
    RegistrosReais = List.Transform(Table.ToRecords(Unicos),(r)=>[Fonte="NYC",Cod_Orgao=r[Chave_Orgao],Orgao=r[Orgao_Original],Chave_Orgao=r[Chave_Orgao]]),
    Simulados = cad_Etapa1{[Item="Tab_Empresas_Simuladas",Kind="Table"]}[Data],
    RegistrosSimulados = List.Transform(Table.ToRecords(Simulados),(r)=>[Fonte="SIMULADO",Cod_Orgao=r[Codigo_Empresa],Orgao=r[Empresa_Padrao],Chave_Orgao="SIMULADO|" & fnChave(r[Empresa_Padrao])]),
    Resultado = Table.FromRecords(RegistrosReais & RegistrosSimulados,type table [Fonte=text,Cod_Orgao=text,Orgao=text,Chave_Orgao=text]),
    Ordenada = Table.Sort(Resultado,{{"Fonte",Order.Ascending},{"Cod_Orgao",Order.Ascending}})
in Ordenada
