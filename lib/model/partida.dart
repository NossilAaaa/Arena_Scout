class Partida {
  String id;
  String titulo;
  String timeCasa; // Ex: Grêmio
  String timeFora; // Ex: Internacional
  int golsCasa;
  int golsFora;
  double latitude;  // Para o mapa
  double longitude; // Para o mapa
  String analiseIA; // Relatório que o Gemini vai gerar

  Partida({
    required this.id,
    required this.titulo,
    required this.timeCasa,
    required this.timeFora,
    required this.golsCasa,
    required this.golsFora,
    required this.latitude,
    required this.longitude,
    required this.analiseIA,
  });

  // Converte o objeto para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'timeCasa': timeCasa,
      'timeFora': timeFora,
      'golsCasa': golsCasa,
      'golsFora': golsFora,
      'latitude': latitude,
      'longitude': longitude,
      'analiseIA': analiseIA,
    };
  }

  // Cria o objeto a partir dos dados do Firestore
  factory Partida.fromMap(Map<String, dynamic> map, String id) {
    return Partida(
      id: id,
      titulo: map['titulo'] ?? '',
      timeCasa: map['timeCasa'] ?? '',
      timeFora: map['timeFora'] ?? '',
      golsCasa: map['golsCasa']?.toInt() ?? 0,
      golsFora: map['golsFora']?.toInt() ?? 0,
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      analiseIA: map['analiseIA'] ?? '',
    );
  }
}