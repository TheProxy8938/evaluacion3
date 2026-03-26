import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/paquetes_list_screen.dart';
import 'screens/entrega_screen.dart';
import 'screens/entrega_detalles_screen.dart';
import 'models/paquete.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.loadToken();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PaquExpress',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: ApiService.isLoggedIn() ? const PaquetesListScreen() : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/paquetes': (context) => const PaquetesListScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/entrega') {
          final args = settings.arguments;
          if (args is Paquete) {
            return MaterialPageRoute(
              builder: (context) => EntregaScreen(paquete: args),
            );
          } else {
            // Si no es un Paquete válido, regresar a la lista
            return MaterialPageRoute(
              builder: (context) => const PaquetesListScreen(),
            );
          }
        } else if (settings.name == '/entrega_detalles') {
          final args = settings.arguments;
          if (args is int) {
            return MaterialPageRoute(
              builder: (context) => EntregaDetallesScreen(paqueteId: args),
            );
          } else {
            // Si no es un ID válido, regresar a la lista
            return MaterialPageRoute(
              builder: (context) => const PaquetesListScreen(),
            );
          }
        }
        return null;
      },
    );
  }
}
