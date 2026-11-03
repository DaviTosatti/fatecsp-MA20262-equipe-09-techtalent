// fnData
(valor as any) as nullable date =>
let
    Resultado =
        if valor = null then null
        else if valor is date then valor
        else if valor is datetimezone then Date.From(valor)
        else if valor is datetime then Date.From(valor)
        else if valor is number then Date.From(valor)
        else
            let
                Texto = Text.Trim(Text.From(valor)),
                DataTexto =
                    if Texto = "" then null
                    else if Text.Length(Texto) >= 11 and Text.Middle(Texto, 10, 1) = "T" then
                        (try Date.From(DateTimeZone.FromText(Texto, [Culture = "en-US"]))
                         otherwise Date.From(DateTime.FromText(Texto, [Culture = "en-US"])))
                    else if Text.Length(Texto) = 11 and Text.Middle(Texto, 2, 1) = "-" and Text.Middle(Texto, 6, 1) = "-" then
                        Date.FromText(Texto, [Format = "dd-MMM-yyyy", Culture = "en-US"])
                    else
                        let
                            Partes = Text.Split(Text.Replace(Texto, "/", "-"), "-"),
                            QuantidadePartes = List.Count(Partes),
                            P1 = Number.FromText(Partes{0}, "en-US"),
                            P2 = Number.FromText(Partes{1}, "en-US"),
                            P3 = Number.FromText(Partes{2}, "en-US"),
                            DataValida =
                                if QuantidadePartes <> 3 then error "Formato de data inválido."
                                else if Text.Length(Partes{0}) = 4 then #date(P1, P2, P3)
                                else #date(P3, P2, P1)
                        in
                            DataValida
            in
                DataTexto
in
    try Resultado otherwise null
