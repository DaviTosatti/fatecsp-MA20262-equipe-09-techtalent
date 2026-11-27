# Evidências da Etapa de BD

Este diretório reúne capturas de tela ou exportações dos resultados obtidos após importar os dados reais e executar os scripts da etapa de Banco de Dados.

As evidências devem permitir conferir a estrutura do banco, os resultados das consultas analíticas e os testes de consistência. Sempre que possível, cada arquivo deve indicar no nome a consulta ou conferência correspondente.

## 1. Estrutura e ambiente

- [ ] Estrutura das tabelas, incluindo colunas, chaves primárias e chaves estrangeiras.
- [ ] Índices criados pelo `techtalent_ddl.sql`.
- [ ] Resultado de `PRAGMA foreign_key_check` sem linhas retornadas.
- [ ] Versão do SQLite, obtida com `SELECT sqlite_version();`.

## 2. Consultas analíticas

Salvar capturas ou exportações dos resultados das consultas existentes em `techtalent_consultas.sql`:

- [ ] **C1** — Ranking de cargos por publicações e posições anunciadas.
- [ ] **C2** — Ranking exploratório por palavra/expressão completa.
- [ ] **C2.1** — Cobertura da coluna Habilidades por fonte. Na base atual, NYC deve apresentar 70 de 225 publicações sem habilidades informadas (31,11%).
- [ ] **C3** — Distribuição dos salários históricos por cargo, experiência e ano.
- [ ] **C3.1** — Distribuição dos salários históricos por cargo, experiência, ano e modalidade de trabalho. Para Data Scientist / Senior / 2023, conferir 579 observações: 357 presenciais, 218 remotas e 4 híbridas.
- [ ] **C4** — Faixas salariais de anúncios de NYC por cargo e periodicidade.
- [ ] **C5** — Posições anunciadas SIMULADO versus metas fictícias por empresa/mês.
- [ ] **C6** — Perfil das publicações por fonte e tipo.
- [ ] **C7** — Registros rejeitados agrupados por motivo.

## 3. Consultas de conferência

Salvar os resultados das verificações existentes em `techtalent_conferencia.sql`:

- [ ] **K1** — Batimento dos volumes com as referências publicadas nas Etapas 2 e 3. As diferenças devem ser zero.
- [ ] **K2** — Integridade referencial com `PRAGMA foreign_key_check`, sem linhas retornadas.
- [ ] **K3** — Verificação de chaves estrangeiras órfãs. Todas as contagens devem ser zero.
- [ ] **K4** — Verificação de chaves vazias ou duplicadas. Todas as contagens devem ser zero.
- [ ] **K5** — Preservação dos registros rejeitados: JSON inválido, motivo ausente e divergências devem ser zero.
- [ ] **K5.1** — Inspeção dos dados originais preservados para cada registro rejeitado.
- [ ] **K6** — Cobertura de vagas por fonte.
- [ ] **K7** — Calendário de 365 dias, de 01/01/2026 a 31/12/2026, sem falhas de continuidade.
- [ ] **K8** — Referência didática para vagas SIMULADO em BRL/Mensal.
- [ ] **K9** — Regressão do indicador de habilidades de NYC: 225 publicações, 70 sem informação e 31,11%, com diferenças zero.
- [ ] **K10** — Regressão da busca pela palavra completa Excel: 18 anúncios de NYC, sem contar ocorrências de `excellent`.

## 4. Organização dos arquivos

Sugestão de nomes para facilitar a identificação e a revisão:

```text
 evidencias/
 ├── README.md
 ├── estrutura_tabelas_indices.png
 ├── sqlite_versao.txt
 ├── C1_ranking_cargos.png
 ├── C2_ranking_habilidades.png
 ├── C2.1_cobertura_habilidades.png
 ├── C3_distribuicao_salarios.png
 ├── C3.1_salarios_modalidade.png
 ├── C4_faixas_salariais_nyc.png
 ├── C5_posicoes_vs_metas.png
 ├── C6_perfil_publicacoes.png
 ├── C7_rejeitados_por_motivo.png
 ├── K1_batimento_volumes.png
 ├── K2_integridade_referencial.png
 ├── K3_chaves_orfas.png
 ├── K4_chaves_vazias_duplicadas.png
 ├── K5_preservacao_rejeitados.png
 ├── K5.1_detalhe_rejeitados.png
 ├── K6_cobertura_fontes.png
 ├── K7_calendario.png
 ├── K8_referencia_simulado.png
 ├── K9_regressao_cobertura_nyc.png
 └── K10_regressao_excel.png
```

Os nomes acima são uma sugestão; podem ser adaptados ao formato das evidências produzidas. Não é necessário criar capturas artificiais: anexar somente resultados efetivamente obtidos na execução dos scripts.

## 5. Situação das evidências

As evidências reais ainda precisam ser geradas após a importação dos dados da Etapa 2 e a execução dos scripts no banco preenchido. Os valores de referência descritos neste README são critérios de conferência documentados no projeto, não substituem a captura dos resultados da execução.
