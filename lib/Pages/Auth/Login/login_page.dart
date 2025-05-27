import 'package:flutter/material.dart';
import '../../../Service/usuario_service.dart'; // Importe o seu UsuarioService
import '../../../Service/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UsuarioService _usuarioService = UsuarioService();
  bool _isLoading = false; // Estado para controlar o loading

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final senha = _passwordController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, preencha todos os campos.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final result = await _usuarioService.loginUsuario(
      email: email,
      senha: senha,
    );

    if (result['sucesso']) {
      final String token = result['token'];
      final int expiresIn = result['expiresIn'];

      // 1. Salvar o token no AuthService
      AuthService.saveToken(token, expiresIn);

      // 2. Opcional: Obter o membro_id logo após o login
      //    Isso é útil se a tela inicial precisar do membro_id imediatamente.
      final String? membroId = await AuthService.getMembroIdDoUsuarioLogado();
      print('Login bem-sucedido! Membro ID: $membroId'); // Para depuração

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Login realizado com sucesso!'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );

      // Você pode passar o membroId para a próxima tela se necessário
      Navigator.pushReplacementNamed(
        context,
        '/home', // Sua rota principal
        arguments: {'membroId': membroId}, // Exemplo de como passar argumentos
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['mensagem'] ?? 'Erro desconhecido no login.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Acessando o ColorScheme do tema atual
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // scaffoldBackgroundColor já é definido no AppThemes
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Centraliza verticalmente
                children: [
                  // Espaçamento superior para centralizar melhor em telas menores
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                  Image.asset(
                    'assets/logo.png',
                    height: 120,
                    // Garante que a imagem se adapte ao tema (se for SVG ou tiver variação de cor)
                    // Para PNG, o ideal é ter uma versão dark/light se o logo mudar de cor.
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Login",
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onBackground, // Cor do texto baseada no tema
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration( // Já usa o _inputDecorationTheme global
                      labelText: 'Email',
                      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    style: TextStyle(color: colorScheme.onSurface),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration( // Já usa o _inputDecorationTheme global
                      labelText: 'Senha',
                      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      // Elevated Button para um visual mais proeminente e contraste
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary, // Cor primária do tema
                        foregroundColor: colorScheme.onPrimary, // Cor do texto no botão primário
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: textTheme.labelLarge, // Estilo de texto do tema
                      ),
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                          strokeWidth: 2,
                        ),
                      )
                          : const Text("Entrar"),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Não tem uma conta? ",
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/signup'),
                          child: Text(
                            "Cadastre-se",
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary, // Cor primária para o link
                              decoration: TextDecoration.underline,
                              decorationColor: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Espaçamento inferior para centralizar melhor
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}