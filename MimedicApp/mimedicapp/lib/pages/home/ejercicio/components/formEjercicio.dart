import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/configs/colors.dart';
import 'package:mimedicapp/pages/home/ejercicio/ejercicio_form_controller.dart';

class FormEjercicioUsuario extends StatelessWidget {
  final EjercicioUsuarioFormController controller;

  const FormEjercicioUsuario({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Form(
      key: c.formKey,
      child: ListView(
        children: [
          Autocomplete<String>(
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }

              return c.ejercicios.map((e) => e.nombre).where((nombre) => nombre
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()));
            },
            fieldViewBuilder: (context, textCtrl, focusNode, onFieldSubmitted) {
              if (textCtrl.text.isEmpty && c.nombreCtrl.text.isNotEmpty) {
                textCtrl.text = c.nombreCtrl.text;
              }

              textCtrl.addListener(() {
                c.nombreCtrl.text = textCtrl.text;
              });

              return TextFormField(
                controller: textCtrl,
                focusNode: focusNode,
                decoration: const InputDecoration(labelText: 'Ejercicio'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requerido';
                  return null;
                },
                maxLines: null,
                maxLength: 20,
                buildCounter: (_,
                        {required currentLength,
                        required isFocused,
                        maxLength}) =>
                    null,
              );
            },
            onSelected: (selection) {
              c.nombreCtrl.text = selection;
            },
          ),
          const SizedBox(height: 18),
          TextFormField(
              controller: c.duracionCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration:
                  const InputDecoration(labelText: 'Duración (minutos)'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Requerido';
                final num? parsed = num.tryParse(v);
                if (parsed == null) return 'Debe ser número';
                if (parsed <= 0) return 'Debe ser mayor que 0';
                return null;
              },
              maxLines: null,
              maxLength: 3,
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,),
          const SizedBox(height: 22),
          Obx(() => ListTile(
                title: Text(
                  c.hora.value != null
                      ? "Hora: ${c.hora.value!.format(context)}"
                      : "Seleccionar hora",
                  style: const TextStyle(color: AppColors.primary),
                ),
                trailing:
                    const Icon(Icons.access_time, color: AppColors.accent),
                onTap: () => c.seleccionarHora(),
              )),
          const SizedBox(height: 22),
          TextFormField(
              controller: c.notasCtrl,
              decoration:
                  const InputDecoration(labelText: 'Descripción (opcional)'),
              maxLines: null,
              maxLength: 255),
          const SizedBox(height: 30),
          Obx(() => ElevatedButton.icon(
                onPressed: c.isFormValid.value ? c.guardar : null,
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.isFormValid.value
                      ? AppColors.accent
                      : AppColors.grey400,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              )),
        ],
      ),
    );
  }
}
