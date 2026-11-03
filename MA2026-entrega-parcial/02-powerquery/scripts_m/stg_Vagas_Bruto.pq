// stg_Vagas_Bruto
let
    Origem = Folder.Files(pPastaVagas),
    SoPlanilhas = Table.SelectRows(Origem, each Text.Lower([Extension]) = ".xlsx" and not Text.StartsWith([Name], "~$")),
    ArquivosOrdenados = Table.Sort(SoPlanilhas, {{"Name", Order.Ascending}}),
    ComDados = Table.AddColumn(ArquivosOrdenados, "Dados", each fnLerVagas([Content])),
    SoNomeEDados = Table.SelectColumns(ComDados, {"Name", "Dados"}),
    Renomeada = Table.RenameColumns(SoNomeEDados, {{"Name", "Arquivo_Origem"}}),
    Anexada = Table.ExpandTableColumn(Renomeada, "Dados", ColunasAlvo & {"Linha_Origem"}),
    Ordenada = Table.Sort(Anexada, {{"Arquivo_Origem", Order.Ascending}, {"Linha_Origem", Order.Ascending}})
in
    Ordenada
