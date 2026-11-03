// dCargo
let
    Reais = Table.SelectRows(stg_Vagas_Bruto, each [Fonte]="NYC" and fnChave([Codigo_Cargo_Original]) <> null and fnChave([Codigo_Cargo_Original]) <> ""),
    ReaisSelecionados = Table.SelectColumns(Reais,{"Codigo_Cargo_Original","Cargo_Publico_Original"}),
    ReaisLimpos = Table.TransformColumns(ReaisSelecionados,{{"Codigo_Cargo_Original",each Text.From(_),type text},{"Cargo_Publico_Original",each fnLimparTexto(Text.From(_)),type text}}),
    PorCodigo = Table.Group(ReaisLimpos,{"Codigo_Cargo_Original"},{{"Titulos",each List.Distinct([Cargo_Publico_Original]),type list}}),
    Ambiguos = Table.SelectRows(PorCodigo,each List.Count([Titulos])<>1),
    Validados = if not Table.IsEmpty(Ambiguos) then error Error.Record("CargoAmbiguo","Código público associado a títulos diferentes.",Ambiguos) else PorCodigo,
    RegistrosReais = List.Transform(Table.ToRecords(Validados),(r)=> [
        Fonte="NYC",Cod_Cargo="NYC|" & r[Codigo_Cargo_Original],Codigo_Origem=r[Codigo_Cargo_Original],
        Cargo=r[Titulos]{0},Categoria=null,Salario_Ref=null,Moeda_Ref=null,Periodicidade_Ref=null,
        Chave_Cargo="NYC|" & fnChave(r[Codigo_Cargo_Original])]),
    Simulados = cad_Etapa1{[Item="Tab_Cargos_Simulados",Kind="Table"]}[Data],
    RegistrosSimulados = List.Transform(Table.ToRecords(Simulados),(r)=> [
        Fonte="SIMULADO",Cod_Cargo=r[Codigo_Cargo],Codigo_Origem=r[Codigo_Cargo],Cargo=r[Cargo_Padrao],
        Categoria=r[Categoria],Salario_Ref=r[Salario_Ref],Moeda_Ref=r[Moeda_Ref],Periodicidade_Ref=r[Unidade_Ref],
        Chave_Cargo="SIMULADO|" & fnChave(r[Cargo_Padrao])]),
    Combinada = Table.FromRecords(RegistrosReais & RegistrosSimulados,type table [
        Fonte=text,Cod_Cargo=text,Codigo_Origem=text,Cargo=text,Categoria=nullable text,
        Salario_Ref=nullable number,Moeda_Ref=nullable text,Periodicidade_Ref=nullable text,Chave_Cargo=text]),
    Ordenada = Table.Sort(Combinada,{{"Fonte",Order.Ascending},{"Cod_Cargo",Order.Ascending}}),
    Unica = if Table.RowCount(Ordenada)<>List.Count(List.Distinct(Ordenada[Chave_Cargo])) then error "Chave de cargo duplicada." else Ordenada
in Unica
