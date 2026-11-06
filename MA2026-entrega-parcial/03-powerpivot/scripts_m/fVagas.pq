// fVagas
// Referência à tabela salva da Etapa 2; preserva registros e campos.
let
    Origem = cad_Etapa2{[Item = "fVagas", Kind = "Table"]}[Data],
    Tipos = Table.TransformColumnTypes(Origem, {
        {"Fonte", type text},
        {"Fonte_Dados", type text},
        {"Arquivo_Origem", type text},
        {"Linha_Origem", Int64.Type},
        {"ID_Registro_FaseI", type text},
        {"Linha_FaseI", Int64.Type},
        {"ID_Vaga", type text},
        {"Cod_Orgao", type text},
        {"Orgao", type text},
        {"Cod_Cargo", type text},
        {"Cargo", type text},
        {"Titulo", type text},
        {"Categoria", type text},
        {"Tipo_Publicacao", type text},
        {"Quantidade", Int64.Type},
        {"Salario_Min", Currency.Type},
        {"Salario_Max", Currency.Type},
        {"Amplitude_Salarial", Currency.Type},
        {"Ponto_Medio_Faixa", Currency.Type},
        {"Moeda", type text},
        {"Periodicidade", type text},
        {"Data_Publicacao", type date},
        {"Hora_Atendimento_Tratada", type time},
        {"Mes_Publicacao", type date},
        {"Atualizacao", type date},
        {"Limite_Candidatura", type date},
        {"Modalidade", type text},
        {"Vinculo", type text},
        {"Localidade", type text},
        {"Localidade_Detalhe", type text},
        {"Horario_Jornada", type text},
        {"Descricao", type text},
        {"Requisitos", type text},
        {"Habilidades", type text},
        {"Observacao_Qualidade", type text},
        {"ID_Cenario", type text}
    }, "pt-BR")
in
    Tipos
