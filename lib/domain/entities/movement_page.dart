import 'tray_movement.dart';

class MovementPage {
  const MovementPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  final List<TrayMovement> items;
  final int currentPage;
  final int lastPage;
  final int total;

  bool get hasPrevious => currentPage > 1;
  bool get hasNext => currentPage < lastPage;
}
