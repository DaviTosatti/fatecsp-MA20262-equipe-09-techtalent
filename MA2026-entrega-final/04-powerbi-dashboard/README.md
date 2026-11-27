# 📊 TechTalent — Dashboard Analítico (Power BI)

Módulo de visualização e inteligência de dados do projeto **TechTalent**, desenvolvido para a disciplina de **Microinformática Aplicada** (Análise e Desenvolvimento de Sistemas — Fatec-SP, 2026), sob orientação do Prof. Carlos Henrique Veríssimo Pereira.

---

## 📁 Arquivos desta Pasta

* **`TechTalent_Dashboard.pbix`**: Arquivo completo do Power BI Desktop contendo as transformações em Power Query (Linguagem M), o modelo dimensional e as 22 medidas DAX.
* **`TechTalent_Dashboard.pdf`**: Exportação em PDF das 3 páginas do relatório para consulta rápida diretamente pelo navegador, sem necessidade de instalar o Power BI Desktop.
* **`README.md`**: Documentação da arquitetura do modelo, indicadores principais e instruções de atualização das fontes de dados.

---

## 🗂️ Estrutura das Páginas e Indicadores Principais

### 1. Visão Executiva
Panorama consolidado das vagas anunciadas, histórico salarial e qualidade dos dados:
* **KPIs Globais (sem filtros ativos):**
  * **232** anúncios publicados (`225` da base `NYC` e `7` da base `SIMULADO`)
  * **260** posições anunciadas no total
  * **6.599** observações na base histórica de salários (2020–2024)
  * **$145,560.56** de salário médio anual informado (USD)
  * **8** registros rejeitados na auditoria de qualidade
* **Análises Visuais:** Segmentações por `Fonte` e `NomeMes`, evolução mensal de anúncios e posições, distribuição de vagas por órgão (`dOrgao`) e acompanhamento de posições anunciadas frente à meta de contratações (`Posições sobre Meta SIM %`).

### 2. Vagas e Habilidades
Diagnóstico de requisitos técnicos, aderência salarial em BRL e rastreabilidade de inconsistências:
* **Cobertura de Requisitos:** Contagem e percentual de anúncios com e sem habilidades descritas (**70** anúncios sem habilidade informada).
* **Demanda Técnica (`dHabilidades`):** Extração automatizada de competências via Linguagem M a partir do texto das vagas (SQL, Python, Excel, Power BI, Cloud, entre outras).
* **Comparativo Salarial (Base Simulada — BRL Mensal):** Confronto entre o salário de referência por cargo (`dCargo`) e o valor mínimo anunciado nas vagas.
* **Auditoria de Dados:** Tabela detalhada com os **8 registros rejeitados** (`Rejeitados`) e seus respectivos motivos de descarte.

### 3. Salários Históricos
Análise evolutiva da remuneração global de profissionais de dados e tecnologia entre **2020 e 2024**:
* **Indicadores:** Média salarial em USD, mediana salarial em USD e percentual de atuação em regime **Remoto**.
* **Análises Visuais:** Filtro por ano (`dAno`), curva histórica comparando média e mediana salarial anual e ranking de volume de observações por cargo (`dCargoSalarios`).

---

## 🏗️ Arquitetura do Modelo de Dados (Star Schema)

O relatório foi estruturado em **Modelo Estrela** para garantir integridade referencial e desempenho nas agregações:

* **Tabelas Fato:** `fVagas`, `fMetas` e `fSalarios`.
* **Tabelas Dimensão:** `dCalendario` (marcada como tabela de data oficial), `dAno`, `dCargo`, `dCargoSalarios`, `dHabilidades`, `dOrgao`, `dPais`, `dPaisEmpresa` e `dPaisResidencia`.
* **Tabelas Auxiliares:** `_Medidas` (repositório centralizado com 22 medidas DAX) e `Rejeitados` (mantida isolada do modelo relacional para auditoria).

---

## ⚙️ Como Atualizar os Dados Localmente

O caminho da planilha de origem (`TechTalent_02_PowerQuery.xlsx`) é controlado pelo parâmetro **`pPastaDados`**. Para reprocessar os dados em outro computador:

1. Abra o arquivo **`TechTalent_Dashboard.pbix`** no Power BI Desktop.
2. Na guia **Página Inicial**, clique em **Transformar dados → Gerenciar Parâmetros**.
3. No campo **Valor Atual** de **`pPastaDados`**, informe o caminho completo da pasta onde está o arquivo `TechTalent_02_PowerQuery.xlsx`, terminando obrigatoriamente com barra invertida (`\`).
   * *Exemplo:* `C:\Users\seu-usuario\Documentos\TechTalent\`
4. Clique em **OK** e, no canto superior esquerdo do Editor do Power Query, clique em **Fechar e Aplicar**.
