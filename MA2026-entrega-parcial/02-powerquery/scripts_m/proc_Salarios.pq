// proc_Salarios
let
    Origem = stg_Salarios_Bruto,
    ComConversao = Table.AddColumn(Origem,"Conversao",each [
        Ano=fnNumero([Ano_Original],"en-US"),Salario=fnNumero([Salario_Original],"en-US"),Salario_USD=fnNumero([Salario_USD_Original],"en-US"),
        Chave_Cargo=fnChave([Cargo_Original]),Chave_Residencia=fnChave([Residencia_Original]),Chave_Empresa=fnChave([Pais_Empresa_Original])]),
    NumerosEChaves = Table.ExpandRecordColumn(ComConversao,"Conversao",{"Ano","Salario","Salario_USD","Chave_Cargo","Chave_Residencia","Chave_Empresa"}),
    MesclaCargo = Table.NestedJoin(NumerosEChaves,{"Chave_Cargo"},dCargoSalarios,{"Chave_Cargo"},"CadastroCargo",JoinKind.LeftOuter),
    ExpandeCargo = Table.ExpandTableColumn(MesclaCargo,"CadastroCargo",{"Cod_Cargo_Salarial","Cargo"},{"Cod_Cargo_Salarial","Cargo"}),
    MesclaResidencia = Table.NestedJoin(ExpandeCargo,{"Chave_Residencia"},dPais,{"Chave_Pais"},"CadastroResidencia",JoinKind.LeftOuter),
    ExpandeResidencia = Table.ExpandTableColumn(MesclaResidencia,"CadastroResidencia",{"Cod_Pais","Pais"},{"Cod_Pais_Residencia","Pais_Residencia"}),
    MesclaEmpresa = Table.NestedJoin(ExpandeResidencia,{"Chave_Empresa"},dPais,{"Chave_Pais"},"CadastroEmpresa",JoinKind.LeftOuter),
    ExpandeEmpresa = Table.ExpandTableColumn(MesclaEmpresa,"CadastroEmpresa",{"Cod_Pais","Pais"},{"Cod_Pais_Empresa","Pais_Empresa"}),
    ComMotivo = Table.AddColumn(ExpandeEmpresa,"Motivo",each
        if [Cargo_Original]=null or fnChave([Cargo_Original])="" then "Cargo salarial vazio"
        else if [Ano]=null then "Ano salarial não numérico"
        else if [Ano]<>Number.RoundDown([Ano]) or [Ano]<2020 or [Ano]>2024 then "Ano salarial fora do período"
        else if [Salario]=null or [Salario_USD]=null then "Salário ausente ou não numérico"
        else if [Salario]<=0 or [Salario_USD]<=0 then "Salário não positivo"
        else if [Moeda_Original]=null or fnChave([Moeda_Original])="" then "Moeda salarial ausente"
        else if [Cod_Cargo_Salarial]=null then "Cargo salarial não cadastrado"
        else if [Cod_Pais_Residencia]=null or [Cod_Pais_Empresa]=null then "País salarial sem correspondência"
        else null,type nullable text),
    Aceitas = Table.SelectRows(ComMotivo,each [Motivo]=null),
    ComRotulos = Table.AddColumn(Aceitas,"Rotulos",each [
        Experiencia=fnRotuloCadastro([Experiencia_Original],cad_AtributosSalarios[Experiencia]),
        Vinculo=fnRotuloCadastro([Vinculo_Original],cad_AtributosSalarios[Vinculo]),
        Modalidade=fnRotuloCadastro([Modalidade_Original],cad_AtributosSalarios[Modalidade]),
        Porte=fnRotuloCadastro([Porte_Original],cad_AtributosSalarios[Porte]),
        Moeda=Text.Upper(fnLimparTexto(Text.From([Moeda_Original]))),
        Periodicidade="Não confirmada",
        Observacao="Salário em USD informado pela origem; periodicidade não confirmada. Registros de igual valor não são removidos."]),
    Rotulos = Table.ExpandRecordColumn(ComRotulos,"Rotulos",{"Experiencia","Vinculo","Modalidade","Porte","Moeda","Periodicidade","Observacao"}),
    CamposTexto = {"Fonte","Arquivo_Origem","ID_Registro_FaseI","Cod_Cargo_Salarial","Cargo","Experiencia","Vinculo","Modalidade","Cod_Pais_Residencia","Pais_Residencia","Cod_Pais_Empresa","Pais_Empresa","Porte","Moeda","Periodicidade","Observacao"},
    Tipos = Table.TransformColumnTypes(Rotulos,List.Transform(CamposTexto,each {_,type text}) & {{"Ano",Int64.Type},{"Salario",type number},{"Salario_USD",type number},{"Linha_Origem",Int64.Type},{"Linha_FaseI",Int64.Type}}),
    FormatoFinal = Table.SelectColumns(Tipos,{"Fonte","Arquivo_Origem","Linha_Origem","ID_Registro_FaseI","Linha_FaseI","Cod_Cargo_Salarial","Cargo","Experiencia","Vinculo","Modalidade","Ano","Cod_Pais_Residencia","Pais_Residencia","Cod_Pais_Empresa","Pais_Empresa","Porte","Salario","Moeda","Salario_USD","Periodicidade","Observacao"}),
    Rejeitadas = Table.SelectRows(ComMotivo,each [Motivo]<>null),
    DescartesOriginais = Table.SelectColumns(Rejeitadas,Table.ColumnNames(Origem) & {"Motivo"}),
    Descartes = Table.AddColumn(DescartesOriginais,"Base",each "Salários",type text),
    Contagens = #table(type table [Base=text,Etapa=text,Linhas=Int64.Type],{
        {"Salários","Origem",Table.RowCount(Origem)},{"Salários","CadastrosRelacionados",Table.RowCount(ExpandeEmpresa)},
        {"Salários","AceitasSemDeduplicar",Table.RowCount(Aceitas)},{"Salários","FormatoFinal",Table.RowCount(FormatoFinal)}})
in [Aceitas=FormatoFinal,Descartes=Descartes,Contagens=Contagens]
