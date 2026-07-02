import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:io';

class AiService {

  Future<String> gerarAnalise(String timeCasa, int golsCasa, String timeFora, int golsFora) async {
    final prompt = '''
    Atue como um comentarista esportivo especializado em futebol brasileiro. 
    Faça uma análise técnica e curta (máximo de 3 frases) com os principais destaques da partida, sobre o seguinte placar: 
    $timeCasa $golsCasa x $golsFora $timeFora.
    ''';

    // Loop inteligente: Tenta conectar até 3 vezes caso o servidor esteja sobrecarregado
    for (int tentativa = 1; tentativa <= 3; tentativa++) {
      try {
        final gemini = Gemini.instance;

        final response = await gemini.text(prompt);

        final textoResposta = response?.output ?? '';

        if (textoResposta.isEmpty) {
          throw Exception('Resposta vazia da IA.');
        }

        return textoResposta;

      } catch (e) {
        final erro = e.toString();
        print('Tentativa $tentativa — Erro Gemini: $erro');

        if (erro.contains('quota') || erro.contains('429')) {
          return 'Erro: O limite de tokens gratuitos da IA foi atingido. Tente novamente mais tarde.';
        }

        final e503 = erro.contains('503') || erro.contains('high demand') || erro.contains('UNAVAILABLE');
        if (e503 && tentativa < 3) {
          print('Servidor ocupado. Aguardando ${tentativa * 2}s antes de tentar novamente...');

          await Future.delayed(Duration(seconds: tentativa * 2));
          continue;
        }

        if (e is SocketException || erro.contains('SocketException') || erro.contains('Failed host lookup')) {
          return 'Erro de conexão: Verifique sua internet e tente novamente.';
        }

        return 'A Inteligência Artificial está com alta demanda de acessos no momento. Tente gerar uma nova análise mais tarde.';
      }
    }

    return 'Serviço da IA indisponível após 3 tentativas.';
  }
}