import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/models/medicamento.dart';
import 'package:mimedicapp/models/unidad.dart';

/// Minimal interface describing the controller used by the medicamento form.
/// Implement this in controllers that back the form so the widget can be
/// strongly typed instead of using `dynamic`.
abstract class MedicamentoFormController {
  GlobalKey<FormState> get formKey;

  TextEditingController get nombreCtrl;
  TextEditingController get dosisCtrl;
  TextEditingController get unidadCtrl;
  TextEditingController get frecuenciaCtrl;

  Rxn<DateTime> get fechaInicio;
  Rxn<DateTime> get fechaFin;
  Rxn<TimeOfDay> get horaInicio;

  RxList<Medicamento> get medicamentos;
  RxList<Unidad> get unidades;

  RxBool get isLoading;
  RxBool get isFormValid;

  Future<void> seleccionarFecha({required bool esInicio});
  Future<void> seleccionarHoraInicio();
  Future<void> guardar();
}
