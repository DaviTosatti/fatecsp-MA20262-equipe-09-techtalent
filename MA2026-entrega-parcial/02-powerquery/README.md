# TechTalent — Etapa 2: Power Query

Preparação de vagas e observações salariais para analisar cargos, habilidades, faixas salariais e localidades do mercado de tecnologia. A execução adapta as nove atividades do **Guia Prático — Etapa 2: Power Query**, preservando os dados e os cadastros da [Etapa 1](../01-excel/TechTalent_01_Excel.xlsx).

**Situação da revisão:** consultas, cargas, exportações, testes funcionais e organização dos seis grupos conferidos no Excel nativo. As três capturas exigidas pelo guia estão disponíveis em `evidencias/`; os 13 itens de conferência estão concluídos.

## Arquivos e fontes

```text
02-powerquery/
├── TechTalent_02_PowerQuery.xlsx
├── README.md
├── dados_brutos/
│   ├── vagas/
│   │   ├── vagas_portal_publico.xlsx
│   │   └── vagas_estudo_simulado.xlsx
│   └── planejamento_contratacoes_SIMULADO.xlsx
├── dados_limpos/
│   ├── fVagas.csv
│   └── fSalarios.csv
├── scripts_m/                    49 consultas, um arquivo UTF-8 por consulta
└── evidencias/                   três capturas reais do Excel
```

| Entrada | Conteúdo e origem |
| --- | --- |
| `vagas_portal_publico.xlsx` | 225 anúncios reais do [Jobs NYC Postings / NYC Open Data](https://data.cityofnewyork.us/City-Government/Jobs-NYC-Postings/kpav-sd4t), já preservados na Etapa 1; 30 campos originais e metadados de rastreio. Extração de 03/11/2026. |
| `vagas_estudo_simulado.xlsx` | Os mesmos 15 casos fictícios de vagas da Etapa 1, identificados como `SIMULADO`. Os cabeçalhos `Qtd` e `Data_Publicacao` demonstram diferenças de estrutura. |
| `TechTalent_01_Excel.xlsx`, na pasta `01-excel` | Tabelas de referência e 6.599 observações da base [Data Science Salaries 2024](https://www.kaggle.com/datasets/sazidthe1/data-science-salaries), de 2020 a 2024. |
| `planejamento_contratacoes_SIMULADO.xlsx` | Planejamento fictício de duas empresas e seis meses de 2026: 12 combinações empresa/mês, total de 31 contratações planejadas. |

O [roteiro da Etapa 1](../04-documentacao/roteiro-fase-um.md) detalha a proveniência, os cadastros e a auditoria anterior. Os dados NYC seguem os [termos do portal](https://data.cityofnewyork.us/stories/s/Terms-of-Use/k9k7-3cje). A atualização lê cópias locais; não realiza nova coleta na internet.

As fontes reais e os casos fictícios permanecem identificáveis pela coluna `Fonte`. Os 15 casos aparecem uma única vez na entrada de vagas desta etapa; o laboratório da Etapa 1 não é acrescentado novamente. O planejamento é uma demonstração acadêmica, sem representar previsão de mercado.

Foram conferidos os hashes dos nove arquivos de origem, referência e backup, sem alteração de conteúdo. Os três arquivos de ingresso da Etapa 2 permanecem como Somente Leitura. Após clonar, marque novamente essas entradas como Somente Leitura, pois o Git não preserva esse atributo do Windows. A pasta de vagas contém somente os dois arquivos elegíveis; backups e saídas ficam fora dela.

## Configuração e atualização

Use o Excel para Windows com Power Query. Mantenha a estrutura de pastas, salve e feche a Etapa 1 e abra [TechTalent_02_PowerQuery.xlsx](TechTalent_02_PowerQuery.xlsx). Em **Dados → Obter Dados → Iniciar Editor do Power Query → Gerenciar Parâmetros**, ajuste `pPastaProjeto` para a pasta absoluta de `02-powerquery`, incluindo a barra final. Os outros caminhos derivam desse parâmetro.

| Parâmetro | Valor ou expressão |
| --- | --- |
| `pPastaProjeto` | Texto editável: caminho absoluto local de `MA2026-entrega-parcial\02-powerquery\`. |
| `pPastaVagas` | `pPastaProjeto & "dados_brutos\vagas\"` |
| `pArquivoEtapa1` | `pPastaProjeto & "..\01-excel\TechTalent_01_Excel.xlsx"` |
| `pArquivoMetas` | `pPastaProjeto & "dados_brutos\planejamento_contratacoes_SIMULADO.xlsx"` |
| `pDataInicio` | `#date(2026, 1, 1)` |
| `pDataFim` | `#date(2026, 12, 31)` |
| `pCulturaPadrao` | `"pt-BR"`; os números textuais NYC usam `en-US` conforme a origem. |

Os sete parâmetros são obrigatórios e possuem metadados de parâmetro no M. O intervalo de datas vale para as vagas; as observações salariais mantêm os anos de sua própria fonte, de 2020 a 2024.

Após configurar, use **Dados → Atualizar Tudo**, aguarde o término e confira `Conferencia`. As 13 cargas foram atualizadas sincronamente no Excel, com `Refresh(false)` e `FastCombine=False`, sem erros. Caminho inexistente gera erro de atualização explícito. Corrija dados na origem ou no cadastro da Etapa 1, salve e atualize; edições nas tabelas carregadas serão substituídas pela próxima atualização.

## Procedimentos das nove atividades

| Atividade do guia | Adaptação implementada |
| --- | --- |
| 1. Preparar e conectar | Pastas separadas, parâmetros centralizados, conexão à pasta de vagas e às tabelas da Etapa 1 salva e fechada; seis grupos nativos conferidos. |
| 2. Unificar e consolidar | Leitura dos dois XLSX, seleção de aba do tipo `Sheet`, promoção de cabeçalhos e aplicação do de-para para 39 campos canônicos antes de anexar. `Conf_Colunas` denuncia campos desconhecidos, ausentes ou em colisão. |
| 3. Limpar, tratar nulos e duplicidades | Identificação de linhas sem conteúdo desconsiderando metadados, validação de campos críticos e primeira deduplicação pela chave bruta. Arquivo e linha são preservados antes dos filtros. |
| 4. Ajustar tipos e localidade | Conversões de datas, horas e números por cultura; datas impossíveis não são normalizadas para outro dia; quantidade fracionária é recusada antes de `Int64.Type`. |
| 5. Padronizar textos | Remoção de espaços excedentes e NBSP, chaves de busca uniformes e grafia oficial dos cadastros. `Text.Proper` nas categorias é complementado pelo cadastro; siglas de tecnologias são preservadas. |
| 6. Mesclar cadastros | Junções externas à esquerda com cargos e órgãos, verificação de correspondência e da cardinalidade e segunda deduplicação pela chave oficial. Os cargos salariais têm cadastro próprio. |
| 7. Criar colunas | Amplitude salarial, ponto médio da faixa e mês de publicação, mantendo moeda e periodicidade. Inclusão de localidade, jornada, requisitos e habilidades para as próximas etapas. |
| 8. Tratar exceções | Rejeitados por anti junção à esquerda, com um motivo principal e rastreio por registro; reconciliação de entradas, aceitos e rejeitados. |
| 9. Despivotar, carregar e publicar | Planejamento largo despivotado em empresa/mês; 13 cargas, dois CSV públicos e 49 arquivos M conferidos. Capturas reais de grupos, Etapas Aplicadas e Conferencia disponíveis. |

## Grãos, chaves e regras

**Vagas:** uma linha aceita representa um evento de publicação, com chave formada por fonte, identificador da vaga, tipo de publicação, data, horário, cargo e órgão. A primeira passagem usa os valores brutos; a segunda usa os valores normalizados e os códigos dos cadastros. Ordenação por arquivo e linha, seguida de `Table.Buffer`, torna a escolha da linha preservada determinística. Publicações `Internal` e `External` não são fundidas. Os dois eventos `SIM-001` permanecem porque as datas e os horários diferem.

Nos registros reais, `Cod_Cargo` acrescenta o prefixo `NYC` ao `title_code_no` existente. `Cod_Orgao`, no formato `NYC|<nome normalizado>`, é uma chave técnica do projeto derivada da agência informada, sem alegar um código oficial de órgão fornecido pela fonte.

**Salários:** uma linha representa uma observação da fonte histórica. Valores iguais não comprovam que duas observações são duplicatas; as 6.599 linhas permanecem. `dCargoSalarios` não é usada para rejeitar cargos NYC. Os códigos internos de países servem ao relacionamento e não são apresentados como códigos ISO.

**Metas:** uma linha representa uma empresa simulada em um mês. `Table.UnpivotOtherColumns` transforma duas linhas largas em 12 linhas. O total é 31: 18 para `SIM-E01` e 13 para `SIM-E02`. Novas colunas mensais válidas entram pelo mesmo despivotamento; metas nulas, negativas ou fracionárias são denunciadas.

As regras de vagas recusam fonte desconhecida, identificador obrigatório vazio, quantidade vazia, não numérica, fracionária ou não positiva, data inválida ou fora de 2026, horário informado inválido, faixa salarial inválida e ausência de correspondência obrigatória de cargo ou órgão. As duas passagens de deduplicação também registram os descartes. Nulos numéricos não são preenchidos com zero.

O horário ausente nas vagas NYC é não aplicável, sem criar meia-noite fictícia. O horário `05:30` é válido nesta etapa. Salário zero permitido pela fonte NYC permanece identificável; não é confundido com nulo. Divergência superior a 20% da referência didática não causa rejeição automática, e referência zero não provoca divisão por zero. As comparações com referências pertencem à auditoria preservada da Etapa 1, respeitando moeda e periodicidade; esta etapa não recalcula esse desvio.

Categorias desconhecidas nas listas auxiliares são preservadas e sinalizadas. Descrições opcionais ausentes recebem rótulos de ausência, como `Não informada` para localidade e `Não informado` para jornada. Não há correspondência aproximada para resolver órgão ambíguo ou cargo desconhecido.

### Oito registros rejeitados na base atual

Cada registro recebe o primeiro motivo efetivo do fluxo. `Rejeitados` contém oito registros, não oito tipos genéricos nem a contagem de ocorrências da auditoria anterior.

| Registro da Etapa 1 | Motivo principal | Observação preservada |
| --- | --- | --- |
| `SIM-VAG-004` | Quantidade vazia | Ausência mantida na origem. |
| `SIM-VAG-005` | Quantidade zero | Salário zero original também permanece rastreável. |
| `SIM-VAG-006` | Quantidade negativa | Sem converter para valor positivo. |
| `SIM-VAG-007` | Quantidade não numérica | `duas` é inválido; o salário textual `10000,00` é conversível para 10000. |
| `SIM-VAG-008` | Data inválida | `31/02/2026` não é convertido em uma data de março. |
| `SIM-VAG-009` | Data fora do período | A data pertence a 2025; `05:30` é um horário válido. |
| `SIM-VAG-010` | Hora inválida | O salário discrepante, isoladamente, não causa rejeição. |
| `SIM-VAG-012` | Órgão sem correspondência | A empresa ambígua não é associada arbitrariamente; o cargo também continua pendente na Etapa 1. |

As linhas rejeitadas conservam os campos de origem, `Arquivo_Origem`, `Linha_Origem`, a ligação com `ID_Registro_FaseI` e o motivo. As pendências exigem confirmação da origem ou do cadastro antes de eventual correção; não foram eliminadas para melhorar artificialmente os resultados.

## Saídas e conferências

As dez abas são `Parametros`, `fVagas`, `fSalarios`, `dCargo`, `dOrgao`, `dCargoSalarios`, `dPais`, `Rejeitados`, `fMetas` e `Conferencia`. Há oito tabelas de saída e cinco de conferência; as demais consultas são de apoio, sem carga em planilha. Não foi criado Modelo de Dados.

| Tabela carregada | Local | Linhas atuais | Finalidade |
| --- | --- | ---: | --- |
| `fVagas` | Aba homônima, A1 | 232 | 225 anúncios reais e sete casos simulados aceitos; 36 colunas. |
| `fSalarios` | Aba homônima, A1 | 6.599 | Observações salariais; 21 colunas. |
| `dCargo` | Aba homônima, A1 | 45 | 41 cargos NYC e quatro cargos simulados. |
| `dOrgao` | Aba homônima, A1 | 31 | 29 órgãos NYC e duas empresas simuladas. |
| `dCargoSalarios` | Aba homônima, A1 | 132 | Cadastro de cargos da fonte salarial. |
| `dPais` | Aba homônima, A1 | 89 | Cadastro de países de residência e empresa. |
| `Rejeitados` | Aba homônima, A1 | 8 | Registros recusados com motivo e linhagem. |
| `fMetas` | Aba homônima, A1 | 12 | Planejamento fictício por empresa/mês, soma 31. |
| `Conf_Reconciliacao` | Conferencia, A1 | 4 | Entradas = aceitos + rejeitados, por base/fonte e total. |
| `Conf_Motivos` | Conferencia, J1 | 8 | Quantidade por motivo principal; soma oito. |
| `Conf_Etapas` | Conferencia, A14 | 25 | Contagens efetivas dos 21 estágios de vagas e quatro de salários. |
| `Conf_Metas` | Conferencia, J24 | 4 | Duas linhas de origem, 12 despivotadas, soma 31 e zero órgãos sem par. |
| `Conf_Colunas` | Conferencia, A60 | 2 | Diagnóstico de cabeçalhos de cada arquivo de vagas. |

Reconciliação conferida: **vagas 240 = 232 + 8; salários 6.599 = 6.599 + 0; total 6.839 = 6.831 + 8**. As diferenças são zero; os dois arquivos de vagas não apresentam colunas não mapeadas, ausentes ou em colisão. As junções não multiplicaram registros.

## Catálogo das 49 consultas

Os seis grupos foram conferidos no painel nativo, com 7, 10, 12, 7, 8 e 5 consultas, respectivamente, totalizando 49.

### 01_Parametros — sete consultas

| Consulta | Função |
| --- | --- |
| `pPastaProjeto` | Centraliza a pasta absoluta editável da Etapa 2. |
| `pPastaVagas` | Deriva a pasta de ingestão de vagas. |
| `pArquivoEtapa1` | Deriva o caminho da pasta de trabalho da Etapa 1. |
| `pArquivoMetas` | Deriva o caminho do planejamento fictício. |
| `pDataInicio` | Define o início do período das vagas. |
| `pDataFim` | Define o fim do período das vagas. |
| `pCulturaPadrao` | Define a cultura padrão de conversão. |

### 02_Funcoes — dez consultas

| Consulta | Função |
| --- | --- |
| `fnLimparTexto` | Limpa espaços externos, repetidos e NBSP, preservando siglas. |
| `fnChave` | Gera chave textual normalizada em maiúsculas para busca. |
| `fnNumero` | Converte números pela cultura da origem sem trocar ausência por zero. |
| `fnData` | Converte datas tipadas, seriais e textuais; recusa datas impossíveis. |
| `fnHora` | Converte horas tipadas, frações e textos; sinaliza valores inválidos. |
| `fnValorOficial` | Recupera grafia oficial de listas; preserva texto desconhecido para conferência. |
| `fnLerPlanilha` | Abre uma aba `Sheet` do XLSX e promove seus cabeçalhos. |
| `fnPadronizarColunas` | Aplica o de-para dos 39 campos e denuncia colisões. |
| `fnLerVagas` | Integra leitura, padronização e índice da linha de origem. |
| `fnRotuloCadastro` | Recupera rótulos de apresentação nos cadastros da Etapa 1. |

### 03_Cadastros — 12 consultas

| Consulta | Função |
| --- | --- |
| `ColunasAlvo` | Define o contrato de 39 campos de entrada das vagas. |
| `DeParaColunas` | Relaciona cabeçalhos ingleses e portugueses ao contrato canônico. |
| `cad_Etapa1` | Acessa as tabelas da Etapa 1 salva em disco. |
| `cad_Publicacoes` | Reutiliza o cadastro de tipos de publicação. |
| `cad_Vinculos` | Reutiliza o cadastro de vínculos das vagas. |
| `cad_Frequencias` | Reutiliza o cadastro de periodicidades salariais. |
| `lst_Publicacoes` | Disponibiliza os valores oficiais de publicação. |
| `lst_Vinculos` | Disponibiliza os valores oficiais de vínculo. |
| `lst_Frequencias` | Disponibiliza os valores oficiais de periodicidade. |
| `cad_DeParaOrgao` | Relaciona nomes NYC e variantes das empresas simuladas aos órgãos. |
| `cad_CargoChave` | Prepara chaves, códigos e atributos dos cargos de vagas. |
| `cad_AtributosSalarios` | Reúne referências de experiência, vínculo, modalidade e porte salarial. |

### 04_Staging — sete consultas

| Consulta | Função |
| --- | --- |
| `stg_Vagas_Bruto` | Lê a pasta, ignora `~$`, aceita `.xlsx` sem diferenciar maiúsculas e anexa as origens padronizadas com rastreio. |
| `stg_Salarios_Bruto` | Recupera os 11 campos originais e metadados de `Tab_Salarios`. |
| `proc_Vagas` | Executa o pipeline único de vagas, registrando estágios, aceitos e descartes. |
| `Rejeitados_Vagas` | Identifica por anti junção os registros de vagas não aceitos. |
| `proc_Salarios` | Converte e relaciona observações salariais sem deduplicar valores iguais. |
| `Rejeitados_Salarios` | Identifica observações salariais não aceitas; vazio na base atual. |
| `stg_Metas_Bruto` | Lê o planejamento largo antes do despivotamento. |

### 05_Saida — oito consultas

| Consulta | Função |
| --- | --- |
| `dCargo` | Expõe o cadastro próprio de cargos NYC e simulados. |
| `dOrgao` | Expõe os órgãos NYC e as empresas simuladas. |
| `dCargoSalarios` | Expõe o cadastro independente de cargos da base salarial. |
| `dPais` | Expõe os países com códigos internos e nomes em português. |
| `fVagas` | Apresenta os 21 estágios reais como Etapas Aplicadas e carrega somente o formato final aceito. |
| `fSalarios` | Carrega as observações salariais aceitas e seus atributos. |
| `Rejeitados` | Consolida os registros recusados das duas bases. |
| `fMetas` | Despivota e carrega o planejamento fictício por empresa/mês. |

### 06_Conferencia — cinco consultas

| Consulta | Função |
| --- | --- |
| `Conf_Colunas` | Mostra cabeçalhos originais, padronizados e problemas de contrato por arquivo. |
| `Conf_Reconciliacao` | Confere lidas, aceitas, rejeitadas e diferença por base/fonte e total. |
| `Conf_Motivos` | Agrupa os rejeitados pelo primeiro motivo efetivo. |
| `Conf_Etapas` | Mostra a contagem de cada estágio do pipeline. |
| `Conf_Metas` | Confere origem, despivotamento, total planejado e correspondência de órgãos. |

## Testes e conferência dos 13 itens do guia

Foram aprovadas 63 verificações independentes dos resultados, 34 casos de funções no motor nativo e 21 cenários nativos de atualização. Os cenários incluem reenvio de arquivo, repetição de atualização, reabertura, quantidade fracionária, cultura `10000,00`, horário `05:30`, desvio salarial, segunda deduplicação, diagnóstico de coluna desconhecida, novo mês e caminho inexistente. Os testes transitórios foram desfeitos nas cópias usadas para conferência.

Após fechar e reabrir a pasta de trabalho, 149.000 células foram comparadas sem divergências. Os dois CSV públicos, de 232 × 36 e 6.599 × 21, foram lidos integralmente de volta e conferidos. A serialização passou em oito testes: nulo, decimal, data, hora, vírgulas e aspas, quebra de linha, booleano e zero real.

O perfil de `fVagas` no Editor mostra 232 linhas e zero erros. A configuração de perfil baseada nas primeiras 1.000 linhas abrange todas as 232 linhas dessa consulta. As 6.599 observações de `fSalarios` foram conferidas integralmente pelos testes nativos e pela verificação independente dos resultados.

| Item do guia | Resultado nesta adaptação | Situação |
| --- | --- | --- |
| 1. Parâmetros configurados | Sete parâmetros e caminhos derivados funcionais; grupo nativo conferido. | Concluído |
| 2. Pasta lida inteira | Dois arquivos, 240 registros de vagas, com arquivo e linha. | Concluído |
| 3. D10 resolvido | Zero campos não mapeados, ausentes ou em colisão nos dois arquivos. | Concluído |
| 4. Nulos e duplicatas | Etapas contadas; duas passagens; reenvio e casos legítimos repetidos conferidos. | Concluído |
| 5. Tipos com localidade | Culturas por fonte, datas, horas, números e frações conferidos no Excel. | Concluído |
| 6. Textos padronizados | Espaços e NBSP tratados; grafias oficiais e siglas preservadas. | Concluído |
| 7. Mesclagens | Sem multiplicação; códigos obrigatórios presentes nos aceitos. | Concluído |
| 8. Colunas calculadas | Amplitude, ponto médio e mês confrontados com os valores de origem. | Concluído |
| 9. Rejeitados rastreáveis | Oito registros, motivos e linhagem conferidos contra as entradas. | Concluído |
| 10. Reconciliação | Diferença zero por base/fonte e no total. | Concluído |
| 11. Atualização funciona | Reenvio, restauração, atualização repetida e reabertura aprovados. | Concluído |
| 12. Artefatos no repositório | XLSX, 49 M, dois CSV, documentação e três capturas reais conferidos. | Concluído |
| 13. Escopo respeitado | Sem Modelo de Dados, relacionamentos no modelo, DAX, VBA, SQL ou Power BI. | Concluído |

Evidências: [painel com os seis grupos](evidencias/01_grupos_consultas.jpg), [Etapas Aplicadas e perfil de `fVagas`](evidencias/02_etapas_aplicadas_vagas.jpg) e [Conferencia com a reconciliação](evidencias/03_conferencia_reconciliacao.jpg).

## Limites de interpretação e publicação

Os 225 anúncios reais incluem 115 publicações externas e 110 internas, com 116 identificadores de vaga. São eventos publicados por órgãos de Nova York; a contagem de anúncios não equivale a vagas únicas nem representa todo o mercado de tecnologia, o Brasil ou oportunidades necessariamente abertas na data de leitura.

A moeda dos anúncios NYC não foi explicitada na extração e permanece `Não informada`. A frequência salarial dos anúncios é preservada; a periodicidade das observações salariais históricas permanece `Não confirmada`. `Salario_USD` é o valor fornecido pela fonte histórica, sem atualização cambial nesta etapa. O ponto médio de uma faixa não é salário efetivamente recebido. Comparações futuras devem separar fonte, moeda, periodicidade e período; cargos de taxonomias diferentes não são equiparados automaticamente.

Os arquivos públicos de dados limpos são somente [fVagas.csv](dados_limpos/fVagas.csv) e [fSalarios.csv](dados_limpos/fSalarios.csv), em UTF-8 com BOM, vírgula como delimitador, campos entre aspas, datas ISO e decimais com ponto. Os arquivos `.pq`, com o nome da consulta no comentário inicial, fazem parte da entrega exigida pelo guia. CSV complementares, scripts Python/PowerShell e relatórios JSON de apoio ficam no ZIP local de evidências técnicas, fora do Git.

Cada integrante deve registrar suas contribuições com a própria conta, conforme o guia.
