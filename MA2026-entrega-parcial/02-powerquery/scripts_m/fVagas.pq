// fVagas
// Apresenta os estágios do pipeline único, sem repetir suas regras de tratamento.
let
    Processo = proc_Vagas,
    Origem = Processo[Etapas][Origem],
    SemLinhasEmBranco = Processo[Etapas][SemLinhasEmBranco],
    FontesConhecidas = Processo[Etapas][FontesConhecidas],
    SemIDVazio = Processo[Etapas][SemIDVazio],
    SemQtdNulaZero = Processo[Etapas][SemQtdNulaZero],
    SemDuplicatasExatas = Processo[Etapas][SemDuplicatasExatas],
    DatasHoras = Processo[Etapas][DatasHoras],
    SemDataInvalida = Processo[Etapas][SemDataInvalida],
    NoPeriodo = Processo[Etapas][NoPeriodo],
    SemHoraInvalida = Processo[Etapas][SemHoraInvalida],
    Numeros = Processo[Etapas][Numeros],
    SemErrosNumericos = Processo[Etapas][SemErrosNumericos],
    QuantidadeInteira = Processo[Etapas][QuantidadeInteira],
    QuantidadePositiva = Processo[Etapas][QuantidadePositiva],
    FaixaValida = Processo[Etapas][FaixaValida],
    ExpandeOrgao = Processo[Etapas][ExpandeOrgao],
    ComOrgao = Processo[Etapas][ComOrgao],
    ExpandeCargo = Processo[Etapas][ExpandeCargo],
    ComCargo = Processo[Etapas][ComCargo],
    SemDuplicatas = Processo[Etapas][SemDuplicatas],
    FormatoFinal = Processo[Etapas][FormatoFinal]
in
    FormatoFinal
