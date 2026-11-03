# Etapa II — Power Query aplicado ao TechTalent

A preparação segue o Guia Prático da Etapa 2, com 42 páginas, e o projeto-modelo complementar de 14 páginas. As consultas serão adaptadas ao mercado de tecnologia e manterão os grãos distintos de vagas e observações salariais.

## Preparação das entradas

| Arquivo | Conteúdo | Natureza |
| --- | --- | --- |
| `dados_brutos/vagas/vagas_portal_publico.xlsx` | 225 anúncios e os 30 campos originais do NYC Open Data, acrescidos de marcadores de origem e ligação com a Etapa I. | Real. |
| `dados_brutos/vagas/vagas_estudo_simulado.xlsx` | Os mesmos 15 registros fictícios da tabela mista da Etapa I, com os valores originais preservados. Os cabeçalhos `Qtd` e `Data_Publicacao` demonstram diferenças de estrutura. | Simulado. |
| `dados_brutos/planejamento_contratacoes_SIMULADO.xlsx` | Planejamento fictício de contratações de duas empresas, em seis meses de 2026. O despivotamento deverá produzir 12 linhas, com total de 31 contratações planejadas. | Simulado. |

As cópias de ingresso preservam valores e tipos da base da Etapa I. Os marcadores adicionais explicam a fonte, a cultura numérica e o registro anterior. Não representam dados novos coletados do mercado.

O planejamento mensal foi criado ficcionalmente para demonstrar a transformação de uma fonte larga em linhas por empresa e mês. Não é previsão de mercado. Os 15 cenários das vagas também são fictícios e continuam identificados pela coluna `Fonte`.

A pasta de ingestão de vagas contém somente os dois arquivos elegíveis. Backups, arquivos temporários e saídas ficam fora dela. A base salarial possui uma única entrada canônica: a tabela da Etapa I, evitando importar novamente o backup ou o CSV equivalente.

O arquivo [TechTalent_01_Excel.xlsx](../01-excel/TechTalent_01_Excel.xlsx) fornece os cadastros e a base salarial. Ele deve permanecer salvo e fechado durante a atualização. A Etapa I e os seus backups são preservados.

## Marcos de desenvolvimento

- Preparação das entradas e organização das pastas: concluída e conferida.
- Parâmetros, importações e diagnóstico de colunas: concluídos e executados no Excel.
- Tratamento, dimensões e registros rejeitados: próximo marco.
- Metas, exportações e conferências de atualização: próximo marco.
- Documentação e evidências finais: próximo marco.

Nesta etapa, os arquivos `.pq` de cada consulta são parte da entrega exigida pelo professor e serão publicados em `scripts_m/`. Scripts Python, PowerShell e metadados técnicos de apoio permanecem no ZIP local.

## Parâmetros e importação

A pasta [TechTalent_02_PowerQuery.xlsx](TechTalent_02_PowerQuery.xlsx) contém consultas nativas do Power Query. Neste marco, são 21 consultas: parâmetros, funções de leitura e conversão, contrato de colunas, acesso à Etapa I, estágio bruto e diagnóstico. Somente `Conf_Colunas` está carregada, na aba `Conferencia`, a partir de A60. As tabelas de saída serão preenchidas no próximo marco.

Ao mover o repositório para outro computador, abra o Editor do Power Query e ajuste **pPastaProjeto**, em Gerenciar Parâmetros, para o caminho absoluto de `MA2026-entrega-parcial/02-powerquery/`, incluindo a barra final. Os parâmetros `pPastaVagas`, `pArquivoEtapa1` e `pArquivoMetas` derivam desse caminho. A aba `Parametros` mostra a pasta atual para ajudar na configuração. As culturas numéricas são explícitas: `en-US` para os números textuais do portal e `pt-BR` para os cenários simulados.

`fnLerPlanilha` seleciona uma aba do tipo `Sheet`, promove o cabeçalho e preserva a linha de origem antes dos filtros. A leitura da pasta aceita `.xlsx` sem diferenciar maiúsculas e ignora arquivos de bloqueio iniciados por `~$`. A referência cadastral lê as tabelas estruturadas do arquivo da Etapa I salvo e fechado.

O diagnóstico registra os cabeçalhos originais e padronizados de cada arquivo. Na execução deste marco, os dois arquivos tiveram zero colunas não mapeadas, ausentes ou em colisão. Nomes divergentes, como `Qtd` e `Data_Publicacao`, possuem correspondência explícita em `DeParaColunas`.

Foram conferidos 34 casos de conversão no motor nativo: datas tipadas, seriais e textuais; horários tipados, fracionários e textuais; datas impossíveis; números nos dois padrões; campos nulos; espaços repetidos e NBSP. Todos passaram. Os valores não conversíveis permanecem nulos para a validação posterior; quantidades fracionárias não são arredondadas para aparentar validade.
