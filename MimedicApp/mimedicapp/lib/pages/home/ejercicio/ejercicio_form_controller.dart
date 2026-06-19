import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/models/ejercicio.dart';

abstract class EjercicioUsuarioFormController {
  GlobalKey<FormState> get formKey;

  TextEditingController get nombreCtrl;
  TextEditingController get notasCtrl;
  TextEditingController get duracionCtrl;

  Rxn<TimeOfDay> get hora;

  RxList<Ejercicio> get ejercicios;

  RxBool get isLoading;
  RxBool get isFormValid;

  Future<void> seleccionarHora();
  Future<void> guardar();
}