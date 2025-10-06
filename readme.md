# API REST para Gerenciamento de Pessoas com Delphi e Horse

![Linguagem](https://img.shields.io/badge/Linguagem-Delphi%2012-blue?style=for-the-badge&logo=delphi)
![Framework](https://img.shields.io/badge/Framework-Horse-orange?style=for-the-badge)
![Banco de Dados](https://img.shields.io/badge/Banco-Firebird-red?style=for-the-badge&logo=firebird)

API RESTful desenvolvida para servir como back-end em um projeto full-stack, fornecendo dados para um front-end em React. O projeto foi construído com foco em boas práticas de desenvolvimento de APIs, utilizando o micro-framework Horse para garantir alta performance e um código limpo.

**Status do Projeto:** Concluído ✔️

---

## 💡 Conceitos e Arquitetura

* **Padrão MVC (Model-View-Controller):** A API foi estruturada para separar as responsabilidades, com rotas e controllers bem definidos, facilitando a manutenção e a escalabilidade.
* **Middlewares:** Utilização de middlewares essenciais do Horse para funcionalidades como `CORS` (permitindo o acesso do front-end), `BodyParser` (para interpretar o JSON das requisições) e tratamento de exceções.
* **Comunicação via JSON:** Padronização de toda a comunicação de entrada e saída de dados no formato JSON, o padrão de mercado para APIs modernas.

---

## 🛠️ Tecnologias Utilizadas

* **IDE:** RAD Studio 12.3 (Delphi 12 Athens)
* **Linguagem:** Object Pascal
* **Framework Back-End:** Horse
* **Banco de Dados:** Firebird
* **Acesso a Dados:** FireDAC
* **Servidor:** Servidor HTTP Indy (padrão do Horse)

---

## 🚀 Setup e Execução

Para executar esta API localmente, siga os passos abaixo:

1.  **Pré-requisitos:**
    * Ter o Delphi 12 (RAD Studio 12.3) instalado.
    * Ter um servidor Firebird ativo na sua máquina.
    * O framework Horse e suas dependências precisam estar instalados via Boss (gerenciador de pacotes do Delphi).

2.  **Passos:**
    * Clone este repositório.
    * Abra o arquivo do projeto (`.dproj`) no Delphi.
    * Garanta que o arquivo do banco de dados (`.fdb`) esteja acessível e que a string de conexão no código (provavelmente em um DataModule) esteja configurada corretamente.
    * Compile (Build) e Execute (Run) o projeto a partir da IDE.

3.  **Verificação:**
    * Após executar, a API estará rodando em `http://localhost:9000`.
    * Você pode testar o endpoint principal acessando `http://localhost:9000/pessoas` em seu navegador ou em uma ferramenta como o Postman.

---

## 🗺️ Endpoints da API

A API implementa as seguintes rotas para o recurso `pessoas`:

| Método | Rota | Descrição |
| :--- | :--- | :--- |
| `GET` | `/pessoas` | Retorna a lista de todas as pessoas cadastradas. |
| `GET` | `/pessoas/:id` | Retorna os dados de uma única pessoa pelo seu ID. |
| `POST` | `/pessoas` | Cria um novo registro de pessoa. Requer um corpo (body) em JSON. |
| `PUT` | `/pessoas/:id` | Atualiza os dados de uma pessoa existente pelo seu ID. |
| `DELETE` | `/pessoas/:id` | Remove o registro de uma pessoa pelo seu ID. |