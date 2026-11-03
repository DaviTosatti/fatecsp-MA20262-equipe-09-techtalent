// DeParaColunas
let
    Tabela = #table(type table [Nome_Origem = text, Nome_Alvo = text], {
        {"job_id", "ID_Vaga_Original"},
        {"agency", "Orgao_Original"},
        {"posting_type", "Tipo_Publicacao_Original"},
        {"number_of_positions", "Quantidade_Original"},
        {"business_title", "Titulo_Original"},
        {"civil_service_title", "Cargo_Publico_Original"},
        {"title_classification", "Classificacao_Original"},
        {"title_code_no", "Codigo_Cargo_Original"},
        {"level", "Nivel_Original"},
        {"job_category", "Categoria_Original"},
        {"full_time_part_time_indicator", "Vinculo_Original"},
        {"career_level", "Carreira_Original"},
        {"salary_range_from", "Salario_Min_Original"},
        {"salary_range_to", "Salario_Max_Original"},
        {"salary_frequency", "Frequencia_Original"},
        {"work_location", "Localidade_Original"},
        {"division_work_unit", "Divisao_Original"},
        {"job_description", "Descricao_Original"},
        {"minimum_qual_requirements", "Requisitos_Originais"},
        {"preferred_skills", "Habilidades_Originais"},
        {"additional_information", "Informacoes_Originais"},
        {"to_apply", "Candidatura_Original"},
        {"hours_shift", "Horario_Original"},
        {"work_location_1", "Localidade_Detalhe_Original"},
        {"recruitment_contact", "Contato_Original"},
        {"residency_requirement", "Residencia_Exigida_Original"},
        {"posting_date", "Publicacao_Original"},
        {"post_until", "Limite_Original"},
        {"posting_updated", "Atualizacao_Original"},
        {"process_date", "Processamento_Original"},
        {"Qtd", "Quantidade_Original"},
        {"Data_Publicacao", "Publicacao_Original"}
    })
in
    Tabela
