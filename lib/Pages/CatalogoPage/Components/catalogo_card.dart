import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:siga/Model/catalogo.dart';
 // ✅ Importando o novo modelo

class CatalogoCard extends StatelessWidget {
  final CatalogoItem item;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CatalogoCard({
    super.key,
    required this.item,
    this.onTap,
    this.onDelete,
  });

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
      margin: EdgeInsets.zero, // A GridView já fornece o espaçamento
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SEÇÃO DA IMAGEM ---
            _buildImageSection(cs),
            
            // --- SEÇÃO DE INFORMAÇÕES ---
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nome, 
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.descricao, 
                    style: textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        currencyFormatter.format(item.preco), 
                        style: textTheme.titleSmall?.copyWith(color: cs.primary, fontWeight: FontWeight.bold)
                      ),
                      // ✅ Mostra um chip de status de disponibilidade
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (item.disponivel ? Colors.green : Colors.grey).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.disponivel ? 'Disponível' : 'Indisponível',
                          style: textTheme.labelSmall?.copyWith(
                            color: item.disponivel ? Colors.green.shade800 : Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            // --- SEÇÃO DE AÇÕES ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onDelete != null)
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: cs.error, size: 20),
                      tooltip: 'Excluir Item',
                      onPressed: onDelete,
                    ),
                  if (onTap != null)
                    IconButton(
                      icon: Icon(Icons.edit_outlined, color: cs.onSurfaceVariant, size: 20),
                      tooltip: 'Editar Item',
                      onPressed: onTap,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói a seção de imagem, usando a fotoUrl ou um placeholder.
  Widget _buildImageSection(ColorScheme cs) {
    bool hasImage = item.fotoUrl != null && item.fotoUrl!.isNotEmpty;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: cs.surfaceContainerHighest,
        child: hasImage
            ? Image.network(
                item.fotoUrl!,
                fit: BoxFit.cover,
                // Mostra um loading enquanto a imagem carrega
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                // Mostra um ícone de erro se a imagem falhar ao carregar
                errorBuilder: (context, error, stackTrace) {
                  print("Erro ao carregar imagem do catálogo: $error");
                  return Icon(Icons.broken_image_outlined, size: 40, color: cs.onSurfaceVariant);
                },
              )
            : Icon(Icons.inventory_2_outlined, size: 48, color: cs.onSurfaceVariant),
      ),
    );
  }
}
