# TechTalent — Etapa 2: Power Query

Consolidação e tratamento de vagas e observações salariais, conforme as nove atividades do guia. O arquivo [TechTalent_02_PowerQuery.xlsx](TechTalent_02_PowerQuery.xlsx) reutiliza os dados e cadastros da [Etapa 1](../01-excel/TechTalent_01_Excel.xlsx).

## Entradas e atualização

| Entrada | Conteúdo |
| --- | --- |
| `dados_brutos/vagas/vagas_portal_publico.xlsx` | 225 anúncios do [NYC Open Data](https://data.cityofnewyork.us/City-Government/Jobs-NYC-Postings/kpav-sd4t), extraídos em 03/11/2026. |
| `dados_brutos/vagas/vagas_estudo_simulado.xlsx` | Os mesmos 15 casos fictícios da Etapa 1, identificados por `Fonte = SIMULADO`; inclui cabeçalhos diferentes, como `Qtd`. |
| `../01-excel/TechTalent_01_Excel.xlsx` | Cadastros e 6.599 observações de [Data Science Salaries 2024](https://www.kaggle.com/datasets/sazidthe1/data-science-salaries), de 2020 a 2024. |
| `dados_brutos/planejamento_contratacoes_SIMULADO.xlsx` | Planejamento fictício de duas empresas em seis meses: 12 combinações e 31 contratações planejadas. |

Mantenha as entradas como Somente Leitura e os backups fora da pasta de vagas. Após clonar, reaplique esse atributo, pois o Git não o preserva. A atualização lê arquivos locais; a proveniência está no [roteiro da Etapa 1](../04-documentacao/roteiro-fase-um.md) e nos [termos NYC Open Data](https://data.cityofnewyork.us/stories/s/Terms-of-Use/k9k7-3cje).

No Excel para Windows, salve e feche a Etapa 1. Abra a Etapa 2 e, no Editor do Power Query → **Gerenciar Parâmetros**, ajuste `pPastaProjeto` para o caminho absoluto da pasta `02-powerquery`, com a barra final. Depois use **Dados → Atualizar Tudo** e consulte `Conferencia`. Corrija valores na origem ou no cadastro, pois a atualização substitui as tabelas carregadas.

| Parâmetro | Valor |
| --- | --- |
| `pPastaProjeto` | Caminho absoluto local de `MA2026-entrega-parcial/02-powerquery/`, usando as barras do Windows. |
| `pPastaVagas` | Pasta `dados_brutos/vagas/`, derivada de `pPastaProjeto`. |
| `pArquivoEtapa1` | Arquivo `../01-excel/TechTalent_01_Excel.xlsx`, derivado de `pPastaProjeto`. |
| `pArquivoMetas` | Arquivo `dados_brutos/planejamento_contratacoes_SIMULADO.xlsx`, derivado de `pPastaProjeto`. |
| `pDataInicio` | `#date(2026, 1, 1)` — início do recorte de vagas. |
| `pDataFim` | `#date(2026, 12, 31)` — fim do recorte de vagas. |
| `pCulturaPadrao` | `pt-BR`; os números textuais NYC usam `en-US`. |

## Tratamento e rejeições

O fluxo segue o guia: preparar e conectar; padronizar cabeçalhos e anexar arquivos; tratar nulos e duplicidades; ajustar tipos e culturas; padronizar textos; mesclar cadastros; calcular colunas; separar rejeitados; despivotar metas e carregar resultados. São preservados `Arquivo_Origem`, `Linha_Origem` e `ID_Registro_FaseI`.

Uma vaga é um **evento de publicação**. A chave reúne fonte, ID, tipo de publicação, data, hora, cargo e órgão. Duas passagens removem duplicatas: antes e depois da normalização, preservando a primeira linha por arquivo e origem. Publicações internas/externas e os dois eventos `SIM-001`, com datas e horas diferentes, permanecem distintos. Salários iguais não são deduplicados sem identificador que comprove repetição. Cada meta corresponde a empresa/mês; os cargos salariais têm cadastro próprio.

São recusados identificador vazio, fonte desconhecida, quantidade ausente, não numérica, fracionária ou não positiva, data inválida ou fora de 2026, horário informado inválido, faixa salarial inválida e cargo/órgão sem correspondência. Nulos numéricos não viram zero. A hora NYC ausente é não aplicável; `05:30` é válido. Categorias desconhecidas permanecem sinalizadas. Desvio salarial da auditoria anterior não causa descarte automático.

| Registro rejeitado | Primeiro motivo |
| --- | --- |
| `SIM-VAG-004` | Quantidade vazia. |
| `SIM-VAG-005` | Quantidade zero. |
| `SIM-VAG-006` | Quantidade negativa. |
| `SIM-VAG-007` | Quantidade não numérica; seu salário `10000,00` é conversível. |
| `SIM-VAG-008` | Data inválida: `31/02/2026`. |
| `SIM-VAG-009` | Data fora do período. |
| `SIM-VAG-010` | Hora inválida. |
| `SIM-VAG-012` | Órgão sem correspondência; o cargo também permanece pendente na origem. |

`Rejeitados` guarda uma linha por registro descartado, com os valores originais, a linhagem e o primeiro motivo. Correspondências pendentes exigem esclarecimento; não são preenchidas por aproximação.

## Saídas e conferência

| Tabela | Linhas | Conteúdo |
| --- | ---: | --- |
| `fVagas` | 232 | 225 anúncios reais e sete simulados; 36 colunas com localidade, jornada, habilidades e faixa salarial. |
| `fSalarios` | 6.599 | Observações salariais; 21 colunas. |
| `dCargo` | 45 | 41 cargos NYC e quatro simulados. |
| `dOrgao` | 31 | 29 órgãos NYC e duas empresas simuladas. |
| `dCargoSalarios` | 132 | Cargos da base salarial. |
| `dPais` | 89 | Países de residência e da empresa. |
| `Rejeitados` | 8 | Registros descartados. |
| `fMetas` | 12 | Planejamento fictício por empresa/mês; soma 31. |

As cinco consultas `Conf_` ficam na aba `Conferencia`: reconciliação em A1, motivos em J1, etapas em A14, metas em J24 e colunas em A60. A reconciliação é **vagas 240 = 232 + 8; salários 6.599 = 6.599 + 0; total 6.839 = 6.831 + 8**. Conferir diferença zero, ausência de colunas desconhecidas e correspondências sem multiplicação de linhas. As demais consultas de apoio ficam somente como conexão.

## Catálogo das consultas

Cada consulta possui seu arquivo em `scripts_m/`.

| Grupo | Consulta | Finalidade |
| --- | --- | --- |
| 01_Parametros | `pPastaProjeto` | Centraliza o caminho local. |
| 01_Parametros | `pPastaVagas` | Localiza a pasta de vagas. |
| 01_Parametros | `pArquivoEtapa1` | Localiza dados e cadastros anteriores. |
| 01_Parametros | `pArquivoMetas` | Localiza o planejamento. |
| 01_Parametros | `pDataInicio` | Define a primeira data válida. |
| 01_Parametros | `pDataFim` | Define a última data válida. |
| 01_Parametros | `pCulturaPadrao` | Define a cultura padrão. |
| 02_Funcoes | `fnLimparTexto` | Remove espaços excedentes e NBSP. |
| 02_Funcoes | `fnChave` | Uniformiza chaves textuais. |
| 02_Funcoes | `fnNumero` | Converte números conforme a cultura. |
| 02_Funcoes | `fnData` | Converte datas e recusa datas impossíveis. |
| 02_Funcoes | `fnHora` | Converte horários. |
| 02_Funcoes | `fnValorOficial` | Recupera grafia oficial das listas. |
| 02_Funcoes | `fnLerPlanilha` | Lê a aba de origem e seu cabeçalho. |
| 02_Funcoes | `fnPadronizarColunas` | Aplica o de-para dos campos. |
| 02_Funcoes | `fnLerVagas` | Integra leitura, cabeçalhos e linha original. |
| 02_Funcoes | `fnRotuloCadastro` | Recupera rótulos de apresentação. |
| 03_Cadastros | `ColunasAlvo` | Define os 39 campos de entrada. |
| 03_Cadastros | `DeParaColunas` | Relaciona cabeçalhos de cada origem. |
| 03_Cadastros | `cad_Etapa1` | Acessa as tabelas da Etapa 1. |
| 03_Cadastros | `cad_Publicacoes` | Recupera tipos de publicação. |
| 03_Cadastros | `cad_Vinculos` | Recupera vínculos. |
| 03_Cadastros | `cad_Frequencias` | Recupera periodicidades salariais. |
| 03_Cadastros | `lst_Publicacoes` | Lista os tipos de publicação válidos. |
| 03_Cadastros | `lst_Vinculos` | Lista os vínculos válidos. |
| 03_Cadastros | `lst_Frequencias` | Lista as periodicidades válidas. |
| 03_Cadastros | `cad_DeParaOrgao` | Relaciona nomes de órgãos e empresas. |
| 03_Cadastros | `cad_CargoChave` | Prepara códigos e atributos de cargos. |
| 03_Cadastros | `cad_AtributosSalarios` | Reúne experiência, vínculo, modalidade e porte. |
| 04_Staging | `stg_Vagas_Bruto` | Lê e anexa os XLSX, ignorando arquivos `~$`. |
| 04_Staging | `stg_Salarios_Bruto` | Recupera valores salariais originais. |
| 04_Staging | `proc_Vagas` | Aplica as regras e registra descartes. |
| 04_Staging | `Rejeitados_Vagas` | Localiza vagas não aceitas por anti junção. |
| 04_Staging | `proc_Salarios` | Converte e relaciona observações salariais. |
| 04_Staging | `Rejeitados_Salarios` | Localiza observações não aceitas. |
| 04_Staging | `stg_Metas_Bruto` | Lê o planejamento em formato largo. |
| 05_Saida | `dCargo` | Apresenta cargos NYC e simulados. |
| 05_Saida | `dOrgao` | Apresenta órgãos e empresas. |
| 05_Saida | `dCargoSalarios` | Apresenta cargos da fonte salarial. |
| 05_Saida | `dPais` | Apresenta países com códigos internos. |
| 05_Saida | `fVagas` | Expõe as etapas e carrega vagas aceitas. |
| 05_Saida | `fSalarios` | Carrega salários aceitos. |
| 05_Saida | `Rejeitados` | Consolida registros descartados. |
| 05_Saida | `fMetas` | Despivota o planejamento em empresa/mês. |
| 06_Conferencia | `Conf_Colunas` | Diagnostica cabeçalhos por arquivo. |
| 06_Conferencia | `Conf_Reconciliacao` | Compara entradas, aceitos e rejeitados. |
| 06_Conferencia | `Conf_Motivos` | Conta rejeitados por motivo. |
| 06_Conferencia | `Conf_Etapas` | Mostra as contagens durante o tratamento. |
| 06_Conferencia | `Conf_Metas` | Confere despivotamento, total e órgãos. |

## Evidências e limites

[Grupos de consultas](evidencias/01_grupos_consultas.jpg) · [Etapas Aplicadas de fVagas](evidencias/02_etapas_aplicadas_vagas.jpg) · [Reconciliação](evidencias/03_conferencia_reconciliacao.jpg).

Os anúncios NYC são municipais e incluem publicações internas e externas; 225 anúncios correspondem a 116 IDs, não a 225 vagas únicas. `Cod_Orgao` é uma chave técnica derivada do nome; `Cod_Cargo` usa o código de título da fonte com prefixo NYC. As taxonomias de cargos e os países usam cadastros próprios.

A moeda NYC permanece `Não informada`; a periodicidade salarial histórica, `Não confirmada`. `Salario_USD` vem da fonte, sem conversão cambial atual. As comparações devem respeitar fonte, moeda, periodicidade e período. Os casos e as metas `SIMULADO` têm finalidade didática; anúncios não comprovam contratações realizadas.

Os dados limpos são [fVagas.csv](dados_limpos/fVagas.csv) e [fSalarios.csv](dados_limpos/fSalarios.csv), em UTF-8 com BOM, separados por vírgula, datas ISO e decimais com ponto. Esta etapa prepara tabelas para a modelagem seguinte.
