import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'Model/estoque_model.dart';
import 'Model/pedidos_model.dart';
import 'Model/usuario.dart';
import 'Model/usuario_model.dart';

import 'Themes/themes.dart';
import 'Pages/AlertaPage/alerta_page.dart';
import 'Pages/AtendimentoPage/atendimento_page.dart';
import 'Pages/Auth/Login/login_page.dart';
import 'Pages/Auth/Register/register_page.dart';
import 'Pages/EstoquePage/estoque_page.dart';
import 'Pages/FeedbackPage/feedback_page.dart';
import 'Pages/HomePage/Components/bottom_nav_bar.dart';
import 'Pages/HomePage/Components/sidebar.dart';
import 'Pages/PedidosPage/pedidos_page.dart';

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
            ChangeNotifierProvider(create: (_) => UsuarioProvider()), // provedor de usuários
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

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    PedidosPage(),
    AtendimentoPage(),
    AlertaPage(),
    FeedbacksPage(),
    EstoquePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobileView = constraints.maxWidth < 600;

        if (isMobileView) {
          return Scaffold(
            body: pages[selectedIndex],
            bottomNavigationBar: BottomNavBar(
              selectedIndex: selectedIndex,
              onItemSelected: (idx) => setState(() => selectedIndex = idx),
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: Colors.black12,
            body: Row(
              children: [
                Sidebar(
                  selectedIndex: selectedIndex,
                  onItemSelected: (index) => setState(() => selectedIndex = index),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: pages[selectedIndex],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
