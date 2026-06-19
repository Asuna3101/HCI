import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/models/clinic.dart';
import 'package:mimedicapp/models/specialty.dart';
import 'package:mimedicapp/models/doctor.dart';

/// Interfaz que expone el mínimo que necesita `CitaFormPage`.
/// Permite usar tanto el controlador de creación como el de edición.
abstract class CitaFormInterface {
  // Combos
  RxList<Clinic> get clinicas;
  RxList<Specialty> get especialidades;
  RxList<Doctor> get doctores;

  Rxn<Clinic> get clinicaSel;
  Rxn<Specialty> get especialidadSel;
  Rxn<Doctor> get doctorSel;

  // Fecha/hora y notas
  Rxn<DateTime> get fecha;
  Rxn<TimeOfDay> get hora;
  TextEditingController get notasCtrl;
  RxBool get cargando;

  String get fechaLabel;
  String get horaLabel;

  // Acciones
  void resetForm({bool keepCatalogs = true});
  Future<void> seleccionarFecha();
  Future<void> seleccionarHora();
  Future<void> onClinicaChanged(Clinic? c);
  Future<void> onEspecialidadChanged(Specialty? s);
  Future<void> guardar();
}
