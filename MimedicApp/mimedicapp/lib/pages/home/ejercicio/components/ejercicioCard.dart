import 'package:flutter/material.dart';
import 'package:mimedicapp/configs/colors.dart';
import 'package:mimedicapp/models/ejercicioUsuario.dart';
import 'package:mimedicapp/pages/home/ejercicio/components/ejercicioDetail.dart';

class EjercicioCard extends StatelessWidget {
  final EjercicioUsuario ejercicio;
  final VoidCallback onEdit;
  final bool selectionMode;
  final bool isSelected;
  final VoidCallback? onToggleSelect;

  const EjercicioCard({
    super.key,
    required this.ejercicio,
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
          onTap: () => showEjercicioDetailsDialog(context, ejercicio),
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
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                // IZQUIERDA: nombre
                SizedBox(
                  width: 120,
                  child: Text(
                    ejercicio.nombre ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                // horario + duración
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatHora(ejercicio.horario),
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Duración: ${ejercicio.duracionMin ?? 0} min",
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Estado: ${(ejercicio.realizado ?? false) ? 'Realizado' : 'Pendiente'}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
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
  String _formatHora(String? raw) {
  if (raw == null) return '';
  if (raw.length >= 5) return raw.substring(0, 5);
  return raw;
}
}
