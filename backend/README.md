# Gestão de Máquinas — Backend

Backend em Node.js + Express + PostgreSQL para conectar os front-ends HTML/JavaScript à base de dados.

## 1. Instalação

```bash
npm install
```

## 2. Configuração

Copie `.env.example` para `.env` e informe a senha do PostgreSQL:

```env
PORT=3000
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ecofactor
DB_USER=postgres
DB_PASSWORD=sua_senha
```

## 3. Banco

Crie o banco `ecofactor` no PostgreSQL e execute `database/schema.sql`.

## 4. Executar

```bash
npm start
```

Para desenvolvimento:

```bash
npm run dev
```

Abra `http://localhost:3000`.

## Endpoints principais

- `GET /api/health`
- `GET /api/maquinas`
- `GET /api/maquinas/:id`
- `POST /api/maquinas`
- `PUT /api/maquinas/:id`
- `DELETE /api/maquinas/:id`
- `GET /api/producao`
- `POST /api/producao`
- `GET /api/manutencoes`
- `POST /api/manutencoes`
- `GET /api/alertas`
- `POST /api/alertas`
- `PATCH /api/alertas/:id/resolver`
- `GET /api/dashboard`

## Exemplo de cadastro de máquina

```javascript
const resposta = await fetch('/api/maquinas', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    nome: document.getElementById('nome').value,
    setor: document.getElementById('setor').value,
    tipo: document.getElementById('tipo').value,
    status: document.getElementById('status').value,
    consumo_medio_energia: Number(document.getElementById('consumo').value),
    temperatura_atual: Number(document.getElementById('temperatura').value)
  })
});

const dados = await resposta.json();
```


## Execução

1. Abra a pasta `backend` no Visual Studio Code.
2. Execute `npm install`.
3. Crie o banco PostgreSQL `ecofactor`.
4. Execute `database/schema.sql` no banco `ecofactor`.
5. Crie `.env` com `DB_NAME=ecofactor`.
6. Execute `npm start`.
7. Abra `http://localhost:3000`.

Teste a conexão em `http://localhost:3000/api/health`.

As telas HTML usam `fetch()` para chamar a API; não abra os HTML com duplo clique. Abra pelo endereço do servidor.
