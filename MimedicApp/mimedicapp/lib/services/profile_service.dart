import 'package:mimedicapp/configs/api_config.dart';
import 'package:mimedicapp/services/api_service.dart';
import 'dart:io';

class ProfileService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> uploadPhotoFile(File file) async {
    final res = await _api.uploadFile(
      '/profile/me/photo',
      'file',
      file,
      auth: true,
      method: 'PUT',
    );
    return Map<String, dynamic>.from(res as Map);
  }

  Future<void> changePassword(
      {required String oldPassword, required String newPassword}) async {
    await _api.put(
      '${ApiConfig.baseUrl}/profile/me/password',
      {'old_password': oldPassword, 'new_password': newPassword},
      auth: true,
    );
  }

  Future<void> deleteAccount({required bool confirm}) async {
    await _api.delete(
      '${ApiConfig.baseUrl}/profile/me?confirm=$confirm',
      auth: true,
    );
  }

  Future<void> recoverAccount({required String email}) async {
    await _api.post(
      '${ApiConfig.baseUrl}/profile/recover',
      {'email': email},
      auth: false,
    );
  }
}
