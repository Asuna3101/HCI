import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Minimal interface describing the controller used by the comida form.
/// Implement this in controllers that back the form so the widget can be
/// strongly typed instead of using `dynamic`.
abstract class ComidaFormController {
  GlobalKey<FormState> get formKey;

  TextEditingController get nombreCtrl;
  TextEditingController get descripcionCtrl;

  Rxn<int> get categoriaSeleccionada;

  RxList<Map<String, dynamic>> get categorias;
  RxList<Map<String, dynamic>> get sugerencias;
  RxBool get mostrarSugerencias;

  RxBool get isLoading;

  // Indica si es modo edición (true) o agregar (false)
  bool get isEditMode => false;

  void seleccionarSugerencia(Map<String, dynamic> sugerencia);
  Future<void> guardar();
}
