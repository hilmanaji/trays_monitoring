# Tray Monitoring (RFID Tray Tracking)

Aplikasi handheld Flutter untuk melacak tray produksi berbasis RFID UHF, dijalankan di perangkat
**UROVO DT50(P)**.

## Mulai cepat

```bash
flutter pub get
flutter run --dart-define=API_SERVER_URL=http://<alamat-server>
```

Tanpa `--dart-define`, aplikasi memakai server default `http://192.168.62.38/api/v1`.

```bash
flutter analyze
flutter test
flutter build apk --release --dart-define=API_SERVER_URL=<url-produksi>
```

## Dokumentasi

📘 **[Dokumentasi Teknis Lengkap](docs/TECHNICAL_DOCUMENTATION.md)** — arsitektur, kontrak API,
subsistem RFID, design system, panduan developer untuk menambah fitur, keterbatasan yang diketahui,
troubleshooting, dan checklist rilis.
