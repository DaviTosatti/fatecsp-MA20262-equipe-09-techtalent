// Conf_Etapas
let
    Etapas = Table.Combine({proc_Vagas[Contagens],proc_Salarios[Contagens]}),
    ComOrdem = Table.AddIndexColumn(Etapas,"Ordem",1,1,Int64.Type),
    Reordenada = Table.ReorderColumns(ComOrdem,{"Ordem","Base","Etapa","Linhas"})
in Reordenada
