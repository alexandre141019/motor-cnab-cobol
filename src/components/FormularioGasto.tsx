import React, { useState } from 'react';
import { Keyboard, StyleSheet, Text, TextInput, TouchableOpacity, View } from 'react-native';

interface FormularioGastoProps {
  onAdicionarGasto: (descricao: string, valor: number) => void;
}

export function FormularioGasto({ onAdicionarGasto }: FormularioGastoProps) {
  const [descricao, setDescricao] = useState('');
  const [valor, setValor] = useState('');

  const lidarComEnvio = () => {
    if (!descricao || !valor) return;
    
    onAdicionarGasto(descricao, parseFloat(valor));
    
    setDescricao('');
    setValor('');
    
    // Esse comando fecha o teclado do iPhone na hora!
    Keyboard.dismiss();
  };

  return (
    <View style={styles.formulario}>
      <TextInput 
        style={styles.input}
        placeholder="Onde você gastou? (Ex: Mercado)"
        placeholderTextColor="#9CA3AF"
        value={descricao}
        onChangeText={setDescricao}
      />
      <TextInput 
        style={styles.input}
        placeholder="Valor (Ex: 45.90)"
        placeholderTextColor="#9CA3AF"
        keyboardType="numeric"
        value={valor}
        onChangeText={setValor}
      />
      <TouchableOpacity style={styles.botao} onPress={lidarComEnvio}>
        <Text style={styles.textoBotao}>Adicionar Gasto</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  formulario: {
    padding: 20,
    backgroundColor: '#1F2937',
    margin: 16,
    borderRadius: 12,
  },
  input: {
    borderWidth: 1,
    borderColor: '#374151',
    padding: 12,
    borderRadius: 8,
    marginBottom: 12,
    fontSize: 16,
    backgroundColor: '#111827',
    color: '#FFFFFF',
  },
  botao: {
    backgroundColor: '#00FF7F',
    padding: 14,
    borderRadius: 8,
    alignItems: 'center',
  },
  textoBotao: {
    color: '#064E3B',
    fontSize: 16,
    fontWeight: 'bold',
  },
});
