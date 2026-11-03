// fnPadronizarColunas
(tabela as table) as table =>
let
    Originais = Table.ColumnNames(tabela),
    Mapeamento = Record.FromList(DeParaColunas[Nome_Alvo], DeParaColunas[Nome_Origem]),
    Destinos = List.Transform(Originais, each Record.FieldOrDefault(Mapeamento, Text.Trim(_), Text.Trim(_))),
    Colisoes = List.Select(List.Distinct(Destinos), (alvo) => List.Count(List.Select(Destinos, each _ = alvo)) > 1),
    Pares = List.Select(List.Zip({Originais, Destinos}), each _{0} <> _{1}),
    Renomeada =
        if not List.IsEmpty(Colisoes) then
            error Error.Record("ColunasAmbiguas", "Mais de uma coluna aponta para o mesmo campo.", [Colunas = Text.Combine(Colisoes, ", ")])
        else Table.RenameColumns(tabela, Pares, MissingField.Ignore),
    NoFormatoAlvo = Table.SelectColumns(Renomeada, ColunasAlvo, MissingField.UseNull)
in
    NoFormatoAlvo
