import 'package:ceos/core/router/app_router.dart';
import 'package:ceos/core/theme/app_theme.dart';
import 'package:ceos/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: CeosApp()));
}

class CeosApp extends ConsumerWidget {
  const CeosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    ref.watch(authBootstrapProvider);

    return MaterialApp.router(
      title: 'CEOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
