import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/pages/home/citas/citas_page.dart';
import 'package:mimedicapp/pages/home/ejercicio/agregarEjercicio/agregarEjercicio_page.dart';
import 'package:mimedicapp/pages/home/ejercicio/editarEjercicio/editarEjercicio_page.dart';
import 'package:mimedicapp/pages/home/medicacion/agregarMedicamento/agregarMedicamento_page.dart';
import 'package:mimedicapp/pages/home/medicacion/editarMedicamento/editarMedicamento_page.dart';
import 'package:mimedicapp/pages/home/reportes/reportes_page.dart';
import 'home_controller.dart';
import 'home_page.dart';
import 'home_routes.dart';
import 'package:mimedicapp/pages/home/medicacion/medicacion_page.dart';
import 'package:mimedicapp/pages/home/comidas/comidas_page.dart';
import 'package:mimedicapp/pages/home/comidas/agregarComida/agregarComida_page.dart';
import 'package:mimedicapp/pages/home/comidas/editarComida/editarComida_page.dart';
import 'package:mimedicapp/pages/home/ejercicio/ejercicio_page.dart';
import 'package:mimedicapp/pages/home/citas/formulario_cita_medica/agregar_cita_page.dart';
import 'package:mimedicapp/pages/home/citas/formulario_cita_medica/editar_cita_page.dart';

class HomeNavigator extends StatelessWidget {
  const HomeNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());

    final routeBuilders = <String, WidgetBuilder>{
      HomeRoutes.inicio: (_) => const HomePage(),
      HomeRoutes.medicacion: (_) => const MedicacionPage(),
      // HomeRoutes.citas:      (_) => const CitasListPage(),
      HomeRoutes.comidas: (_) => const ComidasPage(),
      HomeRoutes.agregarComida: (_) => const AgregarComidaPage(),
      HomeRoutes.editarComida: (_) => const EditarComidaPage(),
      HomeRoutes.ejercicio: (_) => const EjercicioPage(),
      HomeRoutes.reportes: (_) => const ReportesPage(),
      HomeRoutes.agregarMedicamento: (_) => const AgregarMedicamentoPage(),
      HomeRoutes.editarMedicamento: (_) => const EditarMedicamentoPage(),
      HomeRoutes.citas: (_) => const CitasPage(),
      HomeRoutes.agregarCita: (_) => const AgregarCitaPage(),
      HomeRoutes.editarCita: (_) => const EditarCitaPage(),
      HomeRoutes.agregarEjercicio: (_) => const AgregarEjercicioUsuarioPage(),
      HomeRoutes.editarEjercicio: (_) => const EditarEjercicioUsuarioPage(),
    };

    return Navigator(
      key: Get.nestedKey(1),
      initialRoute: HomeRoutes.inicio,
      onGenerateRoute: (settings) {
        final builder = routeBuilders[settings.name];
        if (builder != null) {
          return MaterialPageRoute(
            builder: builder,
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
      },
    );
    // return Navigator(
    //   key: Get.nestedKey(1),
    //   initialRoute: HomeRoutes.inicio,
    //   onGenerateRoute: (settings) =>
    //       MaterialPageRoute(builder: routes[settings.name] ?? (_) =>
    //       const Scaffold(body: Center(child: Text('Ruta no encontrada'))),
    //           settings: settings),
    // );
  }
}
