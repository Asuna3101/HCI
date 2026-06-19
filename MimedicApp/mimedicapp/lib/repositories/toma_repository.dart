import 'package:mimedicapp/services/toma_service.dart';
import 'package:mimedicapp/models/toma.dart';

class TomaRepository {
  final TomaService _service;
  TomaRepository([TomaService? service]) : _service = service ?? TomaService();

  Future<List<Toma>> getPendingTomas({DateTime? at}) => _service.getPendingTomas(at: at);

  Future<void> markTomado(int tomaId, bool tomado) => _service.markTomado(tomaId, tomado);

  Future<int> postponeTomas(int tomaId, int minutes) => _service.postponeTomas(tomaId, minutes);
}
