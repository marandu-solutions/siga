import 'package:flutter/material.dart';
import 'Pages/Auth/Login/login_page.dart';
import 'Pages/Auth/Register/register_page.dart';
import 'Pages/HomePage/home_page.dart';
import 'Themes/themes.dart';

void main() {
  runApp(const MaranduApp());
}

class MaranduApp extends StatelessWidget {
  const MaranduApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MARANDU',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system, // Segue o tema do dispositivo
      theme: AppThemes.lightTheme, // Tema claro personalizado
      darkTheme: AppThemes.darkTheme, // Tema escuro personalizado
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const MainLayout(),
      },
    );
  }
}

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 32,
              color: Theme.of(context).colorScheme.onSurface, // Cor adaptativa
            ),
            const SizedBox(width: 10),
            Text(
              'MARANDU',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: const HomePage(),
    );
  }
}