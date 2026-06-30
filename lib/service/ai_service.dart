import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';

class AiService {
  static const String _apiKey = 'AIzaSyD8g41GjayV95uhhAiQFzUmc7oEXQJAZaw';
  //static const String _apiKey = 'AIzaSyCk9YSVJ4Y0RWWW1AcXSfkuxsFMdtanpB0';
  Future<String> gerarAnalise(String timeCasa, int golsCasa, String timeFora, int golsFora) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        // LIMITADOR DE TOKENS: Controla o tamanho da resposta e o custo
        generationConfig: GenerationConfig(
          maxOutputTokens: 100, // Limita a resposta a aproximadamente 100 tokens
          temperature: 0.5,     // Controla a criatividade (0.0 = robótico, 1.0 = muito criativo)
        ),
      );

      final prompt = '''
      Atue como um comentarista esportivo especializado em futebol brasileiro. 
      Faça uma análise técnica e curta (máximo de 3 frases) sobre o seguinte placar: 
      $timeCasa $golsCasa x $golsFora $timeFora.
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      return response.text ?? 'Análise gerada, mas o texto retornou vazio.';

    } on GenerativeAIException catch (e) {
      print('Erro da API Gemini: $e');
      if (e.toString().contains('quota') || e.toString().contains('429')) {
        return 'Erro: O limite de tokens gratuitos da IA foi atingido. Tente novamente mais tarde.';
      }
      return 'Erro na IA: Não foi possível processar a análise técnica neste momento.';

    } on SocketException catch (_) {
      return 'Erro de conexão: Verifique sua internet e tente novamente.';

    } catch (e) {
      print('Erro desconhecido: $e');
      return 'Ocorreu um erro inesperado ao conectar com a IA.';
    }
  }
}