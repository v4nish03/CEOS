import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/users_provider.dart';

class UserFormModal extends ConsumerStatefulWidget {
  final String currentRole; // SUPERADMIN o ADMIN

  const UserFormModal({super.key, required this.currentRole});

  @override
  ConsumerState<UserFormModal> createState() => _UserFormModalState();
}

class _UserFormModalState extends ConsumerState<UserFormModal> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'DOCTOR';
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nombre = _nombreController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (nombre.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Todos los campos son obligatorios')));
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La contraseña debe tener al menos 8 caracteres')));
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final repo = ref.read(usersRepositoryProvider);
      await repo.createUser(
        nombre: nombre,
        email: email,
        password: password,
        rol: _selectedRole,
      );
      
      ref.invalidate(usersProvider);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario creado con éxito')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ADMIN no puede crear SUPERADMINs.
    final roles = widget.currentRole == 'SUPERADMIN'
        ? const ['SUPERADMIN', 'ADMIN', 'INVENTARIO', 'DOCTOR']
        : const ['ADMIN', 'INVENTARIO', 'DOCTOR'];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_add_alt_1, color: Colors.blueAccent, size: 30),
              SizedBox(width: 10),
              Text(
                'Nuevo Usuario',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nombreController,
            decoration: InputDecoration(
              labelText: 'Nombre completo',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Contraseña segura',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Rol del usuario',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.badge_outlined),
            ),
            value: _selectedRole,
            items: roles.map((r) => DropdownMenuItem(
              value: r,
              child: Text(r),
            )).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedRole = val);
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isLoading ? null : _submit,
              child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Crear Cuenta', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
