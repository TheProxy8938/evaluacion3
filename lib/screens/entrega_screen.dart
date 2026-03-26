import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../models/paquete.dart';
import '../services/api_service.dart';

class EntregaScreen extends StatefulWidget {
  final Paquete paquete;

  const EntregaScreen({
    Key? key,
    required this.paquete,
  }) : super(key: key);

  @override
  State<EntregaScreen> createState() => _EntregaScreenState();
}

class _EntregaScreenState extends State<EntregaScreen> {
  Uint8List? _fotoBytes;
  double? _latitud;
  double? _longitud;
  bool _isLoading = false;
  bool _fotoCargada = false;
  bool _ubicacionCargada = false;
  bool _yaEntregado = false;  
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Verificar si ya fue entregado
    _yaEntregado = widget.paquete.entregado;
    
    if (!_yaEntregado) {
      _obtenerUbicacion();
    }
  }

  Future<void> _obtenerUbicacion() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _mostrarError('Los servicios de ubicación están deshabilitados');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        _mostrarError('Permiso de ubicación denegado permanentemente');
        return;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition();
        setState(() {
          _latitud = position.latitude;
          _longitud = position.longitude;
          _ubicacionCargada = true;
        });
      }
    } catch (e) {
      _mostrarError('Error al obtener ubicación: $e');
    }
  }

  Future<void> _capturarFoto() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _fotoBytes = bytes;
          _fotoCargada = true;
        });
      }
    } catch (e) {
      _mostrarError('Error al capturar foto: $e');
    }
  }

  Future<void> _seleccionarFoto() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _fotoBytes = bytes;
          _fotoCargada = true;
        });
      }
    } catch (e) {
      _mostrarError('Error al seleccionar foto: $e');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _entregarPaquete() async {
    if (!_ubicacionCargada) {
      _mostrarError('Por favor, obtén la ubicación GPS');
      return;
    }

    if (_latitud == null || _longitud == null) {
      _mostrarError('Ubicación no disponible');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Codificar foto a base64 si existe
      String? fotoBase64 = null;
      if (_fotoBytes != null && _fotoBytes!.isNotEmpty) {
        fotoBase64 = base64Encode(_fotoBytes!);
        print('[FOTO] Foto codificada: ${fotoBase64.length} caracteres');
      } else {
        print('[ADVERTENCIA] No hay foto capturada');
      }

      print('[ENVIO] Enviando entrega paquete ${widget.paquete.id}');
      await ApiService.entregarPaquete(
        widget.paquete.id,
        fotoBase64,
        _latitud!,
        _longitud!,
      );

      print('[EXITO] Entrega recibida por API');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Paquete entregado exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, '/paquetes');
      }
    } catch (e) {
      _mostrarError('Error al entregar: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entregar Paquete'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Información del paquete
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Detalles del Paquete',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Chip(
                          label: Text('ID: ${widget.paquete.id}'),
                          backgroundColor: Colors.blue.shade100,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.paquete.direccionDestino,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sección de foto
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _fotoCargada ? Icons.check_circle : Icons.camera_alt,
                          color: _fotoCargada ? Colors.green : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Foto de Evidencia',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_fotoBytes != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _fotoBytes!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.camera),
                            label: const Text('Capturar'),
                            onPressed: (_isLoading || _yaEntregado) ? null : _capturarFoto,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Galería'),
                            onPressed: (_isLoading || _yaEntregado) ? null : _seleccionarFoto,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sección de ubicación
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _ubicacionCargada
                              ? Icons.check_circle
                              : Icons.location_on,
                          color: _ubicacionCargada ? Colors.green : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Ubicación GPS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_ubicacionCargada && _latitud != null && _longitud != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Latitud: ${_latitud!.toStringAsFixed(6)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Longitud: ${_longitud!.toStringAsFixed(6)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Obteniendo ubicación...',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Actualizar Ubicación'),
                        onPressed: (_isLoading || _yaEntregado) ? null : _obtenerUbicacion,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botón de entrega
            if (_yaEntregado)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Paquete Ya Entregado',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Este paquete fue entregado el ${widget.paquete.id}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Paquete Entregado'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: (_isLoading || !_ubicacionCargada)
                      ? null
                      : _entregarPaquete,
                ),
              ),
            const SizedBox(height: 24),

            // Checklist
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lista de Verificacion',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _CheckItem(
                      label: 'Foto capturada',
                      checked: _fotoCargada,
                    ),
                    const SizedBox(height: 6),
                    _CheckItem(
                      label: 'Ubicación GPS obtenida',
                      checked: _ubicacionCargada,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String label;
  final bool checked;

  const _CheckItem({
    required this.label,
    required this.checked,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          checked ? Icons.check_box : Icons.check_box_outline_blank,
          color: checked ? Colors.green : Colors.grey,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: checked ? Colors.green : Colors.grey,
            decoration: checked ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }
}
