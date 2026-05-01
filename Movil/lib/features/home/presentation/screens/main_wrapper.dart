import 'package:flutter/material.dart';
import '../widgets/dashboard_view.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  // Pantallas reales conectadas
  final List<Widget> _screens = [
    const DashboardView(), // Nuestra vista con Grid y bienvenida
    const Center(child: Text('Vista Inventario (Próximamente)')),
    const Center(child: Text('Vista Solicitudes (Próximamente)')),
    const Center(child: Text('Vista Perfil (Próximamente)')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack( // Usamos IndexedStack para mantener el estado de las vistas
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Stock'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Acción'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}