-- ============================================================================
-- PROJETO: DATA WAREHOUSE DELIVERY - MODELAGEM DIMENSIONAL (STAR SCHEMA)
-- AUTOR: Lucas Henrique
-- ETAPAS: 1. Criação das Tabelas (DDL) | 2. Inserção de Dados (DML)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- ETAPA 1: CRIAÇÃO DAS TABELAS DIMENSÃO (CADASTROS / CONTEXTO)
-- ----------------------------------------------------------------------------

-- Dimensão Cliente: Armazena dados cadastrais dos clientes
CREATE TABLE DIM_CLIENTE (
    ID_CLIENTE INT PRIMARY KEY,
    NOME_DO_CLIENTE VARCHAR(100) NOT NULL
);

-- Dimensão Restaurante: Armazena dados dos estabelecimentos e suas categorias
CREATE TABLE DIM_RESTAURANTE (
    ID_RESTAURANTE INT PRIMARY KEY,
    NOME_DO_RESTAURANTE VARCHAR(100) NOT NULL,
    CATEGORIA_RESTAURANTE VARCHAR(50) NOT NULL
);

-- Dimensão Entregador: Armazena informações dos parceiros de entrega e seus veículos
CREATE TABLE DIM_ENTREGADOR (
    ID_ENTREGADOR INT PRIMARY KEY,
    NOME_DO_ENTREGADOR VARCHAR(100) NOT NULL,
    TIPO_VEICULO_ENTREGADOR VARCHAR(30) NOT NULL
);


-- ----------------------------------------------------------------------------
-- ETAPA 2: CRIAÇÃO DA TABELA FATO (EVENTOS / MÉTRICAS DE NEGÓCIO)
-- ----------------------------------------------------------------------------

-- Tabela Fato: Registra os eventos de pedidos e garante a integridade referencial
CREATE TABLE FATO_PEDIDOS (
    ID_PEDIDO INT PRIMARY KEY,
    ID_CLIENTE INT NOT NULL,
    ID_RESTAURANTE INT NOT NULL,
    ID_ENTREGADOR INT NOT NULL,
    VALOR_TAXA_ENTREGA DECIMAL(10, 2) NOT NULL,
    VALOR_TOTAL_PEDIDO DECIMAL(10, 2) NOT NULL,
    AVALIACAO_DO_PEDIDO INT,
    
    -- Restrições de Chave Estrangeira (Foreign Keys)
    CONSTRAINT FK_PEDIDO_CLIENTE FOREIGN KEY (ID_CLIENTE) REFERENCES DIM_CLIENTE(ID_CLIENTE),
    CONSTRAINT FK_PEDIDO_RESTAURANTE FOREIGN KEY (ID_RESTAURANTE) REFERENCES DIM_RESTAURANTE(ID_RESTAURANTE),
    CONSTRAINT FK_PEDIDO_ENTREGADOR FOREIGN KEY (ID_ENTREGADOR) REFERENCES DIM_ENTREGADOR(ID_ENTREGADOR)
);


-- ----------------------------------------------------------------------------
-- ETAPA 3: CARGA INICIAL DE DADOS (INSERT INTO)
-- ----------------------------------------------------------------------------

-- 1. Povoando Tabelas Dimensão
INSERT INTO DIM_CLIENTE (ID_CLIENTE, NOME_DO_CLIENTE) VALUES
(1, 'Lucas Silva'),
(2, 'Priscila Alves'),
(3, 'João Pedro'),
(4, 'Mariana Costa');

INSERT INTO DIM_RESTAURANTE (ID_RESTAURANTE, NOME_DO_RESTAURANTE, CATEGORIA_RESTAURANTE) VALUES
(10, 'Sushi Express', 'Japonesa'),
(20, 'Pizza House', 'Pizzaria'),
(30, 'Burger King', 'Hamburgueria'),
(40, 'Cantina Italiana', 'Pizzaria');

INSERT INTO DIM_ENTREGADOR (ID_ENTREGADOR, NOME_DO_ENTREGADOR, TIPO_VEICULO_ENTREGADOR) VALUES
(100, 'Carlos Eduardo', 'Moto'),
(200, 'Ana Beatriz', 'Bicicleta'),
(300, 'Diego Martins', 'Moto');

-- 2. Povoando Tabela Fato (Relacionando as chaves das dimensões)
INSERT INTO FATO_PEDIDOS (
    ID_PEDIDO, 
    ID_CLIENTE, 
    ID_RESTAURANTE, 
    ID_ENTREGADOR, 
    VALOR_TAXA_ENTREGA, 
    VALOR_TOTAL_PEDIDO, 
    AVALIACAO_DO_PEDIDO
) VALUES
(1001, 1, 10, 100, 8.50, 120.00, 5),
(1002, 2, 20, 200, 5.00, 85.50, 4),
(1003, 3, 10, 200, 6.00, 95.00, 5),
(1004, 1, 30, 100, 7.00, 45.00, 3),
(1005, 4, 40, 300, 9.00, 110.00, 5);

-- ============================================================================
-- REGRA DE NEGÓCIO: DESEMPENHO OPERACIONAL POR CATEGORIA E MODAL DE ENTREGA
-- OBJETIVO: Consolidação de métricas operacionais e financeiras por combinação 
--           entre categoria de restaurante e tipo de veículo do entregador.
-- TÉCNICAS APLICADAS:
--   - INNER JOINs para integração entre a Tabela Fato e as Tabelas Dimensão
--   - Agregação (GROUP BY) por múltiplos atributos dimensionais
--   - Funções agregadas (COUNT, SUM, AVG) e formatação numérica com ROUND()
--   - Ordenação dinâmica por faturamento decrescente (ORDER BY)
-- ============================================================================

SELECT
	R.CATEGORIA_RESTAURANTE,
	E.TIPO_VEICULO_ENTREGADOR,
	COUNT(P.ID_PEDIDO) AS VOLUME_PEDIDOS,
	SUM(P.VALOR_TOTAL_PEDIDO) AS FATURAMENTO,
	SUM(P.VALOR_TAXA_ENTREGA) AS TOTAL_ENTREGA,
	ROUND(AVG(P.VALOR_TOTAL_PEDIDO), 2) AS TICKET_MEDIO
FROM DIM_RESTAURANTE R
INNER JOIN FATO_PEDIDOS P
ON P.ID_RESTAURANTE = R.ID_RESTAURANTE
INNER JOIN DIM_ENTREGADOR E 
ON E.ID_ENTREGADOR = P.ID_ENTREGADOR
GROUP BY R.CATEGORIA_RESTAURANTE, E.TIPO_VEICULO_ENTREGADOR
ORDER BY FATURAMENTO DESC;

-- ============================================================================
-- REGRA DE NEGÓCIO: RANKING E PARTICIPAÇÃO FINANCEIRA DOS CLIENTES POR CATEGORIA
-- OBJETIVO: Identificar os clientes mais valiosos (Top 2 Spenders) em cada 
--           categoria de restaurante e calcular o percentual de representatividade 
--           (% Share) do gasto do cliente em relação ao faturamento total da categoria.
-- TÉCNICAS APLICADAS:
--   - CTEs (Common Table Expressions) para modularização e clareza da lógica
--   - INNER JOINs para integração da Tabela Fato com as Tabelas Dimensão
--   - DENSE_RANK() OVER (PARTITION BY ... ORDER BY ...) para ranqueamento sem saltos
--   - SUM() OVER (PARTITION BY ...) para agregação em janela (Window Function)
--   - Filtro de ranking e cálculo percentual de participação no faturamento
-- ============================================================================

WITH FATURAMENTO AS (
SELECT
	C.ID_CLIENTE,
	C.NOME_DO_CLIENTE,
	R.CATEGORIA_RESTAURANTE,
	SUM(P.VALOR_TOTAL_PEDIDO) AS GASTO_CLIENTE
FROM DIM_CLIENTE C
INNER JOIN FATO_PEDIDOS P
ON C.ID_CLIENTE = P.ID_CLIENTE
INNER JOIN DIM_RESTAURANTE R
ON R.ID_RESTAURANTE = P.ID_RESTAURANTE
GROUP BY C.ID_CLIENTE, C.NOME_DO_CLIENTE, R.CATEGORIA_RESTAURANTE
),

RANK_FATURAMENTO AS(
SELECT *, 
	DENSE_RANK() OVER(PARTITION BY CATEGORIA_RESTAURANTE ORDER BY GASTO_CLIENTE DESC) AS RANK_FATURAMENTO_CATEGORIA,
	SUM(GASTO_CLIENTE) OVER(PARTITION BY CATEGORIA_RESTAURANTE) AS FATURAMENTO_TOTAL_CATEGORIA
FROM FATURAMENTO
)

SELECT *,
	ROUND((GASTO_CLIENTE / FATURAMENTO_TOTAL_CATEGORIA) * 100, 2) AS PORCENTAGEM
FROM RANK_FATURAMENTO
WHERE RANK_FATURAMENTO_CATEGORIA <= 2;

-- ============================================================================
-- REGRA DE NEGÓCIO 3: DESEMPENHO E QUALIDADE DOS ENTREGADORES
-- OBJETIVO: Mapear o volume de entregas, o maior ticket transportado e a média 
--           de avaliações dos entregadores com mais de 1 entrega, classificando 
--           aqueles que exigem atenção operacional.
-- TÉCNICAS APLICADAS:
--   - CTEs para separação da camada de agregação e da camada de regras de negócio
--   - Funções agregadas (MAX, COUNT, AVG) com ROUND()
--   - Estrutura condicional CASE WHEN para segmentação de qualidade
--   - Filtros pós-agregação e ordenação ascendente por nota
-- ============================================================================
WITH ENTREGADOR AS(
SELECT
	E.ID_ENTREGADOR,
	E.NOME_DO_ENTREGADOR,
	MAX(P.VALOR_TOTAL_PEDIDO) AS PEDIDO_MAXIMO,
	COUNT(P.ID_PEDIDO) AS QTD_ENTREGAS,
	ROUND(AVG(P.AVALIACAO_DO_PEDIDO), 2) AS MEDIA_AVALIACAO
FROM DIM_ENTREGADOR E
INNER JOIN FATO_PEDIDOS P
ON P.ID_ENTREGADOR = E.ID_ENTREGADOR
GROUP BY E.ID_ENTREGADOR, E.NOME_DO_ENTREGADOR
),

CLASSIFICACAO AS (
SELECT *,
	CASE
		WHEN MEDIA_AVALIACAO < 4 THEN 'ATENCAO OPERACIONAL'
		ELSE 'EXCELENTE'
		END AS CLASSIFICACAO_ENTREGADOR
FROM ENTREGADOR 
)

SELECT *
FROM CLASSIFICACAO
WHERE QTD_ENTREGAS > 1
ORDER BY MEDIA_AVALIACAO ASC;
