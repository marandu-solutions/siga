import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Importante para o logo
import 'package:lucide_icons/lucide_icons.dart';
import '../../../Service/usuario_service.dart';

// -------------------------------------------------------------------
// Widget do Logo Vetorial (para consistência)
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
    final svgString = '''<svg width="$size" height="$size" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg"><defs><linearGradient id="logoGradient" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" style="stop-color:${_colorToHex(gradient.colors[0])};stop-opacity:1" /><stop offset="100%" style="stop-color:${_colorToHex(gradient.colors[1])};stop-opacity:1" /></linearGradient></defs><circle cx="50" cy="50" r="45" stroke="url(#logoGradient)" stroke-width="8" fill="none"/><path d="M 25 70 L 25 30 L 50 55 L 75 30 L 75 70" stroke="url(#logoGradient)" stroke-width="12" fill="none" stroke-linejoin="round" stroke-linecap="round"/></svg>''';
    return SvgPicture.string(svgString, width: size, height: size);
  }
  String _colorToHex(Color color) => '#${color.value.toRadixString(16).substring(2)}';
}


// -------------------------------------------------------------------
// A Nova Tela de Cadastro
// -------------------------------------------------------------------
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Chaves para validar cada passo do formulário
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();

  // Controladores de texto
  final companyController = TextEditingController();
  final ownerController = TextEditingController();
  final phoneController = TextEditingController();
  final cpfController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final UsuarioService _usuarioService = UsuarioService();
  bool _isLoading = false;
  int _currentStep = 0;

  @override
  void dispose() {
    companyController.dispose();
    ownerController.dispose();
    phoneController.dispose();
    cpfController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // --- LÓGICA DO STEPPER ---
  void _onStepContinue() {
    bool isStepValid = false;
    // Valida o passo atual antes de continuar
    if (_currentStep == 0) {
      isStepValid = _formKeyStep1.currentState!.validate();
    } else if (_currentStep == 1) {
      isStepValid = _formKeyStep2.currentState!.validate();
      if (isStepValid) {
        _handleSignUp(); // Se o segundo passo for válido, finaliza o cadastro
        return;
      }
    }

    if (isStepValid && _currentStep < 1) {
      setState(() => _currentStep += 1);
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  // --- LÓGICA DE CADASTRO ---
  Future<void> _handleSignUp() async {
    setState(() => _isLoading = true);

    final sucesso = await _usuarioService.cadastrarUsuario(
      email: emailController.text.trim(),
      senha: passwordController.text.trim(),
      username: ownerController.text.trim(),
    );

    if (!mounted) return;

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Usuário cadastrado com sucesso! Faça o login.'), backgroundColor: Theme.of(context).colorScheme.secondary));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Falha ao cadastrar usuário. Tente novamente.'), backgroundColor: Theme.of(context).colorScheme.error));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                const MaranduLogo(size: 80),
                const SizedBox(height: 16),
                Text("Crie sua Conta", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text("Vamos começar a organizar seus atendimentos.", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 24),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                  ),
                  child: Stepper(
                    type: StepperType.vertical,
                    currentStep: _currentStep,
                    onStepContinue: _onStepContinue,
                    onStepCancel: _onStepCancel,
                    onStepTapped: null, // Desabilita o toque nos passos
                    controlsBuilder: (context, details) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Row(
                          children: [
                            FilledButton(
                              onPressed: _isLoading ? null : details.onStepContinue,
                              child: _isLoading && _currentStep == 1
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text(details.currentStep == 0 ? "Continuar" : "Finalizar Cadastro"),
                            ),
                            if (details.onStepCancel != null)
                              TextButton(onPressed: details.onStepCancel, child: const Text("Voltar")),
                          ],
                        ),
                      );
                    },
                    steps: [
                      _buildStepEmpresa(),
                      _buildStepCredenciais(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Já tem uma conta?"),
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Fazer Login")),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS DOS PASSOS ---
  Step _buildStepEmpresa() {
    return Step(
      title: const Text('Informações da Empresa'),
      content: Form(
        key: _formKeyStep1,
        child: Column(
          children: [
            TextFormField(controller: companyController, decoration: const InputDecoration(labelText: 'Nome da Empresa', prefixIcon: Icon(LucideIcons.building2)), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
            const SizedBox(height: 16),
            TextFormField(controller: ownerController, decoration: const InputDecoration(labelText: 'Nome do Proprietário', prefixIcon: Icon(LucideIcons.user)), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
            const SizedBox(height: 16),
            TextFormField(controller: phoneController, decoration: const InputDecoration(labelText: 'Telefone', prefixIcon: Icon(LucideIcons.phone)), keyboardType: TextInputType.phone, validator: (v) => v!.length < 10 ? 'Número inválido' : null),
            const SizedBox(height: 16),
            TextFormField(controller: cpfController, decoration: const InputDecoration(labelText: 'CPF', prefixIcon: Icon(LucideIcons.fileText)), keyboardType: TextInputType.number, maxLength: 11, validator: (v) => v!.length != 11 ? 'CPF deve ter 11 dígitos' : null),
          ],
        ),
      ),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildStepCredenciais() {
    return Step(
      title: const Text('Credenciais de Acesso'),
      content: Form(
        key: _formKeyStep2,
        child: Column(
          children: [
            TextFormField(controller: emailController, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(LucideIcons.mail)), keyboardType: TextInputType.emailAddress, validator: (v) => !v!.contains('@') ? 'Email inválido' : null),
            const SizedBox(height: 16),
            TextFormField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Senha', prefixIcon: Icon(LucideIcons.lock)), validator: (v) => v!.length < 6 ? 'Mínimo de 6 caracteres' : null),
            const SizedBox(height: 16),
            // CORREÇÃO: Ícone inválido 'lockKeyhole' trocado por 'keyRound'.
            TextFormField(controller: confirmPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'Confirmar Senha', prefixIcon: Icon(LucideIcons.keyRound)), validator: (v) => v! != passwordController.text ? 'As senhas não coincidem' : null),
          ],
        ),
      ),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    );
  }
}
