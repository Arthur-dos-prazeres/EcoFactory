-- =====================================================
-- BANCO DE DADOS - GESTÃO DE MÁQUINAS
-- PostgreSQL
-- =====================================================


-- =====================================================
-- TABELA DE USUÁRIOS
-- =====================================================

CREATE TABLE usuarios (

    id SERIAL PRIMARY KEY,

    nome VARCHAR(100) NOT NULL,

    email VARCHAR(150) UNIQUE NOT NULL,

    senha VARCHAR(255) NOT NULL,

    perfil VARCHAR(30) DEFAULT 'usuario',

    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);


-- =====================================================
-- TABELA DE MÁQUINAS
-- =====================================================

CREATE TABLE maquinas (

    id SERIAL PRIMARY KEY,

    nome VARCHAR(100) NOT NULL,

    setor VARCHAR(100) NOT NULL,

    tipo VARCHAR(100) NOT NULL,

    status VARCHAR(30) NOT NULL
        CHECK (
            status IN (
                'Em operação',
                'Em manutenção',
                'Parada',
                'Desativada'
            )
        ),

    consumo_medio_energia DECIMAL(10,2),

    temperatura_atual DECIMAL(5,2),

    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);


-- =====================================================
-- TABELA DE PRODUÇÃO
-- =====================================================

CREATE TABLE producoes (

    id SERIAL PRIMARY KEY,

    maquina_id INTEGER NOT NULL,

    produto VARCHAR(150) NOT NULL,

    quantidade_produzida INTEGER NOT NULL
        CHECK (quantidade_produzida >= 0),

    quantidade_rejeitada INTEGER DEFAULT 0
        CHECK (quantidade_rejeitada >= 0),

    data_producao DATE NOT NULL,

    turno VARCHAR(30),

    observacoes TEXT,

    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_producao_maquina

        FOREIGN KEY (maquina_id)

        REFERENCES maquinas(id)

        ON DELETE CASCADE

);


-- =====================================================
-- TABELA DE MANUTENÇÕES
-- =====================================================

CREATE TABLE manutencoes (

    id SERIAL PRIMARY KEY,

    maquina_id INTEGER NOT NULL,

    tipo VARCHAR(30) NOT NULL
        CHECK (
            tipo IN (
                'Preventiva',
                'Corretiva',
                'Preditiva'
            )
        ),

    descricao TEXT NOT NULL,

    data_programada DATE NOT NULL,

    data_realizada DATE,

    status VARCHAR(30) DEFAULT 'Agendada'
        CHECK (
            status IN (
                'Agendada',
                'Em andamento',
                'Concluída',
                'Cancelada'
            )
        ),

    responsavel VARCHAR(100),

    custo DECIMAL(10,2) DEFAULT 0,

    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_manutencao_maquina

        FOREIGN KEY (maquina_id)

        REFERENCES maquinas(id)

        ON DELETE CASCADE

);


-- =====================================================
-- TABELA DE ALERTAS
-- =====================================================

CREATE TABLE alertas (

    id SERIAL PRIMARY KEY,

    maquina_id INTEGER,

    tipo VARCHAR(50) NOT NULL,

    mensagem TEXT NOT NULL,

    nivel VARCHAR(20) NOT NULL
        CHECK (
            nivel IN (
                'Baixo',
                'Médio',
                'Alto',
                'Crítico'
            )
        ),

    resolvido BOOLEAN DEFAULT FALSE,

    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_alerta_maquina

        FOREIGN KEY (maquina_id)

        REFERENCES maquinas(id)

        ON DELETE CASCADE

);


-- =====================================================
-- ÍNDICES
-- =====================================================

CREATE INDEX idx_maquinas_status
ON maquinas(status);


CREATE INDEX idx_maquinas_setor
ON maquinas(setor);


CREATE INDEX idx_producoes_maquina
ON producoes(maquina_id);


CREATE INDEX idx_producoes_data
ON producoes(data_producao);


CREATE INDEX idx_manutencoes_maquina
ON manutencoes(maquina_id);


CREATE INDEX idx_manutencoes_status
ON manutencoes(status);


CREATE INDEX idx_alertas_maquina
ON alertas(maquina_id);


CREATE INDEX idx_alertas_resolvido
ON alertas(resolvido);
-- =====================================================
-- USUÁRIO DE TESTE
-- =====================================================

INSERT INTO usuarios
(nome, email, senha, perfil)
VALUES
(
    'Administrador',
    'admin@gestaomaquinas.com',
    'senha-temporaria',
    'admin'
);


-- =====================================================
-- MÁQUINAS
-- =====================================================

INSERT INTO maquinas
(
    nome,
    setor,
    tipo,
    status,
    consumo_medio_energia,
    temperatura_atual
)
VALUES

(
    'Torno CNC 01',
    'Usinagem',
    'CNC',
    'Em operação',
    12.50,
    68.30
),

(
    'Prensa 02',
    'Produção',
    'Prensa',
    'Em manutenção',
    18.70,
    55.20
),

(
    'Soldadora 03',
    'Soldagem',
    'Solda',
    'Em operação',
    10.20,
    61.80
),

(
    'Torno Convencional 04',
    'Usinagem',
    'Torno',
    'Parada',
    8.40,
    32.50
),

(
    'Cortadora 05',
    'Corte',
    'Corte',
    'Desativada',
    0,
    25.00
);


-- =====================================================
-- PRODUÇÃO
-- =====================================================

INSERT INTO producoes
(
    maquina_id,
    produto,
    quantidade_produzida,
    quantidade_rejeitada,
    data_producao,
    turno,
    observacoes
)
VALUES

(
    1,
    'Peça A-100',
    500,
    5,
    CURRENT_DATE,
    'Manhã',
    'Produção normal'
),

(
    1,
    'Peça B-200',
    350,
    8,
    CURRENT_DATE,
    'Tarde',
    'Pequena quantidade de peças rejeitadas'
),

(
    3,
    'Componente C-300',
    420,
    3,
    CURRENT_DATE,
    'Manhã',
    'Produção dentro do esperado'
);


-- =====================================================
-- MANUTENÇÕES
-- =====================================================

INSERT INTO manutencoes
(
    maquina_id,
    tipo,
    descricao,
    data_programada,
    status,
    responsavel,
    custo
)
VALUES

(
    2,
    'Preventiva',
    'Troca de rolamento e inspeção geral',
    CURRENT_DATE,
    'Em andamento',
    'Equipe de Manutenção',
    850.00
),

(
    1,
    'Preditiva',
    'Verificação de vibração do equipamento',
    CURRENT_DATE + 7,
    'Agendada',
    'Equipe de Manutenção',
    300.00
);


-- =====================================================
-- ALERTAS
-- =====================================================

INSERT INTO alertas
(
    maquina_id,
    tipo,
    mensagem,
    nivel
)
VALUES

(
    1,
    'Temperatura',
    'Temperatura da máquina acima do nível recomendado.',
    'Alto'
),

(
    2,
    'Manutenção',
    'Máquina está em manutenção.',
    'Médio'
);
SELECT COUNT(*) AS total_maquinas
FROM maquinas;

SELECT COUNT(*) AS maquinas_em_operacao
FROM maquinas
WHERE status = '
Em operação';

SELECT COUNT(*) AS maquinas_em_manutencao
FROM maquinas
WHERE status = 'Em manutenção';


SELECT COUNT(*) AS maquinas_paradas
FROM maquinas
WHERE status = 'Parada';


SELECT SUM(quantidade_produzida) AS producao_total
FROM producoes;


SELECT SUM(quantidade_rejeitada) AS total_rejeitado
FROM producoes;SELECT COUNT(*) AS alertas_abertos
FROM alertas
WHERE resolvido = FALSE;



SELECT
    id,
    nome,
    setor,
    tipo,
    status,
    consumo_medio_energia,
    temperatura_atual
FROM maquinas
ORDER BY id;


SELECT COUNT(*) AS alertas_abertos
FROM alertas
WHERE resolvido = FALSE;


