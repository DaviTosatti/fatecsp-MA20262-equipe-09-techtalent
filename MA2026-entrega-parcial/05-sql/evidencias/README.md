# Evidências da reprodução da carga SQLite

Esta pasta contém exportações reais dos resultados obtidos ao executar os scripts da Etapa 5 com os dados tratados presentes no repositório e as tabelas exportadas da pasta `TechTalent_02_PowerQuery.xlsx`.

## Execução realizada

Ordem: `techtalent_ddl.sql` → importação das seis tabelas `stg_*` → `techtalent_carga.sql` → `techtalent_views.sql` → `techtalent_consultas.sql` → `techtalent_conferencia.sql`. A carga foi repetida para verificar reexecução.

## Arquivos

- `00_relatorio_execucao.txt`: resumo do ambiente, contagens e validações.
- `C1` a `C7`: resultados das consultas analíticas.
- `K1` a `K10`: resultados das conferências descritas no SQL.
- `estrutura_*.csv`: colunas, índices e chaves estrangeiras do banco criado.
- `versao_sqlite.txt`: versão do SQLite usada.
- `consultas_*.csv` e `conferencia_*.csv`: saídas brutas na ordem dos SELECTs dos scripts.

## Resultado principal

A carga real gerou 232 vagas, 6.599 observações salariais, 12 metas e 8 rejeitados. A conferência retornou zero diferenças nos indicadores publicados, nenhuma violação de chave estrangeira, zero órfãos/duplicidades e os indicadores NYC de habilidades (70/225 = 31,11%) e Excel (18) conforme esperado.

Os CSVs são exportações de resultados; não são capturas de tela. O banco `techtalent.db` é mantido como artefato local separado e não deve ser incluído na pasta de evidências sem solicitação do professor.
