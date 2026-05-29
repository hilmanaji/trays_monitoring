import 'package:flutter_test/flutter_test.dart';
import 'package:trays_monitoring/domain/entities/stock_by_tray_type.dart';
import 'package:trays_monitoring/domain/entities/tray_type.dart';
import 'package:trays_monitoring/presentation/utils/project_stock_summary.dart';

void main() {
  group('ProjectStockSummaryBuilder', () {
    test('aggregates stock totals by tray project', () {
      final summary = ProjectStockSummaryBuilder.build(
        const [
          StockByTrayType(trayTypeId: 11, trayTypeName: 'D01N', total: 3),
          StockByTrayType(trayTypeId: 10, trayTypeName: 'D58A', total: 2),
          StockByTrayType(trayTypeId: 12, trayTypeName: 'P59', total: 4),
        ],
        const [
          TrayType(
            id: 11,
            code: 'PKG-T049',
            name: 'D01N',
            description: 'TRAY D01N_500x350x20',
            project: 'AJI',
          ),
          TrayType(
            id: 10,
            code: 'PKG-T076',
            name: 'D58A',
            description: 'TRAY D58A_500x350x38',
            project: 'AJI',
          ),
          TrayType(
            id: 12,
            code: 'PKG-T193',
            name: 'P59',
            description: 'TRAY P59_500x350x42',
            project: 'ICHIKOH',
          ),
        ],
      );

      expect(summary.length, 2);
      expect(summary.first.project, 'AJI');
      expect(summary.first.total, 5);
      expect(summary.last.project, 'ICHIKOH');
      expect(summary.last.total, 4);
    });

    test('falls back to alias matching when tray type id is unavailable', () {
      final summary = ProjectStockSummaryBuilder.build(
        const [
          StockByTrayType(
            trayTypeId: 0,
            trayTypeName: 'TRAY AJI D58A_500x350x38MM',
            total: 2,
          ),
        ],
        const [
          TrayType(
            id: 10,
            code: 'PKG-T076',
            name: 'D58A',
            description: 'TRAY AJI D58A_500x350x38MM',
            project: 'AJI',
          ),
        ],
      );

      expect(summary.single.project, 'AJI');
      expect(summary.single.total, 2);
    });
  });
}