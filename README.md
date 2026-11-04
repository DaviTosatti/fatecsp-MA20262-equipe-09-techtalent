# TechTalent — análise do mercado de trabalho em tecnologia

Projeto Evolutivo de Dados da equipe 09, disciplina Microinformática Aplicada da Fatec São Paulo, semestre 2026/2.

**Pergunta central:** quais são os cargos, habilidades e faixas salariais mais demandados pelo mercado de trabalho em tecnologia?

A Fase I prepara e audita os dados no Excel Avançado conforme as dez atividades do guia CaféData de 37 páginas, adaptadas ao tema da equipe. O arquivo contém exatamente as abas **Bruto**, **Tratado**, **Cadastros** e **Auditoria**.

A Etapa 2 aplica as nove atividades do guia Power Query de 42 páginas: importa cópias locais, padroniza, mescla cadastros, separa rejeitados, despivota metas e reconcilia as saídas. São **49 consultas em seis grupos nativos** e **13 tabelas carregadas**, preservando os arquivos da Fase I.

## Arquivos principais

- [Pasta de trabalho da Fase I](MA2026-entrega-parcial/01-excel/TechTalent_01_Excel.xlsx).
- [Pasta de trabalho da Etapa 2 — Power Query](MA2026-entrega-parcial/02-powerquery/TechTalent_02_PowerQuery.xlsx).
- [Configuração, catálogo das consultas e conferência da Etapa 2](MA2026-entrega-parcial/02-powerquery/README.md).
- [Vagas tratadas em CSV](MA2026-entrega-parcial/02-powerquery/dados_limpos/fVagas.csv) e [observações salariais em CSV](MA2026-entrega-parcial/02-powerquery/dados_limpos/fSalarios.csv).
- [Roteiro, fontes, equivalências e conferência](MA2026-entrega-parcial/04-documentacao/roteiro-fase-um.md).
- [Cópia de segurança do Excel anterior](MA2026-entrega-parcial/01-excel/backup/salarios_ciencia_dados_anterior.xlsx).
- [Excel anterior mantido no caminho original](MA2026-entrega-parcial/01-excel/data_science_salaries_organizado.xlsx).

## Dados e limites de interpretação

A planilha preserva **6.599 registros salariais de ciência de dados de 2020 a 2024**, provenientes do Excel anterior, e **225 anúncios de emprego de tecnologia, dados e inovação do governo municipal de Nova Iorque**, provenientes de uma exportação estática do NYC Open Data coletada em 3 de novembro de 2026. Os anúncios correspondem a **116 Job IDs distintos** e incluem publicações internas e externas para uma mesma identificação.

A origem salarial foi confirmada no conjunto [Data Science Salaries 2024, de Sazidul Islam](https://www.kaggle.com/datasets/sazidthe1/data-science-salaries): os 11 cabeçalhos e os valores dos 6.599 registros do CSV oficial coincidem com os do Excel anterior, na mesma ordem. O [roteiro](MA2026-entrega-parcial/04-documentacao/roteiro-fase-um.md) resume a comparação, os hashes e a licença declarada. A periodicidade salarial não está explicitada na descrição da fonte.

Os salários permanecem em sua tabela própria. A `Tab_Vagas` contém **240 linhas misturadas: 225 anúncios reais e 15 registros simulados**, com a coluna `Fonte` identificando a origem de cada linha. Para contar ou analisar anúncios reais, filtre a fonte; não interprete as 240 linhas como anúncios reais nem os 225 anúncios como 225 vagas únicas. Registros salariais, anúncios e posições anunciadas são unidades diferentes. O recorte de Nova Iorque não representa o mercado brasileiro ou todo o mercado de tecnologia.

Os valores originais são preservados; tratamentos e verificações ficam em colunas adicionais. Os campos de salário e quantidade de posições de Nova Iorque são texto no esquema oficial e permanecem assim na Fase I. Na Etapa 2, as consultas convertem esses valores com a cultura da origem, mantendo o rastreio até os arquivos de entrada. As habilidades estão em textos livres e ainda não constituem uma contagem normalizada de tecnologias.

Os **mesmos 15 registros fictícios** também aparecem no laboratório `Tab_Cenarios`, com **29 colunas derivadas** para praticar os controles do guia. São duas representações dos mesmos cenários, não 30 registros fictícios diferentes. Os cenários e os cadastros fictícios estão documentados na planilha e identificados com `Fonte = SIMULADO`. Demonstram datas e horas variadas, atendimento fictício de recrutamento, turnos, quantidades inválidas, referências salariais fictícias, desvios de ±20% e inconsistências controladas.

A simulação foi autorizada pelo usuário e serve ao exercício dos recursos do Excel. Ela não preenche campos dos registros reais, não participa das contagens de 6.599 observações ou 225 anúncios e não fornece resultados sobre o mercado de trabalho. A criação dos campos fictícios e sua finalidade também devem constar no corpo do commit correspondente.

O GitHub mantém os artefatos da atividade nos caminhos do guia: arquivos Excel, backups, entradas e saídas de dados, documentação e evidências. Os 49 arquivos `.pq` em `02-powerquery/scripts_m/` são parte da entrega exigida pelo professor. Programas Python, PowerShell e JavaScript, relatórios JSON, metadados técnicos de apoio e modelos de colaboração ficam apenas no ZIP local de apoio.

## Continuidade

A Fase I não implementa consultas atualizáveis, Power Query, Power Pivot, macros VBA, SQL, integração de API ou Power BI. A exportação do portal é um retrato estático de entrada. Os indicadores e dashboards serão desenvolvidos nas fases correspondentes, após a resolução das pendências e a definição das regras de análise.

A Etapa 2 implementa somente o Power Query previsto para esta fase, sem Modelo de Dados. As saídas mantêm grãos separados: **232 eventos de publicação aceitos** (225 reais e sete simulados), **6.599 observações salariais** e **oito registros simulados rejeitados**, com motivo e origem. O planejamento de duas empresas, seis meses e 31 contratações é inteiramente fictício e está identificado como `SIMULADO`.

## Validação

Foram aprovadas **205 de 205 verificações independentes**, **19 de 19 testes no Excel nativo** e **três de três testes de cores condicionais**. O painel apresenta diferença zero em todas as linhas e nenhum erro de fórmula. As entradas e os backups passaram por comparação integral, incluindo os espaços dos cenários preservados.

A auditoria contém **587 ocorrências**, e a tabela mista de vagas tem **233 linhas com alertas**. Esses números incluem pendências de tipagem e controles didáticos; não são contagens de problemas reais do mercado. O laboratório dos 15 cenários apresenta **22 ocorrências em 13 linhas**.

O [roteiro](MA2026-entrega-parcial/04-documentacao/roteiro-fase-um.md) reúne o gabarito dos cenários, os procedimentos de conferência e as pendências de aplicação aos dados reais. As evidências detalhadas dos testes ficam no ZIP local de apoio.

Na Etapa 2, foram aprovadas **63 verificações independentes**, **34 casos de funções no motor nativo** e **21 cenários nativos de atualização**, além da conferência visual dos grupos, das Etapas Aplicadas e da reconciliação. As entradas totalizam **6.839 = 6.831 aceitas + oito rejeitadas**, com diferença zero. O [README da etapa](MA2026-entrega-parcial/02-powerquery/README.md) contém o checklist, as limitações e os links das três capturas exigidas.

Commits e pull requests usam Conventional Commits, com tipos como `feat`, `fix`, `docs` e `chore`, descrições e comentários em português, etapas coerentes e horários reais. O corpo do commit que introduzir dados fictícios deve declarar sua natureza e finalidade didática.
