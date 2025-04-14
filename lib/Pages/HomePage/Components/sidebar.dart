import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Sidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> with SingleTickerProviderStateMixin {
  bool isCollapsed = false;
  late AnimationController _controller;
  late Animation<double> _widthAnimation;

  final double expandedWidth = 250;
  final double collapsedWidth = 80;

  final List<Map<String, dynamic>> navItems = [
    {'icon': LucideIcons.package, 'label': 'Pedidos'},
    {'icon': LucideIcons.headphones, 'label': 'Atendimento'},
    {'icon': LucideIcons.alertCircle, 'label': 'Alerta'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _widthAnimation = Tween<double>(
      begin: expandedWidth,
      end: collapsedWidth,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  void toggleSidebar() {
    setState(() {
      isCollapsed = !isCollapsed;
      isCollapsed ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _widthAnimation,
      builder: (context, child) {
        final isNarrow = _widthAnimation.value <= collapsedWidth + 5;

        return Padding(
          padding: isNarrow
              ? const EdgeInsets.only(left: 16, top: 16, bottom: 16)
              : EdgeInsets.zero,
          child: Container(
            width: _widthAnimation.value,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1E4C), Color(0xFF2A2A72)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: isNarrow
                  ? BorderRadius.circular(20)
                  : const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Avatar
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.orangeAccent,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(height: 30),

                // Menu
                Expanded(
                  child: ListView.builder(
                    itemCount: navItems.length,
                    itemBuilder: (context, index) {
                      final item = navItems[index];
                      final bool isSelected = widget.selectedIndex == index;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: InkWell(
                          onTap: () => widget.onItemSelected(index),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: isNarrow
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 0), // remove um pouco do padding
                                Icon(
                                  item['icon'],
                                  color: Colors.white,
                                  size: 22,
                                ),
                                if (!isNarrow) ...[
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      item['label'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Linha branca acima do botão
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.white24,
                ),

                // Botão de recolher
                if (isNarrow)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: toggleSidebar,
                    ),
                  )
                else
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: const Icon(Icons.chevron_left, color: Colors.white),
                        onPressed: toggleSidebar,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
