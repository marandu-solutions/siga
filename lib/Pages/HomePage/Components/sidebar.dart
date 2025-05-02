// lib/components/sidebar.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Sidebar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const Sidebar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> with SingleTickerProviderStateMixin {
  static const double _expandedWidth = 250;
  static const double _collapsedWidth = 80;
  bool _isCollapsed = false;

  late final AnimationController _controller;
  late final Animation<double> _widthAnim;

  final List<Map<String, dynamic>> _navItems = [
    {'icon': LucideIcons.package,        'label': 'Pedidos'},
    {'icon': LucideIcons.headphones,     'label': 'Atendimento'},
    {'icon': LucideIcons.alertCircle,    'label': 'Alerta'},
    {'icon': LucideIcons.box,            'label': 'Estoque'},
    {'icon': LucideIcons.messageCircle,  'label': 'Feedbacks'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _widthAnim = Tween<double>(
      begin: _expandedWidth,
      end: _collapsedWidth,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isCollapsed = !_isCollapsed;
      if (_isCollapsed) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: _collapsedWidth,
        maxWidth: _expandedWidth,
      ),
      child: AnimatedBuilder(
        animation: _widthAnim,
        builder: (context, child) {
          final isNarrow = _widthAnim.value <= (_collapsedWidth + 5);

          return Container(
            width: _widthAnim.value,
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
                const SizedBox(height: 24),
                // Avatar or Logo
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.orangeAccent,
                  child: Icon(Icons.person, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 32),

                // Navigation items
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: _navItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = _navItems[index];
                      final selected = widget.selectedIndex == index;

                      return InkWell(
                        onTap: () => widget.onItemSelected(index),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.white.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: isNarrow
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.start,
                            children: [
                              Icon(item['icon'], color: Colors.white, size: 22),
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
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Divider
                Container(
                  height: 1,
                  margin:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.white24,
                ),

                // Collapse/Expand button
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Align(
                    alignment:
                    isNarrow ? Alignment.center : Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(
                        _isCollapsed
                            ? Icons.chevron_right
                            : Icons.chevron_left,
                        color: Colors.white,
                      ),
                      onPressed: _toggle,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
