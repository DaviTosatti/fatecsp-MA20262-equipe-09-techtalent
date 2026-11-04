// stg_Metas_Bruto
let
    Fonte = Excel.Workbook(File.Contents(pArquivoMetas),true),
    Planilhas = Table.SelectRows(Fonte,each [Kind]="Sheet"),
    Planilha = if Table.IsEmpty(Planilhas) then error "Arquivo de planejamento sem planilha." else Planilhas{0}[Data]
in Planilha
