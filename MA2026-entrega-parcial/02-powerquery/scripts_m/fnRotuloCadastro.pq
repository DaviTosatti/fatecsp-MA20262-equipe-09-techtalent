// fnRotuloCadastro
(valor as any, cadastro as table) as nullable text =>
let
    Limpo = if valor = null then null else fnLimparTexto(Text.From(valor)),
    Encontrados = Table.SelectRows(cadastro, each fnChave([Nome_Origem]) = fnChave(Limpo))
in
    if Limpo = null then null else if Table.IsEmpty(Encontrados) then Limpo else Encontrados{0}[Nome_Portugues]
