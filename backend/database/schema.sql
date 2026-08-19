-- =====================================================
-- BANCO DE DADOS - GESTÃO DE MÁQUINAS
-- PostgreSQL
-- =====================================================


-- =====================================================
-- TABELA DE USUÁRIOS
-- =====================================================

CREATE TABLE IF NOT EXISTS usuarios (

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

CREATE TABLE IF NOT EXISTS maquinas (

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

CREATE TABLE IF NOT EXISTS producoes (

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

CREATE TABLE IF NOT EXISTS manutencoes (

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

CREATE TABLE IF NOT EXISTS alertas (

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

CREATE INDEX IF NOT EXISTS idx_maquinas_status
ON maquinas(status);


CREATE INDEX IF NOT EXISTS idx_maquinas_setor
ON maquinas(setor);


CREATE INDEX IF NOT EXISTS idx_producoes_maquina
ON producoes(maquina_id);


CREATE INDEX IF NOT EXISTS idx_producoes_data
ON producoes(data_producao);


CREATE INDEX IF NOT EXISTS idx_manutencoes_maquina
ON manutencoes(maquina_id);


CREATE INDEX IF NOT EXISTS idx_manutencoes_status
ON manutencoes(status);


CREATE INDEX IF NOT EXISTS idx_alertas_maquina
ON alertas(maquina_id);


CREATE INDEX IF NOT EXISTS idx_alertas_resolvido
ON alertas(resolvido);
-- =====================================================
-- USUÁRIO DE TESTE
-- =====================================================

INSERT INTO usuarios (nome,email,senha,perfil)
SELECT 'Administrador','admin@gestaomaquinas.com','senha-temporaria','admin'
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE email='admin@gestaomaquinas.com');


-- =====================================================
-- MÁQUINAS DE TESTE
-- =====================================================

INSERT INTO maquinas (nome,setor,tipo,status,consumo_medio_energia,temperatura_atual)
SELECT * FROM (VALUES
  ('Torno CNC 01','Usinagem','CNC','Em operação',12.50,68.30),
  ('Prensa 02','Produção','Prensa','Em manutenção',18.70,55.20),
  ('Soldadora 03','Soldagem','Solda','Em operação',10.20,61.80),
  ('Torno Convencional 04','Usinagem','Torno','Parada',8.40,32.50),
  ('Cortadora 05','Corte','Corte','Desativada',0,25.00)
) AS v(nome,setor,tipo,status,consumo_medio_energia,temperatura_atual)
WHERE NOT EXISTS (SELECT 1 FROM maquinas m WHERE m.nome=v.nome);


-- =====================================================
-- PRODUÇÃO DE TESTE
-- =====================================================

INSERT INTO producoes (maquina_id,produto,quantidade_produzida,quantidade_rejeitada,data_producao,turno,observacoes)
SELECT m.id, v.produto, v.qtd, v.rej, CURRENT_DATE, v.turno, v.obs
FROM maquinas m
JOIN (VALUES
  ('Torno CNC 01','Peça A-100',500,5,'Manhã','Produção normal'),
  ('Torno CNC 01','Peça B-200',350,8,'Tarde','Pequena quantidade de peças rejeitadas'),
  ('Soldadora 03','Componente C-300',420,3,'Manhã','Produção dentro do esperado')
) AS v(nome,produto,qtd,rej,turno,obs) ON v.nome=m.nome
WHERE NOT EXISTS (SELECT 1 FROM producoes p WHERE p.maquina_id=m.id AND p.produto=v.produto AND p.data_producao=CURRENT_DATE);


-- =====================================================
-- MANUTENÇÕES DE TESTE
-- =====================================================

INSERT INTO manutencoes (maquina_id,tipo,descricao,data_programada,status,responsavel,custo)
SELECT m.id,v.tipo,v.descricao,v.data_programada,v.status,v.responsavel,v.custo
FROM maquinas m
JOIN (VALUES
  ('Prensa 02','Preventiva','Troca de rolamento e inspeção geral',CURRENT_DATE,'Em andamento','Equipe de Manutenção',850.00),
  ('Torno CNC 01','Preditiva','Verificação de vibração do equipamento',CURRENT_DATE+7,'Agendada','Equipe de Manutenção',300.00)
) AS v(nome,tipo,descricao,data_programada,status,responsavel,custo) ON v.nome=m.nome
WHERE NOT EXISTS (SELECT 1 FROM manutencoes x WHERE x.maquina_id=m.id AND x.descricao=v.descricao);


-- =====================================================
-- ALERTAS DE TESTE
-- =====================================================

INSERT INTO alertas (maquina_id,tipo,mensagem,nivel)
SELECT m.id,v.tipo,v.mensagem,v.nivel
FROM maquinas m
JOIN (VALUES
  ('Torno CNC 01','Temperatura','Temperatura da máquina acima do nível recomendado.','Alto'),
  ('Prensa 02','Manutenção','Máquina está em manutenção.','Médio')
) AS v(nome,tipo,mensagem,nivel) ON v.nome=m.nome
WHERE NOT EXISTS (SELECT 1 FROM alertas a WHERE a.maquina_id=m.id AND a.mensagem=v.mensagem);
