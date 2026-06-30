import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/partida.dart';

class PartidaDao {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _colecao = 'partidas';

  Future<void> add(Partida partida) async {
    try {
      await _firestore.collection(_colecao).add(partida.toMap());
    } catch (e) {
      print('Erro ao adicionar partida: $e');
    }
  }

  Future<void> update(Partida partida) async {
    try {
      await _firestore.collection(_colecao).doc(partida.id).update(partida.toMap());
    } catch (e) {
      print('Erro ao atualizar partida: $e');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _firestore.collection(_colecao).doc(id).delete();
    } catch (e) {
      print('Erro ao excluir partida: $e');
    }
  }

  Future<List<Partida>> getList() async {
    try {
      final snapshot = await _firestore.collection(_colecao).get();
      final lista = <Partida>[];
      for (var doc in snapshot.docs) {
        lista.add(Partida.fromMap(doc.data(), doc.id));
      }
      return lista;
    } catch (e) {
      print('Erro ao buscar dados: $e');
      return [];
    }
  }
}