require('dotenv').config();

const express = require('express');
const cors = require('cors');
const path = require('path');
const { Pool } = require('pg');

const app = express();
const PORT = Number(process.env.PORT || 3000);

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT || 5432),
  database: process.env.DB_NAME || 'ecofactor',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '',
});

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

const asyncRoute = (handler) => (req, res, next) =>
  Promise.resolve(handler(req, res, next)).catch(next);

function idMiddleware(req, res, next) {
  const id = Number(req.params.id);
  if (!Number.isInteger(id) || id <= 0) {
    return res.status(400).json({ erro: 'ID inválido.' });
  }
  req.id = id;
  next();
}

function validarMaquina(body) {
  for (const campo of ['nome', 'setor', 'tipo', 'status']) {
    if (!body[campo] || String(body[campo]).trim() === '') {
      return `O campo ${campo} é obrigatório.`;
    }
  }
  const consumo = Number(body.consumo_medio_energia);
  const temperatura = Number(body.temperatura_atual);
  if (!Number.isFinite(consumo) || consumo < 0) return 'Consumo médio de energia inválido.';
  if (!Number.isFinite(temperatura)) return 'Temperatura atual inválida.';
  const statusValidos = ['Em operação', 'Em manutenção', 'Parada', 'Desativada'];
  if (!statusValidos.includes(String(body.status))) return 'Status de máquina inválido.';
  return null;
}

// ---------------- HEALTH ----------------
app.get('/api/health', asyncRoute(async (req, res) => {
  const result = await pool.query('SELECT NOW() AS data');
  res.json({ status: 'ok', banco: process.env.DB_NAME || 'ecofactor', data: result.rows[0].data });
}));

// ---------------- MAQUINAS ----------------
app.get('/api/maquinas', asyncRoute(async (req, res) => {
  const result = await pool.query(`
    SELECT id, nome, setor, tipo, status, consumo_medio_energia,
           temperatura_atual, criado_em, atualizado_em
    FROM maquinas ORDER BY id DESC
  `);
  res.json(result.rows);
}));

app.get('/api/maquinas/:id', idMiddleware, asyncRoute(async (req, res) => {
  const result = await pool.query(
    `SELECT id, nome, setor, tipo, status, consumo_medio_energia,
            temperatura_atual, criado_em, atualizado_em
     FROM maquinas WHERE id = $1`, [req.id]
  );
  if (!result.rowCount) return res.status(404).json({ erro: 'Máquina não encontrada.' });
  res.json(result.rows[0]);
}));

app.post('/api/maquinas', asyncRoute(async (req, res) => {
  const erro = validarMaquina(req.body);
  if (erro) return res.status(400).json({ erro });

  const { nome, setor, tipo, status } = req.body;
  const consumo = Number(req.body.consumo_medio_energia);
  const temperatura = Number(req.body.temperatura_atual);

  const result = await pool.query(`
    INSERT INTO maquinas (nome, setor, tipo, status, consumo_medio_energia, temperatura_atual)
    VALUES ($1, $2, $3, $4, $5, $6)
    RETURNING *
  `, [String(nome).trim(), String(setor).trim(), String(tipo).trim(), String(status).trim(), consumo, temperatura]);

  res.status(201).json({ mensagem: 'Máquina cadastrada com sucesso.', maquina: result.rows[0] });
}));

app.put('/api/maquinas/:id', idMiddleware, asyncRoute(async (req, res) => {
  const erro = validarMaquina(req.body);
  if (erro) return res.status(400).json({ erro });

  const { nome, setor, tipo, status } = req.body;
  const consumo = Number(req.body.consumo_medio_energia);
  const temperatura = Number(req.body.temperatura_atual);

  const result = await pool.query(`
    UPDATE maquinas SET nome=$1, setor=$2, tipo=$3, status=$4,
      consumo_medio_energia=$5, temperatura_atual=$6, atualizado_em=CURRENT_TIMESTAMP
    WHERE id=$7 RETURNING *
  `, [String(nome).trim(), String(setor).trim(), String(tipo).trim(), String(status).trim(), consumo, temperatura, req.id]);

  if (!result.rowCount) return res.status(404).json({ erro: 'Máquina não encontrada.' });
  res.json({ mensagem: 'Máquina atualizada com sucesso.', maquina: result.rows[0] });
}));

app.delete('/api/maquinas/:id', idMiddleware, asyncRoute(async (req, res) => {
  const result = await pool.query('DELETE FROM maquinas WHERE id=$1 RETURNING id,nome', [req.id]);
  if (!result.rowCount) return res.status(404).json({ erro: 'Máquina não encontrada.' });
  res.json({ mensagem: 'Máquina excluída com sucesso.', maquina: result.rows[0] });
}));

// ---------------- PRODUCAO ----------------
app.get('/api/producao', asyncRoute(async (req, res) => {
  const result = await pool.query(`
    SELECT p.id, p.maquina_id, m.nome AS maquina, p.produto,
           p.quantidade_produzida, p.quantidade_rejeitada,
           p.data_producao, p.turno, p.observacoes, p.criado_em
    FROM producoes p JOIN maquinas m ON m.id=p.maquina_id
    ORDER BY p.data_producao DESC, p.id DESC
  `);
  res.json(result.rows);
}));

app.post('/api/producao', asyncRoute(async (req, res) => {
  const { maquina_id, produto, quantidade_produzida, quantidade_rejeitada=0,
          data_producao, turno=null, observacoes=null } = req.body;
  if (!maquina_id || !produto || quantidade_produzida === undefined || !data_producao) {
    return res.status(400).json({ erro: 'maquina_id, produto, quantidade_produzida e data_producao são obrigatórios.' });
  }
  const q = Number(quantidade_produzida), r = Number(quantidade_rejeitada);
  if (!Number.isInteger(q) || q < 0 || !Number.isInteger(r) || r < 0) {
    return res.status(400).json({ erro: 'As quantidades devem ser números inteiros não negativos.' });
  }
  const result = await pool.query(`
    INSERT INTO producoes (maquina_id, produto, quantidade_produzida, quantidade_rejeitada, data_producao, turno, observacoes)
    VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING *
  `, [Number(maquina_id), String(produto).trim(), q, r, data_producao, turno, observacoes]);
  res.status(201).json({ mensagem: 'Produção cadastrada com sucesso.', producao: result.rows[0] });
}));

// ---------------- MANUTENCOES ----------------
app.get('/api/manutencoes', asyncRoute(async (req, res) => {
  const result = await pool.query(`
    SELECT mt.id, mt.maquina_id, m.nome AS maquina, mt.tipo, mt.descricao,
           mt.data_programada, mt.data_realizada, mt.status, mt.responsavel, mt.custo, mt.criado_em
    FROM manutencoes mt JOIN maquinas m ON m.id=mt.maquina_id
    ORDER BY mt.data_programada ASC, mt.id DESC
  `);
  res.json(result.rows);
}));

app.post('/api/manutencoes', asyncRoute(async (req, res) => {
  const { maquina_id, tipo, descricao, data_programada, data_realizada=null,
          status='Agendada', responsavel=null, custo=0 } = req.body;
  if (!maquina_id || !tipo || !descricao || !data_programada) {
    return res.status(400).json({ erro: 'maquina_id, tipo, descricao e data_programada são obrigatórios.' });
  }
  const result = await pool.query(`
    INSERT INTO manutencoes (maquina_id,tipo,descricao,data_programada,data_realizada,status,responsavel,custo)
    VALUES ($1,$2,$3,$4,$5,$6,$7,$8) RETURNING *
  `, [Number(maquina_id), tipo, String(descricao).trim(), data_programada, data_realizada, status, responsavel, Number(custo)]);
  res.status(201).json({ mensagem: 'Manutenção cadastrada com sucesso.', manutencao: result.rows[0] });
}));

// ---------------- ALERTAS ----------------
app.get('/api/alertas', asyncRoute(async (req, res) => {
  const result = await pool.query(`
    SELECT a.id,a.maquina_id,m.nome AS maquina,a.tipo,a.mensagem,a.nivel,a.resolvido,a.criado_em
    FROM alertas a LEFT JOIN maquinas m ON m.id=a.maquina_id
    ORDER BY a.resolvido ASC,a.criado_em DESC
  `);
  res.json(result.rows);
}));

app.post('/api/alertas', asyncRoute(async (req, res) => {
  const { maquina_id=null, tipo, mensagem, nivel } = req.body;
  if (!tipo || !mensagem || !nivel) return res.status(400).json({ erro: 'tipo, mensagem e nivel são obrigatórios.' });
  const result = await pool.query(`INSERT INTO alertas (maquina_id,tipo,mensagem,nivel) VALUES ($1,$2,$3,$4) RETURNING *`,
    [maquina_id ? Number(maquina_id) : null, tipo, mensagem, nivel]);
  res.status(201).json({ mensagem: 'Alerta criado com sucesso.', alerta: result.rows[0] });
}));

app.patch('/api/alertas/:id/resolver', idMiddleware, asyncRoute(async (req, res) => {
  const result = await pool.query('UPDATE alertas SET resolvido=TRUE WHERE id=$1 RETURNING *', [req.id]);
  if (!result.rowCount) return res.status(404).json({ erro: 'Alerta não encontrado.' });
  res.json({ mensagem: 'Alerta marcado como resolvido.', alerta: result.rows[0] });
}));

// ---------------- DASHBOARD ----------------
app.get('/api/dashboard', asyncRoute(async (req, res) => {
  const [maquinas, producao, alertas, manutencoes, turnos] = await Promise.all([
    pool.query(`SELECT COUNT(*)::int total,
      COUNT(*) FILTER (WHERE status='Em operação')::int em_operacao,
      COUNT(*) FILTER (WHERE status='Parada')::int paradas,
      COUNT(*) FILTER (WHERE status='Em manutenção')::int em_manutencao,
      COUNT(*) FILTER (WHERE status='Desativada')::int desativadas FROM maquinas`),
    pool.query(`SELECT COALESCE(SUM(quantidade_produzida),0)::int total_produzido,
      COALESCE(SUM(quantidade_rejeitada),0)::int total_rejeitado FROM producoes WHERE data_producao=CURRENT_DATE`),
    pool.query(`SELECT COUNT(*)::int total FROM alertas WHERE resolvido=FALSE`),
    pool.query(`SELECT COUNT(*)::int total FROM manutencoes WHERE status IN ('Agendada','Em andamento')`),
    pool.query(`SELECT COALESCE(turno,'Sem turno') turno, COALESCE(SUM(quantidade_produzida),0)::int quantidade
      FROM producoes WHERE data_producao=CURRENT_DATE GROUP BY COALESCE(turno,'Sem turno') ORDER BY quantidade DESC`)
  ]);
  res.json({
    maquinas: maquinas.rows[0],
    producao_hoje: producao.rows[0],
    alertas_abertos: alertas.rows[0].total,
    manutencoes_pendentes: manutencoes.rows[0].total,
    producao_por_turno: turnos.rows
  });
}));

app.get('/', (req,res) => res.sendFile(path.join(__dirname,'public','Dashboard.html')));

app.use((req,res) => res.status(404).json({ erro:'Rota não encontrada.' }));
app.use((err,req,res,next) => {
  console.error(err);
  if (err.code === '23505') return res.status(409).json({ erro:'Registro duplicado.' });
  if (err.code === '23503') return res.status(400).json({ erro:'Registro relacionado não existe.' });
  if (err.code === '23514') return res.status(400).json({ erro:'Valor inválido para uma regra do banco de dados.' });
  res.status(500).json({ erro:'Erro interno do servidor.', detalhe: process.env.NODE_ENV === 'development' ? err.message : undefined });
});

app.listen(PORT, () => {
  console.log(`Servidor iniciado em http://localhost:${PORT}`);
  console.log(`Banco configurado: ${process.env.DB_NAME || 'ecofactor'}`);
});

process.on('SIGINT', async () => { await pool.end(); process.exit(0); });
