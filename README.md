# 🛵 Delivery Data Warehouse - Star Schema & Advanced Analytics

![SQL](https://img.shields.io/badge/Language-SQL-blue.svg)
![Data Modeling](https://img.shields.io/badge/Architecture-Star__Schema-orange.svg)
![Status](https://img.shields.io/badge/Status-Completed-success.svg)

## 📌 Sobre o Projeto

Este projeto consiste na modelagem e implementação de um **Data Warehouse** analítico para um aplicativo de delivery de comida. O objetivo principal foi transformar dados transacionais em uma arquitetura dimensional **Star Schema (Esquema Estrela)** altamente performática, permitindo a extração de métricas operacionais e financeiras complexas.

A solução abrange desde a criação das tabelas (DDL) e integridade referencial até a carga de dados (DML) e a construção de queries analíticas avançadas (DQL) utilizando **CTEs (Common Table Expressions)**, **Window Functions (`OVER / PARTITION BY`)** e **Regras Condicionais (`CASE WHEN`)**.

---

## 🏛️ Arquitetura do Data Warehouse (Star Schema)

A modelagem foi dividida entre **Tabelas Dimensão** (que armazenam os contextos e entidades de negócio) e a **Tabela Fato** (que armazena os eventos, transações e métricas numéricas).
### 🗂️ Estrutura das Tabelas

* **`DIM_CLIENTE`**: Cadastro dos clientes da plataforma.
* **`DIM_RESTAURANTE`**: Cadastro dos estabelecimentos parceiros e suas categorias gastronômicas.
* **`DIM_ENTREGADOR`**: Dados dos parceiros de entrega e seus modais de transporte (Moto, Bicicleta, etc.).
* **`FATO_PEDIDOS`**: Tabela central contendo os eventos de vendas, chaves estrangeiras (`FK`) e métricas (`VALOR_TOTAL_PEDIDO`, `VALOR_TAXA_ENTREGA`, `AVALIACAO_DO_PEDIDO`).

---

## 🛠️ Tecnologias e Conceitos Aplicados

* **SQL ANSI**: Compatível com PostgreSQL, MySQL, SQL Server e SQLite.
* **DDL (Data Definition Language)**: Criação de tabelas, definição de tipos de dados e restrições de integridade (`PRIMARY KEY`, `FOREIGN KEY`).
* **DML (Data Manipulation Language)**: Carga de dados simulando transações reais.
* **DQL (Data Query Language) Avançado**:
  * **CTEs Encadeadas (`WITH`)**: Modularização de código para alta legibilidade e manutenibilidade.
  * **Window Functions (`DENSE_RANK`, `SUM OVER PARTITION BY`)**: Ranqueamento e agregações de janela sem colapsar linhas.
  * **Estruturas Condicionais (`CASE WHEN`)**: Regras de negócio dinâmicas para classificação de qualidade.
  * **Agregações & Agrupamentos**: `GROUP BY`, `SUM`, `AVG`, `COUNT`, `MAX`, `ROUND`.

---

## 📂 Estrutura do Repositório

* [`script_data_warehouse.sql`](./script_data_warehouse.sql): Script SQL contendo o DDL para criação do schema, DML para povoamento dos dados e as 3 consultas analíticas completas.

---

## 📊 Regras de Negócio Implementadas

### 1️⃣ Desempenho Operacional por Categoria e Modal de Entrega
Consolidação do volume de pedidos, faturamento, custos de entrega e ticket médio agrupados por categoria do restaurante e tipo de veículo do entregador.

### 2️⃣ Ranking e Participação Financeira dos Clientes (% Share)
Identificação dos clientes mais valiosos (**Top 2 Spenders**) por categoria de restaurante, calculando o percentual de representatividade (`% Share`) sobre o faturamento total da categoria utilizando CTEs e Window Functions.

### 3️⃣ Avaliação de Qualidade e Operação dos Entregadores
Mapeamento do volume de entregas, maior ticket transportado e média de avaliações dos entregadores com mais de 1 entrega, classificando automaticamente em **'Atenção Operacional'** ou **'Excelente'** através de condicionais `CASE WHEN`.

---

## 👤 Autor

Desenvolvido por **Lucas Henrique**  
*Engenheiro de Dados em formação | Apaixonado por SQL, Arquitetura de Dados e Soluções de Alta Performance.*
