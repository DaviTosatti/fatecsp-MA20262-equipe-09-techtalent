# Roteiro da Fase I — preparação e auditoria no Excel

Referência didática: **FatecSP_MA_Guia_Etapa1_Excel_CafeData.pdf**, “Guia Prático, Etapa 1: Excel Avançado”, Prof. Veríssimo, outubro de 2026, 37 páginas. Foram consideradas as dez atividades e os apêndices A a D. Os exemplos de 15 vendas e os resultados numéricos CaféData não são dados nem metas de resultado do TechTalent.

O objetivo desta fase é preservar, padronizar, relacionar e auditar as bases que apoiarão a pergunta: **quais são os cargos, habilidades e faixas salariais mais demandados pelo mercado de tecnologia?** A preparação ainda não fornece uma medida representativa da demanda do mercado inteiro.

## Fontes e unidades de registro

| Base | Origem imediata e recorte | Unidade e controle de entrada | Limitações |
| --- | --- | --- | --- |
| Salários | Excel `data_science_salaries_organizado.xlsx`, já existente no repositório no commit `d6da846`; conteúdo tabular confirmado no conjunto [Data Science Salaries 2024, de Sazidul Islam](https://www.kaggle.com/datasets/sazidthe1/data-science-salaries), anos de 2020 a 2024. | 6.599 registros, 11 campos; cada linha é uma observação salarial. | A descrição da fonte não explicita periodicidade salarial nem demonstra representatividade. Não presumir que cada linha seja uma pessoa distinta ou uma vaga anunciada. |
| Anúncios de Nova Iorque | [Jobs NYC Postings, identificador kpav-sd4t](https://data.cityofnewyork.us/City-Government/Jobs-NYC-Postings/kpav-sd4t), DCAS/NYC Open Data; seleção em `job_category` contendo `Technology, Data & Innovation`, inclusive categorias compostas. | 225 anúncios, 30 campos, 116 Job IDs distintos; 115 publicações `External` e 110 `Internal`. | Um Job ID pode ter anúncio interno e externo. Isso não autoriza somar anúncios como vagas únicas. O recorte abrange empregos municipais de Nova Iorque, sem representatividade presumida para Brasil ou setor privado. |
| Cenários didáticos | Dados fictícios criados com autorização do usuário e documentados na própria planilha. | **15 cenários fictícios**, com `Fonte = SIMULADO`, presentes na `Tab_Vagas` e representados também no laboratório `Tab_Cenarios`. | As duas representações são dos mesmos 15 cenários. Não são 30 casos diferentes, não preenchem linhas reais e não entram nas contagens de mercado. |

A exportação NYC foi coletada em **03/11/2026, às 16:37:55, horário de São Paulo**. Os metadados informam última atualização do conjunto em **27/10/2026, às 19:00:36 UTC**. A coleta é um **snapshot estático**, equivalente à exportação pontual de um filtro no portal. O Excel não contém conexão com o portal, integração de API nem atualização automática.

O CSV original de Nova Iorque tem SHA-256 `436ec9863df43803f643ff5a3ad220842bf9bc03897d8d7132a59bb485df6cac`. A licença nominal não está informada pelo provedor; consultar os [termos NYC Open Data](https://data.cityofnewyork.us/stories/s/Terms-of-Use/k9k7-3cje), sem presumir CC0.

O [Excel anterior](../01-excel/data_science_salaries_organizado.xlsx), seu [backup](../01-excel/backup/salarios_ciencia_dados_anterior.xlsx) e sua [cópia de entrada](../01-excel/dados-originais/salarios_ciencia_dados_origem.xlsx) têm SHA-256 `e6f8aea8046de5d7347b6c68fe8e9a8c92de082ef5375091a293dda57cfc41b2` e permanecem inalterados.

O [CSV oficial Kaggle preservado](../01-excel/dados-originais/salarios_ciencia_dados_kaggle.csv) tem SHA-256 `a27cd03130ff286c1d8b581e6011fb7776cbd683f71994573168335b9b05fd51`. A comparação encontrou os mesmos **11 cabeçalhos e valores dos 6.599 registros na mesma ordem**, após representar os números inteiros do Excel como texto decimal, sem limpar ou traduzir valores. Isso confirma correspondência de conteúdo tabular, sem alegar igualdade binária entre XLSX e CSV. A prova estruturada e os metadados completos são arquivos de apoio do ZIP local, não arquivos publicados no GitHub.

Os [metadados oficiais Kaggle](https://www.kaggle.com/api/v1/datasets/metadata/sazidthe1/data-science-salaries) identificam Sazidul Islam e reconhecem `ai-jobs.net` como origem primária. A [listagem oficial](https://www.kaggle.com/api/v1/datasets/list?search=data%20science%20salaries&user=sazidthe1) informa versão 2, atualização em 20/01/2024 e licença **Database: Open Database, Contents: Database Contents**; o campo `licenses` dos metadados contém **DbCL-1.0**. A descrição define `salary` como salário informado na moeda original e `salary_in_usd` como salário convertido em USD, sem explicitar unidade anual ou mensal. A periodicidade continua pendente.

## Organização dos arquivos e das quatro abas

```text
MA2026-entrega-parcial/
  01-excel/
    data_science_salaries_organizado.xlsx    Excel anterior preservado
    backup/
      salarios_ciencia_dados_anterior.xlsx  cópia binária de segurança
    dados-originais/
      salarios_ciencia_dados_origem.xlsx    entrada salarial preservada
      salarios_ciencia_dados_kaggle.csv     CSV oficial comparado ao Excel
      vagas_nova_iorque.csv                 exportação estática preservada
    TechTalent_01_Excel.xlsx                arquivo de trabalho
  04-documentacao/
    roteiro-fase-um.md                      este roteiro
```

Mantenha os arquivos de entrada e o backup sem edição e como somente leitura. Não substitua a entrada anterior ao obter uma versão mais recente; identifique a nova versão e registre sua origem antes de refazer o tratamento.

Por solicitação do usuário, o GitHub contém os artefatos da atividade nos caminhos existentes. Scripts, Python, JSON, provas estruturadas, metadados completos e modelos auxiliares de colaboração ficam no **ZIP local de apoio**. A entrada JSON dos cenários é apoio local; os dados e sua identificação fictícia ficam documentados no próprio Excel.

| Aba | Finalidade e regra de preservação |
| --- | --- |
| **Bruto** | **Quatro blocos** preservados: salários, 225 anúncios NYC, entrada dos 15 cenários e versão dos mesmos 15 cenários no esquema de vagas. Cada bloco conserva seus valores e tipos; não há tabelas estruturadas nem limpeza. Os blocos fictícios são identificados como `SIMULADO`. |
| **Tratado** | Três tabelas: salários com 6.599 observações; **Tab_Vagas com 240 linhas misturadas**, sendo 225 reais e 15 simuladas, identificadas pela coluna `Fonte`; e **Tab_Cenarios com os mesmos 15 cenários e 29 colunas derivadas**, como laboratório dos controles. Os valores originais de cada entrada são preservados em suas colunas. |
| **Cadastros** | Tabelas de referência, correspondências e listas válidas. Códigos e rótulos em português servem à apresentação e organização interna. Não equivalem a uma validação externa da veracidade da origem. |
| **Auditoria** | Registro fixo de uma linha por ocorrência, com fonte, identificador, linha de origem, campo, valor encontrado, tipo, ação, situação e observação; painel compara detectado, registrado e diferença. |

Os salários e as vagas mantêm seus esquemas próprios. A `Tab_Vagas` mistura as 225 linhas reais e as 15 fictícias no mesmo esquema, com **Fonte por linha**; qualquer contagem de anúncios reais precisa filtrar a fonte. A `Tab_Cenarios` representa novamente os **mesmos 15 casos fictícios** para demonstrar as fórmulas do guia. Ela não acrescenta 15 vagas fictícias novas. Os totais reais continuam **6.599 observações e 225 anúncios**; 240 é o número de linhas da tabela mista, não um indicador de vagas reais.

Identifique a fonte, o bloco e a linha de origem ao rastrear uma ocorrência. A referência numérica à origem é fixa, nunca uma fórmula `LIN()` que se altere ao ordenar. Ações e situações também ficam em valores fixos, sem depender da posição de uma matriz dinâmica.

## Inspeção e dicionário dos dados

### Observações salariais

| Campo original | Significado | Tipo e cuidado |
| --- | --- | --- |
| `job_title` | Título do cargo informado. | Texto; limpar espaços apenas em coluna tratada e consultar a correspondência de apresentação. |
| `experience_level` | Nível de experiência informado. | Texto categórico; lista e tradução de apresentação em cadastro. |
| `employment_type` | Tipo de vínculo informado. | Texto categórico; não deduzir uma relação jurídica brasileira. |
| `work_models` | Modalidade de trabalho informada. | Texto categórico; `Remote`, `On-site` e `Hybrid` permanecem no original. |
| `work_year` | Ano da observação. | Inteiro de 2020 a 2024; não é uma data completa. |
| `employee_residence` | País de residência informado. | Texto; não equivale à localização da vaga. |
| `salary` | Salário na moeda informada. | Número no arquivo recebido; conservar valor e moeda associados. |
| `salary_currency` | Código da moeda do salário. | Texto; não somar salários de moedas diferentes. |
| `salary_in_usd` | Valor em USD já existente na origem. | Número recebido; não é conversão cambial atual calculada pelo projeto. |
| `company_location` | País da empresa informado. | Texto; campo distinto da residência do profissional. |
| `company_size` | Porte da empresa informado. | Texto categórico; manter significado fornecido pelo cadastro. |

A base contém 5.827 salários em USD e também outras moedas. A inspeção de entrada encontrou zero duplicatas integrais; isso não prova que as observações sejam indivíduos distintos. A ausência de data completa, hora, identificador individual, habilidades e anúncios de vaga nesta fonte deve continuar explícita.

### Anúncios municipais de Nova Iorque

O esquema oficial declara **27 campos como texto e três como data de calendário**. Não há campo declarado como número. O CSV não codifica tipos; sua importação preserva o texto de origem, e as datas são tratadas em novas colunas. Campos vazios ficam vazios, sem preenchimento presumido.

| Campo ou grupo original | Significado e tratamento previsto |
| --- | --- |
| `job_id` | Identificador do anúncio de abertura; preservar como texto. Pode repetir entre publicação interna e externa. |
| `agency` | Órgão municipal anunciante; usar cadastro de apresentação e identificação interna. |
| `posting_type` | Publicação interna ou externa; preservar os valores `Internal` e `External` no original. |
| `number_of_positions` | Quantidade de posições informada, **declarada como texto**; sinalizar a tipagem e encaminhar conversão à Etapa 2. |
| `business_title`, `civil_service_title` | Título de divulgação e título do serviço público; são campos diferentes. |
| `title_classification`, `title_code_no`, `level` | Classificação, código e nível do título público; preservar códigos e texto. |
| `job_category` | Categoria ou conjunto de categorias do anúncio; o filtro de entrada mantém categorias compostas. |
| `full_time_part_time_indicator`, `career_level` | Indicador de jornada e nível de carreira; listas de valores da fonte. |
| `salary_range_from`, `salary_range_to` | Limites salariais, **declarados como texto**; preservar e sinalizar. Não converter nem calcular média salarial nesta fase. A descrição da fonte admite zero. |
| `salary_frequency` | Periodicidade salarial; há 206 anúncios anuais, 18 por hora e um por dia. Não comparar como se fossem a mesma unidade. |
| `work_location`, `work_location_1` | Localizações informadas, geral e específica. Não atribuir coordenadas nem bairro sem fonte. |
| `division_work_unit` | Divisão ou unidade do órgão. |
| `job_description` | Descrição livre das responsabilidades. |
| `minimum_qual_requirements` | Requisitos mínimos em texto livre. |
| `preferred_skills` | Habilidades preferenciais em texto livre; 70 anúncios sem preenchimento. Ausência de informação não significa ausência de exigências. |
| `additional_information`, `to_apply` | Informação adicional e instruções de candidatura. |
| `hours_shift` | Texto de jornada/turno quando fornecido; não confundir com a hora do timestamp de publicação. |
| `recruitment_contact`, `residency_requirement` | Contato e regra de residência informados pela fonte. |
| `posting_date`, `posting_updated`, `process_date` | Datas de publicação, atualização e processamento, declaradas como `calendar_date`; preservar ISO original e tratar em colunas novas. |
| `post_until` | Encerramento, declarado como texto; vazio significa anúncio até preenchimento, conforme descrição da fonte. Não classificar todo vazio como erro. |

Os 225 anúncios mantêm 116 Job IDs. Publicações `Internal` e `External` não são eliminadas. A inspeção da exportação encontrou zero duplicatas integrais. As datas de publicação do recorte vão de 31/08/2026 a 26/10/2026. Os timestamps à meia-noite não demonstram a hora real da publicação nem o turno de trabalho da vaga.

### Cenários didáticos simulados

O usuário autorizou dados fictícios para demonstrar campos e controles sem equivalentes encontrados nos recortes reais consultados. O conjunto mantém **15 cenários**, com `Fonte = SIMULADO`, inseridos na `Tab_Vagas` junto às 225 linhas reais. Os campos dos 225 registros reais permanecem inalterados. Os mesmos 15 casos aparecem no laboratório `Tab_Cenarios`, com **29 colunas derivadas**; não são 15 casos adicionais.

As duas representações das entradas fictícias estão preservadas em blocos identificados da aba Bruto. Os cenários e os cadastros fictícios estão documentados no Excel; o JSON usado como apoio à criação fica somente no ZIP local e não é uma fonte externa de mercado.

| Elemento fictício | Finalidade didática e limite |
| --- | --- |
| Datas em formatos diferentes, data impossível e data fora do período didático | Exercitar padronização, verificação de dia/mês e status de período. Não são datas atribuídas a anúncios NYC ou observações salariais. |
| Horas de atendimento de recrutamento e janela a partir das 06h | Demonstrar conversão de hora e classificação de turnos de **atendimento fictício**. Não representam turno de trabalho das vagas reais nem horário real de publicação. |
| Empresas, grafias de empresa, cargos e cadastros fictícios | Exercitar de-para, códigos, atributos e ausência de correspondência; incluir categoria divergente sem alterar o dado de entrada. |
| Quantidades vazias, zero e texto | Demonstrar status, formatação condicional e auditoria. Texto permanece texto nesta fase. |
| Salários e referências fictícias, com referências em BRL por mês | Demonstrar busca e desvio absoluto superior a 20% **somente quando moeda e periodicidade coincidirem**. O caso **SIM-014 usa USD/Anual** diante de referência BRL/Mensal para testar o retorno “Não comparável”, sem conversão. Não constituem benchmark do mercado. |
| Valores desconhecidos e duplicatas controladas | Demonstrar listas, retornos sem cadastro e registro das ocorrências sem completar correspondências por suposição nem remover linhas. |

Os resultados devem ser conferidos contra a própria entrada fictícia, não contra os números CaféData. As ocorrências simuladas permanecem identificadas por fonte, bloco e tabela no registro e no painel. Não somar os 15 casos da Tab_Vagas aos mesmos 15 da Tab_Cenarios como se fossem 30 casos; são representações distintas para conferências distintas. Nenhum cenário fundamenta conclusão sobre cargos, salários ou habilidades demandados.

## Equivalência das dez atividades do guia

| Atividade e páginas | Aplicação no TechTalent | Conferência necessária |
| --- | --- | --- |
| **1. Preparar o ambiente**, pp. 5–8 | Separar backup, dados originais, arquivo de trabalho e documentação; manter o Excel anterior. | Comparar hashes e confirmar atributos de somente leitura; abrir entradas sem salvar. |
| **2. Conhecer os dados brutos**, pp. 8–10 | Identificar os quatro blocos preservados e distinguir fonte, esquema, unidade, tipo e representação de cada entrada. | Conferir 6.599 salários e 225 anúncios reais; identificar os mesmos 15 cenários em duas representações. |
| **3. Organizar abas e tabelas**, pp. 10–15 | Exatamente quatro abas; quatro blocos Bruto sem tabela; três tabelas em Tratado, incluindo Tab_Vagas mista e Tab_Cenarios de laboratório. | Conferir 240 linhas na Tab_Vagas, sendo 225 reais e 15 simuladas, e 15 casos no laboratório sem duplicar o total de cenários. |
| **4. Tratar textos, códigos e datas**, pp. 16–21 | Tratar textos e datas ISO nas fontes reais; nos cenários, exercitar também formatos mistos, datas inválidas, horas e de-para de empresas fictícias. | Comparar entrada/tratado, verificar dia e mês após `DATA` e conferir conversão de horas apenas onde exista hora informada. |
| **5. Buscar dados dos cadastros**, pp. 21–23 | Recuperar códigos internos, descrições em português e atributos de apresentação com PROCX exato; manter retornos de ausência de correspondência. | Testar uma chave conhecida e uma desconhecida sem inserir correspondências por suposição. |
| **6. Criar auxiliares**, pp. 23–24 | Mês, nome do mês e dia da semana para datas completas NYC e dos cenários; turno de atendimento apenas na simulação. Ano salarial permanece ano. | Não fabricar data `01/01` nas observações reais nem classificar turno por timestamp NYC `00:00`. |
| **7. Validar entradas**, pp. 24–26 | Listas nos campos categóricos originais das tabelas Tratado e nos tipos/situações da auditoria; alerta **Parar**. | Tentar valor fora da lista, cancelar, circular dados inválidos e desfazer testes. |
| **8. Destacar inconsistências**, pp. 26–28 | Status e cores para vazios, tipos, valores inválidos e ausência de cadastro; desvio salarial de ±20% demonstrado **apenas com referências fictícias em Tab_Cenarios**. | Consultar Gerenciar Regras e testar em cópia de trabalho. Conferir que nenhuma referência simulada seja aplicada aos salários reais. |
| **9. Auditar a base**, pp. 29–33 | Resumo dos problemas, rastreamento de fórmulas, registro fixo por ocorrência e painel detectado/registrado/diferença. | Diferença zero por tipo após registro; ausência de erros de fórmula; rastrear casos até a fonte. |
| **10. Revisar e salvar**, pp. 33–34 | Retirar testes, limpar filtros, ordenar pelas referências de origem e salvar `.xlsx`, sem consultas ou macros. | Fechar/reabrir no Excel, recalcular e conferir cada item; pendências precisam de ação registrada. |

## Equivalência das 24 fórmulas numeradas

Os números abaixo são os identificadores das fórmulas no PDF, não o número de colunas exigido na adaptação. A equivalência conserva a finalidade do controle. Os controles sem aplicação sustentada nos recortes reais são demonstrados no bloco **SIMULADO**, conforme autorização do usuário. Essa demonstração não transforma dados fictícios em evidência de mercado e não encerra a pendência de aplicabilidade às bases reais.

| Nº e finalidade no guia | Equivalência nesta base |
| --- | --- |
| **1 — Produto_Trat** | Limpeza de espaços do título de cargo em coluna tratada. Acrônimos e títulos originais continuam preservados; a apresentação em português vem do cadastro. |
| **2 — Categoria_Trat** | Padronização de categorias reais e rótulos de apresentação, preservando originais; no bloco SIMULADO, padronização da categoria fictícia antes de compará-la ao cadastro. |
| **3 — Pagamento_Trat** | Busca de um valor categórico em sua lista válida: experiência ou vínculo, na base salarial. Não há pagamento de venda. |
| **4 — Canal_Trat** | Busca em lista de modalidade de trabalho ou tipo de publicação. Não se cria canal comercial fictício. |
| **5 — Data_Trat** | Separação de ano, mês e dia do ISO NYC e dos formatos mistos simulados; montar `DATA` e comparar novamente dia/mês para rejeitar datas impossíveis. Ano salarial isolado não passa por essa conversão. |
| **6 — Status_Data** | Classificação de data inválida e de período conforme a respectiva entrada. Os cenários incluem período didático identificado; não se impõe o período CaféData às fontes reais. |
| **7 — Hora_Trat** | Conversão da hora de atendimento fictício em Tab_Cenarios. Fontes reais não recebem horas inventadas; o timestamp NYC `00:00` continua sem interpretação como hora de evento ou jornada. |
| **8 — Cod_Filial** | Busca exata de país ou órgão nas fontes reais; de-para de empresas fictícias na simulação. Grafia sem correspondência continua identificada. |
| **9 — Filial_Padrao** | Recuperação da descrição de país/órgão real ou empresa fictícia associada ao respectivo cadastro. Ausência retorna “Sem correspondência”. |
| **10 — Cod_Produto** | Busca do código interno do cargo tratado; inclui cargo desconhecido no bloco simulado. Título sem correspondência permanece “Não cadastrado”. |
| **11 — Categoria_Cad** | Recuperação de atributos descritivos de apresentação; nos cenários, categoria do cadastro fictício. Não prova classificação externa independente. |
| **12 — Preco_Ref** | Busca de referência salarial **fictícia em BRL/mês somente em Tab_Cenarios**. Nas bases reais, benchmark independente comparável continua ausente; não usar a média da amostra como referência oficial. |
| **13 — Custo_Unit** | Finalidade de recuperar atributo complementar do cadastro, quando existir equivalente identificado. Não há custo unitário comprovado nas fontes reais; a demonstração de buscas em cadastros fictícios não cria custo real de contratação nem encerra a validação didática com o professor. |
| **14 — Confere_Categoria** | Conferência interna de categoria; o bloco simulado contém divergência controlada em relação ao cadastro fictício. Nenhum desses cadastros certifica a qualidade externa dos registros reais. |
| **15 — Mes** | Número do mês extraído de data NYC ou simulada válida; sem mês presumido para observações salariais que trazem apenas ano. |
| **16 — Nome_Mes** | Nome do mês em português a partir de data válida; formato regional explícito quando necessário. |
| **17 — Dia_Semana** | Dia da semana da data NYC válida em português; nenhum dia da semana é inferido apenas de `work_year`. |
| **18 — Turno** | Classificação do **atendimento fictício de recrutamento** por hora em Tab_Cenarios, com janela a partir das 06h e retorno fora do horário antes disso. Não classifica jornada das vagas reais; `hours_shift` NYC permanece texto original. |
| **19 — Status_Qtd** | Verificação de `number_of_positions` NYC e de quantidades simuladas, incluindo vazio, zero e texto. Texto não é convertido silenciosamente para satisfazer o teste de inteiro; conversão pertence à Etapa 2. |
| **20 — Cor da quantidade** | Formatação condicional vinculada ao status de quantidade, incluindo ausência de tipo numérico; regra reativa sobre as células afetadas. |
| **21 — Status_Preco** | Status de tipagem e validade dos salários reais quando verificáveis, sem converter limites NYC. Em Tab_Cenarios, comparar salário e referência fictícios apenas quando moeda e periodicidade coincidirem; tratar ausência de referência e desvio absoluto superior a 20%. SIM-014 usa USD/Anual diante de referência BRL/Mensal e deve retornar “Não comparável”, sem conversão. |
| **22 — Cor do desvio** | Regra reativa de ±20% sobre salários e referências **somente simulados**, com proteção para ausência de referência. Nas fontes reais, as cores mostram status verificáveis, sem atribuir “OK” a um benchmark inexistente. |
| **23 — Problemas** | Concatenação das ocorrências da linha em texto filtrável, com a mesma terminologia usada no registro e no painel. Uma linha pode gerar várias ocorrências. |
| **24 — Erros de fórmula** | Contagem de células com erro em cada tabela de Tratado, equivalente a `SOMARPRODUTO(--ÉERROS(tabela))`; não confundir mensagens textuais de status com erros do Excel. |

As fórmulas são armazenadas no `.xlsx` na sintaxe interna do Excel e exibidas conforme o idioma da instalação. No Excel em português, usar `PROCX`, `ARRUMAR`, `SE`, `ÉNÚM`, `DATA`, `DIA`, `MÊS`, `TEXTO`, `CONT.SE` e demais equivalentes do apêndice A. A representação interna em inglês não traduz os títulos, comentários ou nomes do projeto para inglês.

## Preservação dos defeitos e limites de tratamento

- **D1 a D4:** tratar somente em colunas adicionais; datas devem ser válidas e correspondências precisam estar documentadas. Não modificar identificadores para facilitar uma busca.
- **D5:** quantidade ausente, zero ou sem tipo numérico deve permanecer visível. O esquema NYC admite texto; isso é encaminhamento de tipagem, não prova de erro no provedor.
- **D6:** valores monetários armazenados como texto permanecem texto. Não usar o aviso “Converter em Número”, `VALOR`, multiplicação por 1 ou conversão programática para antecipar a Etapa 2.
- **D7:** retorno sem cadastro não é preenchido com a primeira categoria disponível. Registrar e confirmar a correspondência antes de alterar o cadastro.
- **D8:** conservar linhas e identificadores repetidos. Mesmo Job ID interno/externo não é duplicata integral e não deve ser removido nesta fase.
- **D9:** a regra de ±20% é demonstrada nos cenários com referências salariais fictícias em BRL/mês. Nas fontes reais, não aplicar ±20% à média, ao `salary_in_usd` ou a salários de periodicidades diferentes para fabricar um benchmark.
- **D10:** preservar os quatro blocos de entrada e a identificação da fonte na tabela mista de vagas. A adequação dos 15 fictícios ao esquema de vagas não transforma nem consolida as duas fontes reais; conversões de tipo das fontes reais permanecem para a fase seguinte.

## Auditoria e painel de conferência

Cada ocorrência deve identificar **fonte/base, referência fixa à origem, identificador, campo, valor encontrado, tipo de problema, ação necessária, situação e observação**. Registre uma linha por problema, mesmo que duas ocorrências pertençam ao mesmo anúncio. Use valores fixos para a ocorrência; a situação não pode se deslocar ao reordenar a base ou recalcular uma fórmula.

As situações seguem a finalidade do guia: **Pendente de esclarecimento**, **Encaminhado à Etapa 2**, **Tratado por fórmula** e **Verificado sem alteração**. “Tratado por fórmula” significa que a coluna derivada foi tratada; não autoriza reescrever a origem. Observações devem registrar decisão, responsável e data quando houver confirmação.

O painel conta cada tipo a partir das verificações de Tratado (**Detectado**), conta o mesmo tipo na tabela de ocorrências (**Registrado**) e calcula **Diferença = Detectado − Registrado**. Conferir cada linha e o total: diferença total zero sozinha pode ocultar tipos com diferenças positivas e negativas. O total de ocorrências pode superar o total de registros problemáticos.

As ocorrências dos 15 cenários devem ter `Fonte = SIMULADO`, além da identificação da tabela/bloco em que o controle foi aplicado. Ao conferir detectado/registrado, distinguir a Tab_Vagas e o laboratório Tab_Cenarios para não contar o mesmo cenário como duas vagas. Contagens de ocorrências podem existir nas duas representações, mas não se tornam contagens de registros únicos. Nenhuma ocorrência fictícia deve ser descrita como falha encontrada no Kaggle ou no NYC Open Data.

Pendências de aplicação às fontes reais, como a falta de benchmark, custo e hora de evento, devem ficar identificadas com ação de consulta ao professor. A simulação demonstra os recursos do Excel e não elimina essas ausências reais. Elas não são erros salariais de cada linha, nem devem ser contadas como 225 salários fora de uma referência inexistente.

## Evidências da validação final

| Verificação | Resultado |
| --- | --- |
| Verificações independentes de estrutura, preservação, cálculos e rastreabilidade | **205 de 205 aprovadas**. |
| Testes de comportamento no Excel nativo | **19 de 19 aprovados**. |
| Testes de cores da formatação condicional | **Três de três aprovados**. |
| Painel de auditoria | **Diferença zero em todas as linhas** e **zero erros de fórmula**. |
| Preservação | Comparação integral das entradas, originais e backups aprovada, incluindo os espaços dos cenários. |
| Registros de auditoria | **587 ocorrências** na pasta de trabalho. |
| Linhas com alertas na tabela mista Tab_Vagas | **233 de 240 linhas**. |
| Laboratório Tab_Cenarios | **22 ocorrências em 13 dos 15 registros**. |

As 587 ocorrências incluem valores preservados como texto e encaminhados à etapa seguinte, além dos controles didáticos nas duas representações dos cenários. As 233 linhas com alertas pertencem à tabela mista. Esses resultados verificam a preparação e a auditoria do arquivo; **não medem problemas reais do mercado de trabalho**. As evidências detalhadas e os scripts de conferência ficam no ZIP local de apoio, sem publicação de arquivos JSON ou scripts no GitHub.

## Conferência no Excel

Os procedimentos abaixo permitem à equipe repetir a conferência operacional no Excel. Os resultados automatizados e os testes no Excel nativo estão resumidos acima; isso não implica que cada interação de menu descrita tenha sido executada manualmente. Registrar a evidência ao repetir uma verificação.

1. **Integridade e contagens:** comparar entradas e quatro blocos Bruto, incluindo cabeçalhos, vazios, valores e tipos. Conferir 6.599 salários, 225 anúncios NYC e as duas representações dos mesmos 15 cenários. Em Tab_Vagas, conferir **240 linhas totais = 225 reais + 15 simuladas** por Fonte. Em Tab_Cenarios, conferir os mesmos 15 casos e 29 colunas derivadas. Não usar contagem de coluna inteira que misture blocos.
2. **Estrutura e fórmulas:** confirmar exatamente quatro abas, tabelas com nomes únicos e sem sobreposição, filtros e referências fixas. Em **Fórmulas → Mostrar Fórmulas**, conferir início, meio e fim de cada coluna calculada. Desligar a visualização ao terminar.
3. **Datas válidas e impossíveis:** escolher uma data ISO NYC, conferir a data tratada em formato Geral e em `dd/mm/aaaa`, e conferir seu mês e dia da semana. Numa cópia de teste, usar uma data impossível, verificar o status e desfazer. Não salvar a data de teste no original.
4. **Buscas e rastreamento:** numa célula de código/atributo recuperado, usar **Fórmulas → Rastrear Precedentes**, inclusive o segundo nível. Seguir a seta para Cadastros e a cadeia até o texto original. Usar **Rastrear Dependentes** até status/resumo e **Remover Setas** ao terminar. Uma chave desconhecida deve produzir mensagem explícita, sem erro `#N/D` oculto por um resultado plausível.
5. **Avaliação e erros:** usar **Fórmulas → Avaliar Fórmula** em uma data e em uma busca; acompanhar as etapas. Executar **Fórmulas → Verificação de Erros**. Para conferir o detector, digitar temporariamente `=1/0` em célula livre fora das tabelas, confirmar `#DIV/0!` na verificação e **apagar a célula imediatamente depois**. Essa célula externa não compõe a contagem de erros das tabelas Tratado.
6. **Listas com bloqueio:** em **Dados → Validação de Dados**, conferir fonte da lista e **Alerta de erro → Estilo: Parar**. Num campo categórico original em Tratado, tentar um valor inexistente, cancelar o alerta e confirmar a preservação do valor anterior. Usar **Circular Dados Inválidos** para entradas preexistentes; limpar círculos após conferir. A validação não corrige o passado e colar conteúdo pode contornar o bloqueio.
7. **Cores reativas:** em **Página Inicial → Formatação Condicional → Gerenciar Regras**, conferir fórmula e intervalo aplicado. Numa cópia de teste, retirar um valor obrigatório, verificar status e cor e usar **Ctrl+Z**. Não alterar os blocos Bruto. As regras de cor devem acompanhar status, sem substituir o registro de ocorrências.
8. **Cenários simulados:** conferir datas de formatos diferentes, datas impossíveis, hora de atendimento antes das 06h, hora inválida, empresas sem correspondência, cargo desconhecido, categoria divergente e quantidades vazia/zero/texto. Conferir a regra de desvio **superior** a 20% para mais e para menos, incluindo ausência de referência; exatamente 20% não deve ser tratado como superior a 20%. Não remover a duplicata controlada. Usar o gabarito abaixo para repetir a conferência.
9. **Registro e painel:** sortear ocorrências de cada base real e do bloco simulado, localizar a entrada por fonte e linha, comparar valor e identificador e verificar a ação. Conferir detectado, registrado e diferença **por tipo de problema**, que é a agregação do painel. Usar a coluna Fonte para filtrar e rastrear as ocorrências no registro e em Tratado; o painel não apresenta diferenças separadas por fonte. Conferir os erros de fórmula separadamente. Uma ocorrência encaminhada continua registrada, não desaparece do painel.
10. **Revisão final:** apagar células de testes transitórios, preservando os 15 cenários como parte documentada da atividade. Limpar filtros e ordenar cada tabela pela referência de origem. Conferir que nenhuma entrada real foi sobrescrita, que quantidades/salários NYC continuam texto e que a simulação está identificada. Salvar como `.xlsx`, fechar e reabrir; recalcular e verificar ausência de aviso de vínculos externos ou reparo.

## Gabarito dos 15 registros simulados

Este gabarito corresponde ao laboratório **Tab_Cenarios**, não aos anúncios reais nem ao total de ocorrências da Tab_Vagas. O `ID_Registro` distingue as 15 linhas; `ID_Cenario = SIM-001` aparece duas vezes de propósito, para exercitar a identificação de repetição.

| ID_Registro | ID_Cenario | Turno de atendimento fictício | Ocorrências esperadas no laboratório | Quantidade |
| --- | --- | --- | --- | ---: |
| SIM-REG-001 | SIM-001 | Manhã | Identificador repetido. | 1 |
| SIM-REG-002 | SIM-002 | Manhã | Nenhuma ocorrência. | 0 |
| SIM-REG-003 | SIM-003 | Tarde | Nenhuma ocorrência. | 0 |
| SIM-REG-004 | SIM-004 | Tarde | Quantidade vazia. | 1 |
| SIM-REG-005 | SIM-005 | Noite | Quantidade zero; salário inválido. | 2 |
| SIM-REG-006 | SIM-006 | Manhã | Quantidade inválida. | 1 |
| SIM-REG-007 | SIM-007 | Manhã | Quantidade inválida; salário como texto. | 2 |
| SIM-REG-008 | SIM-008 | Manhã | Data inválida. | 1 |
| SIM-REG-009 | SIM-009 | Fora do horário | Data fora do período; hora antes das 06h. | 2 |
| SIM-REG-010 | SIM-010 | Hora inválida | Desvio salarial superior a 20%; hora inválida. | 2 |
| SIM-REG-011 | SIM-011 | Noite | Desvio salarial superior a 20%; categoria divergente. | 2 |
| SIM-REG-012 | SIM-012 | Tarde | Cargo não cadastrado; empresa sem correspondência; referência salarial não utilizável; modalidade fora da lista; vínculo fora da lista. | 5 |
| SIM-REG-013 | SIM-013 | Noite | Referência salarial não utilizável. | 1 |
| SIM-REG-014 | SIM-014 | Tarde | Salário não comparável: USD/Anual diante de referência BRL/Mensal. | 1 |
| SIM-REG-015 | SIM-001 | Manhã | Identificador repetido. | 1 |
| **Total** | **15 registros** | | **13 linhas com ocorrências** | **22** |

Distribuição dos turnos fictícios: **seis Manhã, quatro Tarde, três Noite, um Fora do horário e um Hora inválida**, totalizando 15. As comparações salariais do laboratório só são realizadas quando moeda e periodicidade coincidem; o caso SIM-014 deve permanecer “Não comparável”, sem conversão presumida.

## Pendências que exigem decisão do professor ou confirmação da fonte

| Pendência | Ação necessária |
| --- | --- |
| Periodicidade e metodologia salarial | A correspondência com o CSV de Sazidul Islam foi confirmada e a licença declarada está registrada. Confirmar unidade anual/mensal, metodologia da coleta primária e significado de cada observação; esses pontos não são resolvidos pela igualdade dos arquivos. |
| Benchmark real de salário e desvio de ±20% | O controle é demonstrado com referências fictícias em Tab_Cenarios. Para aplicá-lo aos dados reais, validar com o professor e obter referência independente comparável por cargo, localidade, período, moeda e periodicidade. |
| Ausência de custo unitário | Validar a dispensa ou equivalência didática sem inventar custo de contratação. |
| Ausência de hora de evento e turno real verificável | A conversão de hora e os turnos são demonstrados por atendimento fictício. Validar a adaptação às fontes reais: a hora `00:00` dos timestamps NYC não é evidência de turno. |
| Cadastro interno derivado da origem | Validar a finalidade didática das buscas; traduções e códigos de apresentação não constituem cadastro externo oficial de cargos. |
| Quantidades e salários NYC como texto | Na Etapa 2, definir conversão auditável, regras para vazios/zero e periodicidades, preservando a fonte. Não resolver a tipagem nesta fase. |
| Demanda de habilidades e total de vagas únicas | Nas fases adequadas, definir vocabulário, extração dos textos livres, semântica dos Job IDs e tratamento de publicações internas/externas antes de construir KPIs. |

## Registro das etapas no Git

O histórico usa commits separados por etapa concluída e revisada, com descrições em português e tipos Conventional Commits, como `chore(dados)`, `feat(excel)` e `docs(fase-um)`.

O **corpo do commit que introduziu os cenários** declara que os campos são fictícios e foram criados para demonstrar procedimentos do guia cujos equivalentes não foram encontrados nos recortes reais consultados. A identificação `Fonte = SIMULADO` distingue os 15 registros fictícios dentro da tabela mista, preservando os registros reais.

O pull request deve descrever o arquivo resultante, a preservação das entradas, as verificações efetivamente executadas e as pendências restantes. Usar título, descrição e comentários em português, mantendo os tipos técnicos Conventional Commits. Não habilitar integração automática nem alterar datas de commits para simular o tempo decorrido. Os modelos de colaboração e os scripts auxiliares ficam somente no ZIP local de apoio.
