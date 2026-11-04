// fnLimparTexto
(texto as nullable text) as nullable text =>
if texto = null then null
else
    let
        SemEspacoEspecial = Text.Replace(texto, Character.FromNumber(160), " "),
        Aparado = Text.Trim(SemEspacoEspecial),
        SemRepeticoes = Text.Combine(List.Select(Text.Split(Aparado, " "), each _ <> ""), " ")
    in
        SemRepeticoes
