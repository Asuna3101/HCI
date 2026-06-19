import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mimedicapp/services/user_service.dart';
import 'package:mimedicapp/services/profile_service.dart';
import 'dart:io';

class ProfileController extends GetxController {
  final UserService _userService = UserService();
  final ProfileService _profileService = ProfileService();

  final isLoading = false.obs;
  final nombre = ''.obs;
  final correo = ''.obs;
  final celular = ''.obs;
  final fechaNacimiento = Rxn<DateTime>();
  final fotoBase64 = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      final user = await _userService.getCurrentUser();
      nombre.value = user.nombre;
      correo.value = user.correo;
      celular.value = user.celular;
      fechaNacimiento.value = user.fechaNacimiento;
      fotoBase64.value = user.foto ?? '';
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cargar el perfil: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword(
      {required String oldPass, required String newPass}) async {
    await _profileService.changePassword(
        oldPassword: oldPass, newPassword: newPass);
  }

  Future<void> deleteAccount() async {
    await _profileService.deleteAccount(confirm: true);
    Get.snackbar('Cuenta', 'Cuenta desactivada',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2));
  }

  Future<void> recoverAccount(String email) async {
    await _profileService.recoverAccount(email: email);
    Get.snackbar('Recuperación',
        'Si existe el correo, se enviaron instrucciones',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2));
  }

  Future<void> pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    final res = await _profileService.uploadPhotoFile(File(picked.path));
    if (res['photo'] is String) {
      fotoBase64.value = res['photo'] as String;
    }
    await loadProfile();
  }

  Future<void> logout() async {
    try {
      await _userService.logout();
    } catch (_) {}
    Get.offAllNamed('/sign-in');
  }
}
