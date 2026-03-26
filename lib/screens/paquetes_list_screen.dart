import 'package:flutter/material.dart';
import '../models/paquete.dart';
import '../services/api_service.dart';

class PaquetesListScreen extends StatefulWidget {
  const PaquetesListScreen({Key? key}) : super(key: key);

  @override
  State<PaquetesListScreen> createState() => _PaquetesListScreenState();
}

class _PaquetesListScreenState extends State<PaquetesListScreen> {
  late Future<List<Paquete>> _paquetesFuture;
  String _filterMode = 'asignados'; // 'asignados' o 'disponibles'

  @override
  void initState() {
    super.initState();
    _loadPaquetes();
  }

  void _loadPaquetes() {
    setState(() {
      if (_filterMode == 'asignados') {
        _paquetesFuture = ApiService.getPaquetesAsignados(ApiService.usuarioId ?? 0);
      } else {
        _paquetesFuture = ApiService.getPaquetes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paquetes'),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPaquetes,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ApiService.clearToken();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            color: Colors.blue.shade50,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'asignados',
                        label: Text('Asignados'),
                        icon: Icon(Icons.check_circle),
                      ),
                      ButtonSegment(
                        value: 'disponibles',
                        label: Text('Disponibles'),
                        icon: Icon(Icons.local_shipping),
                      ),
                    ],
                    selected: {_filterMode},
                    onSelectionChanged: (Set<String> selection) {
                      setState(() {
                        _filterMode = selection.first;
                      });
                      _loadPaquetes();
                    },
                  ),
                ),
              ],
            ),
          ),

          // Lista de paquetes
          Expanded(
            child: FutureBuilder<List<Paquete>>(
              future: _paquetesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadPaquetes,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                final paquetes = snapshot.data ?? [];

                if (paquetes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _filterMode == 'asignados'
                              ? 'No hay paquetes asignados'
                              : 'No hay paquetes disponibles',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: paquetes.length,
                  itemBuilder: (context, index) {
                    final paquete = paquetes[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/entrega',
                          arguments: paquete,
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Paquete #${paquete.id}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          paquete.direccionDestino,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (paquete.entregado)
                                    const Chip(
                                      label: Text('Entregado'),
                                      backgroundColor: Colors.green,
                                      labelStyle: TextStyle(color: Colors.white),
                                    )
                                  else
                                    const Chip(
                                      label: Text('Pendiente'),
                                      backgroundColor: Colors.orange,
                                      labelStyle: TextStyle(color: Colors.white),
                                    ),
                                ],
                              ),
                              if (_filterMode == 'asignados' && !paquete.entregado)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.location_on),
                                      label: const Text('Entregar'),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/entrega',
                                          arguments: paquete,
                                        );
                                      },
                                    ),
                                  ),
                                )
                              else if (_filterMode == 'asignados' && paquete.entregado)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.info),
                                      label: const Text('Ver Detalles'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade600,
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/entrega_detalles',
                                          arguments: paquete.id,
                                        );
                                      },
                                    ),
                                  ),
                                )
                              else if (_filterMode == 'disponibles')
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.add),
                                      label: const Text('Asignarme'),
                                      onPressed: () async {
                                        try {
                                          await ApiService.asignarPaquete(
                                            paquete.id,
                                            ApiService.usuarioId ?? 0,
                                          );
                                          _loadPaquetes();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Paquete asignado correctamente',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text('Error: $e'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
