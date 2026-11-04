// fnLerVagas
(conteudo as binary) as table =>
let
    Planilha = fnLerPlanilha(conteudo),
    Padronizada = fnPadronizarColunas(Planilha),
    ComLinha = Table.AddIndexColumn(Padronizada, "Linha_Origem", 2, 1, Int64.Type)
in
    ComLinha
