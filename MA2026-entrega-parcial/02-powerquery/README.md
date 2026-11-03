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
- Tratamento, dimensões e registros rejeitados: concluídos e executados no Excel.
- Metas, exportações e conferências de atualização: próximo marco.
- Documentação e evidências finais: próximo marco.

Nesta etapa, os arquivos `.pq` de cada consulta são parte da entrega exigida pelo professor e serão publicados em `scripts_m/`. Scripts Python, PowerShell e metadados técnicos de apoio permanecem no ZIP local.

## Parâmetros e importação

A pasta [TechTalent_02_PowerQuery.xlsx](TechTalent_02_PowerQuery.xlsx) contém consultas nativas do Power Query. Neste marco, são 21 consultas: parâmetros, funções de leitura e conversão, contrato de colunas, acesso à Etapa I, estágio bruto e diagnóstico. Somente `Conf_Colunas` está carregada, na aba `Conferencia`, a partir de A60. As tabelas de saída serão preenchidas no próximo marco.

Ao mover o repositório para outro computador, abra o Editor do Power Query e ajuste **pPastaProjeto**, em Gerenciar Parâmetros, para o caminho absoluto de `MA2026-entrega-parcial/02-powerquery/`, incluindo a barra final. Os parâmetros `pPastaVagas`, `pArquivoEtapa1` e `pArquivoMetas` derivam desse caminho. A aba `Parametros` mostra a pasta atual para ajudar na configuração. As culturas numéricas são explícitas: `en-US` para os números textuais do portal e `pt-BR` para os cenários simulados.

`fnLerPlanilha` seleciona uma aba do tipo `Sheet`, promove o cabeçalho e preserva a linha de origem antes dos filtros. A leitura da pasta aceita `.xlsx` sem diferenciar maiúsculas e ignora arquivos de bloqueio iniciados por `~$`. A referência cadastral lê as tabelas estruturadas do arquivo da Etapa I salvo e fechado.

O diagnóstico registra os cabeçalhos originais e padronizados de cada arquivo. Na execução deste marco, os dois arquivos tiveram zero colunas não mapeadas, ausentes ou em colisão. Nomes divergentes, como `Qtd` e `Data_Publicacao`, possuem correspondência explícita em `DeParaColunas`.

Foram conferidos 34 casos de conversão no motor nativo: datas tipadas, seriais e textuais; horários tipados, fracionários e textuais; datas impossíveis; números nos dois padrões; campos nulos; espaços repetidos e NBSP. Todos passaram. Os valores não conversíveis permanecem nulos para a validação posterior; quantidades fracionárias não são arredondadas para aparentar validade.

## Tratamento e relacionamento

O segundo marco de consultas acrescenta os cadastros, as dimensões, os tratamentos e os rejeitados. A pasta de trabalho passa a ter 43 consultas nativas e oito tabelas carregadas, incluindo o diagnóstico inicial.

| Saída | Linhas | Significado |
| --- | ---: | --- |
| `fVagas` | 232 | 225 anúncios reais e sete eventos simulados aceitos. Inclui localidade, jornada, habilidades, faixa salarial e linhagem. |
| `fSalarios` | 6.599 | Observações salariais reais da Etapa I, sem deduplicar observações apenas por terem os mesmos valores. |
| `Rejeitados` | 8 | Registros simulados recusados pelas regras, com campos originais, arquivo, linha e motivo principal. |
| `dCargo` | 45 | 41 códigos de cargos públicos da fonte NYC e quatro cargos simulados. |
| `dOrgao` | 31 | 29 órgãos reais e duas empresas fictícias. |
| `dCargoSalarios` | 132 | Cadastro próprio dos cargos das observações salariais. |
| `dPais` | 89 | Cadastro de países da Etapa I. |

O grão das vagas é um evento de publicação identificado por fonte, identificador, tipo de publicação, data, horário e códigos de cargo e órgão. Publicações internas e externas do mesmo cargo permanecem distintas. Os dois eventos `SIM-001` também permanecem, pois suas datas e horários diferem.

As duplicidades são tratadas em duas passagens: chave bruta e chave oficial após a normalização e os relacionamentos. A ordenação por arquivo e linha, seguida de `Table.Buffer`, define qual registro permanece. Os relacionamentos usam correspondências explícitas; não há aproximação de nomes para preencher códigos desconhecidos.

`proc_Vagas` concentra as regras, os descartes e as contagens. `fVagas` apresenta os 21 estágios desse mesmo processo como Etapas Aplicadas selecionáveis, sem repetir as regras. A limpeza inclui espaços excedentes e NBSP; as siglas são preservadas. A categoria usa `Text.Proper` e a descrição oficial do cadastro quando existe.

As colunas calculadas próprias do tema são `Amplitude_Salarial`, `Ponto_Medio_Faixa` e `Mes_Publicacao`. Os cálculos de faixa mantêm a moeda e a periodicidade de cada registro; não convertem moedas nem transformam salários de periodicidade desconhecida em valores anuais.

## Rejeições e pendências

Cada registro recusado recebe o primeiro motivo efetivo do fluxo. A auditoria da Etapa I pode ter várias ocorrências para o mesmo registro e continua preservada.

| Registro da Etapa I | Motivo principal |
| --- | --- |
| SIM-VAG-004 | Quantidade vazia. |
| SIM-VAG-005 | Quantidade zero. |
| SIM-VAG-006 | Quantidade negativa. |
| SIM-VAG-007 | Quantidade não numérica (`duas`). Seu salário textual `10000,00` é conversível. |
| SIM-VAG-008 | Data inválida (`31/02/2026`). |
| SIM-VAG-009 | Data fora do recorte de 2026. O horário 05:30 é válido nesta etapa. |
| SIM-VAG-010 | Hora inválida. O desvio salarial, isoladamente, não provoca rejeição. |
| SIM-VAG-012 | Órgão sem correspondência confirmada. O cargo com erro de grafia também permanece pendente na Etapa I. |

Campos descritivos opcionais ausentes recebem rótulos explícitos de ausência. Quantidade e salário não recebem zero no lugar de nulo. Códigos de cargo ou órgão sem correspondência são rejeitados. Valores fora das listas auxiliares permanecem identificáveis; não são substituídos por uma categoria arbitrária.

A moeda das vagas do portal não foi informada na extração e permanece `Não informada`. A periodicidade da base salarial histórica permanece `Não confirmada`. Os anúncios são uma amostra do portal NYC, com publicações internas e externas; não representam todo o mercado nem necessariamente oportunidades ainda abertas. Comparações salariais futuras precisam respeitar essas limitações.
