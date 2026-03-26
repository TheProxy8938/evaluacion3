import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/agente.dart';
import '../models/paquete.dart';

class ApiService {
  // Cambiar a tu IP local o dominio si es necesario
  static const String baseUrl = 'http://localhost:8000';
  // Para pruebas en emulador Android: http://10.0.2.2:8000
  // Para pruebas en dispositivo físico: http://<tu-ip-local>:8000

  static String? _accessToken;
  static int? _usuarioId;

  // Getter para el token
  static String? get accessToken => _accessToken;
  static int? get usuarioId => _usuarioId;

  /// Cargar token guardado desde SharedPreferences
  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _usuarioId = prefs.getInt('usuario_id');
  }

  /// Guardar token en SharedPreferences
  static Future<void> saveToken(String token, int id) async {
    _accessToken = token;
    _usuarioId = id;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    await prefs.setInt('usuario_id', id);
  }

  /// Limpiar token (logout)
  static Future<void> clearToken() async {
    _accessToken = null;
    _usuarioId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('usuario_id');
  }

  /// Verificar si hay sesión activa
  static bool isLoggedIn() => _accessToken != null;

  // ==================== AUTENTICACIÓN ====================

  /// Login de agente
  static Future<TokenResponse> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout en la conexión'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['access_token'], data['usuario_id']);
        return TokenResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Error en el login');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  /// Registrar nuevo agente
  static Future<TokenResponse> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout en la conexión'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['access_token'], data['usuario_id']);
        return TokenResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Error en el registro');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  /// Obtener información del usuario actual
  static Future<Agente> getCurrentUser() async {
    if (_accessToken == null) {
      throw Exception('No hay sesión activa');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return Agente.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al obtener usuario');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ==================== PAQUETES ====================

  /// Obtener lista de paquetes sin asignar
  static Future<List<Paquete>> getPaquetes() async {
    if (_accessToken == null) {
      throw Exception('No hay sesión activa');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/paquetes'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((p) => Paquete.fromJson(p)).toList();
      } else {
        throw Exception('Error al obtener paquetes');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Obtener paquetes asignados a un agente
  static Future<List<Paquete>> getPaquetesAsignados(int agenteId) async {
    if (_accessToken == null) {
      throw Exception('No hay sesión activa');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/paquetes?agente_id=$agenteId'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((p) => Paquete.fromJson(p)).toList();
      } else {
        throw Exception('Error al obtener paquetes');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Obtener detalles de un paquete específico
  static Future<Paquete> getPaquete(int paqueteId) async {
    if (_accessToken == null) {
      throw Exception('No hay sesión activa');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/paquetes/$paqueteId'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return Paquete.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Paquete no encontrado');
      } else {
        throw Exception('Error al obtener paquete');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Registrar entrega de un paquete
  static Future<Map<String, dynamic>> entregarPaquete(
    int paqueteId,
    String? fotoBase64,
    double latitud,
    double longitud,
  ) async {
    if (_accessToken == null) {
      throw Exception('No hay sesión activa');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/paquetes/$paqueteId/entregar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({
          'paquete_id': paqueteId,
          'foto_base64': fotoBase64,
          'latitud': latitud,
          'longitud': longitud,
        }),
      ).timeout(const Duration(seconds: 30)); // Timeout más largo para carga de foto

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Error en la entrega');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Asignar paquete a un agente
  static Future<Map<String, dynamic>> asignarPaquete(
    int paqueteId,
    int agenteId,
  ) async {
    if (_accessToken == null) {
      throw Exception('No hay sesión activa');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/paquetes/$paqueteId/asignar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({
          'agente_id': agenteId,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al asignar paquete');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Validar conexión a la API
  static Future<bool> checkConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Obtener detalles de paquete con foto en base64
  static Future<Paquete> getPaqueteConFoto(int paqueteId) async {
    if (_accessToken == null) {
      throw Exception('No hay sesión activa');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/paquetes/$paqueteId'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Paquete.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Paquete no encontrado');
      } else {
        throw Exception('Error al obtener paquete');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

