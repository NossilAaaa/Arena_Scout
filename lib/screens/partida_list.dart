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
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final lista = await _dao.getList();

      if (mounted) {
        setState(() {
          _partidas = lista;
        });
      }
    } catch (e) {
      print("Erro ao carregar a lista: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

          // Substituição para o Card expansível
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              shape: const Border(), // Remove bordas extras ao expandir
              leading: const Icon(Icons.sports_soccer, color: Colors.green, size: 40),
              title: Text(
                p.titulo,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    '${p.timeCasa} ${p.golsCasa} x ${p.golsFora} ${p.timeFora}',
                    style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        'GPS: ${p.latitude.toStringAsFixed(3)}, ${p.longitude.toStringAsFixed(3)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              children: [
                // Balão de texto da Inteligência Artificial
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome, size: 18, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Análise Tática - IA',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          p.analiseIA.isNotEmpty
                              ? p.analiseIA
                              : 'Nenhuma análise gerada para esta partida.',
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Botão Excluir protegido dentro do menu expansível
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _excluirPartida(p.id),
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      label: const Text('Excluir Partida', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}