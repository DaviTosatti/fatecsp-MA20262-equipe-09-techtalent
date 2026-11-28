# Evidências da reprodução da carga SQLite

Esta pasta contém exportações reais dos resultados obtidos ao executar os scripts da Etapa 5 com os dados tratados presentes no repositório e as tabelas exportadas da pasta `TechTalent_02_PowerQuery.xlsx`.

## Execução realizada

Ordem: `techtalent_ddl.sql` → importação das seis tabelas `stg_*` → `techtalent_carga.sql` → `techtalent_views.sql` → `techtalent_consultas.sql` → `techtalent_conferencia.sql`. A carga foi repetida para verificar reexecução.

## Estrutura e ambiente

- [Resumo da execução](00_relatorio_execucao.txt) e [versão do SQLite](versao_sqlite.txt).
- Estrutura do banco: [tabelas e colunas](estrutura_tabelas_colunas.csv), [índices](estrutura_indices.csv) e [chaves estrangeiras](estrutura_chaves_estrangeiras.csv).
- [Testes automatizados](testes_automatizados.txt) e [índice das saídas](00_indice_resultados.csv).

## Consultas analíticas

- **[C1](C1_ranking_cargos.csv)** — Ranking de cargos por publicações e posições anunciadas.
- **[C2](C2_habilidades.csv)** — Ranking exploratório por palavra/expressão completa.
- **[C2.1](C2_1_cobertura_habilidades.csv)** — Cobertura da coluna Habilidades por fonte. Na base atual, NYC deve apresentar 70 de 225 publicações sem habilidades informadas (31,11%).
- **[C3](C3_salarios_por_cargo_ano.csv)** — Distribuição dos salários históricos por cargo, experiência e ano.
- **[C3.1](C3_1_salarios_por_modalidade.csv)** — Distribuição dos salários históricos por cargo, experiência, ano e modalidade de trabalho. Para Data Scientist / Senior / 2023, conferir 579 observações: 357 presenciais, 218 remotas e 4 híbridas.
- **[C4](C4_faixas_salariais_nyc.csv)** — Faixas salariais de anúncios de NYC por cargo e periodicidade.
- **[C5](C5_metas_simuladas.csv)** — Posições anunciadas SIMULADO versus metas fictícias por empresa/mês.
- **[C6](C6_perfil_publicacoes.csv)** — Perfil das publicações por fonte e tipo.
- **[C7](C7_rejeitados_por_motivo.csv)** — Registros rejeitados agrupados por motivo.

## Conferências

- **[K1](K1_batimento_referencias.csv)** — Batimento dos volumes com as referências publicadas nas Etapas 2 e 3. As diferenças devem ser zero.
- **[K2](K2_foreign_key_check.csv)** — Integridade referencial com `PRAGMA foreign_key_check`, sem linhas retornadas.
- **[K3](K3_integridade_referencial.csv)** — Verificação de chaves estrangeiras órfãs. Todas as contagens devem ser zero.
- **[K4](K4_chaves_vazias_duplicadas.csv)** — Verificação de chaves vazias ou duplicadas. Todas as contagens devem ser zero.
- **[K5](K5_preservacao_rejeitados.csv)** — Preservação dos registros rejeitados: JSON inválido, motivo ausente e divergências devem ser zero.
- **[K5.1](K5_1_detalhe_rejeitados.csv)** — Inspeção dos dados originais preservados para cada registro rejeitado.
- **[K6](K6_cobertura_fontes.csv)** — Cobertura de vagas por fonte.
- **[K7](K7_calendario.csv)** — Calendário de 365 dias, de 01/01/2026 a 31/12/2026, sem falhas de continuidade.
- **[K8](K8_referencia_simulada.csv)** — Referência didática para vagas SIMULADO em BRL/Mensal.
- **[K9](K9_regressao_habilidades.csv)** — Regressão do indicador de habilidades de NYC: 225 publicações, 70 sem informação e 31,11%, com diferenças zero.
- **[K10](K10_regressao_excel.csv)** — Regressão da busca pela palavra completa Excel: 18 anúncios de NYC, sem contar ocorrências de `excellent`.

## Saídas brutas

- `consultas_*.csv` e `conferencia_*.csv`: saídas brutas na ordem dos SELECTs dos scripts.

## Resultado principal

A carga real gerou 232 publicações aceitas (260 posições anunciadas), 6.599 observações salariais, 12 metas e 8 rejeitados. A conferência retornou zero diferenças nos indicadores publicados, nenhuma violação de chave estrangeira, zero órfãos/duplicidades e os indicadores NYC de habilidades (70/225 = 31,11%) e Excel (18) conforme esperado.

Os CSVs são exportações de resultados; não são capturas de tela. O banco `techtalent.db` é mantido como artefato local separado e não deve ser incluído na pasta de evidências sem solicitação do professor.
