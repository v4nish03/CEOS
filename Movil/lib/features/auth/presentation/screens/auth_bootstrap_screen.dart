import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class AuthBootstrapScreen extends ConsumerWidget {
  const AuthBootstrapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el estado de autenticación
    final authState = ref.watch(authProvider);

    // Si ya terminó de checar y no está autenticado, lo mandamos al login con una transición
    if (authState.status == AuthStatus.unauthenticated) {
      return const LoginScreen();
    }

    // Mientras el estado sea 'checking' o 'authenticated' (esperando al router),
    // mostramos el logo de la clínica.
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Reemplazar con tu asset real: Image.asset('assets/logo_clinica.png')
            const Icon(
              Icons.local_hospital_rounded, 
              size: 100, 
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}