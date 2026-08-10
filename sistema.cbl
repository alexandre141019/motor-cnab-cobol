       IDENTIFICATION DIVISION.
       PROGRAM-ID. CNAB-SENIOR.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ARQ-ENTRADA ASSIGN TO "transacoes.txt"
               ORGANIZATION IS LINE SEQUENTIAL.
               
           SELECT ARQ-RETORNO ASSIGN TO "retorno.txt"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  ARQ-ENTRADA.
       01  REG-ENTRADA           PIC X(120).

       FD  ARQ-RETORNO.
       01  REG-RETORNO           PIC X(120).

       WORKING-STORAGE SECTION.
       01  WS-FIM-ARQUIVO        PIC X(01) VALUE "N".
       01  WS-REG-TIPO           PIC X(01).
       
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
           DISPLAY "=== INICIANDO MOTOR CNAB BANCARIO (NIVEL SENIOR) ==="
           
           OPEN INPUT ARQ-ENTRADA
           OPEN OUTPUT ARQ-RETORNO
           
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
           
           PERFORM EXIBIR-ESTATISTICAS
           
           CLOSE ARQ-ENTRADA
           CLOSE ARQ-RETORNO
           STOP RUN.

       TRATAR-TIPO-REGISTRO.
           EVALUATE WS-REG-TIPO
               WHEN "0"
                   DISPLAY "LOG: HEADER DE ENTRADA IDENTIFICADO"
               WHEN "1"
                   MOVE REG-ENTRADA TO REG-DETALHE
                   PERFORM PROCESSAR-DETALHE
               WHEN "9"
                   DISPLAY "LOG: TRAILER DE ENTRADA IDENTIFICADO"
               WHEN OTHER
                   DISPLAY "LOG: TIPO DE REGISTRO DESCONHECIDO"
           END-EVALUATE.

       PROCESSAR-DETALHE.
           ADD 1 TO WS-CONT-TOTAL
           INITIALIZE RET-DETALHE
           
           MOVE DET-TIPO  TO R-TIPO
           MOVE DET-CPF   TO R-CPF
           MOVE DET-NOME  TO R-NOME
           MOVE DET-VALOR TO R-VALOR
           
           IF DET-VALOR = ZERO
               ADD 1 TO WS-CONT-ERRO
               MOVE 13 TO R-OCORRENCIA
               MOVE "ERRO: VALOR DA TRANSACAO ZERADO" TO R-MENSAGEM
               DISPLAY "REGISTRO REJEITADO: VALOR ZERADO"
           ELSE
               PERFORM VALIDA-LIMITE
           END-IF
           
           WRITE REG-RETORNO FROM RET-DETALHE.

       VALIDA-LIMITE.
           IF DET-VALOR > 2000.00
               ADD 1 TO WS-CONT-ERRO
               MOVE 45 TO R-OCORRENCIA
               MOVE "REJEITADO: VALOR ACIMA DO LIMITE" TO R-MENSAGEM
               DISPLAY "REGISTRO REJEITADO: LIMITE EXCEDIDO"
           ELSE
               ADD 1 TO WS-CONT-SUCESSO
               MOVE 00 TO R-OCORRENCIA
               MOVE "TRANSACAO PROCESSADA COM SUCESSO" TO R-MENSAGEM
               ADD DET-VALOR TO WS-VALOR-TOTAL
               DISPLAY "REGISTRO PROCESSADO COM SUCESSO"
           END-IF.

       EXIBIR-ESTATISTICAS.
           DISPLAY "----------------------------------------"
           DISPLAY "PROCESSAMENTO BATCH CONCLUIDO!"
           DISPLAY "TOTAL DETALHES PROCESSADOS: " WS-CONT-TOTAL
           DISPLAY "VALOR TOTAL LIQUIDADO.....: R$ " WS-VALOR-TOTAL
           DISPLAY "----------------------------------------".
