import 'package:flutter_test/flutter_test.dart';
import 'package:trays_monitoring/data/models/stock_by_tray_type_model.dart';

void main() {
  group('StockByTrayTypeModel', () {
    test('parses pivot-style stock rows from backend', () {
      final model = StockByTrayTypeModel.fromJson(<String, dynamic>{
        'tray_type': 'D01N',
        'FG': 1,
        'WH': 2,
        'SCRAP': 0,
      });

      expect(model.trayTypeName, 'D01N');
      expect(model.total, 3);
    });

    test('parses nested tray_type payloads', () {
      final model = StockByTrayTypeModel.fromJson(<String, dynamic>{
        'tray_type_id': 11,
        'total': 4,
        'tray_type': <String, dynamic>{
          'model': 'D58A',
          'material_description': 'TRAY AJI D58A_500x350x38MM',
        },
      });

      expect(model.trayTypeId, 11);
      expect(model.trayTypeName, 'D58A');
      expect(model.total, 4);
    });
  });
}