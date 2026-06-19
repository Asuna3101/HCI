import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/configs/colors.dart';
import '../../comida_form_controller.dart';

class FormAgregarComida extends StatelessWidget {
  final ComidaFormController controller;

  const FormAgregarComida({
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
          // Campo de nombre con autocompletado (disponible en ambos modos)
          Autocomplete<Map<String, dynamic>>(
            initialValue: TextEditingValue(text: c.nombreCtrl.text),
            displayStringForOption: (option) =>
                option['nombre'] as String? ?? '',
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<Map<String, dynamic>>.empty();
              }

              // Filtrar sugerencias
              return c.sugerencias.where((comida) {
                final nombre =
                    (comida['nombre'] as String? ?? '').toLowerCase();
                return nombre.contains(textEditingValue.text.toLowerCase());
              });
            },
            fieldViewBuilder: (context, textCtrl, focusNode, onFieldSubmitted) {
              // Sincronizar con nombreCtrl
              textCtrl.addListener(() {
                c.nombreCtrl.text = textCtrl.text;
              });

              return TextFormField(
                controller: textCtrl,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: 'Nombre de la comida *',
                  hintText: c.isEditMode
                      ? 'Editar nombre de la comida'
                      : 'Ej: Manzana, Pizza, etc.',
                  prefixIcon: const Icon(Icons.restaurant),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
                maxLines: null,
                maxLength: 100,
                buildCounter: (_,
                        {required currentLength,
                        required isFocused,
                        maxLength}) =>
                    null,
              );
            },
            onSelected: (Map<String, dynamic> selection) {
              c.seleccionarSugerencia(selection);
            },
          ),

          const SizedBox(height: 16),

          // Descripción
          TextFormField(
            controller: c.descripcionCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descripción (opcional)',
              hintText: 'Añade detalles sobre la comida...',
              alignLabelWithHint: true,
            ),
            maxLength: 500,
            buildCounter: (_,
                    {required currentLength, required isFocused, maxLength}) =>
                null,
          ),

          const SizedBox(height: 24),

          // Categoría
          const Text(
            'Categoría *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            if (c.categorias.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return Column(
              children: c.categorias.map((cat) {
                final id = cat['id'] as int?;
                final nombre = cat['nombre'] as String? ?? '';
                final isRecomendable = id == 1;

                return RadioListTile<int>(
                  value: id ?? 0,
                  groupValue: c.categoriaSeleccionada.value,
                  onChanged: (value) {
                    c.categoriaSeleccionada.value = value;
                  },
                  title: Text(nombre),
                  secondary: Icon(
                    isRecomendable ? Icons.thumb_up : Icons.thumb_down,
                    color: isRecomendable ? Colors.green : Colors.red,
                  ),
                  activeColor: AppColors.primary,
                );
              }).toList(),
            );
          }),

          const SizedBox(height: 32),

          // Botón guardar
          Obx(() => ElevatedButton.icon(
                onPressed: c.isLoading.value ? null : c.guardar,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Comida'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      c.isLoading.value ? AppColors.grey400 : AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontFamily: 'Titulo',
                    fontSize: 18,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
