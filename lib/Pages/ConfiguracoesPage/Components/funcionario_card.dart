import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../Model/funcionario.dart';

class FuncionarioCard extends StatelessWidget {
  final Funcionario funcionario; // Usa seu modelo real
  const FuncionarioCard({required this.funcionario});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              child: Text(funcionario.nome.isNotEmpty ? funcionario.nome[0].toUpperCase() : '?'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(funcionario.nome, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  Text(funcionario.email, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            // Chip para o cargo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                funcionario.cargo,
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
              ),
            ),
            // Indicador de status Ativo/Inativo
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(
                funcionario.ativo ? Icons.check_circle : Icons.pause_circle_filled,
                color: funcionario.ativo ? Colors.green : Colors.grey,
                size: 20,
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) { /* Lógica para editar/desativar */ },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Editar Permissões')),
                PopupMenuItem(
                  value: 'toggle_status',
                  child: Text(
                      funcionario.ativo ? 'Desativar' : 'Reativar',
                      style: TextStyle(color: funcionario.ativo ? Colors.red : Colors.green)
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
