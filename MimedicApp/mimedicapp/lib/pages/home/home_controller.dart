import 'package:get/get.dart';
import 'package:mimedicapp/pages/home/home_routes.dart';

class HomeController extends GetxController {
  void goToMedicacion() => Get.toNamed(HomeRoutes.medicacion, id: 1);
  void goToCitas() => Get.toNamed(HomeRoutes.citas, id: 1);
  void goToComidas() => Get.toNamed(HomeRoutes.comidas, id: 1);
  void goToEjercicio() => Get.toNamed(HomeRoutes.ejercicio, id: 1);
  void goToReportes() => Get.toNamed(HomeRoutes.reportes, id: 1);
}