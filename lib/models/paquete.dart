class Paquete {
  final int id;
  final String direccionDestino;
  final bool entregado;
  final String? fotoEvidencia;
  final double? latitud;
  final double? longitud;
  final int? agenteId;

  Paquete({
    required this.id,
    required this.direccionDestino,
    this.entregado = false,
    this.fotoEvidencia,
    this.latitud,
    this.longitud,
    this.agenteId,
  });

  factory Paquete.fromJson(Map<String, dynamic> json) {
    return Paquete(
      id: json['id'] as int,
      direccionDestino: json['direccion_destino'] as String,
      entregado: json['entregado'] == 1 || json['entregado'] == true,
      fotoEvidencia: json['foto_evidencia'] as String?,
      latitud: (json['latitud'] as num?)?.toDouble(),
      longitud: (json['longitud'] as num?)?.toDouble(),
      agenteId: json['agente_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'direccion_destino': direccionDestino,
      'entregado': entregado,
      'foto_evidencia': fotoEvidencia,
      'latitud': latitud,
      'longitud': longitud,
      'agente_id': agenteId,
    };
  }

  Paquete copyWith({
    int? id,
    String? direccionDestino,
    bool? entregado,
    String? fotoEvidencia,
    double? latitud,
    double? longitud,
    int? agenteId,
  }) {
    return Paquete(
      id: id ?? this.id,
      direccionDestino: direccionDestino ?? this.direccionDestino,
      entregado: entregado ?? this.entregado,
      fotoEvidencia: fotoEvidencia ?? this.fotoEvidencia,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      agenteId: agenteId ?? this.agenteId,
    );
  }
}
