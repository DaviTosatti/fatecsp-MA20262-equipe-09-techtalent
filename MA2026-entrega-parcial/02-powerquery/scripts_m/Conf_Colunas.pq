// Conf_Colunas
let
    Origem = Folder.Files(pPastaVagas),
    SoPlanilhas = Table.SelectRows(Origem, each Text.Lower([Extension]) = ".xlsx" and not Text.StartsWith([Name], "~$")),
    Mapeamento = Record.FromList(DeParaColunas[Nome_Alvo], DeParaColunas[Nome_Origem]),
    ComDiagnostico = Table.AddColumn(SoPlanilhas, "Diagnostico", each
        let
            Originais = Table.ColumnNames(fnLerPlanilha([Content])),
            Destinos = List.Transform(Originais, each Record.FieldOrDefault(Mapeamento, Text.Trim(_), Text.Trim(_))),
            NaoMapeadas = List.Difference(List.Distinct(Destinos), ColunasAlvo),
            Ausentes = List.Difference(ColunasAlvo, List.Distinct(Destinos)),
            Colisoes = List.Select(List.Distinct(Destinos), (alvo) => List.Count(List.Select(Destinos, each _ = alvo)) > 1)
        in
            [
                Cabecalhos_Originais = Text.Combine(Originais, ", "),
                Cabecalhos_Padronizados = Text.Combine(Destinos, ", "),
                Colunas_Nao_Mapeadas = Text.Combine(NaoMapeadas, ", "),
                Colunas_Ausentes = Text.Combine(Ausentes, ", "),
                Colisoes = Text.Combine(Colisoes, ", ")
            ]),
    Selecionadas = Table.SelectColumns(ComDiagnostico, {"Name", "Diagnostico"}),
    Renomeada = Table.RenameColumns(Selecionadas, {{"Name", "Arquivo_Origem"}}),
    Expandida = Table.ExpandRecordColumn(Renomeada, "Diagnostico",
        {"Cabecalhos_Originais", "Cabecalhos_Padronizados", "Colunas_Nao_Mapeadas", "Colunas_Ausentes", "Colisoes"}),
    Ordenada = Table.Sort(Expandida, {{"Arquivo_Origem", Order.Ascending}})
in
    Ordenada
