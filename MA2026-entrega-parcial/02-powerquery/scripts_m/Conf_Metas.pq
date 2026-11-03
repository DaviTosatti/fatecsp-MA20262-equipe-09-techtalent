// Conf_Metas
let
    ColunasMeses = List.RemoveItems(Table.ColumnNames(stg_Metas_Bruto),{"Cod_Orgao","Orgao","Fonte"}),
    ValoresLargos = List.Combine(List.Transform(ColunasMeses,(c)=>List.Transform(Table.Column(stg_Metas_Bruto,c),each fnNumero(_,"pt-BR")))),
    SomaLarga = List.Sum(ValoresLargos),
    OrigensLongas = Table.RowCount(Table.Distinct(Table.SelectColumns(fMetas,{"Fonte","Cod_Orgao"}))),
    OrigensLargas = Table.RowCount(stg_Metas_Bruto),
    LinhasEsperadas = OrigensLargas * List.Count(ColunasMeses),
    OrgaosValidos = dOrgao[Cod_Orgao],
    SemOrgao = Table.RowCount(Table.SelectRows(fMetas,each not List.Contains(OrgaosValidos,[Cod_Orgao]))),
    Resultado = #table(type table [Indicador=text,Resultado=number,Esperado=number,Diferenca=number],{
        {"Órgãos do planejamento",OrigensLongas,OrigensLargas,OrigensLongas-OrigensLargas},
        {"Linhas após despivotar",Table.RowCount(fMetas),LinhasEsperadas,Table.RowCount(fMetas)-LinhasEsperadas},
        {"Total de contratações fictícias",List.Sum(fMetas[Meta_Contratacoes]),SomaLarga,List.Sum(fMetas[Meta_Contratacoes])-SomaLarga},
        {"Metas sem órgão correspondente",SemOrgao,0,SemOrgao}})
in Resultado
