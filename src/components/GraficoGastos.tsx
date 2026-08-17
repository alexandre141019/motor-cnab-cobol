import React from 'react';
import { Dimensions, StyleSheet, Text, View } from 'react-native';
import Svg, { Rect } from 'react-native-svg';
import { Gasto } from '../types/gasto';

interface GraficoGastosProps {
  gastos: Gasto[];
}

export function GraficoGastos({ gastos }: GraficoGastosProps) {
  const larguraTela = Dimensions.get('window').width - 64;
  const alturaGrafico = 100;

  // Pega os 4 maiores gastos para exibir no gráfico
  const maioresGastos = [...gastos]
    .sort((a, b) => b.valor - a.valor)
    .slice(0, 4);

  const valorMaximo = maioresGastos.length > 0 
    ? Math.max(...maioresGastos.map(g => g.valor)) 
    : 1;

  return (
    <View style={styles.container}>
      <Text style={styles.titulo}>Maiores Despesas</Text>
      
      {maioresGastos.length === 0 ? (
        <Text style={styles.textoVazio}>Nenhum gasto cadastrado para exibir.</Text>
      ) : (
        <View style={styles.graficoContainer}>
          {maioresGastos.map((gasto, index) => {
            // Calcula a largura da barra proporcionalmente ao valor do gasto
            const larguraBarra = (gasto.valor / valorMaximo) * larguraTela;

            return (
              <View key={gasto.id} style={styles.barraRow}>
                <View style={styles.textosRow}>
                  <Text style={styles.labelGasto} numberOfLines={1}>
                    {gasto.descricao}
                  </Text>
                  <Text style={styles.valorGasto}>R$ {gasto.valor.toFixed(2)}</Text>
                </View>
                
                <Svg height="12" width={larguraTela}>
                  {/* Fundo da barra */}
                  <Rect x="0" y="0" width={larguraTela} height="12" rx="6" fill="#374151" />
                  {/* Barra preenchida */}
                  <Rect x="0" y="0" width={larguraBarra} height="12" rx="6" fill="#00FF7F" />
                </Svg>
              </View>
            );
          })}
        </View>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#1F2937',
    marginHorizontal: 16,
    marginBottom: 16,
    padding: 16,
    borderRadius: 12,
  },
  titulo: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 12,
  },
  textoVazio: {
    color: '#9CA3AF',
    fontSize: 14,
    textAlign: 'center',
    paddingVertical: 10,
  },
  graficoContainer: {
    gap: 12,
  },
  barraRow: {
    gap: 4,
  },
  textosRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  labelGasto: {
    color: '#E5E7EB',
    fontSize: 14,
    maxWidth: '70%',
  },
  valorGasto: {
    color: '#00FF7F',
    fontSize: 14,
    fontWeight: '600',
  },
});
