import '../../domain/entities/stock_by_tray_type.dart';
import '../../domain/entities/tray_type.dart';

class ProjectStockSummary {
  const ProjectStockSummary({required this.project, required this.total});

  final String project;
  final int total;
}

class ProjectStockSummaryBuilder {
  const ProjectStockSummaryBuilder._();

  static List<ProjectStockSummary> build(
    List<StockByTrayType> stockItems,
    List<TrayType> trayTypes,
  ) {
    final projectById = <int, String>{};
    final projectByAlias = <String, String>{};

    for (final trayType in trayTypes) {
      final project = _cleanProject(trayType.project);
      projectById[trayType.id] = project;

      for (final alias in <String>{
        trayType.name,
        trayType.code,
        trayType.description,
      }) {
        final normalized = _normalize(alias);
        if (normalized.isNotEmpty) {
          projectByAlias[normalized] = project;
        }
      }
    }

    final totals = <String, int>{};
    for (final stock in stockItems) {
      if (stock.total <= 0) {
        continue;
      }

      final project = _resolveProject(stock, trayTypes, projectById, projectByAlias);
      totals.update(project, (current) => current + stock.total, ifAbsent: () => stock.total);
    }

    final summaries = totals.entries
        .map((entry) => ProjectStockSummary(project: entry.key, total: entry.value))
        .toList()
      ..sort((left, right) {
        final totalCompare = right.total.compareTo(left.total);
        if (totalCompare != 0) {
          return totalCompare;
        }
        return left.project.compareTo(right.project);
      });

    return summaries;
  }

  static String _resolveProject(
    StockByTrayType stock,
    List<TrayType> trayTypes,
    Map<int, String> projectById,
    Map<String, String> projectByAlias,
  ) {
    final byId = projectById[stock.trayTypeId];
    if (byId != null && byId.isNotEmpty) {
      return byId;
    }

    final normalizedName = _normalize(stock.trayTypeName);
    final direct = projectByAlias[normalizedName];
    if (direct != null && direct.isNotEmpty) {
      return direct;
    }

    for (final trayType in trayTypes) {
      final aliases = <String>[
        trayType.name,
        trayType.code,
        trayType.description,
      ].map(_normalize).where((value) => value.isNotEmpty);

      for (final alias in aliases) {
        if (alias == normalizedName ||
            alias.contains(normalizedName) ||
            normalizedName.contains(alias)) {
          return _cleanProject(trayType.project);
        }
      }
    }

    return 'Unassigned';
  }

  static String _cleanProject(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? 'Unassigned' : normalized;
  }

  static String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }
}