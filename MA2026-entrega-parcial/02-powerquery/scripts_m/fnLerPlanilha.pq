// fnLerPlanilha
(conteudo as binary) as table =>
let
    Pasta = Excel.Workbook(conteudo, true, true),
    Abas = Table.SelectRows(Pasta, each [Kind] = "Sheet"),
    PrimeiraAba =
        if Table.IsEmpty(Abas) then error "O arquivo não contém uma aba de dados."
        else Abas{0}[Data]
in
    PrimeiraAba
