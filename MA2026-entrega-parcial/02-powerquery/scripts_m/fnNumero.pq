// fnNumero
(valor as any, cultura as nullable text) as nullable number =>
let
    CulturaEscolhida = if cultura = null or Text.Trim(cultura) = "" then pCulturaPadrao else cultura,
    Numero =
        if valor = null then null
        else if valor is number then valor
        else Number.FromText(Text.Trim(Text.From(valor)), CulturaEscolhida)
in
    try Numero otherwise null
