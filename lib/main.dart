// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

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

  // ✅ Inicializa o Firebase. ESSENCIAL!
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // ✅ Nosso novo MultiProvider, agora muito mais simples
    MultiProvider(
      providers: [
        // O único provider que precisamos na raiz é o AuthService.
        // Ele vai gerenciar o estado de autenticação para toda a app.
        ChangeNotifierProvider(create: (_) => AuthService()),
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
  const MaranduApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MARANDU',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,

      // ✅ Usamos o AuthWrapper como 'home'. Ele decide qual tela mostrar.
      home: const AuthWrapper(),

      // ✅ Definimos as outras rotas para navegação manual se necessário.
      routes: {
        '/signup': (_) => const SignUpScreen(),
        '/home': (_) => const HomePage(),
      },
    );
  }
}

// -------------------------------------------------------------------
// ✅ NOVO WIDGET: O coração do roteamento dinâmico
// -------------------------------------------------------------------
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Usamos context.watch para "ouvir" as mudanças no AuthService
    final authService = context.watch<AuthService>();

    // Um switch para retornar a tela correta baseada no status
    switch (authService.status) {
      case AuthStatus.uninitialized:
      case AuthStatus.authenticating:
      // Enquanto o Firebase verifica o login, mostramos uma tela de loading
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      case AuthStatus.authenticated:
      // Se o usuário está logado, vai para a HomePage
        return const HomePage();
      case AuthStatus.unauthenticated:
      default:
      // Se não está logado, vai para a tela de Login
        return const LoginScreen();
    }
  }
}