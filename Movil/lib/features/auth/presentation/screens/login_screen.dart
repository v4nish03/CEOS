import 'dart:math' as math;
import 'package:ceos/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 15),
  )..repeat();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose(); 
    super.dispose();
  }

  // 🪄 HELPER PARA MOSTRAR ALERTAS HERMOSAS Y MODERNAS
  void _showCustomSnackBar({
    required String message, 
    required bool isError,
    bool isWarning = false,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars(); // Limpia los anteriores al instante

    Color backgroundColor = const Color(0xFF1E293B); // Por defecto oscuro elegante
    IconData icon = Icons.info_outline_rounded;

    if (isError) {
      backgroundColor = const Color(0xFFEF4444); // Rojo pastel moderno
      icon = Icons.error_outline_rounded;
    } else if (isWarning) {
      backgroundColor = const Color(0xFFF59E0B); // Ámbar/Naranja cálido
      icon = Icons.warning_amber_rounded;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 4,
        behavior: SnackBarBehavior.floating, // Hace que flote en lugar de pegarse abajo
        backgroundColor: backgroundColor,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Bordes curvos premium
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 14, 
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      // Usamos nuestra nueva alerta estilizada de advertencia
      _showCustomSnackBar(
        message: 'Por favor, ingresa tu correo y contraseña.', 
        isError: false,
        isWarning: true,
      );
      return;
    }

    try {
      await ref.read(authProvider.notifier).login(email, password);
    } catch (e) {
      if (!mounted) return;
      // Usamos nuestra nueva alerta estilizada de error
      _showCustomSnackBar(
        message: 'No se pudo iniciar sesión: $e', 
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.checking;
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 🎨 FONDO DEGRADADO BASE
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE0F2FE),
                  Color(0xFFF0FDFA),
                ],
              ),
            ),
          ),
          
          // 🌊 SISTEMA DE BURBUJAS MÚLTIPLES ANIMADAS
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final value = _animationController.value * 2 * math.pi;
              return Stack(
                children: [
                  Positioned(
                    top: -20 + (math.sin(value) * 20),
                    right: -40 + (math.cos(value) * 20),
                    child: _buildBubble(260, theme.primaryColor.withAlpha(15)),
                  ),
                  Positioned(
                    top: screenSize.height * 0.35 + (math.cos(value + 1) * 25),
                    left: -60 + (math.sin(value + 1) * 20),
                    child: _buildBubble(140, theme.primaryColor.withBlue(230).withAlpha(18)),
                  ),
                  Positioned(
                    top: screenSize.height * 0.55 + (math.sin(value + 2) * 30),
                    right: 20 + (math.cos(value + 2) * 15),
                    child: _buildBubble(70, theme.primaryColor.withGreen(200).withAlpha(22)),
                  ),
                  Positioned(
                    top: screenSize.height * 0.1 + (math.cos(value * 1.5) * 15),
                    left: 30 + (math.sin(value * 1.5) * 15),
                    child: _buildBubble(45, theme.primaryColor.withAlpha(15)),
                  ),
                  Positioned(
                    bottom: -80 + (math.cos(value) * 20),
                    left: -30 + (math.sin(value) * 25),
                    child: _buildBubble(300, theme.primaryColor.withAlpha(12)),
                  ),
                ],
              );
            },
          ),

          // CONTENIDO PRINCIPAL
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _BrandHeader(),
                      const SizedBox(height: 48),

                      // Input de Correo
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          labelText: 'Correo electrónico',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF64748B)),
                          filled: true,
                          fillColor: Colors.white.withAlpha(240),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: theme.primaryColor, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Input de Contraseña
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        onSubmitted: (_) => isLoading ? null : _handleLogin(),
                        style: const TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF64748B)),
                          suffixIcon: IconButton(
                            tooltip: _isPasswordVisible ? 'Ocultar contraseña' : 'Mostrar contraseña',
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: const Color(0xFF64748B),
                            ),
                            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                          ),
                          filled: true,
                          fillColor: Colors.white.withAlpha(240),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: theme.primaryColor, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ¿Olvidaste tu contraseña?
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => _showCustomSnackBar(
                            message: 'Solicita recuperación de acceso con administración.', 
                            isError: false,
                          ),
                          child: Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                              color: theme.primaryColor, 
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Botón de Ingresar
                      ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: theme.primaryColor.withAlpha(120),
                          elevation: 2,
                          shadowColor: theme.primaryColor.withAlpha(100),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Ingresar al sistema',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.primaryColor, 
                theme.primaryColor.withBlue(200).withGreen(150), 
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withAlpha(60),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: const Center(
            child: Text(
              'CEOS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: 1.6,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Inventario Clínico',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Control claro, seguro y rápido para clínica dental.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF475569),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}