// stg_Salarios_Bruto
let
    Fonte = cad_Etapa1{[Item="Tab_Salarios",Kind="Table"]}[Data],
    Selecionada = Table.SelectColumns(Fonte,{"Fonte","Linha_Origem","ID_Registro","Cargo_Original","Experiencia_Original","Vinculo_Original","Modalidade_Original","Ano_Original","Residencia_Original","Salario_Original","Moeda_Original","Salario_USD_Original","Pais_Empresa_Original","Porte_Original"}),
    RastreioRenomeado = Table.RenameColumns(Selecionada,{{"Linha_Origem","Linha_FaseI"},{"ID_Registro","ID_Registro_FaseI"}}),
    ComArquivo = Table.AddColumn(RastreioRenomeado,"Arquivo_Origem",each pArquivoEtapa1,type text),
    ComLinha = Table.AddColumn(ComArquivo,"Linha_Origem",each [Linha_FaseI],Int64.Type)
in ComLinha
