# 🏛️ Core Banking & Processador CNAB 240 em COBOL Moderno

Este repositório contém um motor profissional de processamento de arquivos bancários em lote (Batch), operando como um microsserviço containerizado via **Docker** e integrado com uma camada moderna de dados em **TypeScript**.

## 🛠️ Arquitetura e Diferenciais Técnicos
- **Engine Principal**: COBOL estruturado com persistência em arquivos indexados (`ORGANIZATION IS INDEXED`).
- **Banco de Dados**: `CLIENTES.DAT` atuando como a persistência de contas e saldos em tempo real (`COMP-3` para alta performance numérica).
- **Rastreabilidade**: Sistema integrado de logs de auditoria (`LOGS.TXT`) com carimbo de data/hora automática.
- **Containerização**: Ambiente isolado com Alpine Linux, garantindo portabilidade entre Windows/Linux sem dependências locais.
- **Camada TypeScript (Node.js)**: Um parser moderno (ES Modules) que consome o arquivo de retorno posicional do Mainframe, aplicando tipagem e convertendo os dados brutos em objetos JSON prontos para consumo de APIs ou interfaces web.

## 🚀 Como Executar o Motor
```bash
# 1. Construir o ambiente isolado do Docker
docker build -t meu-projeto-cobol .

# 2. Executar o motor e processar o lote CNAB
docker run --rm meu-projeto-cobol

# 3. Rodar a camada moderna de integração para converter em JSON
npx ts-node src/parser.ts
```
