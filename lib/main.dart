// lib/main.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:siga/Service/atendimento_service.dart';
import 'package:siga/Service/feedback_service.dart';
import 'package:siga/Service/notificacao_service.dart';
import 'package:siga/Service/pedidos_service.dart';

import 'Service/auth_service.dart';
import 'Pages/Auth/Login/login_page.dart';
import 'Pages/Auth/Register/register_page.dart';
import 'Pages/HomePage/home_page.dart';
import 'Themes/themes.dart';
import 'firebase_options.dart';

// O ponto de entrada da aplicação agora é assíncrono
void main() async {
  // Garante que os bindings do Flutter foram inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ DESABILITANDO O AUTO-LOGIN PARA TESTES
  // Esta linha força o logout de qualquer sessão salva no dispositivo.
  // Comente ou remova esta linha para reativar o auto-login no futuro.
  await FirebaseAuth.instance.signOut();

  runApp(
    // Nosso MultiProvider com todos os serviços
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => PedidoService()),
        Provider(create: (_) => NotificacaoService()),
        Provider(create: (_) => FeedbackService()),
        Provider(create: (_) => AtendimentoService()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) => const MaranduApp(),
      ),
    ),
  );
}

class MaranduApp extends StatelessWidget {
  const MaranduApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MARANDU',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,

      // O AuthWrapper continua sendo a peça central do roteamento.
      home: const AuthWrapper(),

      // As rotas nomeadas continuam disponíveis.
      routes: {
        '/signup': (_) => const SignUpScreen(),
        '/home': (_) => const HomePage(),
      },
    );
  }
}

// -------------------------------------------------------------------
// O AuthWrapper não precisa de nenhuma alteração.
// Ele continuará funcionando perfeitamente.
// -------------------------------------------------------------------
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    switch (authService.status) {
      case AuthStatus.uninitialized:
      case AuthStatus.authenticating:
      // ✅ ADICIONADO: Também mostramos o loading enquanto os dados do Firestore carregam.
      case AuthStatus.loadingData: 
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Carregando seus dados..."),
              ],
            ),
          ),
        );
      case AuthStatus.authenticated:
        // SÓ ENTRA AQUI QUANDO TUDO ESTIVER PRONTO!
        return const HomePage();
      case AuthStatus.unauthenticated:
      default:
        return const LoginScreen();
    }
  }
}