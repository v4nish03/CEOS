import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  // Asegura que los servicios de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Gestión Inventario Clínica',
      debugShowCheckedModeBanner: false,
      
      // Aplicamos el tema que definimos juntos
      theme: AppTheme.lightTheme,
      
      // Conectamos el router
      routerConfig: router,
    );
  }
}