import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Sidebar extends StatefulWidget {
  final Function(int) onItemSelected;

  const Sidebar({super.key, required this.onItemSelected});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int selectedIndex = 0;

  final List<Map<String, dynamic>> navItems = [
    {'icon': LucideIcons.package, 'label': 'Pedidos'},
    {'icon': LucideIcons.headphones, 'label': 'Atendimento'},
    {'icon': LucideIcons.alertCircle, 'label': 'Alerta'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: navItems.asMap().entries.map((entry) {
          int index = entry.key;
          var item = entry.value;
          return ListTile(
            leading: Icon(
              item['icon'],
              color: selectedIndex == index ? Colors.blueAccent : Colors.black54,
            ),
            title: Text(
              item['label'],
              style: TextStyle(
                color: selectedIndex == index ? Colors.blueAccent : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            selected: selectedIndex == index,
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
              widget.onItemSelected(index);
            },
          );
        }).toList(),
      ),
    );
  }
}
