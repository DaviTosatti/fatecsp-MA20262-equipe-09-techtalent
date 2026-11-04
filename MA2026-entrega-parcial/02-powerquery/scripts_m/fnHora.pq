// fnHora
(valor as any) as nullable time =>
let
    Resultado =
        if valor = null then null
        else if valor is time then valor
        else if valor is datetimezone then DateTime.Time(DateTimeZone.RemoveZone(valor))
        else if valor is datetime then DateTime.Time(valor)
        else if valor is number then Time.From(valor - Number.RoundDown(valor))
        else Time.FromText(Text.Trim(Text.From(valor)), "pt-BR")
in
    try Resultado otherwise null
