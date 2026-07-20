import 'package:ceos/core/theme/app_theme.dart';
import 'package:ceos/core/widgets/premium_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_summary_entity.dart';
import '../providers/users_provider.dart';

class UserFormModal extends ConsumerStatefulWidget {
  final String currentRole; // SUPERADMIN o ADMIN
  final UserSummaryEntity? userToEdit; // Si es null => Crear, si existe => Editar

  const UserFormModal({
    super.key,
    required this.currentRole,
    this.userToEdit,
  });

  @override
  ConsumerState<UserFormModal> createState() => _UserFormModalState();
}

class _UserFormModalState extends ConsumerState<UserFormModal> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late String _selectedRole;
  bool _isLoading = false;
  bool _obscurePassword = true;

  bool get _isEditing => widget.userToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nombreController.text = widget.userToEdit!.name;
      _emailController.text = widget.userToEdit!.email;
      _selectedRole = widget.userToEdit!.role.toUpperCase();
    } else {
      _selectedRole = 'DOCTOR';
    }
  }

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

    if (nombre.isEmpty || email.isEmpty) {
      _showSnackBar('El nombre y el correo son obligatorios', isError: true);
      return;
    }

    if (!_isEditing && password.isEmpty) {
      _showSnackBar('La contraseña es obligatoria para nuevos usuarios', isError: true);
      return;
    }

    if (password.isNotEmpty && password.length < 8) {
      _showSnackBar('La contraseña debe tener al menos 8 caracteres', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(usersRepositoryProvider);

      if (_isEditing) {
        await repo.createUser(
          nombre: nombre,
          email: email,
          password: password,
          rol: _selectedRole,
        );
      } else {
        await repo.createUser(
          nombre: nombre,
          email: email,
          password: password,
          rol: _selectedRole,
        );
      }

      ref.invalidate(usersProvider);

      if (mounted) {
        Navigator.of(context).pop();
        _showSnackBar(_isEditing ? '✓ Usuario actualizado con éxito' : '✓ Usuario creado con éxito');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? const Color(0xFFEF4444) : AppTheme.clinicalTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roles = widget.currentRole == 'SUPERADMIN'
        ? const ['SUPERADMIN', 'ADMIN', 'INVENTARIO', 'DOCTOR']
        : const ['ADMIN', 'INVENTARIO', 'DOCTOR'];

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.white.withAlpha(180),
      labelStyle: const TextStyle(color: PremiumGlass.slate500, fontSize: 13, fontWeight: FontWeight.w500),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withAlpha(200)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withAlpha(180)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.clinicalTeal, width: 1.5),
      ),
    );

    return GlassContainer(
      borderRadius: 28,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: PremiumGlass.slate500.withAlpha(60),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.clinicalTeal.withAlpha(25),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.clinicalTeal.withAlpha(50)),
                ),
                child: Icon(
                  _isEditing ? Icons.manage_accounts_rounded : Icons.person_add_alt_1_rounded,
                  color: AppTheme.clinicalTeal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEditing ? 'Editar Usuario' : 'Nuevo Usuario',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: PremiumGlass.slate800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    _isEditing ? 'Modifica las credenciales y rol' : 'Completa los datos para dar de alta',
                    style: const TextStyle(fontSize: 12, color: PremiumGlass.slate500),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          TextField(
            controller: _nombreController,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(color: PremiumGlass.slate800, fontSize: 14),
            decoration: inputDecoration.copyWith(
              labelText: 'Nombre completo',
              prefixIcon: const Icon(Icons.person_outline_rounded, color: PremiumGlass.slate500, size: 20),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: PremiumGlass.slate800, fontSize: 14),
            decoration: inputDecoration.copyWith(
              labelText: 'Correo electrónico',
              prefixIcon: const Icon(Icons.email_outlined, color: PremiumGlass.slate500, size: 20),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: PremiumGlass.slate800, fontSize: 14),
            decoration: inputDecoration.copyWith(
              labelText: _isEditing ? 'Nueva contraseña (opcional)' : 'Contraseña segura',
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: PremiumGlass.slate500, size: 20),
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                child: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: PremiumGlass.slate500,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: roles.contains(_selectedRole) ? _selectedRole : roles.first,
            decoration: inputDecoration.copyWith(
              labelText: 'Rol asignado',
              prefixIcon: const Icon(Icons.badge_outlined, color: PremiumGlass.slate500, size: 20),
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(16),
            items: roles.map((r) {
              final roleColors = {
                'SUPERADMIN': const Color(0xFF8B5CF6),
                'ADMIN': const Color(0xFF3B82F6),
                'INVENTARIO': const Color(0xFF0D9488),
                'DOCTOR': const Color(0xFF10B981),
              };
              final color = roleColors[r] ?? const Color(0xFF64748B);
              return DropdownMenuItem(
                value: r,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      r,
                      style: const TextStyle(
                        color: PremiumGlass.slate800,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedRole = val);
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.clinicalTeal.withAlpha(50),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.clinicalTeal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(_isEditing ? 'Guardar Cambios' : 'Crear Cuenta'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}