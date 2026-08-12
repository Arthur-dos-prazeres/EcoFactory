# EcoFactory

Sistema web Full Stack desenvolvido como atividade de reposição do curso **Informática para Internet — SENAI**.

## 👨‍💻 Informações do projeto

**Instituição:** SENAI
**Curso:** Informática para Internet
**Estudante:** Arthur Sancler

### Atividade de reposição — Entrega 1

---

## 📋 Sobre o projeto

A **EcoFactory** é uma empresa fictícia que enfrenta dificuldades no acompanhamento da produção, no controle das máquinas, na análise de indicadores e na tomada de decisões.

Este projeto tem como objetivo desenvolver uma aplicação web para **monitoramento e gestão de processos de uma indústria inteligente**, integrando Front-End, Back-End, banco de dados, testes e documentação técnica.

---

## 🎯 Objetivo

Desenvolver uma aplicação web **Full Stack** capaz de auxiliar no gerenciamento dos processos da EcoFactory, proporcionando uma interface responsiva e recursos para acompanhamento da produção e das máquinas.

---

## 👥 Público-alvo

Consumidores e usuários do ecossistema da empresa fictícia **EcoFactory**.

---

## ⚙️ Funcionalidades

* CRUD completo de máquinas;
* Cadastro de dados de produção;
* Consulta de produção;
* Dashboard com indicadores básicos;
* Persistência de dados no PostgreSQL;
* Integração do Front-End com a API REST;
* Validação dos principais formulários;
* Testes automatizados;
* Interface responsiva;
* Documentação técnica e instruções para execução do projeto.

---

## 🛠️ Tecnologias utilizadas

| Área               | Tecnologias                                             |
| ------------------ | ------------------------------------------------------- |
| **Front-End**      | HTML, CSS, JavaScript, React, Vite e Fetch API ou Axios |
| **Back-End**       | Node.js e Express                                       |
| **Banco de dados** | PostgreSQL local, Neon ou Supabase                      |
| **Versionamento**  | Git e GitHub                                            |
| **Testes**         | Vitest, React Testing Library, Jest e Supertest         |
| **Prototipação**   | Figma, Canva ou ferramenta equivalente                  |

---

## 🏗️ Estrutura do projeto

A aplicação é organizada seguindo uma arquitetura separada entre Front-End e Back-End, permitindo a comunicação entre a interface do usuário e a API REST.

```text
EcoFactory/
├── frontend/
│   ├── src/
│   ├── public/
│   └── ...
│
├── backend/
│   ├── src/
│   └── ...
│
├── README.md
└── ...
```

> A estrutura acima pode ser ajustada de acordo com a organização final do projeto.

---

## 🚀 Como executar o projeto

### Pré-requisitos

Antes de iniciar, certifique-se de ter instalado:

* [Node.js](https://nodejs.org/)
* [Git](https://git-scm.com/)
* PostgreSQL, Neon ou Supabase

### 1. Clone o repositório

```bash
git clone URL_DO_REPOSITORIO
```

Entre na pasta do projeto:

```bash
cd EcoFactory
```

### 2. Configuração do Back-End

Acesse a pasta do Back-End:

```bash
cd backend
```

Instale as dependências:

```bash
npm install
```

Configure as variáveis de ambiente necessárias, como a conexão com o banco de dados.

Exemplo:

```env
DATABASE_URL=sua_url_do_banco
PORT=3000
```

Inicie o servidor:

```bash
npm run dev
```

### 3. Configuração do Front-End

Em outro terminal, acesse a pasta do Front-End:

```bash
cd frontend
```

Instale as dependências:

```bash
npm install
```

Inicie a aplicação:

```bash
npm run dev
```

Após a inicialização, acesse o endereço informado pelo Vite no terminal.

---

## 🗄️ Banco de dados

O projeto utiliza **PostgreSQL** para persistência dos dados.

A aplicação pode utilizar:

* PostgreSQL local;
* Neon;
* Supabase.

As informações de conexão devem ser configuradas por meio de variáveis de ambiente. **Não inclua senhas, chaves ou credenciais diretamente no código ou no repositório.**

---

## 🔌 API REST

O Back-End disponibiliza uma API REST responsável pela comunicação entre a aplicação e o banco de dados.

Entre os principais recursos previstos estão:

| Recurso         | Operações                             |
| --------------- | ------------------------------------- |
| **Máquinas**    | Criar, consultar, atualizar e excluir |
| **Produção**    | Cadastrar e consultar                 |
| **Indicadores** | Consultar dados para o dashboard      |

Os endpoints e respectivos métodos HTTP podem ser documentados conforme a implementação final da API.

---

## 🧪 Testes

O projeto utiliza ferramentas de testes para verificar o funcionamento das aplicações Front-End e Back-End.

Entre as tecnologias previstas estão:

* **Vitest**
* **React Testing Library**
* **Jest**
* **Supertest**

Para executar os testes, utilize o comando configurado nos respectivos projetos, por exemplo:

```bash
npm test
```

---

## 🎨 Prototipação

A interface da aplicação é planejada a partir de protótipos desenvolvidos em ferramentas como:

* Figma;
* Canva;
* Ferramentas equivalentes.

Os protótipos servem como referência para a construção da interface responsiva da aplicação.

---

## 📌 Status do projeto

**Em desenvolvimento.**

As funcionalidades serão implementadas e aprimoradas conforme o andamento das etapas do projeto.

---

## 👨‍🎓 Autor

**Arthur Sancler**

Projeto acadêmico desenvolvido para o curso de **Informática para Internet — SENAI**.

---

## 📄 Licença

Este projeto foi desenvolvido para fins **educacionais e acadêmicos**.
