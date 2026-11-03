// Conf_Reconciliacao
let
    Fontes = List.Sort(List.Distinct(stg_Vagas_Bruto[Fonte])),
    LinhasVagas = List.Transform(Fontes,(fonte)=>
        let Lidas=Table.RowCount(Table.SelectRows(stg_Vagas_Bruto,each [Fonte]=fonte)),
            Aceitas=Table.RowCount(Table.SelectRows(fVagas,each [Fonte]=fonte)),
            Rejeitadas=Table.RowCount(Table.SelectRows(Rejeitados_Vagas,each [Fonte]=fonte))
        in {"Vagas",fonte,Lidas,Aceitas,Rejeitadas,Lidas-Aceitas-Rejeitadas}),
    LinhaSalarios = {"Salários","SAL",Table.RowCount(stg_Salarios_Bruto),Table.RowCount(fSalarios),Table.RowCount(Rejeitados_Salarios),Table.RowCount(stg_Salarios_Bruto)-Table.RowCount(fSalarios)-Table.RowCount(Rejeitados_Salarios)},
    Linhas = LinhasVagas & {LinhaSalarios},
    Total = {"Total","Todas",List.Sum(List.Transform(Linhas,each _{2})),List.Sum(List.Transform(Linhas,each _{3})),List.Sum(List.Transform(Linhas,each _{4})),List.Sum(List.Transform(Linhas,each _{5}))},
    Tabela = #table(type table [Base=text,Fonte=nullable text,Lidas=Int64.Type,Aceitas=Int64.Type,Rejeitadas=Int64.Type,Diferenca=Int64.Type],Linhas & {Total}),
    Situacao = Table.AddColumn(Tabela,"Situacao",each if [Diferenca]=0 then "Conferido" else "Verificar",type text)
in Situacao
