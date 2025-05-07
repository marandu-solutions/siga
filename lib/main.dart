// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'Model/estoque_model.dart';
import 'Model/pedidos_model.dart';
import 'Model/usuario_model.dart';
import 'Pages/Auth/Login/login_page.dart';
import 'Pages/Auth/Register/register_page.dart';
import 'Pages/HomePage/home_page.dart';
import 'Themes/themes.dart';

void main() {
  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => PedidoModel()),
            ChangeNotifierProvider(create: (_) => EstoqueModel()),
            ChangeNotifierProvider(create: (_) => UsuarioProvider()),
          ],
          child: const MaranduApp(),
        );
      },
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
      initialRoute: '/home',
      routes: {
        '/': (_) => const LoginScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/home': (_) => const HomePage(),
      },
    );
  }
}
