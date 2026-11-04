// fnChave
(valor as any) as nullable text =>
if valor = null then null
else Text.Upper(fnLimparTexto(Text.From(valor, "pt-BR")), "pt-BR")
