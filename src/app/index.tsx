import AsyncStorage from '@react-native-async-storage/async-storage';
import React, { useEffect, useState } from 'react';
import {
  Alert,
  FlatList,
  Modal,
  SafeAreaView,
  StatusBar,
  StyleSheet,
  Text,
  TouchableOpacity,
  View
} from 'react-native';
import { FormularioGasto } from '../components/FormularioGasto';
import { GraficoGastos } from '../components/GraficoGastos';
import { ItemGasto } from '../components/ItemGasto';
import { Gasto } from '../types/gasto';

const ASYNC_STORAGE_KEY = '@financas_praticas:gastos';

export default function Index() {
  const [gastos, setGastos] = useState<Gasto[]>([]);
  
  // Estados para controlar o Modal de exclusão individual
  const [modalExcluirVisivel, setModalExcluirVisivel] = useState(false);
  const [gastoParaExcluir, setGastoParaExcluir] = useState<Gasto | null>(null);

  useEffect(() => {
    async function carregarGastos() {
      try {
        const dadosSalvos = await AsyncStorage.getItem(ASYNC_STORAGE_KEY);
        if (dadosSalvos) {
          setGastos(JSON.parse(dadosSalvos));
        }
      } catch (error) {
        Alert.alert('Erro', 'Não foi possível carregar os dados.');
      }
    }
    carregarGastos();
  }, []);

  const adicionarGasto = async (descricao: string, valor: number) => {
    const novoGasto: Gasto = {
      id: Math.random().toString(),
      descricao,
      valor
    };

    try {
      const novosGastos = [...gastos, novoGasto];
      setGastos(novosGastos);
      await AsyncStorage.setItem(ASYNC_STORAGE_KEY, JSON.stringify(novosGastos));
    } catch (error) {
      Alert.alert('Erro', 'Não foi possível salvar o gasto.');
    }
  };

  // Abre a janela flutuante guardando qual gasto o usuário escolheu
  const acionarExcluirGasto = (gasto: Gasto) => {
    setGastoParaExcluir(gasto);
    setModalExcluirVisivel(true);
  };

  // Confirmação final da exclusão por dentro do Modal
  const confirmarExcluirGasto = async () => {
    if (!gastoParaExcluir) return;

    try {
      const gastosFiltrados = gastos.filter(g => g.id !== gastoParaExcluir.id);
      setGastos(gastosFiltrados);
      await AsyncStorage.setItem(ASYNC_STORAGE_KEY, JSON.stringify(gastosFiltrados));
      
      // Fecha a janelinha e limpa o estado
      setModalExcluirVisivel(false);
      setGastoParaExcluir(null);
    } catch (error) {
      Alert.alert('Erro', 'Não foi possível excluir o item.');
    }
  };

  const zerarMes = () => {
    Alert.alert(
      'Zerar Mês',
      'Tem certeza que deseja apagar todas as finanças deste mês?',
      [
        { text: 'Cancelar', style: 'cancel' },
        { 
          text: 'Sim, Apagar Tudo', 
          style: 'destructive',
          onPress: async () => {
            try {
              setGastos([]);
              await AsyncStorage.removeItem(ASYNC_STORAGE_KEY);
            } catch (error) {
              Alert.alert('Erro', 'Não foi possível zerar os dados.');
            }
          }
        }
      ]
    );
  };

  const totalGasto = gastos.reduce((sum, item) => sum + item.valor, 0);

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="light-content" />
      
      {/* Cabeçalho */}
      <View style={styles.header}>
        <View style={styles.headerTopRow}>
          <Text style={styles.tituloHeader}>Total Gasto</Text>
          {gastos.length > 0 && (
            <TouchableOpacity style={styles.botaoZerar} onPress={zerarMes}>
              <Text style={styles.textoBotaoZerar}>Zerar Mês 🔄</Text>
            </TouchableOpacity>
          )}
        </View>
        <Text style={styles.saldo}>R$ {totalGasto.toFixed(2)}</Text>
      </View>

      <FormularioGasto onAdicionarGasto={adicionarGasto} />

      <GraficoGastos gastos={gastos} />

      <FlatList 
        data={gastos}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => (
          // Agora passamos a função que aciona o Modal passando o objeto inteiro
          <ItemGasto item={item} onExcluirGasto={() => acionarExcluirGasto(item)} />
        )}
        contentContainerStyle={styles.listaContainer}
      />

      {/* 🔥 JANELA MODAL PERSONALIZADA DE CONFIRMAÇÃO 🔥 */}
      <Modal
        animationType="fade"
        transparent={true}
        visible={modalExcluirVisivel}
        onRequestClose={() => setModalExcluirVisivel(false)}
      >
        <View style={styles.modalFundo}>
          <View style={styles.modalContainer}>
            <Text style={styles.modalTitulo}>Excluir Registro?</Text>
            
            <Text style={styles.modalTexto}>
              Deseja realmente apagar o gasto "{gastoParaExcluir?.descricao}" no valor de 
              <Text style={{fontWeight: 'bold', color: '#EF4444'}}> R$ {gastoParaExcluir?.valor.toFixed(2)}</Text>?
            </Text>

            <View style={styles.modalBotoesRow}>
              <TouchableOpacity 
                style={[styles.modalBotao, styles.modalBotaoCancelar]} 
                onPress={() => setModalExcluirVisivel(false)}
              >
                <Text style={styles.modalTextoBotaoCancelar}>Cancelar</Text>
              </TouchableOpacity>

              <TouchableOpacity 
                style={[styles.modalBotao, styles.modalBotaoConfirmar]} 
                onPress={confirmarExcluirGasto}
              >
                <Text style={styles.modalTextoBotaoConfirmar}>Excluir</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#111827',
  },
  header: {
    backgroundColor: '#00FF7F',
    padding: 24,
    borderBottomLeftRadius: 16,
    borderBottomRightRadius: 16,
    paddingTop: 50,
  },
  headerTopRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    width: '100%',
  },
  tituloHeader: {
    color: '#064E3B',
    fontSize: 16,
    fontWeight: '600',
  },
  saldo: {
    color: '#064E3B',
    fontSize: 32,
    fontWeight: 'bold',
    marginTop: 8,
    textAlign: 'center',
  },
  botaoZerar: {
    backgroundColor: '#EF4444',
    paddingVertical: 6,
    paddingHorizontal: 12,
    borderRadius: 20,
  },
  textoBotaoZerar: {
    color: '#FFFFFF',
    fontSize: 12,
    fontWeight: 'bold',
  },
  listaContainer: {
    paddingHorizontal: 16,
  },
  /* Estilos da Janela Modal */
  modalFundo: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.6)', // Escurece o app ao fundo
    justifyContent: 'center',
    alignItems: 'center',
    padding: 24,
  },
  modalContainer: {
    backgroundColor: '#1F2937', // Combina com os cards do tema escuro
    width: '100%',
    maxWidth: 320,
    borderRadius: 16,
    padding: 24,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#374151',
  },
  modalTitulo: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#FFFFFF',
    marginBottom: 12,
  },
  modalTexto: {
    fontSize: 15,
    color: '#9CA3AF',
    textAlign: 'center',
    marginBottom: 24,
    lineHeight: 22,
  },
  modalBotoesRow: {
    flexDirection: 'row',
    gap: 12,
    width: '100%',
  },
  modalBotao: {
    flex: 1,
    padding: 12,
    borderRadius: 8,
    alignItems: 'center',
  },
  modalBotaoCancelar: {
    backgroundColor: '#374151',
  },
  modalBotaoConfirmar: {
    backgroundColor: '#EF4444',
  },
  modalTextoBotaoCancelar: {
    color: '#E5E7EB',
    fontWeight: '600',
    fontSize: 15,
  },
  modalTextoBotaoConfirmar: {
    color: '#FFFFFF',
    fontWeight: 'bold',
    fontSize: 15,
  },
});
