import * as fs from 'fs';
import * as path from 'path';
import { fileURLToPath } from 'url';

// Resolve o caminho da pasta atual de forma moderna para ES Modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Define a estrutura profissional da transação para exportação (JSON/API)
interface TransacaoProcessada {
    cpf: string;
    nome: string;
    valor: number;
    codigoOcorrencia: string;
    mensagemStatus: string;
}

function processarRetornoCobol() {
    // Caminho para ler a saída gerada pelo contêiner COBOL
    const caminhoArquivo = path.join(__dirname, '..', 'retorno.txt');

    if (!fs.existsSync(caminhoArquivo)) {
        console.error("❌ Arquivo retorno.txt não encontrado na raiz! Certifique-se de exportá-lo do Docker.");
        return;
    }

    const conteudo = fs.readFileSync(caminhoArquivo, 'utf-8');
    const linhas = conteudo.split('\n');
    const transacoes: TransacaoProcessada[] = [];

    console.log("🚀 [TypeScript] Iniciando leitura e parsing do Retorno COBOL...");

    linhas.forEach((linha) => {
        if (linha.length < 50) return;

        const tipoRegistro = linha.substring(0, 1);

        if (tipoRegistro === '0') {
            console.log(`📌 Header Detectado: ${linha.substring(1).trim()}`);
        } else if (tipoRegistro === '1') {
            // Mapeamento exato baseado no PIC X / PIC 9 do seu WORKING-STORAGE do COBOL
            const cpf = linha.substring(1, 12).trim();
            const nome = linha.substring(12, 42).trim();
            
            // Tratamento sênior de decimais implícitos do COBOL (99 no final)
            const valorBruto = linha.substring(42, 52).trim();
            const valorDecimal = parseFloat(valorBruto) / 100;

            const ocorrencia = linha.substring(52, 54).trim();
            const mensagem = linha.substring(54, 94).trim();

            transacoes.push({
                cpf,
                nome,
                valor: valorDecimal,
                codigoOcorrencia: ocorrencia,
                mensagemStatus: mensagem
            });
        } else if (tipoRegistro === '9') {
            console.log(`📌 Trailer Detectado: ${linha.substring(1).trim()}`);
        }
    });

    console.log("\n📊 [TypeScript] Dados convertidos em JSON com Sucesso para consumo de APIs/Front-end:");
    console.dir(transacoes, { depth: null });
}

processarRetornoCobol();
