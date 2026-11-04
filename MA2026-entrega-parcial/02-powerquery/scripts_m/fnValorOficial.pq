// fnValorOficial
(valor as nullable text, lista as list) as nullable text =>
let
    Texto = fnLimparTexto(valor),
    Encontrados =
        if Texto = null then {}
        else List.Select(lista, each _ <> null and fnChave(_) = fnChave(Texto))
in
    if Texto = null or List.IsEmpty(Encontrados) then Texto else Encontrados{0}
