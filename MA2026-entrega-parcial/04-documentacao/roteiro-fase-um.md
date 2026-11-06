# TechTalent — Fase I: preparação e auditoria no Excel

Adaptação das dez atividades e dos apêndices do **Guia Prático — Etapa 1: Excel Avançado**, Prof. Veríssimo, outubro de 2026. O arquivo [TechTalent_01_Excel.xlsx](../01-excel/TechTalent_01_Excel.xlsx) prepara dados para estudar cargos, habilidades e faixas salariais no mercado de tecnologia.

## Fontes e arquivos

| Base | Origem e recorte | Unidade e limites |
| --- | --- | --- |
| Salários | [Data Science Salaries 2024, de Sazidul Islam](https://www.kaggle.com/datasets/sazidthe1/data-science-salaries), correspondente ao Excel anterior do repositório; 2020–2024. | 6.599 observações, 11 campos. Periodicidade não confirmada; uma linha não comprova pessoa distinta ou vaga anunciada. |
| Anúncios NYC | [Jobs NYC Postings — kpav-sd4t](https://data.cityofnewyork.us/City-Government/Jobs-NYC-Postings/kpav-sd4t), categoria contendo `Technology, Data & Innovation`, inclusive categorias compostas. | 225 anúncios, 30 campos, 116 IDs; 115 publicações externas e 110 internas. Empregos municipais de Nova Iorque, sem representar todo o mercado. |
| Cenários didáticos | 15 registros fictícios identificados por `Fonte = SIMULADO`. | Presentes na tabela mista `Tab_Vagas` e no laboratório `Tab_Cenarios`: duas representações dos mesmos 15 casos. |

A exportação NYC foi obtida em **03/11/2026, às 16:37:55, horário de São Paulo**, com atualização do conjunto indicada em 27/10/2026, às 19:00:36 UTC. É uma cópia estática; os [termos NYC Open Data](https://data.cityofnewyork.us/stories/s/Terms-of-Use/k9k7-3cje) regem seu uso.

A fonte salarial reconhece `ai-jobs.net` como origem primária. Os [metadados Kaggle](https://www.kaggle.com/api/v1/datasets/metadata/sazidthe1/data-science-salaries) indicam a licença DbCL-1.0. `salary` é o salário na moeda original; `salary_in_usd` é o valor em USD fornecido pela fonte, sem atualização cambial neste projeto. A descrição não esclarece a unidade anual ou mensal.

| Arquivo em `01-excel/` | Finalidade |
| --- | --- |
| [data_science_salaries_organizado.xlsx](../01-excel/data_science_salaries_organizado.xlsx) | Excel anterior preservado. |
| [backup/salarios_ciencia_dados_anterior.xlsx](../01-excel/backup/salarios_ciencia_dados_anterior.xlsx) | Cópia de segurança do Excel anterior. |
| [dados-originais/salarios_ciencia_dados_origem.xlsx](../01-excel/dados-originais/salarios_ciencia_dados_origem.xlsx) | Entrada salarial preservada. |
| [dados-originais/salarios_ciencia_dados_kaggle.csv](../01-excel/dados-originais/salarios_ciencia_dados_kaggle.csv) | CSV da fonte salarial. |
| [dados-originais/vagas_nova_iorque.csv](../01-excel/dados-originais/vagas_nova_iorque.csv) | Exportação NYC preservada. |
| [TechTalent_01_Excel.xlsx](../01-excel/TechTalent_01_Excel.xlsx) | Pasta de trabalho da atividade. |

Mantenha entradas e backup sem edição e como Somente Leitura. Uma versão mais recente deve receber identificação própria, sem substituir a anterior.

## Estrutura da pasta de trabalho

| Aba | Conteúdo |
| --- | --- |
| **Bruto** | Quatro blocos: salários, 225 anúncios NYC, 15 cenários e sua representação no esquema de vagas. Valores, vazios e tipos preservados, sem tabelas estruturadas. |
| **Tratado** | `Tab_Salarios` com 6.599 observações; `Tab_Vagas` com 240 linhas, sendo 225 reais e 15 simuladas; `Tab_Cenarios` com os mesmos 15 casos e 29 colunas derivadas. |
| **Cadastros** | Cargos, países, empresas fictícias, de-para e listas válidas. Códigos internos e traduções servem à apresentação; não certificam a origem. |
| **Auditoria** | Uma linha por ocorrência e painel de detectado, registrado e diferença. |

Use `Fonte` para distinguir linhas reais e fictícias. `Tab_Cenarios` não acrescenta outras 15 vagas. O rastreio usa referência fixa à linha original, sem fórmula `LIN()` que mude ao ordenar; ações e situações também são valores fixos.

## Campos e cuidados de leitura

| Base | Campos | Significado e cuidado |
| --- | --- | --- |
| Salários | `job_title`, `experience_level`, `employment_type`, `work_models` | Cargo, experiência, vínculo e modalidade; conservar textos e usar cadastros de apresentação. |
| Salários | `work_year` | Ano de 2020 a 2024; não fabricar data diária ou mensal. |
| Salários | `employee_residence`, `company_location`, `company_size` | País da residência, país da empresa e porte; são atributos diferentes. |
| Salários | `salary`, `salary_currency`, `salary_in_usd` | Valor, moeda e valor USD da fonte; não somar moedas diferentes. |
| NYC | `job_id`, `posting_type`, `agency` | ID, publicação interna/externa e órgão; um ID pode aparecer em duas publicações. |
| NYC | `business_title`, `civil_service_title`, `title_classification`, `title_code_no`, `level`, `job_category` | Títulos, código, nível e categorias; conservar códigos e categorias compostas. |
| NYC | `number_of_positions`, `salary_range_from`, `salary_range_to` | Quantidade e limites salariais declarados como texto; preservar tipagem nesta fase. Zero salarial é admitido pela descrição da fonte. |
| NYC | `salary_frequency` | 206 anúncios anuais, 18 por hora e um por dia; unidades não comparáveis diretamente. |
| NYC | `posting_date`, `posting_updated`, `process_date`, `post_until` | Datas de publicação, atualização, processamento e encerramento. Encerramento vazio pode significar até preenchimento. |
| NYC | `work_location`, `work_location_1`, `division_work_unit`, `hours_shift` | Localidades, unidade e jornada em texto; não inferir coordenadas nem hora de evento. |
| NYC | `job_description`, `minimum_qual_requirements`, `preferred_skills` | Descrição, requisitos e habilidades em texto livre; 70 anúncios não informam habilidades. |
| NYC | Demais campos | Informações, candidatura, contato, residência exigida, indicador de jornada e carreira permanecem preservados na entrada. |

As datas NYC vão de 31/08/2026 a 26/10/2026. O horário `00:00` nos timestamps não comprova hora de publicação ou turno. Os cenários incluem datas e horas variadas, empresas/cargos fictícios, quantidades inválidas e salários com referências em BRL/mês para demonstrar os controles.

## Dez atividades do guia

| Atividade e páginas | Aplicação |
| --- | --- |
| 1. Preparar o ambiente, pp. 5–8 | Separar entradas, backup, arquivo de trabalho e documentação. |
| 2. Conhecer os dados, pp. 8–10 | Identificar campos, tipos, vazios, variações e unidade de cada bloco. |
| 3. Organizar abas e tabelas, pp. 10–15 | Quatro abas; Bruto preservado; tabelas estruturadas em Tratado e Cadastros. |
| 4. Tratar textos, códigos e datas, pp. 16–21 | Colunas novas para espaços, grafias, códigos, datas e horas; manter os originais. |
| 5. Buscar cadastros, pp. 21–23 | PROCX exato para códigos, descrições e atributos; retorno explícito sem correspondência. |
| 6. Criar auxiliares, pp. 23–24 | Mês, nome do mês e dia da semana para datas completas; turno apenas no atendimento fictício. |
| 7. Validar entradas, pp. 24–26 | Listas nos campos originais categóricos de Tratado e na auditoria, com alerta **Parar**. |
| 8. Destacar inconsistências, pp. 26–28 | Formatação condicional para status; desvio superior a 20% apenas no laboratório com referência comparável. |
| 9. Auditar, pp. 29–33 | Resumo por linha, rastreamento de fórmulas, registro fixo por ocorrência e painel. |
| 10. Revisar e salvar, pp. 33–34 | Retirar alterações transitórias, limpar filtros, ordenar pela origem e salvar `.xlsx`. |

## Equivalência das 24 fórmulas do guia

| Nº e finalidade | Equivalente no TechTalent |
| --- | --- |
| 1. Produto_Trat | Cargo com espaços tratados; título original preservado. |
| 2. Categoria_Trat | Categoria padronizada e apresentação pelo cadastro. |
| 3. Pagamento_Trat | Valor categórico de experiência ou vínculo, conforme a lista da fonte. |
| 4. Canal_Trat | Modalidade ou tipo de publicação em lista válida. |
| 5. Data_Trat | Data ISO NYC e formatos simulados; reconstruir e conferir dia/mês para recusar datas impossíveis. |
| 6. Status_Data | Data inválida ou fora do período da respectiva entrada. |
| 7. Hora_Trat | Conversão de hora do atendimento fictício. |
| 8. Cod_Filial | Código de país/órgão ou de-para da empresa simulada. |
| 9. Filial_Padrao | Descrição correspondente; ausência explícita. |
| 10. Cod_Produto | Código interno do cargo; desconhecido retorna Não cadastrado. |
| 11. Categoria_Cad | Categoria recuperada do cadastro, para conferência. |
| 12. Preco_Ref | Referência salarial fictícia, somente no laboratório. |
| 13. Custo_Unit | Busca de atributo complementar; não há custo real de contratação disponível. |
| 14. Confere_Categoria | Comparação entre categoria informada e cadastrada. |
| 15. Mes | Número do mês de data completa válida. |
| 16. Nome_Mes | Nome do mês em português. |
| 17. Dia_Semana | Dia da semana de data completa; não inferido do ano salarial. |
| 18. Turno | Atendimento fictício: Manhã antes de 12h, Tarde antes de 18h e Noite; antes de 06h fica Fora do horário. |
| 19. Status_Qtd | Vazio, zero, inválido ou sem tipo numérico; sem converter texto nesta fase. |
| 20. Cor da quantidade | Regra condicional vinculada ao status. |
| 21. Status_Preco | Tipagem/validade e, no laboratório, referência positiva de mesma moeda/periodicidade e desvio superior a 20%. |
| 22. Cor do desvio | Destaque reativo de ±20%, protegido para referência ausente, zero ou não comparável. |
| 23. Problemas | Concatenação filtrável das ocorrências da linha. |
| 24. Erros de fórmula | Contagem por tabela equivalente a `SOMARPRODUTO(--ÉERROS(tabela))`. |

Textos monetários continuam texto; sua conversão pertence à Etapa 2. Linhas repetidas continuam preservadas nesta fase. Correspondência desconhecida não recebe categoria arbitrária. A média da amostra e `salary_in_usd` não são benchmarks externos. No laboratório, **SIM-014 é USD/Anual** e sua referência é BRL/Mensal: o resultado deve ser **Não comparável**.

## Auditoria e conferência no Excel

Cada ocorrência contém fonte/base, linha original, identificador, campo, valor encontrado, tipo, ação, situação e observação. As situações são **Pendente de esclarecimento**, **Encaminhado à Etapa 2**, **Tratado por fórmula** e **Verificado sem alteração**. Uma linha pode ter várias ocorrências; tratamento por fórmula não altera o original.

O painel calcula **Diferença = Detectado − Registrado**, por tipo de problema. Conferir cada tipo, pois diferenças positivas e negativas podem se anular no total. O registro contém **587 ocorrências**; a tabela mista tem **233 de 240 linhas com alertas**; o laboratório tem **22 ocorrências em 13 dos 15 registros**. Esses números descrevem os controles e encaminhamentos, não problemas do mercado de trabalho.

1. Compare os quatro blocos Bruto e as colunas originais de Tratado, incluindo tipos e vazios; filtre Fonte para separar 225 reais e 15 simuladas na Tab_Vagas.
2. Use **Mostrar Fórmulas** para conferir início, meio e fim das colunas; desligue ao terminar.
3. Confira datas válidas, datas impossíveis, mês e dia da semana; ano salarial permanece ano.
4. Use **Rastrear Precedentes**, inclusive segundo nível e cadastro; siga **Rastrear Dependentes** até status/resumo e depois **Remover Setas**.
5. Use **Avaliar Fórmula** e **Verificação de Erros**. Em cópia, digite `=1/0` em célula livre, confira o erro e apague; a célula externa não compõe o detector das tabelas.
6. Em **Validação de Dados**, confira listas e alerta **Parar**; recuse valor desconhecido e use **Circular Dados Inválidos**, limpando círculos depois.
7. Em **Gerenciar Regras**, confira fórmulas e intervalos; em cópia, altere um valor, observe status/cor e desfaça.
8. Confira os cenários abaixo, incluindo desvio estritamente superior a 20%; exatamente 20% não excede o limite.
9. Localize ocorrências pela fonte e linha fixa; compare valor e ação, diferença por tipo e detector de erros separadamente.
10. Apague alterações transitórias, mantenha os 15 cenários documentados, limpe filtros, ordene pela origem, salve e reabra. O painel deve ter diferenças zero e as tabelas, zero erros de fórmula.

## Gabarito dos 15 cenários

O gabarito corresponde a `Tab_Cenarios`. `ID_Registro` distingue as linhas; o cenário `SIM-001` aparece duas vezes para demonstrar repetição.

| Registro | Cenário | Turno fictício | Ocorrências | Total |
| --- | --- | --- | --- | ---: |
| SIM-REG-001 | SIM-001 | Manhã | Identificador repetido. | 1 |
| SIM-REG-002 | SIM-002 | Manhã | Nenhuma. | 0 |
| SIM-REG-003 | SIM-003 | Tarde | Nenhuma. | 0 |
| SIM-REG-004 | SIM-004 | Tarde | Quantidade vazia. | 1 |
| SIM-REG-005 | SIM-005 | Noite | Quantidade zero; salário inválido. | 2 |
| SIM-REG-006 | SIM-006 | Manhã | Quantidade inválida. | 1 |
| SIM-REG-007 | SIM-007 | Manhã | Quantidade inválida; salário como texto. | 2 |
| SIM-REG-008 | SIM-008 | Manhã | Data inválida. | 1 |
| SIM-REG-009 | SIM-009 | Fora do horário | Data fora do período; hora antes de 06h. | 2 |
| SIM-REG-010 | SIM-010 | Hora inválida | Desvio superior a 20%; hora inválida. | 2 |
| SIM-REG-011 | SIM-011 | Noite | Desvio superior a 20%; categoria divergente. | 2 |
| SIM-REG-012 | SIM-012 | Tarde | Cargo/empresa sem cadastro; referência não utilizável; modalidade e vínculo fora da lista. | 5 |
| SIM-REG-013 | SIM-013 | Noite | Referência não utilizável. | 1 |
| SIM-REG-014 | SIM-014 | Tarde | Salário não comparável: USD/Anual versus BRL/Mensal. | 1 |
| SIM-REG-015 | SIM-001 | Manhã | Identificador repetido. | 1 |
| **Total** | **15 registros** | | **13 linhas com ocorrências** | **22** |

Turnos: seis Manhã, quatro Tarde, três Noite, um Fora do horário e um Hora inválida. As duas representações dos cenários não devem ser somadas como vagas diferentes.

## Pendências de interpretação

Confirmar com o professor as equivalências de custo, benchmark salarial e hora/turno real, demonstradas apenas didaticamente. Para as fontes reais, esclarecer periodicidade e metodologia salarial; definir extração de habilidades e semântica de vagas únicas. Os cadastros internos organizam a apresentação, sem constituir certificação externa das ocupações. A tipagem NYC é encaminhada à Etapa 2, preservando esta entrada.
