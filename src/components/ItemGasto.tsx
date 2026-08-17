import React from 'react';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { Gasto } from '../types/gasto';

interface ItemGastoProps {
  item: Gasto;
  onExcluirGasto: () => void; // Adicionamos isso para corrigir o erro!
}

export function ItemGasto({ item, onExcluirGasto }: ItemGastoProps) {
  return (
    <View style={styles.itemGasto}>
      <View style={styles.infoContainer}>
        <Text style={styles.textoItem}>{item.descricao}</Text>
        <Text style={styles.valorItem}>R$ {item.valor.toFixed(2)}</Text>
      </View>
      
      {/* Botão de Lixeira */}
      <TouchableOpacity style={styles.botaoExcluir} onPress={onExcluirGasto}>
        <Text style={styles.textoExcluir}>🗑️</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  itemGasto: {
    backgroundColor: '#1F2937',
    padding: 16,
    borderRadius: 8,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
    borderLeftWidth: 4,
    borderLeftColor: '#EF4444',
  },
  infoContainer: {
    flex: 1,
  },
  textoItem: {
    fontSize: 16,
    color: '#FFFFFF',
    fontWeight: '500',
  },
  valorItem: {
    fontSize: 16,
    color: '#EF4444',
    fontWeight: 'bold',
    marginTop: 2,
  },
  botaoExcluir: {
    padding: 8,
    marginLeft: 8,
  },
  textoExcluir: {
    fontSize: 18,
  },
});
