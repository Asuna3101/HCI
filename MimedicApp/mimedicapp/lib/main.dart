import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mimedicapp/configs/app_theme.dart';
import 'package:mimedicapp/pages/configuracion/theme_controller.dart';
import 'package:mimedicapp/pages/container/container_controller.dart';
import 'package:mimedicapp/pages/container/container_page.dart';
import 'package:mimedicapp/pages/home/home_controller.dart';
import 'package:mimedicapp/pages/inicio/inicio_pantalla.dart';
import 'package:mimedicapp/pages/login/login_pantalla.dart';
import 'package:mimedicapp/pages/login/recover_controller.dart';
import 'package:mimedicapp/pages/login/recover_page.dart';
import 'package:mimedicapp/pages/logros/logros_controller.dart';
import 'package:mimedicapp/pages/progreso/progreso_controller.dart';
import 'package:mimedicapp/pages/registro/registro_pantalla.dart';
import 'package:mimedicapp/services/api_service.dart';
import 'package:mimedicapp/services/habits_service.dart';
import 'package:mimedicapp/services/notifications_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es_ES', null);
  await NotificationsService().init();

  // Registrar el ThemeController ANTES de iniciar la app
  Get.put(ThemeController(), permanent: true);

  runApp(const HabitQuestApp());
}

class HabitQuestApp extends StatelessWidget {
  const HabitQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'HabitQuest',
      debugShowCheckedModeBanner: false,

      // Temas
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),

      // El ThemeController cambiará esto automáticamente con Get.changeThemeMode()
      themeMode: ThemeMode.system,

      initialBinding: BindingsBuilder(() {
        Get.put<ApiService>(
          ApiService(),
          permanent: true,
        );

        Get.put<HabitsService>(
          HabitsService(Get.find<ApiService>()),
          permanent: true,
        );
      }),

      initialRoute: '/inicio',

      getPages: [
        GetPage(
          name: '/inicio',
          page: () => PaginaInicio(),
        ),

        GetPage(
          name: '/sign-up',
          page: () => const PaginaRegistro(),
        ),

        GetPage(
          name: '/sign-in',
          page: () => const PaginaLogin(),
        ),

        GetPage(
          name: '/recover',
          page: () => const RecoverPage(),
          binding: BindingsBuilder(() {
            Get.lazyPut<RecoverController>(
              () => RecoverController(),
              fenix: true,
            );
          }),
        ),

        GetPage(
          name: '/app',
          page: () => const ContainerPage(),
          binding: BindingsBuilder(() {
            Get.put<ContainerController>(
              ContainerController(),
              permanent: true,
            );

            Get.put<HomeController>(
              HomeController(Get.find<HabitsService>()),
              permanent: true,
            );

            Get.put<ProgresoController>(
              ProgresoController(Get.find<HabitsService>()),
              permanent: true,
            );

            Get.put<LogrosController>(
              LogrosController(Get.find<HabitsService>()),
              permanent: true,
            );
          }),
        ),
      ],
    );
  }
}