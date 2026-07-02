import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../model/partida.dart';
import '../service/partidaDao.dart';
import '../service/ai_service.dart';

class PartidaForm extends StatefulWidget {
  const PartidaForm({super.key});

  @override
  State<PartidaForm> createState() => _PartidaFormState();
}

class _PartidaFormState extends State<PartidaForm> {
  final _formKey = GlobalKey<FormState>();
  final PartidaDao _dao = PartidaDao();

  final _tituloController = TextEditingController();
  final _timeCasaController = TextEditingController();
  final _timeForaController = TextEditingController();
  final _golsCasaController = TextEditingController();
  final _golsForaController = TextEditingController();

  double _latitude = 0.0;
  double _longitude = 0.0;
  bool _isGettingLocation = false;
  bool _isSaving = false;

  // Função para capturar o GPS (adaptada do seu projeto de mapas)
  Future<void> _capturarLocalizacao() async {
    setState(() => _isGettingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão de localização negada.');
        }
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Localização capturada!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      try {
        print("--- INICIANDO SALVAMENTO ---");
        final String timeC = _timeCasaController.text;
        final String timeF = _timeForaController.text;
        final int golsC = int.tryParse(_golsCasaController.text) ?? 0;
        final int golsF = int.tryParse(_golsForaController.text) ?? 0;

        print("1. Chamando o Gemini...");
        final AiService aiService = AiService();
        String analiseGerada = await aiService.gerarAnalise(timeC, golsC, timeF, golsF);
        print("2. Resposta do Gemini: $analiseGerada");

        final novaPartida = Partida(
          id: '',
          titulo: _tituloController.text,
          timeCasa: timeC,
          timeFora: timeF,
          golsCasa: golsC,
          golsFora: golsF,
          latitude: _latitude,
          longitude: _longitude,
          analiseIA: analiseGerada,
        );

        print("3. Enviando para o Firestore...");
        // O .timeout() é a mágica! Se o Firebase não responder em 10s, ele cancela e mostra o erro.
        await _dao.add(novaPartida).timeout(const Duration(seconds: 10));

        print("4. Partida salva com sucesso!");
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        print("ERRO CAPTURADO: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao salvar: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Partida'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título (Ex: Final do Campeonato)', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _timeCasaController,
                      decoration: const InputDecoration(labelText: 'Time Casa', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _golsCasaController,
                      decoration: const InputDecoration(labelText: 'Gols Casa', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _timeForaController,
                      decoration: const InputDecoration(labelText: 'Time Fora', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _golsForaController,
                      decoration: const InputDecoration(labelText: 'Gols Fora', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // O Botão Mágico da Geolocalização
              OutlinedButton.icon(
                icon: _isGettingLocation ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.location_on),
                label: Text(_latitude == 0.0 ? 'Capturar Localização Atual (GPS)' : 'GPS Capturado: ${_latitude.toStringAsFixed(2)}, ${_longitude.toStringAsFixed(2)}'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16), foregroundColor: Colors.blue[700]),
                onPressed: _isGettingLocation ? null : _capturarLocalizacao,
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, padding: const EdgeInsets.all(16)),
                onPressed: _isSaving ? null : _salvar,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Salvar Partida', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}