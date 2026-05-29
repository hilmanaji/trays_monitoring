import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/hive_storage_service.dart';
import '../../core/storage/secure_token_storage.dart';
import '../../core/utils/feedback_service.dart';
import '../../core/utils/session_coordinator.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/master_data_remote_datasource.dart';
import '../../data/datasources/movement_remote_datasource.dart';
import '../../data/datasources/pending_movement_local_datasource.dart';
import '../../data/datasources/stock_remote_datasource.dart';
import '../../data/datasources/tray_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/master_data_repository_impl.dart';
import '../../data/repositories/movement_repository_impl.dart';
import '../../data/repositories/stock_repository_impl.dart';
import '../../data/repositories/tray_repository_impl.dart';
import '../../domain/entities/dashboard_snapshot.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/movement_page.dart';
import '../../domain/entities/pending_movement.dart';
import '../../domain/entities/stock_by_tray_type.dart';
import '../../domain/entities/stock_summary.dart';
import '../../domain/entities/tray.dart';
import '../../domain/entities/tray_type.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/master_data_repository.dart';
import '../../domain/repositories/movement_repository.dart';
import '../../domain/repositories/stock_repository.dart';
import '../../domain/repositories/tray_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/dashboard_usecases.dart';
import '../../domain/usecases/master_data_usecases.dart';
import '../../domain/usecases/movement_usecases.dart';
import '../../domain/usecases/stock_usecases.dart';
import '../../domain/usecases/tray_usecases.dart';
import '../../services/api/api_service.dart';
import '../../services/rfid/rfid_scanner_interface.dart';
import '../../services/rfid/rfid_service.dart';
import '../../services/rfid/simulated_rfid_scanner.dart';
import '../../services/rfid/urovo_dt50_rfid_scanner.dart';

final secureTokenStorageProvider = Provider<SecureTokenStorage>((ref) {
  return const SecureTokenStorage();
});

final sessionCoordinatorProvider = Provider<SessionCoordinator>((ref) {
  final coordinator = SessionCoordinator();
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

final hiveStorageServiceProvider = Provider<HiveStorageService>((ref) {
  return HiveStorageService.instance;
});

final operatorFeedbackServiceProvider = Provider<OperatorFeedbackService>((
  ref,
) {
  return OperatorFeedbackService();
});

final rfidScannerProvider = Provider<RFIDScannerInterface>((ref) {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    final scanner = UrovoDT50RfidScanner();
    ref.onDispose(scanner.dispose);
    return scanner;
  }

  final scanner = SimulatedRFIDScanner();
  ref.onDispose(scanner.dispose);
  return scanner;
});

final rfidServiceProvider = Provider<RFIDService>((ref) {
  return RFIDService(ref.watch(rfidScannerProvider));
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(
    ref.watch(secureTokenStorageProvider),
    ref.watch(sessionCoordinatorProvider),
  );
});

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(ref.watch(apiServiceProvider));
});

final masterDataRemoteDatasourceProvider = Provider<MasterDataRemoteDatasource>(
  (ref) {
    return MasterDataRemoteDatasource(ref.watch(apiServiceProvider));
  },
);

final trayRemoteDatasourceProvider = Provider<TrayRemoteDatasource>((ref) {
  return TrayRemoteDatasource(ref.watch(apiServiceProvider));
});

final movementRemoteDatasourceProvider = Provider<MovementRemoteDatasource>((
  ref,
) {
  return MovementRemoteDatasource(ref.watch(apiServiceProvider));
});

final stockRemoteDatasourceProvider = Provider<StockRemoteDatasource>((ref) {
  return StockRemoteDatasource(ref.watch(apiServiceProvider));
});

final pendingMovementLocalDatasourceProvider =
    Provider<PendingMovementLocalDatasource>((ref) {
      return PendingMovementLocalDatasource(
        ref.watch(hiveStorageServiceProvider),
      );
    });

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDatasourceProvider),
    ref.watch(secureTokenStorageProvider),
  );
});

final masterDataRepositoryProvider = Provider<MasterDataRepository>((ref) {
  return MasterDataRepositoryImpl(
    ref.watch(masterDataRemoteDatasourceProvider),
  );
});

final trayRepositoryProvider = Provider<TrayRepository>((ref) {
  return TrayRepositoryImpl(ref.watch(trayRemoteDatasourceProvider));
});

final movementRepositoryProvider = Provider<MovementRepository>((ref) {
  return MovementRepositoryImpl(
    ref.watch(movementRemoteDatasourceProvider),
    ref.watch(pendingMovementLocalDatasourceProvider),
  );
});

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  return StockRepositoryImpl(ref.watch(stockRemoteDatasourceProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final getLocationsUseCaseProvider = Provider<GetLocationsUseCase>((ref) {
  return GetLocationsUseCase(ref.watch(masterDataRepositoryProvider));
});

final getTrayTypesUseCaseProvider = Provider<GetTrayTypesUseCase>((ref) {
  return GetTrayTypesUseCase(ref.watch(masterDataRepositoryProvider));
});

final registerRfidUseCaseProvider = Provider<RegisterRfidUseCase>((ref) {
  return RegisterRfidUseCase(ref.watch(trayRepositoryProvider));
});

final getTraysUseCaseProvider = Provider<GetTraysUseCase>((ref) {
  return GetTraysUseCase(ref.watch(trayRepositoryProvider));
});

final getTrayDetailUseCaseProvider = Provider<GetTrayDetailUseCase>((ref) {
  return GetTrayDetailUseCase(ref.watch(trayRepositoryProvider));
});

final scrapTrayUseCaseProvider = Provider<ScrapTrayUseCase>((ref) {
  return ScrapTrayUseCase(ref.watch(trayRepositoryProvider));
});

final createTrayMovementUseCaseProvider = Provider<CreateTrayMovementUseCase>((
  ref,
) {
  return CreateTrayMovementUseCase(ref.watch(movementRepositoryProvider));
});

final getMovementHistoryUseCaseProvider = Provider<GetMovementHistoryUseCase>((
  ref,
) {
  return GetMovementHistoryUseCase(ref.watch(movementRepositoryProvider));
});

final savePendingMovementUseCaseProvider = Provider<SavePendingMovementUseCase>(
  (ref) {
    return SavePendingMovementUseCase(ref.watch(movementRepositoryProvider));
  },
);

final syncPendingMovementsUseCaseProvider =
    Provider<SyncPendingMovementsUseCase>((ref) {
      return SyncPendingMovementsUseCase(ref.watch(movementRepositoryProvider));
    });

final getStockSummaryUseCaseProvider = Provider<GetStockSummaryUseCase>((ref) {
  return GetStockSummaryUseCase(ref.watch(stockRepositoryProvider));
});

final getStockByTrayTypeUseCaseProvider = Provider<GetStockByTrayTypeUseCase>((
  ref,
) {
  return GetStockByTrayTypeUseCase(ref.watch(stockRepositoryProvider));
});

final getDashboardSnapshotUseCaseProvider =
    Provider<GetDashboardSnapshotUseCase>((ref) {
      return GetDashboardSnapshotUseCase(
        ref.watch(trayRepositoryProvider),
        ref.watch(masterDataRepositoryProvider),
        ref.watch(movementRepositoryProvider),
        ref.watch(stockRepositoryProvider),
      );
    });

final dashboardSnapshotProvider = FutureProvider<DashboardSnapshot>((ref) {
  return ref.watch(getDashboardSnapshotUseCaseProvider).call();
});

final locationsProvider = FutureProvider<List<Location>>((ref) {
  return ref.watch(getLocationsUseCaseProvider).call();
});

final trayTypesProvider = FutureProvider<List<TrayType>>((ref) {
  return ref.watch(getTrayTypesUseCaseProvider).call();
});

final stockSummaryProvider = FutureProvider<List<StockSummary>>((ref) {
  return ref.watch(getStockSummaryUseCaseProvider).call();
});

final stockByTrayTypeProvider = FutureProvider<List<StockByTrayType>>((ref) {
  return ref.watch(getStockByTrayTypeUseCaseProvider).call();
});

final pendingMovementsProvider = FutureProvider<List<PendingMovement>>((ref) {
  return ref.watch(movementRepositoryProvider).getPendingMovements();
});

final pendingSyncBootstrapProvider = FutureProvider<void>((ref) async {
  final connectivityResults = await Connectivity().checkConnectivity();
  if (!connectivityResults.contains(ConnectivityResult.none)) {
    await ref.read(syncPendingMovementsUseCaseProvider).call();
  }
});

final trayDetailProvider = FutureProvider.family<Tray, int>((ref, trayId) {
  return ref.watch(getTrayDetailUseCaseProvider).call(trayId);
});

final trayListProvider = FutureProvider.family<List<Tray>, TraySearchQuery>((
  ref,
  query,
) {
  return ref.watch(getTraysUseCaseProvider).call(search: query.search);
});

final movementHistoryProvider =
    FutureProvider.family<MovementPage, MovementHistoryQuery>((ref, query) {
      return ref
          .watch(getMovementHistoryUseCaseProvider)
          .call(
            page: query.page,
            search: query.search,
            locationId: query.locationId,
            date: query.date,
          );
    });

@immutable
class TraySearchQuery {
  const TraySearchQuery({this.search = ''});

  final String search;

  @override
  bool operator ==(Object other) {
    return other is TraySearchQuery && other.search == search;
  }

  @override
  int get hashCode => search.hashCode;
}

@immutable
class MovementHistoryQuery {
  const MovementHistoryQuery({
    this.page = 1,
    this.search = '',
    this.locationId,
    this.date,
  });

  final int page;
  final String search;
  final int? locationId;
  final DateTime? date;

  @override
  bool operator ==(Object other) {
    return other is MovementHistoryQuery &&
        other.page == page &&
        other.search == search &&
        other.locationId == locationId &&
        other.date == date;
  }

  @override
  int get hashCode => Object.hash(page, search, locationId, date);
}
