import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/pages/container/container_page.dart';
import 'package:mimedicapp/pages/home/citas/citas_page.dart';
import 'package:mimedicapp/pages/inicio/inicio_pantalla.dart';
import 'package:mimedicapp/pages/registro/registro_pantalla.dart';
import 'package:mimedicapp/pages/login/login_pantalla.dart';
import 'package:mimedicapp/pages/login/recover_page.dart';
import 'package:mimedicapp/configs/app_theme.dart';
import 'package:mimedicapp/pages/container/container_controller.dart';
import 'package:mimedicapp/services/api_service.dart';
import 'package:mimedicapp/services/health_service.dart';
import 'package:mimedicapp/pages/home/citas/citas_controller.dart';
import 'package:mimedicapp/widgets/global_toma_listener.dart';
import 'package:mimedicapp/repositories/toma_repository.dart';
import 'package:mimedicapp/pages/login/recover_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MimedicApp());
}

class MimedicApp extends StatelessWidget {
  const MimedicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MimedicApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      themeMode: ThemeMode.light,
      initialBinding: BindingsBuilder(() {
        Get.put<ApiService>(ApiService(), permanent: true);
        Get.put<HealthService>(HealthService(), permanent: true);
      }),

      initialRoute: '/inicio',
      getPages: [
        GetPage(name: '/inicio', page: () => PaginaInicio()),
        GetPage(name: '/sign-up', page: () => const PaginaRegistro()),
        GetPage(name: '/sign-in', page: () => const PaginaLogin()),
        GetPage(
            name: '/recover',
            page: () => const RecoverPage(),
            binding: BindingsBuilder(() {
              Get.lazyPut<RecoverController>(() => RecoverController(),
                  fenix: true);
            })),
        GetPage(
          name: '/app',
          page: () => Stack(
            children: [
              const ContainerPage(),
              // Global listener only active while inside the main app
              GlobalTomaListener(repo: TomaRepository()),
            ],
          ),
          binding: BindingsBuilder(() {
            Get.put<ContainerController>(ContainerController(), permanent: true);
            Get.lazyPut<CitasListController>(() => CitasListController(Get.find<HealthService>()), fenix: true,);
            // Registrar la implementación bajo la interfaz para que páginas busquen por la interfaz
            //Get.lazyPut<CitaFormInterface>(() => AgregarCitaFormController(Get.find<HealthService>()), fenix: true,);
          }),
        ),
        GetPage(name: '/citas', page: () => const CitasPage()),
        //GetPage(name: '/citas/nuevo', page: () => const AgregarCitaPage()),
      ],
    );
  }
}
