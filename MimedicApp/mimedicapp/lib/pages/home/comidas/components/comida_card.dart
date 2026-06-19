import 'package:flutter/material.dart';
import 'package:mimedicapp/models/comida.dart';
import 'package:mimedicapp/pages/home/comidas/components/comida_details.dart';
import 'package:mimedicapp/configs/colors.dart';

class ComidaCard extends StatelessWidget {
  final Comida comida;
  final VoidCallback onEdit;
  final bool selectionMode;
  final bool isSelected;
  final VoidCallback? onToggleSelect;

  const ComidaCard({
    super.key,
    required this.comida,
    required this.onEdit,
    this.selectionMode = false,
    this.isSelected = false,
    this.onToggleSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Card principal
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => showComidaDetailsDialog(context, comida),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: AppColors.getButtonColor(context),
                width: 0.2,
              ),
            ),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      comida.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (comida.descripcion != null &&
                            comida.descripcion!.isNotEmpty)
                          Text(
                            comida.descripcion!,
                            style: const TextStyle(
                                fontSize: 15, color: AppColors.primary),
                            softWrap: true,
                          ),
                        if (comida.categoriaNombre != null)
                          Row(
                            children: [
                              Icon(
                                comida.esRecomendable
                                    ? Icons.thumb_up
                                    : Icons.thumb_down,
                                color: comida.esRecomendable
                                    ? Colors.green
                                    : Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                comida.categoriaNombre!,
                                style: TextStyle(
                                  color: comida.esRecomendable
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Lapiz
        Positioned(
          top: -18,
          right: -18,
          child: IconButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
            ),
            icon: Icon(Icons.edit,
                color: AppColors.getButtonColor(context), size: 30),
            onPressed: onEdit,
          ),
        ),

        // Check de selección (opcional)
        if (selectionMode)
          Positioned(
            top: -18,
            left: -18,
            child: IconButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                elevation: MaterialStateProperty.all(2),
              ),
              icon: Icon(
                isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                color: isSelected ? AppColors.primary : AppColors.grey400,
                size: 26,
              ),
              onPressed: onToggleSelect,
            ),
          ),
      ],
    );
  }
}
