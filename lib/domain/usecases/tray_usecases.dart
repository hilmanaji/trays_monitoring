import '../entities/register_rfid_request.dart';
import '../entities/scrap_request.dart';
import '../entities/tray.dart';
import '../repositories/tray_repository.dart';

class RegisterRfidUseCase {
  RegisterRfidUseCase(this._repository);

  final TrayRepository _repository;

  Future<void> call(RegisterRfidRequest request) {
    return _repository.registerRfid(request);
  }
}

class GetTraysUseCase {
  GetTraysUseCase(this._repository);

  final TrayRepository _repository;

  Future<List<Tray>> call({String? search}) {
    return _repository.getTrays(search: search);
  }
}

class GetTrayDetailUseCase {
  GetTrayDetailUseCase(this._repository);

  final TrayRepository _repository;

  Future<Tray> call(int id) {
    return _repository.getTrayDetail(id);
  }
}

class ScrapTrayUseCase {
  ScrapTrayUseCase(this._repository);

  final TrayRepository _repository;

  Future<void> call(ScrapRequest request) {
    return _repository.scrapTray(request);
  }
}
