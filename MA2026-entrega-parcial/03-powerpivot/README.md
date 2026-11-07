# TechTalent — Etapa 3: Power Pivot e DAX

Modelo de dados para analisar publicações de vagas e observações salariais. A entrada é [TechTalent_02_PowerQuery.xlsx](../02-powerquery/TechTalent_02_PowerQuery.xlsx), com seus cadastros, registros aceitos, planejamento fictício e rejeitados. Esta etapa acrescenta relacionamentos e medidas, preservando o tratamento anterior.

## Abertura e atualização

Abra `TechTalent_03_PowerPivot.xlsx` no Excel para Windows com Power Pivot. No Power Query, ajuste **pArquivoEtapa2** para o caminho absoluto do arquivo da Etapa 2. Mantenha a entrada salva e fechada e use **Dados → Atualizar Tudo**. Consulte as tabelas dinâmicas em `Validacao` e as diferenças em `Conferencia`.

O [modelo relacional](docs/modelo_relacional.md) descreve tabelas, grãos, chaves e relações. As consultas ficam organizadas em `01_Parametros`, `02_Origem` e `03_Modelo`; seu código está em `scripts_m/`. As tabelas de dados são destinadas ao Modelo de Dados, sem cópias em planilhas.

## Medidas e perguntas

As fórmulas e descrições completas estão em [medidas_preliminares.dax](dax/medidas_preliminares.dax).

| Medida | Pergunta |
| --- | --- |
| Qtd Anúncios | Quantos eventos de publicação aceitos aparecem no recorte? |
| Posições Anunciadas | Quantas posições são reportadas nesses anúncios? |
| IDs de Vaga Distintos | Quantos identificadores distintos existem por fonte? |
| Posições por Anúncio | Qual a média de posições reportadas por publicação? |
| Observações Salariais | Quantas observações históricas compõem o recorte? |
| Salário Médio Informado USD | Qual a média do valor USD fornecido pela fonte histórica? |
| Posições SIM Anunciadas | Quantas posições são anunciadas nos casos fictícios? |
| Meta de Contratações SIM | Quantas contratações o planejamento fictício prevê? |
| Posições sobre Meta SIM % | Como o volume anunciado se compara ao planejamento, como exercício didático? |
| Referência SIM BRL Mensal | Qual a referência fictícia das posições com moeda e periodicidade comparáveis? |
| Valor Anunciado SIM BRL Mensal | Qual o limite salarial mínimo dessas mesmas posições? |
| Anúncios NYC | Quantas publicações pertencem à amostra municipal real? |
| Anúncios SIM | Quantas publicações fictícias foram aceitas? |
| Cresc. Anúncios MoM % | Como varia a quantidade de anúncios ante o mês anterior? |
| Conf … | As contagens, relações, chaves, datas e faixas reproduzem a Etapa 2? |

Anúncios e posições reportadas podem repetir o mesmo ID entre publicações internas e externas. O indicador de metas compara anúncios com **contratações planejadas**, sem comprovar contratações realizadas. A referência salarial é fictícia e limitada a BRL/mês, com valor positivo e unidade compatível.

## Validação e conferência

| Tabela dinâmica | Local | Recorte |
| --- | --- | --- |
| `TD_Validacao` | Validacao!A8 | Órgão × mês: anúncios e posições. |
| `TD_Metas` | Validacao!A55 | Empresa simulada × mês: posições, meta e razão didática. |
| `TD_Cargo` | Validacao!A85 | Cargo: anúncios, posições, IDs e referência comparável. |
| `TD_Salarios` | Validacao!A140 | Cargo salarial × ano: observações e média USD. |

Valores de referência da Etapa 2: **232 anúncios, 260 posições reportadas, 122 IDs distintos por fonte, 6.599 observações salariais, 12 metas e oito rejeitados**. O planejamento soma 31; no recorte comparável, a referência fictícia soma BRL 48.000/mês e os limites anunciados, BRL 45.500/mês.

`Conferencia`, a partir de A7, compara referências da entrada com medidas lidas por `VALORCUBO`. O protocolo é **6.839 lidos = 6.831 aceitos + 8 rejeitados**. As diferenças, chaves inválidas, órfãos e falhas do calendário estão zerados. A conferência inclui reprodução das faixas por linha, sem somar moedas diferentes.

Capturas do arquivo: [diagrama](evidencias/diagrama.png), [relacionamentos](evidencias/gerenciar_relacoes.png), [medidas](evidencias/gerenciar_medidas.png), [validação](evidencias/validacao.png) e [conferência](evidencias/conferencia.png).

## Adaptações do tema

O calendário cobre **2026 inteiro**, pois os anúncios NYC são de agosto a outubro e os casos fictícios, de março. As metas têm grão mensal e só devem ser comparadas por mês ou acima. Os salários de 2020–2024 possuem apenas ano e usam `dAno`, sem criar uma data diária fictícia. Os países da empresa e da residência têm papéis separados.

`Feriado` permanece **Não informado**: a entrada não fornece um calendário de feriados aplicável à jurisdição NYC. A moeda NYC e a periodicidade dos salários históricos continuam não confirmadas. `Salario_USD` é histórico, sem atualização cambial. Os cadastros de cargos NYC e salariais permanecem independentes.

Os oito registros descartados continuam em `Rejeitados`, com os [motivos registrados na Etapa 2](../02-powerquery/README.md#tratamento-e-rejeições). Incluem quantidades vazias ou inválidas, data e hora inválidas, data fora do recorte e o caso `SIM-VAG-012`, com órgão e cargo pendentes no cadastro. A correção deve ocorrer na origem e seguir pela atualização das três etapas.

O crescimento mensal fica vazio em totais de vários meses ou quando falta base no mês anterior. Sua interpretação depende da cobertura da amostra; não representa crescimento de todo o mercado de tecnologia.
