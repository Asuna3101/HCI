import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/configs/colors.dart';
import 'recover_controller.dart';

class RecoverPage extends StatelessWidget {
  const RecoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RecoverController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar cuenta'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Te enviaremos un código de 4 dígitos a tu correo.',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: c.emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Obx(() => ElevatedButton(
                    onPressed: c.isSending.value ? null : c.sendCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: c.isSending.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Enviar código'),
                  )),
              const SizedBox(height: 16),
              Obx(() {
                if (!c.isSending.value && c.lastEmailSent.isNotEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Te enviamos un código de recuperación a tu correo:',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          c.lastEmailSent.value,
                          style: const TextStyle(
                              fontSize: 15, color: AppColors.primary),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 8),
              const Text(
                'Código de verificación',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _CodeInput(controller: c.codeCtrl),
              const SizedBox(height: 16),
              TextField(
                controller: c.passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nueva contraseña',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: c.confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar contraseña',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: c.isConfirming.value ? null : c.confirm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: AppColors.primary,
                      ),
                      child: c.isConfirming.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Actualizar contraseña'),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _CodeInput extends StatefulWidget {
  final TextEditingController controller;
  const _CodeInput({required this.controller});

  @override
  State<_CodeInput> createState() => _CodeInputState();
}

class _CodeInputState extends State<_CodeInput> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller,
            builder: (_, value, __) {
              final text = value.text;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final ch = i < text.length ? text[i] : '';
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      ch.isEmpty ? '_' : ch,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: ch.isEmpty
                            ? AppColors.primary.withOpacity(0.55)
                            : AppColors.primary,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          SizedBox(
            height: 0,
            width: 0,
            child: TextField(
              focusNode: _focusNode,
              controller: widget.controller,
              maxLength: 4,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              cursorColor: AppColors.primary,
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(color: Colors.transparent, fontSize: 1),
            ),
          ),
        ],
      ),
    );
  }
}
