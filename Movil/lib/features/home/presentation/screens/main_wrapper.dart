import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ceos/features/auth/presentation/widgets/dashboard_view.dart';
import 'package:ceos/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:ceos/features/users/presentation/screens/users_screen.dart';
import 'package:ceos/features/reports/presentation/screens/reports_screen.dart';
import 'package:ceos/features/request/presentation/screens/requests_screen.dart';
import 'package:ceos/features/auth/presentation/providers/auth_provider.dart';

class MainWrapper extends ConsumerStatefulWidget {
  const MainWrapper({super.key});

  @override
  ConsumerState<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends ConsumerState<MainWrapper> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(authProvider).role;

    // Generar items y pantallas según rol
    final List<Widget> screens = [const DashboardView()];
    final List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
    ];

    if (role == 'DOCTOR') {
      screens.addAll([
        const InventoryScreen(),
        const RequestsScreen(),
      ]);
      items.addAll([
        const BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Materiales'),
        const BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Solicitudes'),
      ]);
    } else if (role == 'INVENTARIO') {
      screens.addAll([
        const InventoryScreen(),
        const Center(child: Text('Vista Movimientos (Próximamente)')),
        const RequestsScreen(),
        const ReportsScreen(),
      ]);
      items.addAll([
        const BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Inventario'),
        const BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Movimientos'),
        const BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Solicitudes'),
        const BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reportes'),
      ]);
    } else { // ADMIN o SUPERADMIN
      screens.addAll([
        const UsersScreen(),
        const InventoryScreen(),
        const RequestsScreen(),
        const ReportsScreen(),
      ]);
      items.addAll([
        const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Usuarios'),
        const BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Inventario'),
        const BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Solicitudes'),
        const BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reportes'),
      ]);
    }

    // Ensure _selectedIndex is valid after a role change or hot reload
    if (_selectedIndex >= screens.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: items,
      ),
    );
  }
}