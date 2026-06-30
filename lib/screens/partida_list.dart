import 'package:flutter/material.dart';
import '../model/partida.dart';
import '../service/partidaDao.dart';
import 'partida_form.dart';

class PartidaList extends StatefulWidget {
  const PartidaList({super.key});

  @override
  State<PartidaList> createState() => _PartidaListState();
}

class _PartidaListState extends State<PartidaList> {
  final PartidaDao _dao = PartidaDao();
  List<Partida> _partidas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarPartidas();
  }

  Future<void> _carregarPartidas() async {
    setState(() => _isLoading = true);
    final lista = await _dao.getList();
    setState(() {
      _partidas = lista;
      _isLoading = false;
    });
  }

  void _excluirPartida(String id) async {
    await _dao.delete(id);
    _carregarPartidas(); // Atualiza a lista após excluir
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ArenaScout: Partidas'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () async {
          // Vai para o formulário e recarrega a lista quando voltar
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PartidaForm()),
          );
          _carregarPartidas();
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _partidas.isEmpty
          ? const Center(child: Text("Nenhuma partida registrada ainda."))
          : ListView.builder(
        itemCount: _partidas.length,
        itemBuilder: (context, index) {
          final p = _partidas[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 3,
            child: ListTile(
              leading: const Icon(Icons.sports_soccer, color: Colors.green, size: 40),
              title: Text(p.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                '${p.timeCasa} ${p.golsCasa} x ${p.golsFora} ${p.timeFora}\n📍 GPS: ${p.latitude.toStringAsFixed(3)}, ${p.longitude.toStringAsFixed(3)}',
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _excluirPartida(p.id),
              ),
            ),
          );
        },
      ),
    );
  }
}