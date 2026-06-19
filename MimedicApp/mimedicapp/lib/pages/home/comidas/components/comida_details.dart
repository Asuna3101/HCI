import 'package:flutter/material.dart';
import 'package:mimedicapp/models/comida.dart';
import 'package:mimedicapp/configs/colors.dart';

void showComidaDetailsDialog(BuildContext context, Comida comida) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          comida.nombre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (comida.descripcion != null &&
                  comida.descripcion!.isNotEmpty) ...[
                const Text(
                  'Descripción:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  comida.descripcion!,
                  style: const TextStyle(color: AppColors.primary),
                ),
                const SizedBox(height: 16),
              ],
              if (comida.categoriaNombre != null) ...[
                const Text(
                  'Categoría:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      comida.esRecomendable ? Icons.thumb_up : Icons.thumb_down,
                      color: comida.esRecomendable ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comida.categoriaNombre!,
                      style: TextStyle(
                        color:
                            comida.esRecomendable ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      );
    },
  );
}
