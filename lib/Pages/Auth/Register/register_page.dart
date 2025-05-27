import 'package:flutter/material.dart';
import '../../../Service/usuario_service.dart'; // Importe o seu UsuarioService

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController companyController = TextEditingController();
  final TextEditingController ownerController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final UsuarioService _usuarioService = UsuarioService();
  bool _isLoading = false;

  @override
  void dispose() {
    companyController.dispose();
    ownerController.dispose();
    phoneController.dispose();
    cpfController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    // Valida apenas os campos da página atual
    if (_formKey.currentState!.validate()) {
      // Pequena lógica para validar apenas a primeira página antes de avançar
      if (_currentPage == 0 && (companyController.text.isEmpty || ownerController.text.isEmpty || phoneController.text.isEmpty || cpfController.text.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Por favor, preencha todos os campos da primeira página.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
      setState(() {
        _currentPage = 1;
      });
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    setState(() {
      _currentPage = 0;
    });
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('As senhas não coincidem.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final email = emailController.text.trim();
    final senha = passwordController.text.trim();
    final username = ownerController.text.trim();

    final bool sucesso = await _usuarioService.cadastrarUsuario(
      email: email,
      senha: senha,
      username: username,
    );

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Usuário cadastrado com sucesso!'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
      Navigator.pop(context); // Volta para a tela de login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Falha ao cadastrar usuário. Verifique seus dados e tente novamente.'),
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
    final isWide = MediaQuery.of(context).size.width > 600;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // scaffoldBackgroundColor já é definido no AppThemes
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              constraints: BoxConstraints(maxWidth: isWide ? 600 : 500),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Centraliza verticalmente
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05), // Espaçamento superior

                    Image.asset(
                      'assets/logo.png',
                      height: 100,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Cadastro", // Alterado para "Cadastro"
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Form(
                      key: _formKey,
                      child: SizedBox(
                        height: 330,
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: companyController,
                                    decoration: InputDecoration(
                                      labelText: 'Nome da Empresa',
                                      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                                    ),
                                    style: TextStyle(color: colorScheme.onSurface),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor, insira o nome da empresa.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: ownerController,
                                    decoration: InputDecoration(
                                      labelText: 'Nome do Proprietário',
                                      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                                    ),
                                    style: TextStyle(color: colorScheme.onSurface),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor, insira o nome do proprietário.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: phoneController,
                                    decoration: InputDecoration(
                                      labelText: 'Telefone',
                                      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                                    ),
                                    style: TextStyle(color: colorScheme.onSurface),
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor, insira o telefone.';
                                      }
                                      // Validação simples de telefone (pode ser melhorada)
                                      if (value.length < 8) {
                                        return 'Telefone inválido.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: cpfController,
                                    decoration: InputDecoration(
                                      labelText: 'CPF',
                                      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                                    ),
                                    style: TextStyle(color: colorScheme.onSurface),
                                    keyboardType: TextInputType.number,
                                    maxLength: 11, // Define um limite para o CPF
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor, insira o CPF.';
                                      }
                                      if (value.length != 11 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
                                        return 'O CPF deve ter 11 dígitos numéricos.';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: emailController,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                                    ),
                                    style: TextStyle(color: colorScheme.onSurface),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor, insira um email.';
                                      }
                                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                        return 'Por favor, insira um email válido.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: passwordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: 'Senha',
                                      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                                    ),
                                    style: TextStyle(color: colorScheme.onSurface),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor, insira uma senha.';
                                      }
                                      if (value.length < 6) {
                                        return 'A senha deve ter pelo menos 6 caracteres.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: confirmPasswordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: 'Confirmar Senha',
                                      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                                    ),
                                    style: TextStyle(color: colorScheme.onSurface),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor, confirme sua senha.';
                                      }
                                      if (value != passwordController.text) {
                                        return 'As senhas não coincidem.';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// Botões de controle
                    Row(
                      children: [
                        if (_currentPage == 1)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : _previousPage,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.primary, // Cor primária do tema
                                side: BorderSide(color: colorScheme.primary), // Borda com cor primária
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: textTheme.labelLarge?.copyWith(fontSize: 14), // Estilo de texto
                              ),
                              child: const Text("Voltar"),
                            ),
                          ),
                        if (_currentPage == 1) const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: textTheme.labelLarge,
                            ),
                            onPressed: _isLoading ? null : (_currentPage == 0 ? _nextPage : _handleSignUp),
                            child: _isLoading
                                ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                                strokeWidth: 2,
                              ),
                            )
                                : Text(
                              _currentPage == 0 ? "Continuar" : "Criar Conta",
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    /// Barra de progresso
                    Container(
                      width: double.infinity,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant, // Cor de fundo da barra baseada no tema
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _currentPage == 0 ? 0.5 : 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.primary, // Cor de progresso baseada no tema
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Link para login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Já tem uma conta? ",
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Entrar",
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                                decoration: TextDecoration.underline,
                                decorationColor: colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05), // Espaçamento inferior
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}