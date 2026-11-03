# TechTalent — análise do mercado de trabalho em tecnologia

Projeto Evolutivo de Dados da equipe 09, disciplina Microinformática Aplicada da Fatec São Paulo, semestre 2026/2.

**Pergunta central:** quais são os cargos, habilidades e faixas salariais mais demandados pelo mercado de trabalho em tecnologia?

A Fase I prepara e audita os dados no Excel Avançado conforme as dez atividades do guia CaféData de 37 páginas, adaptadas ao tema da equipe. O arquivo contém exatamente as abas **Bruto**, **Tratado**, **Cadastros** e **Auditoria**.

## Arquivos principais

- [Pasta de trabalho da Fase I](MA2026-entrega-parcial/01-excel/TechTalent_01_Excel.xlsx).
- [Roteiro, fontes, equivalências e conferência](MA2026-entrega-parcial/04-documentacao/roteiro-fase-um.md).
- [Cópia de segurança do Excel anterior](MA2026-entrega-parcial/01-excel/backup/salarios_ciencia_dados_anterior.xlsx).
- [Excel anterior mantido no caminho original](MA2026-entrega-parcial/01-excel/data_science_salaries_organizado.xlsx).

## Dados e limites de interpretação

A planilha preserva **6.599 registros salariais de ciência de dados de 2020 a 2024**, provenientes do Excel anterior, e **225 anúncios de emprego de tecnologia, dados e inovação do governo municipal de Nova Iorque**, provenientes de uma exportação estática do NYC Open Data coletada em 3 de novembro de 2026. Os anúncios correspondem a **116 Job IDs distintos** e incluem publicações internas e externas para uma mesma identificação.

A origem salarial foi confirmada no conjunto [Data Science Salaries 2024, de Sazidul Islam](https://www.kaggle.com/datasets/sazidthe1/data-science-salaries): os 11 cabeçalhos e os valores dos 6.599 registros do CSV oficial coincidem com os do Excel anterior, na mesma ordem. O [roteiro](MA2026-entrega-parcial/04-documentacao/roteiro-fase-um.md) resume a comparação, os hashes e a licença declarada. A periodicidade salarial não está explicitada na descrição da fonte.

Os salários permanecem em sua tabela própria. A `Tab_Vagas` contém **240 linhas misturadas: 225 anúncios reais e 15 registros simulados**, com a coluna `Fonte` identificando a origem de cada linha. Para contar ou analisar anúncios reais, filtre a fonte; não interprete as 240 linhas como anúncios reais nem os 225 anúncios como 225 vagas únicas. Registros salariais, anúncios e posições anunciadas são unidades diferentes. O recorte de Nova Iorque não representa o mercado brasileiro ou todo o mercado de tecnologia.

Os valores originais são preservados; tratamentos e verificações ficam em colunas adicionais. Os campos de salário e quantidade de posições de Nova Iorque são texto no esquema oficial e permanecem assim nesta fase, com ocorrências encaminhadas à Etapa 2. As habilidades estão em textos livres e ainda não constituem uma contagem normalizada de tecnologias.

Os **mesmos 15 registros fictícios** também aparecem no laboratório `Tab_Cenarios`, com **29 colunas derivadas** para praticar os controles do guia. São duas representações dos mesmos cenários, não 30 registros fictícios diferentes. Os cenários e os cadastros fictícios estão documentados na planilha e identificados com `Fonte = SIMULADO`. Demonstram datas e horas variadas, atendimento fictício de recrutamento, turnos, quantidades inválidas, referências salariais fictícias, desvios de ±20% e inconsistências controladas.

A simulação foi autorizada pelo usuário e serve ao exercício dos recursos do Excel. Ela não preenche campos dos registros reais, não participa das contagens de 6.599 observações ou 225 anúncios e não fornece resultados sobre o mercado de trabalho. A criação dos campos fictícios e sua finalidade também devem constar no corpo do commit correspondente.

O GitHub mantém os arquivos da atividade nos caminhos já existentes: Excel, backup, entradas XLSX/CSV e documentação em `04-documentacao`. Scripts, Python, JSON, metadados de apoio e modelos de colaboração ficam apenas no ZIP local de apoio.

## Continuidade

A Fase I não implementa consultas atualizáveis, Power Query, Power Pivot, macros VBA, SQL, integração de API ou Power BI. A exportação do portal é um retrato estático de entrada. Os indicadores e dashboards serão desenvolvidos nas fases correspondentes, após a resolução das pendências e a definição das regras de análise.

## Validação

Foram aprovadas **205 de 205 verificações independentes**, **19 de 19 testes no Excel nativo** e **três de três testes de cores condicionais**. O painel apresenta diferença zero em todas as linhas e nenhum erro de fórmula. As entradas e os backups passaram por comparação integral, incluindo os espaços dos cenários preservados.

A auditoria contém **587 ocorrências**, e a tabela mista de vagas tem **233 linhas com alertas**. Esses números incluem pendências de tipagem e controles didáticos; não são contagens de problemas reais do mercado. O laboratório dos 15 cenários apresenta **22 ocorrências em 13 linhas**.

O [roteiro](MA2026-entrega-parcial/04-documentacao/roteiro-fase-um.md) reúne o gabarito dos cenários, os procedimentos de conferência e as pendências de aplicação aos dados reais. As evidências detalhadas dos testes ficam no ZIP local de apoio.

Commits e pull requests usam Conventional Commits, com tipos como `feat`, `fix`, `docs` e `chore`, descrições e comentários em português, etapas coerentes e horários reais. O corpo do commit que introduzir dados fictícios deve declarar sua natureza e finalidade didática.
