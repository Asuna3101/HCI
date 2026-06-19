import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/configs/colors.dart';
import 'package:mimedicapp/models/ejercicioUsuario.dart';
import 'package:mimedicapp/pages/home/ejercicio/ejercicio_controller.dart';
import 'package:mimedicapp/services/ejercicio_service.dart';

class EjercicioAlertDialog extends StatelessWidget {
  final EjercicioUsuario ejercicio;

  const EjercicioAlertDialog({
    super.key,
    required this.ejercicio,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 280),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ---------- TÍTULO ----------
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Ejercicio próximo",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Titulo',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ---------- CARD ÚNICA ----------
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ejercicio.nombre ?? 'Ejercicio',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "Tu ejercicio empieza ahora.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ---------- BOTONES ----------
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  backgroundColor: Colors.grey[600],
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                ),
                                child: const Text(
                                  "Entendido",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  try {
                                    if (ejercicio.id != null) {
                                      final updated = EjercicioUsuario(
                                        realizado: true
                                      );
                                      await EjercicioService()
                                          .updateEjercicioUsuario(
                                        ejercicio.id!,
                                        updated,
                                      );
                                      final controllerEj =
                                          Get.find<EjercicioController>();
                                      final lista = await EjercicioService()
                                          .getEjerciciosUsuario();
                                      controllerEj.ejerciciosUsuario
                                          .assignAll(lista);
                                    }
                                  } catch (e) {
                                    // Manejo de errores
                                  }
                                  if (Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                ),
                                child: const Text(
                                  "Completar",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
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

            // ---------- BOTÓN X ----------
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                tooltip: 'Cerrar',
                icon: const Icon(Icons.close, size: 22, color: Colors.black54),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
