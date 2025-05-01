import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'Pages/Auth/Login/login_page.dart';
import 'Pages/Auth/Register/register_page.dart';
import 'Pages/HomePage/home_page.dart';
import 'Themes/themes.dart'; // Adicionando o tema para uso

void main() {
  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => const MaranduApp(),
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
      themeMode: ThemeMode.system, // Isso faz com que o tema siga a preferência do sistema
      theme: AppThemes.lightTheme, // Tema claro
      darkTheme: AppThemes.darkTheme, // Tema escuro
      builder: (context, widget) => ResponsiveBreakpoints.builder(
        child: widget!,
        breakpoints: const [
          Breakpoint(start: 0, end: 350, name: MOBILE),
          Breakpoint(start: 351, end: 600, name: TABLET),
          Breakpoint(start: 601, end: 800, name: DESKTOP),
        ],
      ),
      initialRoute: '/home',
      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const MainLayout(),
      },
    );
  }
}

class MainLayout extends StatelessWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logoHeight = 32.h;
    final spacing = 10.w;
    final fontSize = 20.sp;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo.png',
              height: logoHeight,
              color: Theme.of(context).colorScheme.onSurface, // Ajusta a cor conforme o tema
            ),
            SizedBox(width: spacing),
            Text(
              'MARANDU',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
      body: const HomePage(),
    );
  }
}
