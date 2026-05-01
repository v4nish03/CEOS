import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Panel de Control', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
            Text('Hola, ${authState.name ?? 'Usuario'}', style: const TextStyle(fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {}, // Punto 3-E: Alertas
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Accesos Rápidos', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),
            
            // Grid de Atajos adaptativo por Rol
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: _buildActionsByRol(authState.role, context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionsByRol(String? role, BuildContext context) {
    // Si es DOCTOR
    if (role == 'DOCTOR') {
      return [
        _MenuCard(icon: Icons.add_shopping_cart, label: 'Nueva Solicitud', color: Colors.blue),
        _MenuCard(icon: Icons.history, label: 'Mis Pedidos', color: Colors.orange),
        _MenuCard(icon: Icons.search, label: 'Buscar Material', color: Colors.teal),
      ];
    }
    
    // Si es ADMIN o INVENTARIO
    return [
      _MenuCard(icon: Icons.inventory, label: 'Ver Stock', color: Colors.green),
      _MenuCard(icon: Icons.swap_horiz, label: 'Registrar Mov.', color: Colors.purple),
      _MenuCard(icon: Icons.warning_amber, label: 'Alertas Stock', color: Colors.red),
      _MenuCard(icon: Icons.bar_chart, label: 'Reportes', color: Colors.blueGrey),
    ];
  }
}

// Widget privado para las tarjetas del menú (UX limpia)
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MenuCard({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {}, // Navegación a la feature
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}