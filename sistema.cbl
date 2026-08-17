       IDENTIFICATION DIVISION.
       PROGRAM-ID. CNAB-SENIOR.
       AUTHOR.     FABIO.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *    ARQUIVOS SEQUENCIAIS DE MOVIMENTACAO
           SELECT ARQ-ENTRADA ASSIGN TO "transacoes.txt"
               ORGANIZATION IS LINE SEQUENTIAL.
               
           SELECT ARQ-RETORNO ASSIGN TO "retorno.txt"
               ORGANIZATION IS LINE SEQUENTIAL.

      *    ARQUIVO DE AUDITORIA E LOGS DO SISTEMA
           SELECT ARQ-LOGS ASSIGN TO "LOGS.TXT"
               ORGANIZATION IS LINE SEQUENTIAL.

      *    TABELA DE CLIENTES INDEXADA (BANCO DE DADOS CORE BANCARIO)
           SELECT ARQ-CLIENTES ASSIGN TO "CLIENTES.DAT"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS CLI-CHAVE-CONTA
               FILE STATUS IS WS-STATUS-CLI.

       DATA DIVISION.
       FILE SECTION.
       FD  ARQ-ENTRADA.
       01  REG-ENTRADA           PIC X(120).

       FD  ARQ-RETORNO.
       01  REG-RETORNO           PIC X(120).

       FD  ARQ-LOGS.
       01  REG-LOGS              PIC X(150).

       FD  ARQ-CLIENTES.
       01  REG-CLIENTE.
           05  CLI-CHAVE-CONTA.
               10  CLI-AGENCIA        PIC 9(04).
               10  CLI-CONTA          PIC 9(06).
           05  CLI-NOME               PIC X(30).
           05  CLI-CPF                PIC 9(11).
           05  CLI-SALDO              PIC S9(08)V99 COMP-3.
           05  CLI-STATUS-CONTA       PIC X(01).

       WORKING-STORAGE SECTION.
       01  WS-FIM-ARQUIVO        PIC X(01) VALUE "N".
       01  WS-REG-TIPO           PIC X(01).
       01  WS-STATUS-CLI              PIC X(02).
       
      *    ESTRUTURA DE DATA/HORA DO SISTEMA PARA OS LOGS
       01  WS-DATA-SISTEMA.
           05 WS-ANO             PIC 9(04).
           05 WS-MES             PIC 9(02).
           05 WS-DIA             PIC 9(02).
       01  WS-HORA-SISTEMA.
           05 WS-HOR             PIC 9(02).
           05 WS-MIN             PIC 9(02).
           05 WS-SEG             PIC 9(02).

      *    CONSTANTES DE CORES ANSI PARA O TERMINAL (NIVEL MAXIMO)
       01  WS-CORES-ANSI.
           05 WS-COR-RESET       PIC X(05) VALUE X"1B5B306D".
           05 WS-COR-VERDE       PIC X(05) VALUE X"1B5B33326D".
           05 WS-COR-VERMELHO    PIC X(05) VALUE X"1B5B33316D".
           05 WS-COR-AMARELO     PIC X(05) VALUE X"1B5B33336D".
           05 WS-COR-CIANO       PIC X(05) VALUE X"1B5B33366D".

      *    LAYOUT DO REGISTRO DE LOG
       01  WS-REG-LOG-FORMATADO.
           05 L-DATA             PIC 9(02)/9(02)/9(04).
           05 FILLER             PIC X(02) VALUE " ".
           05 L-HORA             PIC 9(02):9(02):9(02).
           05 FILLER             PIC X(02) VALUE " - ".
           05 L-CONTA            PIC X(12).
           05 FILLER             PIC X(02) VALUE " - ".
           05 L-MENSAGEM         PIC X(80).
       
       01  WS-LAYOUT-ENTRADA.
           05 REG-DETALHE.
               10 DET-TIPO       PIC X(01).
               10 DET-CPF        PIC 9(11).
               10 DET-NOME       PIC X(30).
               10 DET-AGENCIA    PIC 9(04).
               10 DET-CONTA      PIC 9(06).
               10 DET-VALOR      PIC 9(08)V99.
               10 DET-NOSSO-NUM  PIC 9(10).
               10 FILLER         PIC X(48).

       01  WS-LAYOUT-RETORNO.
           05 RET-DETALHE.
               10 R-TIPO         PIC X(01) VALUE "1".
               10 R-CPF          PIC 9(11).
               10 R-NOME         PIC X(30).
               10 R-VALOR        PIC 9(08)V99.
               10 R-OCORRENCIA   PIC 9(02).
               10 R-MENSAGEM     PIC X(40).
               10 FILLER         PIC X(26).
           05 RET-HEADER.
               10 RH-TIPO        PIC X(01) VALUE "0".
               10 RH-TEXTO       PIC X(119) VALUE "HEADER RETORNO - PROCESSAMENTO CONCLUIDO SUCESSO".
           05 RET-TRAILER.
               10 RT-TIPO        PIC X(01) VALUE "9".
               10 RT-TEXTO       PIC X(119) VALUE "TRAILER RETORNO - FINAL DO ARQUIVO CONCILIADO".

       01  WS-CONTADORES.
           05 WS-CONT-TOTAL      PIC 9(04) VALUE ZERO.
           05 WS-CONT-SUCESSO    PIC 9(04) VALUE ZERO.
           05 WS-CONT-ERRO       PIC 9(04) VALUE ZERO.
           05 WS-VALOR-TOTAL     PIC 9(10)V99 VALUE ZERO.

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           ACCEPT WS-DATA-SISTEMA FROM DATE YYYYMMDD
           ACCEPT WS-HORA-SISTEMA FROM TIME

           OPEN INPUT ARQ-ENTRADA
           OPEN OUTPUT ARQ-RETORNO
           OPEN EXTEND ARQ-LOGS
           
           OPEN I-O ARQ-CLIENTES
           IF WS-STATUS-CLI = "35"
               OPEN OUTPUT ARQ-CLIENTES
               CLOSE ARQ-CLIENTES
               OPEN I-O ARQ-CLIENTES
           END-IF
           
           DISPLAY WS-COR-CIANO 
              "=== INICIANDO MOTOR CNAB BANCARIO + CORE BANKING ===" 
              WS-COR-RESET

           PERFORM GRAVAR-LOG-SISTEMA THRU EX-GRAVAR-LOG
           
           WRITE REG-RETORNO FROM RET-HEADER
           
           PERFORM UNTIL WS-FIM-ARQUIVO = "S"
               READ ARQ-ENTRADA
                   AT END
                       MOVE "S" TO WS-FIM-ARQUIVO
                   NOT AT END
                       MOVE REG-ENTRADA(1:1) TO WS-REG-TIPO
                       PERFORM TRATAR-TIPO-REGISTRO
               END-READ
           END-PERFORM
           
           WRITE REG-RETORNO FROM RET-TRAILER
           
           PERFORM EXIBIR-RETORNO-GRAVADO
           PERFORM EXIBIR-ESTATISTICAS
           
           CLOSE ARQ-ENTRADA
           CLOSE ARQ-RETORNO
           CLOSE ARQ-CLIENTES
           CLOSE ARQ-LOGS
           STOP RUN.

       GRAVAR-LOG-SISTEMA.
           MOVE WS-DIA TO L-DIA
           MOVE WS-MES TO L-MES
           MOVE WS-ANO TO L-ANO
           MOVE WS-HOR TO L-HOR
           MOVE WS-MIN TO L-MIN
           MOVE WS-SEG TO L-SEG
           MOVE "SISTEMA" TO L-CONTA
           MOVE "INICIANDO PROCESSAMENTO DO LOTE CNAB BANCARIO" TO L-MENSAGEM
           WRITE REG-LOGS FROM WS-REG-LOG-FORMATADO
           .
       EX-GRAVAR-LOG. EXIT.

       TRATAR-TIPO-REGISTRO.
           EVALUATE WS-REG-TIPO
               WHEN "0"
                   MOVE "SISTEMA" TO L-CONTA
                   MOVE "LOG: HEADER DE ENTRADA IDENTIFICADO" TO L-MENSAGEM
                   WRITE REG-LOGS FROM WS-REG-LOG-FORMATADO
               WHEN "1"
                   MOVE REG-ENTRADA TO REG-DETALHE
                   PERFORM PROCESSAR-DETALHE
               WHEN "9"
                   MOVE "SISTEMA" TO L-CONTA
                   MOVE "LOG: TRAILER DE ENTRADA IDENTIFICADO" TO L-MENSAGEM
                   WRITE REG-LOGS FROM WS-REG-LOG-FORMATADO
               WHEN OTHER
                   MOVE "SISTEMA" TO L-CONTA
                   MOVE "LOG: TIPO DE REGISTRO DESCONHECIDO" TO L-MENSAGEM
                   WRITE REG-LOGS FROM WS-REG-LOG-FORMATADO
           END-EVALUATE.

       PROCESSAR-DETALHE.
           ADD 1 TO WS-CONT-TOTAL
           INITIALIZE RET-DETALHE
           
           MOVE DET-TIPO  TO R-TIPO
           MOVE DET-CPF   TO R-CPF
           MOVE DET-NOME  TO R-NOME
           MOVE DET-VALOR TO R-VALOR
           
           STRING "AG:" DET-AGENCIA " CC:" DET-CONTA DELIMITED BY SIZE 
                  INTO L-CONTA

           IF DET-VALOR = ZERO
               ADD 1 TO WS-CONT-ERRO
               MOVE 13 TO R-OCORRENCIA
               MOVE "ERRO: VALOR DA TRANSACAO ZERADO" TO R-MENSAGEM
               MOVE "REJEITADO - VALOR DA TRANSACAO ZERADO" TO L-MENSAGEM
               WRITE REG-LOGS FROM WS-REG-LOG-FORMATADO
               WRITE REG-RETORNO FROM RET-DETALHE
               DISPLAY WS-COR-VERMELHO "REGISTRO REJEITADO: VALOR ZERADO" WS-COR-RESET
           ELSE
               PERFORM VALIDA-LIMITE
           END-IF.

       VALIDA-LIMITE.
           IF DET-VALOR > 2000.00
               ADD 1 TO WS-CONT-ERRO
               MOVE 45 TO R-OCORRENCIA
               MOVE "REJEITADO: VALOR ACIMA DO LIMITE" TO R-MENSAGEM
               MOVE "REJEITADO - LIMITE INTEGRAL BATCH EXCEDIDO" TO L-MENSAGEM
               WRITE REG-LOGS FROM WS-REG-LOG-FORMATADO
               WRITE REG-RETORNO FROM RET-DETALHE
               DISPLAY WS-COR-AMARELO "REGISTRO REJEITADO: LIMITE EXCEDIDO" WS-COR-RESET
           ELSE
               PERFORM ATUALIZAR-CORE-BANKING
           END-IF.

       ATUALIZAR-CORE-BANKING.
           MOVE DET-AGENCIA TO CLI-AGENCIA
           MOVE DET-CONTA   TO CLI-CONTA
           
           READ ARQ-CLIENTES INVALID KEY
               MOVE DET-NOME  TO CLI-NOME
               MOVE DET-CPF   TO CLI-CPF
               MOVE DET-VALOR TO CLI-SALDO
               MOVE "A"       TO CLI-STATUS-CONTA
               WRITE REG-CLIENTE
                   INVALID KEY
                       MOVE "ERRO CRITICO AO GRAVAR NO BANCO" TO L-MENSAGEM
                       WRITE REG-LOGS FROM WS-REG-LOG-FORMATADO
               END-WRITE
               MOVE "NOVO CLIENTE CADASTRADO E SALDO INICIALIZADO" TO L-MENSAGEM
               WRITE REG-LOGS FROM WS-REG-LOG-FORMATADO
           NOT INVALID KEY
               ADD DET-VALOR TO CLI-SALDO
               REWRITE REG-CLIENTE
                   INVALID KEY
                       MOVE "ERRO CRITICO AO ATUALIZAR SALDO" TO L-MENSAGEM
                       WRITE REG-LOGS FROM WS-REG-LOG-FORMATADO
               END-REWRITE
               MOVE "CLIENTE ENCONTRADO - SALDO CONCILIADO COM SUCESSO" TO L-MENSAGEM
               WRITE REG-LOGS FROM WS-REG-LOG-FORMATADO
           END-READ.

           ADD 1 TO WS-CONT-SUCESSO
           MOVE 00 TO R-OCORRENCIA
           MOVE "TRANSACAO PROCESSADA COM SUCESSO" TO R-MENSAGEM
           ADD DET-VALOR TO WS-VALOR-TOTAL
           WRITE REG-RETORNO FROM RET-DETALHE
           DISPLAY WS-COR-VERDE "REGISTRO PROCESSADO COM SUCESSO" WS-COR-RESET.

       EXIBIR-RETORNO-GRAVADO.
           DISPLAY " "
