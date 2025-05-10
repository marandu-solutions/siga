import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../Model/catalogo.dart';

/// Um card reutilizável que exibe os detalhes de um item do catálogo.
class CatalogoCard extends StatelessWidget {
  /// O item do catálogo a ser exibido.
  final CatalogoItem item;

  /// Callback para quando o checkbox é alterado.
  final ValueChanged<bool?>? onCheckboxChanged;

  /// Callback para quando o botão de editar é pressionado.
  final VoidCallback? onEdit;

  const CatalogoCard({
    Key? key,
    required this.item,
    this.onCheckboxChanged,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Miniatura da foto, se existir
            if (item.getFotoBytes() != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  Uint8List.fromList(item.getFotoBytes()!),
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
            ],

            // Checkbox customizado
            Checkbox(
              value: false,
              onChanged: onCheckboxChanged,
              side: BorderSide(color: cs.primary),
              fillColor: MaterialStateProperty.all(cs.primary),
            ),
            const SizedBox(width: 12),

            // Detalhes do produto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nome,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Preço: R\$${item.preco.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quantidade: ${item.quantidade}',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Botão de editar
            IconButton(
              icon: Icon(Icons.edit, color: cs.primary),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}