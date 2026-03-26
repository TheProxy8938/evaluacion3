class Agente {
  final int id;
  final String username;

  Agente({
    required this.id,
    required this.username,
  });

  factory Agente.fromJson(Map<String, dynamic> json) {
    return Agente(
      id: json['id'] as int,
      username: json['username'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
    };
  }
}

class TokenResponse {
  final String accessToken;
  final String tokenType;
  final int usuarioId;

  TokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.usuarioId,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      usuarioId: json['usuario_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'usuario_id': usuarioId,
    };
  }
}
