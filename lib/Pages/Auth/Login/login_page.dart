import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Importante para o logo
import 'package:lucide_icons/lucide_icons.dart';
import '../../../Service/usuario_service.dart';
import '../../../Service/auth_service.dart';

// -------------------------------------------------------------------
// 1. O WIDGET DO SEU NOVO LOGO (VETORIAL E TRANSPARENTE)
// -------------------------------------------------------------------
class MaranduLogo extends StatelessWidget {
  final double size;
  const MaranduLogo({super.key, this.size = 120.0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradient = LinearGradient(
      colors: [theme.colorScheme.primary, const Color(0xFF673AB7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final String svgString = '''
    <svg width="$size" height="$size" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <linearGradient id="logoGradient" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" style="stop-color:${_colorToHex(gradient.colors[0])};stop-opacity:1" />
          <stop offset="100%" style="stop-color:${_colorToHex(gradient.colors[1])};stop-opacity:1" />
        </linearGradient>
      </defs>
      <circle cx="50" cy="50" r="45" stroke="url(#logoGradient)" stroke-width="8" fill="none"/>
      <path d="M 25 70 L 25 30 L 50 55 L 75 30 L 75 70" stroke="url(#logoGradient)" stroke-width="12" fill="none" stroke-linejoin="round" stroke-linecap="round"/>
    </svg>
    ''';

    return SvgPicture.string(svgString, width: size, height: size);
  }

  String _colorToHex(Color color) => '#${color.value.toRadixString(16).substring(2)}';
}


// -------------------------------------------------------------------
// 2. A SUA TELA DE LOGIN, AGORA USANDO O NOVO LOGO
// -------------------------------------------------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final UsuarioService _usuarioService = UsuarioService();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final result = await _usuarioService.loginUsuario(
      email: _emailController.text.trim(),
      senha: _passwordController.text.trim(),
    );
    if (!mounted) return;
    if (result['sucesso']) {
      AuthService.saveToken(result['token'], result['expiresIn']);
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['mensagem'] ?? 'Erro desconhecido no login.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // USANDO O NOVO LOGO AQUI!
                const MaranduLogo(size: 100),
                const SizedBox(height: 24),
                Text("Bem-vindo de volta!", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                Text("Faça login para continuar", style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 32),
                _buildLoginForm(theme),
                const SizedBox(height: 24),
                _buildSignUpLink(context, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(LucideIcons.mail)),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => (value == null || !value.contains('@')) ? 'Digite um email válido' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(LucideIcons.lock),
              suffixIcon: IconButton(
                icon: Icon(_isPasswordVisible ? LucideIcons.eyeOff : LucideIcons.eye),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
            validator: (value) => (value == null || value.length < 6) ? 'A senha deve ter pelo menos 6 caracteres' : null,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: _isLoading ? Container() : const Icon(LucideIcons.logIn),
              onPressed: _isLoading ? null : _handleLogin,
              label: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text("Entrar"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpLink(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Não tem uma conta?", style: theme.textTheme.bodyMedium),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/signup'),
          child: const Text("Cadastre-se"),
        ),
      ],
    );
  }
}
