import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'Model/pedidos.dart';
import 'Model/catalogo.dart';
import 'Model/usuario.dart';
import 'Pages/Auth/Login/login_page.dart';
import 'Pages/Auth/Register/register_page.dart';
import 'Pages/HomePage/home_page.dart';
import 'Themes/themes.dart';
import 'Model/atendimento.dart';
import 'Service/pedidos_service.dart'; // Importe o PedidoService

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PedidoModel()),
        ChangeNotifierProvider(create: (_) => CatalogoModel()),
        ChangeNotifierProvider(create: (_) => UsuarioProvider()),
        ChangeNotifierProvider(create: (_) => AtendimentoModel()),
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
      initialRoute: '/home',
      routes: {
        '/': (_) => const LoginScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/home': (_) => const HomePage(),
      },
    );
  }
}