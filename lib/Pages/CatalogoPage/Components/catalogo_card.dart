import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../Model/catalogo.dart';

class CatalogoCard extends StatelessWidget {
  final CatalogoItem item;
  final VoidCallback? onTap;
  final VoidCallback? onDelete; // Callback para a exclusão

  const CatalogoCard({
    Key? key,
    required this.item,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outline.withOpacity(0.3)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 16), // Ajusta o padding direito
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (item.getFotoBytes() != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    Uint8List.fromList(item.getFotoBytes()!),
                    width: 72, height: 72, fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(color: cs.surfaceVariant, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.inventory_2_outlined, size: 32, color: cs.onSurfaceVariant),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.nome, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(currencyFormatter.format(item.preco), style: textTheme.titleSmall?.copyWith(color: cs.primary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Estoque: ${item.quantidade}', style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // BOTÃO DE EXCLUIR VISÍVEL E FUNCIONAL
              if (onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: cs.error),
                  tooltip: 'Excluir Item',
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
