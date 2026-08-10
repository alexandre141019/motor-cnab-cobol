FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y gnucobol && rm -rf /var/lib/apt/lists/*
WORKDIR /app

COPY sistema.cbl .
COPY transacoes.txt .

# Compila usando o formato livre para evitar travas de coluna antigas
RUN cobc -x -free -o sistema sistema.cbl

CMD ["sh", "-c", "./sistema && echo '\n=== CONTEUDO DO ARQUIVO RETORNO.TXT ===' && cat retorno.txt"]
