# Dokumentasi Teknis — Tray Monitoring (RFID Tray Tracking)

Dokumen ini adalah rujukan teknis lengkap untuk aplikasi **`trays_monitoring`**: arsitektur, kontrak API,
subsistem RFID, design system, serta **panduan langkah demi langkah** ketika ada perubahan atau penambahan fitur.

| | |
|---|---|
| **Nama paket** | `trays_monitoring` |
| **Versi** | `1.0.0+1` (`pubspec.yaml`) |
| **Dart SDK** | `^3.12.0` |
| **Flutter** | 3.44.0 stable (versi yang dipakai saat dokumen ini ditulis) |
| **Platform target utama** | Android — handheld **UROVO DT50(P)** (RFID Impinj E710/E510, barcode engine HS7) |
| **Platform lain** | Windows / Linux / macOS / Web / iOS — jalan dengan *simulated RFID scanner* (untuk development) |
| **Terakhir diperbarui** | 10 Agustus 2026 |

---

## Daftar Isi

1. [Ringkasan Aplikasi](#1-ringkasan-aplikasi)
2. [Setup & Menjalankan Aplikasi](#2-setup--menjalankan-aplikasi)
3. [Struktur Direktori](#3-struktur-direktori)
4. [Arsitektur](#4-arsitektur)
5. [Dependency Injection (Riverpod)](#5-dependency-injection-riverpod)
6. [Routing & Navigasi](#6-routing--navigasi)
7. [Autentikasi & Session](#7-autentikasi--session)
8. [Lapisan Jaringan (ApiService)](#8-lapisan-jaringan-apiservice)
9. [Kontrak API Backend](#9-kontrak-api-backend)
10. [Model & Konvensi Parsing JSON](#10-model--konvensi-parsing-json)
11. [Mode Offline & Sinkronisasi](#11-mode-offline--sinkronisasi)
12. [Subsistem RFID](#12-subsistem-rfid)
13. [Design System (TrayTrack Neo)](#13-design-system-traytrack-neo)
14. [Katalog Layar & Fitur](#14-katalog-layar--fitur)
15. [Testing](#15-testing)
16. [Panduan Developer — Cookbook](#16-panduan-developer--cookbook)
17. [Konvensi Kode](#17-konvensi-kode)
18. [Keterbatasan yang Diketahui & Utang Teknis](#18-keterbatasan-yang-diketahui--utang-teknis)
19. [Troubleshooting](#19-troubleshooting)
20. [Checklist Rilis](#20-checklist-rilis)

---

## 1. Ringkasan Aplikasi

Aplikasi handheld untuk **melacak tray produksi berbasis RFID UHF** di gudang/lantai produksi SIIX.
Operator memakai perangkat UROVO DT50(P); tag EPC dibaca lewat tombol trigger fisik, lalu dikirim ke backend REST.

Kemampuan utama:

| Modul | Deskripsi |
|---|---|
| **Dashboard** | KPI (total tray, lokasi, stok, movement), aktivitas terakhir, stok per project, badge antrean offline |
| **RFID Scan / Movement** | Scan banyak tag sekaligus → pilih lokasi asal & tujuan → submit perpindahan tray |
| **Register RFID** | Registrasi tag EPC baru ke tray type + lokasi awal, dengan deteksi duplikat |
| **Stock** | Ringkasan stok per lokasi dan per tray type / project |
| **Find (Geiger)** | Mode pencarian satu tray: meter melingkar + haptic yang menguat saat mendekat |
| **Movement History** | Riwayat perpindahan, berpaginasi, filter search/lokasi/tanggal |
| **Scrap** | Pencatatan tray yang di-*write-off* beserta alasan |
| **Tray Directory** | Daftar & detail tray |
| **Profile / Settings** | Info operator, preferensi reader (power, region, beep, haptic, glove mode) |
| **Offline queue** | Movement yang gagal karena jaringan disimpan lokal (Hive) dan disinkronkan kemudian |

---

## 2. Setup & Menjalankan Aplikasi

### 2.1 Prasyarat

- Flutter SDK **3.44.0** (stable) atau lebih baru dengan Dart `^3.12.0`
- Android SDK + JDK **17** (Kotlin/Java `jvmTarget = 17`)
- Perangkat UROVO DT50(P) untuk pengujian RFID sesungguhnya
- Akses jaringan ke server API (lihat [§2.3](#23-konfigurasi-endpoint-api))

### 2.2 Instalasi

```bash
flutter pub get
flutter analyze          # lint: package:flutter_lints/flutter.yaml
flutter test             # unit + widget test
flutter run              # debug di device terpasang
```

### 2.3 Konfigurasi endpoint API

Endpoint diatur di [api_constants.dart](lib/core/constants/api_constants.dart) dan **dapat di-override saat build**
tanpa mengubah kode, lewat `--dart-define`:

| `--dart-define` | Default | Fungsi |
|---|---|---|
| `API_SERVER_URL` | `http://192.168.62.38` | Host + scheme server |
| `API_PATH_PREFIX` | `/api/v1` | Prefix path API (kosongkan untuk tanpa prefix) |
| `API_BASE_URL` | *(kosong)* | Override penuh; jika diisi, dua variabel di atas diabaikan |

```bash
# Contoh: build untuk server staging
flutter run --dart-define=API_SERVER_URL=http://access-siix.test:8080

# Contoh: base URL penuh
flutter build apk --release --dart-define=API_BASE_URL=https://api.siix.co.id/api/v1
```

> **Catatan:** `AndroidManifest.xml` mengaktifkan `android:usesCleartextTraffic="true"` karena server internal
> masih HTTP. Jika nanti pindah ke HTTPS, matikan flag ini.

### 2.4 Build

```bash
flutter build apk --release --dart-define=API_SERVER_URL=<url-produksi>
flutter build appbundle --release --dart-define=API_SERVER_URL=<url-produksi>
```

⚠️ Saat ini `android/app/build.gradle.kts` masih memakai `applicationId = "com.example.trays_monitoring"`
dan **menandatangani release dengan debug key**. Keduanya wajib diganti sebelum distribusi resmi
(lihat [§20](#20-checklist-rilis)).

### 2.5 Dependensi native

File `Urv_RfidSerialPortSdk_v.2.0.6_release.jar` di root proyek adalah SDK serial-port RFID UROVO.
Di-*link* melalui:

```kotlin
// android/app/build.gradle.kts
dependencies {
    implementation(files("../../Urv_RfidSerialPortSdk_v.2.0.6_release.jar"))
}
```

Jangan pindahkan/rename file JAR tanpa memperbarui path relatif di atas.

---

## 3. Struktur Direktori

```
lib/
├── main.dart                       # Entry point: init Hive → ProviderScope → MaterialApp.router
├── core/                           # Utilitas lintas-lapisan, tanpa ketergantungan ke UI
│   ├── constants/api_constants.dart
│   ├── errors/app_exception.dart   # AppException + AppExceptionType
│   ├── storage/
│   │   ├── hive_storage_service.dart      # singleton box 'pending_movements'
│   │   └── secure_token_storage.dart      # flutter_secure_storage, key 'auth_token'
│   └── utils/
│       ├── date_time_formatter.dart
│       ├── feedback_service.dart          # bunyi + getar untuk operator
│       ├── json_utils.dart                # parsing JSON defensif
│       └── session_coordinator.dart       # broadcast event 401
├── domain/                         # Lapisan murni Dart — tidak boleh impor Flutter/Dio/Hive
│   ├── entities/                   # Objek bisnis (Tray, TrayMovement, User, …)
│   ├── repositories/               # Interface abstrak
│   └── usecases/                   # Satu kelas = satu aksi bisnis, dipanggil via .call()
├── data/                           # Implementasi domain
│   ├── datasources/                # Remote (Dio) & local (Hive)
│   ├── models/                     # `XModel extends X` + fromJson/toJson
│   └── repositories/               # `XRepositoryImpl implements XRepository`
├── presentation/
│   ├── providers/                  # Provider Riverpod + StateNotifier controller
│   ├── screens/                    # Satu folder per modul
│   ├── theme/                      # AppColors, AppSpacing, AppTheme, NeoScheme
│   ├── utils/project_stock_summary.dart
│   └── widgets/                    # Komponen design system yang dapat dipakai ulang
├── routes/app_router.dart          # GoRouter + redirect guard autentikasi
└── services/
    ├── api/api_service.dart        # Wrapper Dio + interceptor
    └── rfid/                       # Abstraksi scanner + implementasi UROVO & simulator

android/app/src/main/kotlin/com/example/trays_monitoring/
├── MainActivity.kt                 # mendaftarkan bridge RFID ke FlutterEngine
└── UrovoDt50RfidBridge.kt          # MethodChannel + EventChannel + BroadcastReceiver

assets/fonts/                       # Manrope 400–800 (SIL OFL) — di-bundle agar bisa offline
test/                               # Unit + widget test
```

---

## 4. Arsitektur

Aplikasi memakai **Clean Architecture** tiga lapis dengan **Riverpod** sebagai DI container.

```
┌──────────────────────────── PRESENTATION ─────────────────────────────┐
│  Screens (ConsumerWidget)                                             │
│      ↓ ref.watch / ref.read                                           │
│  Providers & StateNotifier Controllers                                │
└───────────────────────────────┬───────────────────────────────────────┘
                                │ memanggil UseCase
┌───────────────────────────────▼──────── DOMAIN ───────────────────────┐
│  UseCases  ──→  Repository (abstract)  ──→  Entities                  │
│  (Dart murni: tanpa Flutter, tanpa Dio, tanpa Hive)                   │
└───────────────────────────────┬───────────────────────────────────────┘
                                │ diimplementasi oleh
┌───────────────────────────────▼──────── DATA ─────────────────────────┐
│  RepositoryImpl  ──→  RemoteDatasource  ──→  ApiService (Dio)         │
│                  └──→  LocalDatasource   ──→  Hive                    │
│  Models (XModel extends X) melakukan fromJson/toJson                  │
└───────────────────────────────────────────────────────────────────────┘
                                │
┌───────────────────────────────▼──────── SERVICES ─────────────────────┐
│  ApiService (Dio + interceptor)   RFIDService → RFIDScannerInterface  │
│                                     ├── UrovoDT50RfidScanner (channel)│
│                                     └── SimulatedRFIDScanner          │
└───────────────────────────────────────────────────────────────────────┘
```

### Aturan ketergantungan (dependency rule)

| Lapisan | Boleh impor | **Tidak boleh** impor |
|---|---|---|
| `domain/` | hanya `domain/` | `data/`, `presentation/`, `services/`, package Flutter/Dio/Hive |
| `data/` | `domain/`, `core/`, `services/api` | `presentation/` |
| `presentation/` | `domain/`, `core/`, `services/` | `data/datasources` langsung (harus lewat repository provider) |
| `core/` | package pihak ketiga saja | `data/`, `domain/`, `presentation/` |

> Pengecualian yang ada saat ini: `presentation/providers/app_providers.dart` mengimpor `data/`
> karena file itulah *composition root*-nya (tempat wiring semua implementasi). Ini disengaja.

### Alur data — contoh "submit movement"

```
TrayMovementScreen
  → movementFormControllerProvider.notifier.submit(from, to)
    → CreateTrayMovementUseCase.call(MovementRequest)
      → MovementRepositoryImpl.createMovement()
        → MovementRemoteDatasource.createMovement()
          → ApiService.post('/tray-movements', {...})
            → Dio → backend
     ↩ jika AppException(network|timeout):
        → SavePendingMovementUseCase → PendingMovementLocalDatasource → Hive
```

---

## 5. Dependency Injection (Riverpod)

Semua provider *infrastruktur* terdaftar di **[app_providers.dart](lib/presentation/providers/app_providers.dart)**.
File ini adalah composition root — perubahan wiring hampir selalu terjadi di sini.

### Lapisan provider (urutan dari bawah ke atas)

```
secureTokenStorageProvider ─┐
sessionCoordinatorProvider ─┴─→ apiServiceProvider ─→ *RemoteDatasourceProvider ─┐
hiveStorageServiceProvider ────→ pendingMovementLocalDatasourceProvider ─────────┤
                                                                                 ↓
                                                              *RepositoryProvider
                                                                                 ↓
                                                                *UseCaseProvider
                                                                                 ↓
                              FutureProvider data (dashboardSnapshotProvider, …)
                              StateNotifierProvider controller (authController, …)
```

### Provider data (auto-fetch, dipakai langsung oleh UI)

| Provider | Tipe | Isi |
|---|---|---|
| `dashboardSnapshotProvider` | `FutureProvider<DashboardSnapshot>` | 5 request paralel via `Future.wait` |
| `locationsProvider` | `FutureProvider<List<Location>>` | Master lokasi |
| `trayTypesProvider` | `FutureProvider<List<TrayType>>` | Master tray type |
| `stockSummaryProvider` | `FutureProvider<List<StockSummary>>` | Stok per lokasi |
| `stockByTrayTypeProvider` | `FutureProvider<List<StockByTrayType>>` | Stok per tray type |
| `pendingMovementsProvider` | `FutureProvider<List<PendingMovement>>` | Antrean offline dari Hive |
| `pendingSyncBootstrapProvider` | `FutureProvider<void>` | Sinkronisasi sekali saat app start |
| `trayDetailProvider` | `FutureProvider.family<Tray, int>` | Detail tray by id |
| `trayListProvider` | `FutureProvider.family<List<Tray>, TraySearchQuery>` | Daftar tray + search |
| `movementHistoryProvider` | `FutureProvider.family<MovementPage, MovementHistoryQuery>` | Riwayat berpaginasi |

> Parameter `family` memakai **kelas `@immutable` dengan `==`/`hashCode` manual**
> (`TraySearchQuery`, `MovementHistoryQuery`) supaya cache Riverpod bekerja. Kalau menambah parameter
> baru, wajib memperbarui `operator ==` dan `hashCode` — kalau lupa, request akan dieksekusi ulang terus
> atau justru memakai cache yang salah.

### Controller (StateNotifier)

| Provider | State | Lokasi |
|---|---|---|
| `authControllerProvider` | `AuthState` | [auth_controller.dart](lib/presentation/providers/auth_controller.dart) |
| `movementFormControllerProvider` | `MovementFormState` | [movement_form_controller.dart](lib/presentation/providers/movement_form_controller.dart) |
| `registrationControllerProvider` | `SubmissionState` | [registration_controller.dart](lib/presentation/providers/registration_controller.dart) |
| `scrapControllerProvider` | `SubmissionState` | [scrap_controller.dart](lib/presentation/providers/scrap_controller.dart) |
| `findControllerProvider` | `FindState` | [find_screen.dart](lib/presentation/screens/find/find_screen.dart) *(co-located, `autoDispose`)* |
| `settingsProvider` | `AppSettings` | [settings_screen.dart](lib/presentation/screens/settings/settings_screen.dart) *(co-located)* |

Refresh data setelah mutasi:

```dart
ref.invalidate(dashboardSnapshotProvider);
ref.invalidate(pendingMovementsProvider);
```

---

## 6. Routing & Navigasi

Router: **go_router** di [app_router.dart](lib/routes/app_router.dart).

### Tabel rute

| Path | Layar | Di dalam `AppShell` |
|---|---|---|
| `/splash` | `SplashScreen` | ✗ |
| `/login` | `LoginScreen` | ✗ |
| `/dashboard` | `DashboardScreen` | ✓ |
| `/movement` | `TrayMovementScreen` | ✓ |
| `/stock` | `StockScreen` | ✓ |
| `/find` | `FindScreen` | ✓ |
| `/menu` | `MenuScreen` | ✓ |
| `/register` | `RfidRegistrationScreen` | ✓ |
| `/history` | `MovementHistoryScreen` | ✓ |
| `/scrap` | `ScrapScreen` | ✓ |
| `/profile` | `ProfileScreen` | ✓ |
| `/settings` | `SettingsScreen` | ✓ |
| `/trays` | `TrayListScreen` | ✓ |
| `/trays/detail/:id` | `TrayDetailScreen` | ✓ |

### Redirect guard

```dart
status == unknown || loading  →  paksa ke /splash
!isAuthenticated              →  paksa ke /login
authenticated && (di /login atau /splash)  →  /dashboard
```

Router di-*refresh* otomatis oleh `_RouterRefreshNotifier`, yang mendengarkan `authControllerProvider`.
Artinya: begitu `AuthState` berubah (login, logout, atau session expired), redirect langsung dievaluasi ulang.

### Bottom navigation

`AppShell` punya 5 tab: **Home / Scan / Stock / Find / Menu**.
Rute `/history`, `/scrap`, `/trays`, `/profile`, `/register`, `/settings` dianggap sub-rute dari tab **Menu**
(daftar `_menuSubRoutes` di [app_shell.dart:27](lib/presentation/widgets/app_shell.dart#L27)).

> **Menambah rute baru?** Selain menambah `GoRoute`, perbarui juga `_menuSubRoutes` dan `_titleFor()`
> di `AppShell`, kalau tidak tab yang aktif dan judul app bar akan salah.

---

## 7. Autentikasi & Session

### Alur login

```
LoginScreen (NIK + password)
  → AuthController.login()
    → LoginUseCase → AuthRepository.login()
      → POST /login  (form-urlencoded: nik, password)      ⇒ token
      → SecureTokenStorage.saveToken(token)
    → GetCurrentUser: GET /me                              ⇒ User
  → AuthState(status: authenticated, user: …)
  → router refresh → redirect ke /dashboard
```

### Bootstrap saat app dibuka

`AuthController` memanggil `bootstrap()` di konstruktor:
baca token → jika kosong ⇒ `unauthenticated`; jika ada ⇒ `GET /me`; jika gagal ⇒ token dihapus dan
status jadi `unauthenticated`.

### Penanganan 401 (session expired)

Mekanisme lintas-lapisan lewat `SessionCoordinator` (sebuah `ChangeNotifier`):

```
ApiService interceptor onError → status 401
  → SecureTokenStorage.clearToken()
  → SessionCoordinator.markUnauthorized()      // notifyListeners()
      → AuthController._handleUnauthorized()
        → clearSession() + AuthState(unauthenticated, "Your session expired…")
          → router refresh → /login
```

`AuthStatus`: `unknown` → `loading` → `authenticated` | `unauthenticated`.

Penyimpanan token: `flutter_secure_storage`, key **`auth_token`** ([secure_token_storage.dart](lib/core/storage/secure_token_storage.dart)).
Token disisipkan sebagai header `Authorization: Bearer <token>` oleh interceptor pada tiap request.

### Role

`User.roles` (list) diprioritaskan; kalau kosong, di-*fallback* ke `role` tunggal, lalu ke `'operator'`.
Getter yang tersedia: `resolvedRoles`, `primaryRole`, `rolesLabel`.

> Saat ini **belum ada authorization berbasis role di UI** — semua menu terbuka bagi semua user yang login.

---

## 8. Lapisan Jaringan (ApiService)

[api_service.dart](lib/services/api/api_service.dart) membungkus Dio dan menyediakan `get/post/put/delete`
yang mengembalikan `response.data` mentah (`dynamic`).

### Konfigurasi

| Item | Nilai |
|---|---|
| `baseUrl` | `ApiConstants.baseUrl` |
| `connectTimeout` / `sendTimeout` | 20 detik |
| `receiveTimeout` | 20 detik |
| Header default | `Accept: application/json`, `Content-Type: application/json` |

### Interceptor

1. **`QueuedInterceptorsWrapper.onRequest`** — membaca token dari secure storage dan menyisipkan header
   `Authorization`. Dipakai versi *queued* agar pembacaan token yang asinkron tidak balapan antar-request.
2. **`onError`** — memetakan `DioException` ke `AppException`, dan khusus 401 juga membersihkan token
   serta menandai session invalid.
3. **`LogInterceptor`** — hanya aktif pada `kDebugMode` (body request & response ikut dicetak).

### Pemetaan error → `AppExceptionType`

| Kondisi Dio | `AppExceptionType` | Pesan default |
|---|---|---|
| `connectionTimeout` / `receiveTimeout` / `sendTimeout` | `timeout` | "The server took too long to respond." |
| `connectionError` / `unknown` | `network` | "Network failure. Check your connection and try again." |
| HTTP 401 | `unauthorized` | "Your session has expired. Please sign in again." |
| HTTP 422 | `validation` | pesan dari body + `errors` map di `validationErrors` |
| HTTP ≥ 500 | `server` | pesan dari body, fallback "Server error. Please try again later." |
| lainnya | `unknown` | pesan dari body, fallback "Unexpected error occurred." |

`AppException.displayMessage` otomatis meratakan `validationErrors` menjadi teks multi-baris —
**inilah yang harus ditampilkan ke user**, bukan `message`.

```dart
try {
  await useCase.call(request);
} on AppException catch (error) {
  state = state.copyWith(errorMessage: error.displayMessage);
}
```

`network` dan `timeout` adalah dua tipe yang memicu jalur *offline queue* (lihat [§11](#11-mode-offline--sinkronisasi)).

---

## 9. Kontrak API Backend

Base URL efektif: `{API_SERVER_URL}{API_PATH_PREFIX}` — default `http://192.168.62.38/api/v1`.

| Method | Path | Content-Type | Body / Query | Dipakai oleh |
|---|---|---|---|---|
| `POST` | `/login` | **form-urlencoded** | `nik`, `password` | `AuthRemoteDatasource.login` |
| `GET` | `/me` | – | – | `AuthRemoteDatasource.currentUser` |
| `POST` | `/logout` | json | – | `AuthRemoteDatasource.logout` |
| `GET` | `/locations` | – | – | `MasterDataRemoteDatasource` |
| `GET` | `/tray-types` | – | – | `MasterDataRemoteDatasource` |
| `GET` | `/trays` | – | `search?` | `TrayRemoteDatasource.getTrays` |
| `GET` | `/trays/{id}` | – | – | `TrayRemoteDatasource.getTrayDetail` |
| `POST` | `/rfid/register` | **form-urlencoded** | `rfid_epc`, `tray_type_id`, `current_location_id` | `TrayRemoteDatasource.registerRfid` |
| `POST` | `/trays/scrap` | json | `epc`, `rfid_epc`, `reason`, `remarks` | `TrayRemoteDatasource.scrapTray` |
| `GET` | `/tray-movements` | – | `page`, `search?`, `location_id?`, `date?` (`yyyy-MM-dd`) | `MovementRemoteDatasource.getMovements` |
| `POST` | `/tray-movements` | json | `from_location_id`, `to_location_id`, `rfids[]` | `MovementRemoteDatasource.createMovement` |
| `GET` | `/stocks/summary` | – | – | `StockRemoteDatasource` |
| `GET` | `/stocks/by-tray-type` | – | – | `StockRemoteDatasource` |

Catatan penting:

- `/login` dan `/rfid/register` **sengaja** dikirim sebagai `application/x-www-form-urlencoded`
  (`Options(contentType: Headers.formUrlEncodedContentType)`) mengikuti perilaku backend; sisanya JSON.
- `/trays/scrap` mengirim EPC **dua kali** (`epc` dan `rfid_epc`) untuk kompatibilitas dengan dua versi backend.
- Semua endpoint di atas mengasumsikan token Bearer, kecuali `/login`.

---

## 10. Model & Konvensi Parsing JSON

### Pola model

```dart
class TrayModel extends Tray {                 // model MEWARISI entity
  const TrayModel({required super.id, /* … */});

  factory TrayModel.fromJson(Map<String, dynamic> json) { /* … */ }
  Map<String, dynamic> toJson() { /* … */ }
}
```

Tidak ada code generation (`freezed`/`json_serializable`) — semua `fromJson` ditulis manual.

### `JsonUtils` — parsing defensif

[json_utils.dart](lib/core/utils/json_utils.dart) adalah **satu-satunya cara yang benar** untuk membaca field JSON.
Semua helper menerima daftar kandidat key dan nilai fallback, sehingga aplikasi tetap jalan meski backend
mengganti nama field.

| Helper | Fungsi |
|---|---|
| `asMap(v)` / `asList(v)` | Konversi aman ke `Map<String,dynamic>` / `List` (kembalikan kosong kalau tipe salah) |
| `stringValue(json, [keys], fallback:)` | String pertama yang tidak kosong dan bukan `"null"` |
| `intValue(json, [keys], fallback:)` | Menerima `int`, `num`, atau `String` numerik |
| `dateTimeValue(json, [keys])` | `DateTime.tryParse`, `null` kalau gagal |
| `stringList(v)` | List string, sudah di-trim dan dibuang yang kosong |
| `unwrapList(payload)` | Membongkar envelope `data` / `items` / `rows`, termasuk satu tingkat bersarang |
| `unwrapMap(payload)` | Membongkar envelope `{"data": {...}}` |

Contoh nyata dari [tray_model.dart](lib/data/models/tray_model.dart) — nama tray type dicari di objek relasi
`tray_type` dulu, baru fallback ke field datar di root:

```dart
trayTypeName: JsonUtils.stringValue(
  trayType, const ['name', 'tray_type_name', 'model', 'material_description'],
  fallback: JsonUtils.stringValue(json, const [
    'tray_type_name', 'tray_type_model', 'tray_type_description',
  ], fallback: 'Unknown Tray Type'),
),
```

**Aturan:** jangan pernah `json['field'] as String` langsung. Selalu lewat `JsonUtils` dengan fallback yang masuk akal —
data dari lantai produksi sering tidak lengkap dan crash parsing berarti operator berhenti bekerja.

### Kasus khusus

- **`StockByTrayTypeModel._sumPivotTotals`** — kalau backend mengembalikan bentuk *pivot*
  (kolom per lokasi, bukan field `total`), semua nilai numerik selain kolom identitas dijumlahkan
  sebagai total.
- **`MovementPageModel`** — metadata paginasi dibaca dari `data` kalau berupa map, kalau tidak dari root.
- **`TrayMovementModel.movementNumber`** — fallback ke `MV-{id}` kalau backend tidak mengirim nomor.

---

## 11. Mode Offline & Sinkronisasi

### Penyimpanan

Hive box tunggal: **`pending_movements`** (nama konstan di `ApiConstants.pendingMovementsBox`),
dibuka di `main()` melalui `HiveStorageService.instance.initialize()`.

Data disimpan sebagai **`Map` JSON biasa**, bukan `TypeAdapter` — jadi tidak ada generated adapter yang
perlu di-*regenerate* saat `PendingMovement` berubah. Kunci box = `localId`
(saat ini `DateTime.now().millisecondsSinceEpoch.toString()`).

### Kapan sebuah movement diantrekan

Di `MovementFormController.submit()`: hanya ketika `AppException.type` adalah **`network` atau `timeout`**.
Error validasi (422) dan error server (5xx) **tidak** diantrekan — operator harus memperbaiki dan mengulang.

### Kapan antrean disinkronkan

`pendingSyncBootstrapProvider` di-`watch` oleh `TrayMonitoringApp` — jalan **sekali saat aplikasi start**:

```dart
final connectivityResults = await Connectivity().checkConnectivity();
if (!connectivityResults.contains(ConnectivityResult.none)) {
  await ref.read(syncPendingMovementsUseCaseProvider).call();
}
```

`MovementRepositoryImpl.syncPendingMovements()` mengirim antrean satu per satu; entri yang berhasil dihapus
dari Hive. Bila muncul error `network`/`timeout` lagi, loop **berhenti** (`return`) agar urutan tetap terjaga.
Error jenis lain akan dilewati dan entrinya **tetap tertinggal di antrean**.

> **Keterbatasan:** tidak ada retry otomatis saat koneksi kembali tersambung selagi aplikasi berjalan.
> `OfflineBanner` memang mendengarkan `Connectivity().onConnectivityChanged`, tapi hanya untuk menampilkan
> banner — tidak memicu sinkronisasi. Lihat [§18](#18-keterbatasan-yang-diketahui--utang-teknis).

---

## 12. Subsistem RFID

### Abstraksi

```dart
// lib/services/rfid/rfid_scanner_interface.dart
abstract class RFIDScannerInterface {
  Future<void> startScan();
  Future<void> stopScan();
  Stream<String> get scannedTags;   // stream EPC, sudah UPPERCASE & ter-trim
}
```

`RFIDService` membungkus interface tersebut dan menambahkan `submitManualTag(epc)` (input EPC manual
dari keyboard, untuk device tanpa reader atau saat tag rusak).

### Pemilihan implementasi

```dart
// app_providers.dart
final rfidScannerProvider = Provider<RFIDScannerInterface>((ref) {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return UrovoDT50RfidScanner();   // hardware
  }
  return SimulatedRFIDScanner();     // desktop / web / iOS → development
});
```

`SimulatedRFIDScanner` hanya memancarkan tag yang diinjeksi lewat `emitTag()` **dan hanya saat
`startScan()` sudah dipanggil** — perilaku ini penting untuk test.

### Platform channel (Dart ↔ Kotlin)

| Channel | Nama | Tipe |
|---|---|---|
| Command | `trays_monitoring/rfid/urovo_dt50/commands` | `MethodChannel` |
| Event | `trays_monitoring/rfid/urovo_dt50/tags` | `EventChannel` |

**Method yang tersedia:**

| Method | Argumen | Return |
|---|---|---|
| `startScan` | – | `Map` device info + `hardwareReady`, `initializeCode`, `initializeMessage`, `notes` |
| `stopScan` | – | `null` |
| `submitManualTag` | `{ "epc": String }` | `null` (memancarkan event tag) |
| `getDeviceInfo` | – | `Map` device info |

**Payload event (dari Kotlin ke Dart)** — tiga bentuk berbeda:

```jsonc
// 1. Tag terbaca
{ "epc": "E2801160...", "source": "hardware" | "manual", "deviceModel": "UROVO DT50(P)" }

// 2. Status modul
{ "event": "moduleStatus", "status": "INITIALIZED", "deviceModel": "…" }

// 3. Info baterai reader
{ "event": "batteryInfo", "batteryInfo": { … }, "deviceModel": "…" }
```

`UrovoDT50RfidScanner._handleNativeEvent` **membuang map yang tidak punya key `epc`**, sehingga notifikasi
status/baterai tidak pernah masuk ke stream EPC. Kalau nanti UI perlu menampilkan status modul atau
baterai, tambahkan stream terpisah di scanner — jangan mencampurnya ke `scannedTags`.

### Sisi native (`UrovoDt50RfidBridge.kt`)

Alur `startScan`:

1. `RfidReaderMange.getInstance().initialize(context)` — inisialisasi serial port & power modul.
   `initCode == 0` berarti sukses.
2. Jika sukses: `startMonitorModuleInfo(1500, callback)` untuk polling status/baterai tiap 1,5 detik.
3. Mendaftarkan `BroadcastReceiver` untuk menangkap intent hasil scan dari system service UROVO.
   Pada Android 13+ (`TIRAMISU`) dipakai flag `Context.RECEIVER_EXPORTED`.

Karena action intent berbeda-beda antar versi firmware, bridge mendengarkan **beberapa kandidat sekaligus**:

```kotlin
private val RFID_INTENT_ACTIONS = listOf(
    "com.urovo.rfid.READ_RESULT",
    "com.urovo.rfid.action.TAG_FOUND",
    "com.urovo.rfid.action.READ",
    "urovo.intent.rfid.read",
    "com.urovo.action.rfid",
    "android.intent.action.RFID_RESULT",
)
private val EPC_STRING_KEYS = listOf("epc", "epc_data", "rfid_data", "tag_epc", "rfidData")
private val EPC_LIST_KEYS   = listOf("epcs", "epc_list", "tag_list", "rfid_list", "epcList", "tagList")
```

> **Kalau tag tidak terbaca di unit baru:** kemungkinan besar firmware memakai action atau extra key
> yang belum ada di daftar. Cara diagnosisnya ada di [§19](#19-troubleshooting).

Permission di `AndroidManifest.xml`: `INTERNET`, `ACCESS_NETWORK_STATE`, `SERIAL_PORT`
(untuk `/dev/ttyUSB*`), `RECEIVE_BOOT_COMPLETED`.

### Umpan balik operator

`OperatorFeedbackService` ([feedback_service.dart](lib/core/utils/feedback_service.dart)):

| Method | Suara | Getar |
|---|---|---|
| `tagCaptured()` | `SystemSoundType.click` | 60 ms |
| `operationCompleted()` | `SystemSoundType.alert` | 120 ms |

---

## 13. Design System (TrayTrack Neo)

Bahasa visual: **neomorphism / soft UI**. Satu warna dasar (*ground*) untuk seluruh permukaan; kedalaman
dihasilkan **hanya** oleh sepasang bayangan (gelap di kanan-bawah, terang di kiri-atas) — bukan oleh border
atau warna isi.

### File token

| File | Isi |
|---|---|
| [app_colors.dart](lib/presentation/theme/app_colors.dart) | Palet mentah. **Jangan dipakai langsung di widget** |
| [app_spacing.dart](lib/presentation/theme/app_spacing.dart) | Grid 8dp, touch target, radius |
| [app_theme.dart](lib/presentation/theme/app_theme.dart) | `ThemeData` + `AppColorScheme` (warna semantik status) |
| [neo_theme.dart](lib/presentation/theme/neo_theme.dart) | `NeoScheme` + `NeoDepth` (token neomorfik) |

### Dua ThemeExtension

```dart
// Warna status semantik (OK / Error / Warning / Idle / Active)
final cs = Theme.of(context).extension<AppColorScheme>()!;
cs.statusOk; cs.statusErrorContainer; cs.surfaceCard; cs.scanPulse;

// Token neomorfik — akses lewat extension pada BuildContext
final neo = context.neo;      // dari NeoThemeAccess
neo.ground; neo.ink; neo.inkMuted; neo.accentGradient; neo.raisedShadows(elevation: 1);
```

> `AppColorScheme` adalah **satu-satunya sumber kebenaran** untuk warna status. Jangan hardcode warna
> status di widget dan jangan mengambil dari `AppColors` secara langsung.

### `NeoDepth`

| Nilai | Arti |
|---|---|
| `raised` | Menonjol dari ground — segala sesuatu yang bisa ditekan |
| `inset` | Masuk ke dalam ground — container, field, track, dan state *pressed* |
| `accent` | Gradien steel-blue: hanya untuk aksi primer, counter tag, dan tab aktif |
| `flat` | Warna ground tanpa kedalaman |

### Touch target (mode sarung tangan)

```dart
AppSpacing.touchMin     // 56 — minimum absolut
AppSpacing.touchComfort // 64 — nyaman tangan telanjang
AppSpacing.touchGlove   // 72 — glove mode
```

Semua elemen interaktif **wajib** ≥ `touchMin`.

### Katalog widget

**Primitif neomorfik — [neo_box.dart](lib/presentation/widgets/neo_box.dart)** (727 baris, komponen paling banyak dipakai):

| Widget | Kegunaan |
|---|---|
| `NeoBox` / `NeoBox.inset` / `NeoBox.accent` | Surface dasar; menangani state pressed sendiri |
| `NeoKicker` | Label section huruf kapital berspasi, opsional aksi di kanan |
| `NeoChoiceChip` | Chip pilihan tunggal |
| `NeoIconBadge` | Ikon/teks dalam sumur inset atau accent |
| `NeoCountBadge` | Badge angka |
| `NeoProgressBar` | Progress bar pada track inset |
| `NeoButton` | Tombol aksi primer (accent gradient) |
| `NeoSecondaryButton` | Tombol sekunder |
| `NeoTriggerButton` | Tombol trigger scan besar (punya state `scanning`) |
| `NeoField` | Baris label + nilai, bisa di-tap |
| `NeoPulse` | Animasi denyut untuk indikator scanning |

**Komponen domain:**

| Widget | File | Kegunaan |
|---|---|---|
| `AppShell` | [app_shell.dart](lib/presentation/widgets/app_shell.dart) | Chrome aplikasi: header, tab tray, offline banner |
| `StatusChip` + `TrayStatus` | [status_chip.dart](lib/presentation/widgets/status_chip.dart) | Chip status tray |
| `TrayCard`, `EpcTagTile` | [tray_card.dart](lib/presentation/widgets/tray_card.dart) | Kartu daftar tray / baris tag hasil scan |
| `CounterDisplay`, `ScanFlashOverlay` | [counter_display.dart](lib/presentation/widgets/counter_display.dart) | Angka besar teranimasi + flash saat tag masuk |
| `SignalStrengthMeter`, `GeigerMeter` | [signal_strength_meter.dart](lib/presentation/widgets/signal_strength_meter.dart) | Meter batang & dial melingkar mode Find |
| `KpiCard` | [kpi_card.dart](lib/presentation/widgets/kpi_card.dart) | Kartu KPI dashboard + badge tren |
| `BottomActionBar` | [bottom_action_bar.dart](lib/presentation/widgets/bottom_action_bar.dart) | Bar aksi 1–3 tombol di zona jempol |
| `EmptyStateWidget`, `ScanIdleState`, `ErrorStateWidget` | [empty_state_widget.dart](lib/presentation/widgets/empty_state_widget.dart) | State kosong / idle / error |
| `SectionPanel`, `ModulePage` | [section_panel.dart](lib/presentation/widgets/section_panel.dart), [module_page.dart](lib/presentation/widgets/module_page.dart) | Kerangka layout |
| `OfflineBanner` | [offline_banner.dart](lib/presentation/widgets/offline_banner.dart) | Banner tipis saat offline |
| `SiixLogo` | [siix_logo.dart](lib/presentation/widgets/siix_logo.dart) | Logo, digambar dengan kode (bukan aset gambar) |

### Tipografi

**Manrope** (400/500/600/700/800), di-bundle sebagai TTF statis di `assets/fonts/` — **bukan** `google_fonts`,
karena perangkat sering offline di lantai produksi. Lisensi SIL OFL ada di `assets/fonts/OFL.txt`.

---

## 14. Katalog Layar & Fitur

| Layar | File | Provider yang dipakai | Catatan |
|---|---|---|---|
| Splash | [splash_screen.dart](lib/presentation/screens/auth/splash_screen.dart) | – | Ditampilkan selama status auth `unknown`/`loading` |
| Login | [login_screen.dart](lib/presentation/screens/auth/login_screen.dart) | `authControllerProvider` | Punya parameter `onLogin` untuk keperluan test |
| Dashboard | [dashboard_screen.dart](lib/presentation/screens/dashboard/dashboard_screen.dart) | `dashboardSnapshotProvider`, `pendingMovementsProvider`, `trayTypesProvider` | KPI, aktivitas, stok per project, badge antrean |
| RFID Scan | [tray_movement_screen.dart](lib/presentation/screens/movement/tray_movement_screen.dart) | `movementFormControllerProvider`, `locationsProvider` | 742 baris — layar terkompleks |
| Register RFID | [rfid_registration_screen.dart](lib/presentation/screens/rfid/rfid_registration_screen.dart) | `registrationControllerProvider`, `trayTypesProvider`, `locationsProvider` | Cek duplikat sebelum submit |
| Stock | [stock_screen.dart](lib/presentation/screens/stock/stock_screen.dart) | `stockSummaryProvider`, `stockByTrayTypeProvider`, `trayTypesProvider` | Agregasi per project via `ProjectStockSummaryBuilder` |
| Find (Geiger) | [find_screen.dart](lib/presentation/screens/find/find_screen.dart) | `findControllerProvider` (autoDispose) | RSSI diaproksimasi dari frekuensi deteksi |
| Movement History | [movement_history_screen.dart](lib/presentation/screens/history/movement_history_screen.dart) | `movementHistoryProvider` | Paginasi + filter |
| Scrap | [scrap_screen.dart](lib/presentation/screens/scrap/scrap_screen.dart) | `scrapControllerProvider` | – |
| Tray List / Detail | [tray_list_screen.dart](lib/presentation/screens/tray/tray_list_screen.dart), [tray_detail_screen.dart](lib/presentation/screens/tray/tray_detail_screen.dart) | `trayListProvider`, `trayDetailProvider` | – |
| Menu | [menu_screen.dart](lib/presentation/screens/menu/menu_screen.dart) | `authControllerProvider` | Grid navigasi + sign out |
| Profile | [profile_screen.dart](lib/presentation/screens/profile/profile_screen.dart) | `authControllerProvider` | – |
| Settings | [settings_screen.dart](lib/presentation/screens/settings/settings_screen.dart) | `settingsProvider` | ⚠️ Masih UI saja — lihat [§18](#18-keterbatasan-yang-diketahui--utang-teknis) |

### Catatan implementasi khusus

**Find / Geiger** — SDK tidak memaparkan nilai RSSI mentah, jadi kedekatan **diaproksimasi** dari jumlah
deteksi per detik dalam jendela bergulir 2 detik, dengan peluruhan (*decay*) tiap 500 ms.
Kalau suatu saat SDK memberikan RSSI asli, cukup ganti `_computeRssi()` di `FindController`.

**Registrasi RFID** — sebelum submit, tiap EPC dicek duplikatnya lewat `GET /trays?search=<epc>`
(satu request per EPC — lihat [§18](#18-keterbatasan-yang-diketahui--utang-teknis)). Saat submit, tiap EPC
dikirim satu per satu; EPC yang gagal **dipertahankan di daftar** supaya bisa dicoba ulang, sedangkan
yang berhasil dibuang.

**Stok per project** — `ProjectStockSummaryBuilder` ([project_stock_summary.dart](lib/presentation/utils/project_stock_summary.dart))
memetakan stok tray type ke project dengan tiga tingkat pencocokan: (1) `trayTypeId`, (2) alias ternormalisasi
(name/code/description), (3) pencocokan substring. Yang tak terpetakan masuk ke bucket `"Unassigned"`.

---

## 15. Testing

```
test/
├── widget_test.dart                              # LoginScreen merender kontrol wajib
├── data/models/user_model_test.dart              # parsing role & fallback
├── data/models/stock_by_tray_type_model_test.dart# parsing pivot & total
├── presentation/utils/project_stock_summary_test.dart
└── presentation/layout_overflow_test.dart        # FindScreen & SplashScreen di viewport handheld
```

Jalankan:

```bash
flutter test
flutter test test/presentation/layout_overflow_test.dart
```

### Pola yang dipakai

**1. Override provider agar tidak menyentuh platform channel:**

```dart
ProviderScope(
  overrides: [
    rfidServiceProvider.overrideWithValue(RFIDService(SimulatedRFIDScanner())),
  ],
  child: MaterialApp(theme: AppTheme.light(), home: child),
)
```

**2. Uji overflow di viewport handheld** — DT50 itu pendek dan sempit, dan di sanalah blok soft-UI
berukuran tetap (dial geiger, tabel data) meluap:

```dart
const _handheld      = Size(375, 667);
const _shortHandheld = Size(360, 520);

tester.view.physicalSize   = size;
tester.view.devicePixelRatio = 1.0;
addTearDown(tester.view.reset);
// …
expect(tester.takeException(), isNull);   // overflow melempar exception
```

**3. Injeksi callback untuk melewati jaringan** — `LoginScreen(onLogin: …)` memakai jalur callback
saat parameternya diisi, sehingga test tidak menyentuh `authControllerProvider`.

> **Setiap layar baru yang punya elemen berukuran tetap wajib ditambahkan ke `layout_overflow_test.dart`.**

---

## 16. Panduan Developer — Cookbook

### 16.1 Menambahkan endpoint / fitur baru dari ujung ke ujung

Contoh: menambahkan "Tray Audit" (`GET /audits`).

**Langkah 1 — Entity** (`lib/domain/entities/audit.dart`), Dart murni:

```dart
class Audit {
  const Audit({required this.id, required this.auditNumber, this.createdAt});
  final int id;
  final String auditNumber;
  final DateTime? createdAt;
}
```

**Langkah 2 — Interface repository** (`lib/domain/repositories/audit_repository.dart`):

```dart
abstract class AuditRepository {
  Future<List<Audit>> getAudits();
}
```

**Langkah 3 — UseCase** (`lib/domain/usecases/audit_usecases.dart`) — satu kelas per aksi, dipanggil `.call()`:

```dart
class GetAuditsUseCase {
  GetAuditsUseCase(this._repository);
  final AuditRepository _repository;
  Future<List<Audit>> call() => _repository.getAudits();
}
```

**Langkah 4 — Model** (`lib/data/models/audit_model.dart`) — selalu lewat `JsonUtils`:

```dart
class AuditModel extends Audit {
  const AuditModel({required super.id, required super.auditNumber, super.createdAt});

  factory AuditModel.fromJson(Map<String, dynamic> json) => AuditModel(
    id: JsonUtils.intValue(json, const ['id']),
    auditNumber: JsonUtils.stringValue(json, const ['audit_number', 'number'], fallback: '-'),
    createdAt: JsonUtils.dateTimeValue(json, const ['created_at']),
  );

  Map<String, dynamic> toJson() => {'id': id, 'audit_number': auditNumber,
                                    'created_at': createdAt?.toIso8601String()};
}
```

**Langkah 5 — Datasource** (`lib/data/datasources/audit_remote_datasource.dart`):

```dart
class AuditRemoteDatasource {
  AuditRemoteDatasource(this._apiService);
  final ApiService _apiService;

  Future<List<AuditModel>> getAudits() async {
    final response = await _apiService.get('/audits');
    return JsonUtils.unwrapList(response)
        .map((e) => AuditModel.fromJson(JsonUtils.asMap(e)))
        .toList();
  }
}
```

**Langkah 6 — Implementasi repository** (`lib/data/repositories/audit_repository_impl.dart`) — tipis saja:

```dart
class AuditRepositoryImpl implements AuditRepository {
  AuditRepositoryImpl(this._remoteDatasource);
  final AuditRemoteDatasource _remoteDatasource;

  @override
  Future<List<Audit>> getAudits() => _remoteDatasource.getAudits();
}
```

**Langkah 7 — Wiring di `app_providers.dart`** (urut: datasource → repository → usecase → data provider):

```dart
final auditRemoteDatasourceProvider = Provider<AuditRemoteDatasource>((ref) {
  return AuditRemoteDatasource(ref.watch(apiServiceProvider));
});

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return AuditRepositoryImpl(ref.watch(auditRemoteDatasourceProvider));
});

final getAuditsUseCaseProvider = Provider<GetAuditsUseCase>((ref) {
  return GetAuditsUseCase(ref.watch(auditRepositoryProvider));
});

final auditsProvider = FutureProvider<List<Audit>>((ref) {
  return ref.watch(getAuditsUseCaseProvider).call();
});
```

**Langkah 8 — UI:**

```dart
class AuditScreen extends ConsumerWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audits = ref.watch(auditsProvider);
    return audits.when(
      data:    (items) => /* daftar */,
      loading: () => const Center(child: CircularProgressIndicator()),
      error:   (e, _) => ErrorStateWidget(
        message: e is AppException ? e.displayMessage : e.toString(),
        onRetry: () => ref.invalidate(auditsProvider),
      ),
    );
  }
}
```

**Langkah 9 — Rute:** lihat §16.2.

---

### 16.2 Menambahkan layar & rute baru

1. Buat file di `lib/presentation/screens/<modul>/<nama>_screen.dart`.
2. Daftarkan `GoRoute` di [app_router.dart](lib/routes/app_router.dart) **di dalam `ShellRoute`**
   (kecuali layar tanpa chrome seperti login/splash):

   ```dart
   GoRoute(path: '/audit', builder: (context, state) => const AuditScreen()),
   ```

3. **Perbarui `AppShell`** ([app_shell.dart](lib/presentation/widgets/app_shell.dart)) — tanpa ini, tab aktif
   dan judul app bar akan salah:

   ```dart
   static const List<String> _menuSubRoutes = <String>[ …, '/audit' ];

   (String, String) _titleFor() {
     …
     if (location.startsWith('/audit')) return ('Tray Audit', 'STOCK OPNAME');
     …
   }
   ```

4. Kalau layar itu pantas jadi tab utama, tambahkan ke `AppShell._items` (saat ini 5 tab — lebih dari itu
   akan berdesakan di layar handheld).
5. Kalau layar diakses dari menu, tambahkan tile-nya di [menu_screen.dart](lib/presentation/screens/menu/menu_screen.dart).
6. Tambahkan test overflow di `test/presentation/layout_overflow_test.dart`.

---

### 16.3 Menambahkan controller (state form/interaktif)

Pakai `StateNotifier` dengan kelas state ber-`copyWith` yang punya flag `clearX` eksplisit — pola ini
dipakai konsisten di seluruh aplikasi karena `copyWith` biasa tidak bisa mengeset nilai kembali ke `null`:

```dart
class MyState {
  const MyState({this.isSubmitting = false, this.errorMessage});
  final bool isSubmitting;
  final String? errorMessage;

  MyState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,          // ← perhatikan ini
  }) => MyState(
    isSubmitting: isSubmitting ?? this.isSubmitting,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );
}
```

Kalau controller berlangganan stream RFID, **wajib** membatalkannya di `dispose()`:

```dart
class MyController extends StateNotifier<MyState> {
  MyController({required this.rfidService}) : super(const MyState()) {
    _subscription = rfidService.scannedTags.listen(_handleTagScanned);
  }
  late final StreamSubscription<String> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
```

Untuk controller yang terikat pada satu layar (seperti `FindController`), pakai
`StateNotifierProvider.autoDispose` supaya stream ikut dibersihkan ketika layar ditinggalkan.

---

### 16.4 Membuat operasi baru yang tahan-offline

1. Definisikan entity pending-nya (contoh: `PendingMovement`) beserta `localId` unik.
2. Buat model dengan `toJson`/`fromJson` — **tidak perlu Hive TypeAdapter**, disimpan sebagai `Map` biasa.
3. Tambahkan Hive box di `ApiConstants` lalu buka di `HiveStorageService.initialize()`:

   ```dart
   static const String pendingAuditsBox = 'pending_audits';
   ```

4. Buat local datasource dengan `save` / `getAll` / `remove`.
5. Di controller, tangkap **hanya** `network` dan `timeout` untuk masuk antrean:

   ```dart
   } on AppException catch (error) {
     if (error.type == AppExceptionType.network ||
         error.type == AppExceptionType.timeout) {
       await savePendingUseCase.call(pendingEntity);
       return Result.queuedOffline;
     }
     state = state.copyWith(errorMessage: error.displayMessage);
   }
   ```

6. Tambahkan sinkronisasinya di `pendingSyncBootstrapProvider` (atau buat provider bootstrap sendiri
   dan `ref.watch` di `TrayMonitoringApp`).

---

### 16.5 Mendukung hardware RFID baru

1. Implementasikan `RFIDScannerInterface` di `lib/services/rfid/<vendor>_rfid_scanner.dart`.
2. Normalkan EPC ke **uppercase, ter-trim** sebelum memancarkannya — semua deduplikasi hilir
   mengandalkan asumsi ini.
3. Kalau butuh sisi native, tambahkan bridge Kotlin dan daftarkan di `MainActivity.configureFlutterEngine()`.
4. Perbarui pemilihan implementasi di `rfidScannerProvider`:

   ```dart
   final rfidScannerProvider = Provider<RFIDScannerInterface>((ref) {
     if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
       final scanner = isUrovoDevice() ? UrovoDT50RfidScanner() : NewVendorScanner();
       ref.onDispose(scanner.dispose);
       return scanner;
     }
     final scanner = SimulatedRFIDScanner();
     ref.onDispose(scanner.dispose);
     return scanner;
   });
   ```

5. Tambahkan cabangnya di `RFIDService.submitManualTag()` — saat ini memakai pattern matching per tipe scanner.

---

### 16.6 Mengubah / menambahkan warna & komponen UI

**Warna status baru:**

1. Tambahkan warna mentah di `AppColors`.
2. Tambahkan field-nya di `AppColorScheme` — **beserta** entri di `light`, `dark`, `copyWith`, dan `lerp`.
   Kalau salah satu terlewat, kompilasi akan gagal (ini disengaja).
3. Pakai lewat `Theme.of(context).extension<AppColorScheme>()!`.

**Token neomorfik baru:** hal yang sama pada `NeoScheme` di `neo_theme.dart`.

**Widget baru:** letakkan di `lib/presentation/widgets/`, bangun di atas `NeoBox`, ambil warna dari
`context.neo` / `AppColorScheme`, dan ukuran dari `AppSpacing`. Jangan pernah *hardcode* nilai warna atau
jarak di dalam layar.

---

### 16.7 Mengubah base URL API

Jangan mengedit `_defaultServerUrl` untuk keperluan sementara — pakai `--dart-define`
(lihat [§2.3](#23-konfigurasi-endpoint-api)). Ubah default di kode hanya kalau alamat server produksi
benar-benar berganti secara permanen.

---

## 17. Konvensi Kode

| Aspek | Konvensi |
|---|---|
| Lint | `package:flutter_lints/flutter.yaml` (`analysis_options.yaml`) |
| Format | `dart format` bawaan, lebar 80 kolom |
| Penamaan file | `snake_case.dart` |
| Kelas | `PascalCase`; model = `<Entity>Model`; impl = `<Name>RepositoryImpl` |
| Field privat | Prefiks `_` (`_apiService`, `_remoteDatasource`) |
| Konstruktor | `const` sedapat mungkin; parameter dengan nama untuk ≥ 2 argumen |
| UseCase | Satu kelas satu aksi, dipanggil lewat `.call()` |
| Widget privat layar | Prefiks `_` dan *co-located* di file layar yang sama |
| Widget yang dipakai ulang | Diangkat ke `lib/presentation/widgets/` |
| Error | Selalu `AppException`; tampilkan `displayMessage`, bukan `message` |
| Parsing JSON | Selalu lewat `JsonUtils` dengan fallback |
| String yang dilihat user | Boleh campur Inggris/Indonesia — ikuti gaya layar sekitarnya |
| Komentar | Jelaskan **kenapa**, bukan **apa**; pakai `///` untuk API publik |
| Pemisah section | Baris `// ─────` pada file panjang |

---

## 18. Keterbatasan yang Diketahui & Utang Teknis

Daftar ini berdasarkan pembacaan kode; urut dari yang paling berdampak.

| # | Isu | Lokasi | Dampak |
|---|---|---|---|
| 1 | **Settings belum tersambung ke apa pun.** `settingsProvider` (power RFID, region, beep, haptic, glove, dark mode) hanya dibaca oleh layar Settings sendiri — tidak dipersistensi dan tidak memengaruhi reader, `OperatorFeedbackService`, maupun tema. `main.dart` mengunci `themeMode: ThemeMode.system` | [settings_screen.dart](lib/presentation/screens/settings/settings_screen.dart), [main.dart:28](lib/main.dart#L28) | Operator mengira sudah mengubah pengaturan, padahal tidak berefek |
| 2 | **Tidak ada auto-sync saat koneksi pulih.** Antrean offline hanya disinkronkan saat aplikasi start | [app_providers.dart:250](lib/presentation/providers/app_providers.dart#L250) | Movement bisa tertahan lama kalau aplikasi tidak pernah di-restart |
| 3 | **Cek duplikat registrasi bersifat N+1.** Satu `GET /trays?search=` per EPC, dijalankan berurutan | [registration_controller.dart:133](lib/presentation/providers/registration_controller.dart#L133) | Registrasi massal (mis. 50 tag) jadi lambat; idealnya endpoint bulk-check di backend |
| 4 | **Registrasi mengirim satu request per EPC.** Tidak ada endpoint bulk | [registration_controller.dart](lib/presentation/providers/registration_controller.dart) | Sama seperti di atas |
| 5 | **`MovementPageModel.lastPage` selalu fallback ke `1`** kalau backend tidak mengirimnya (`fallback: items.isEmpty ? 1 : 1` — kedua cabang bernilai sama) | [movement_page_model.dart:27](lib/data/models/movement_page_model.dart#L27) | Tombol "next page" hilang saat metadata paginasi tidak ada |
| 6 | **`FindController.rfidService` bertipe `dynamic`** dan meng-*cast* stream saat runtime | [find_screen.dart:63](lib/presentation/screens/find/find_screen.dart#L63) | Kehilangan type safety; sebaiknya jadi `RFIDService` |
| 7 | **RSSI di mode Find hanyalah aproksimasi** (frekuensi deteksi), bukan RSSI sungguhan dari SDK | [find_screen.dart](lib/presentation/screens/find/find_screen.dart) | Akurasi jarak terbatas; ganti `_computeRssi()` kalau SDK sudah memaparkan RSSI |
| 8 | **Action intent RFID masih ditebak.** Enam kandidat action didengarkan sekaligus karena action pasti per firmware belum dipastikan | [UrovoDt50RfidBridge.kt:27](android/app/src/main/kotlin/com/example/trays_monitoring/UrovoDt50RfidBridge.kt#L27) | Firmware baru bisa saja tidak cocok; perlu diverifikasi per unit |
| 9 | **`applicationId` masih `com.example.trays_monitoring`** dan release ditandatangani dengan **debug key** | [build.gradle.kts](android/app/build.gradle.kts) | Menghalangi distribusi resmi |
| 10 | **Belum ada authorization berbasis role.** `User.roles` diambil tapi tidak pernah dipakai untuk menyembunyikan menu | seluruh `presentation/` | Semua operator bisa mengakses Scrap, Register, dll. |
| 11 | **`syncPendingMovements` membuang error non-jaringan tanpa jejak.** Entri yang gagal validasi tertinggal di antrean selamanya tanpa notifikasi | [movement_repository_impl.dart:60](lib/data/repositories/movement_repository_impl.dart#L60) | Antrean "hantu" yang tidak pernah terkirim |
| 12 | **Status modul & baterai reader tidak ditampilkan.** Native sudah mengirimkannya, tapi Dart membuangnya | [urovo_dt50_rfid_scanner.dart:80](lib/services/rfid/urovo_dt50_rfid_scanner.dart#L80) | Operator tidak tahu baterai reader menipis |
| 13 | **`README.md` masih template bawaan Flutter** | [README.md](README.md) | Arahkan ke dokumen ini |
| 14 | **`usesCleartextTraffic="true"`** untuk seluruh aplikasi | [AndroidManifest.xml](android/app/src/main/AndroidManifest.xml) | Perlu dimatikan begitu backend memakai HTTPS |

---

## 19. Troubleshooting

### Tag RFID tidak terbaca di perangkat

1. Cek hasil `startScan` — panggil `getDeviceInfo` dan periksa `hardwareReady`, `initializeCode`,
   `initializeMessage`, `lastError`. `initializeCode != 0` berarti SDK gagal init (modul mati, permission
   `SERIAL_PORT` ditolak, atau service vendor tidak jalan).
2. Kalau init sukses tapi tidak ada tag masuk, kemungkinan besar broadcast intent dari firmware tidak
   cocok dengan daftar kandidat. Diagnosis:

   ```bash
   adb logcat | grep -i rfid
   ```

   Cari nama action dan extra key yang sebenarnya, lalu tambahkan ke `RFID_INTENT_ACTIONS` /
   `EPC_STRING_KEYS` / `EPC_LIST_KEYS` di [UrovoDt50RfidBridge.kt](android/app/src/main/kotlin/com/example/trays_monitoring/UrovoDt50RfidBridge.kt).
3. Pastikan `stopScan()` tidak terlanjur dipanggil — bridge mengabaikan broadcast saat `isScanning == false`.

### Semua request gagal dengan error network

- Cek base URL efektif: `ApiConstants.baseUrl` = `API_SERVER_URL` + `API_PATH_PREFIX`.
  Kalau build tanpa `--dart-define`, alamatnya `http://192.168.62.38/api/v1`.
- Pastikan perangkat berada di jaringan yang sama dengan server.
- Untuk endpoint HTTP polos, `usesCleartextTraffic` harus tetap `true`.
- `LogInterceptor` aktif di debug build — URL dan body lengkap terlihat di `flutter logs`.

### Ditendang ke login terus-menerus

Backend mengembalikan 401 → interceptor menghapus token → `SessionCoordinator` memicu logout.
Periksa masa berlaku token dan apakah header `Authorization` benar-benar terkirim (lihat log Dio).

### Overflow layout di perangkat handheld

Jalankan `test/presentation/layout_overflow_test.dart`. Kalau layar baru meluap, bungkus konten
berukuran tetap dengan `LayoutBuilder`/`FittedBox` dan skalakan dari parameter `size`
(pola yang dipakai `GeigerMeter`).

### Antrean offline tidak terkirim

Sinkronisasi hanya jalan saat app start dan hanya bila `connectivity_plus` melaporkan ada koneksi.
Restart aplikasi. Untuk memeriksa isi antrean, gunakan `pendingMovementsProvider`
(sudah ditampilkan sebagai badge di Dashboard).

---

## 20. Checklist Rilis

**Wajib sebelum distribusi resmi:**

- [ ] Ganti `applicationId` dari `com.example.trays_monitoring` ke ID resmi (mis. `com.siix.traytrack`)
- [ ] Siapkan keystore release dan `signingConfig` sungguhan (jangan pakai debug key)
- [ ] Naikkan `version` di `pubspec.yaml`
- [ ] Set base URL produksi lewat `--dart-define`
- [ ] Nonaktifkan `usesCleartextTraffic` bila backend sudah HTTPS
- [ ] Ganti `android:label` dari `trays_monitoring` ke nama aplikasi yang tampil ke user
- [ ] Ganti ikon peluncur (`mipmap/ic_launcher`)

**Verifikasi:**

- [ ] `flutter analyze` bersih
- [ ] `flutter test` hijau
- [ ] Uji manual di UROVO DT50(P) sungguhan: registrasi, scan movement, mode find, antrean offline
- [ ] Uji jalur offline: matikan Wi-Fi → submit movement → nyalakan → restart app → pastikan tersinkron
- [ ] Uji session expired: kadaluarsakan token di server → pastikan aplikasi kembali ke login dengan rapi

```bash
flutter build apk --release \
  --dart-define=API_SERVER_URL=http://<server-produksi>
```

---

## Lampiran A — Rujukan Cepat File Penting

| Kebutuhan | File |
|---|---|
| Menambah endpoint | `data/datasources/*_remote_datasource.dart` |
| Mengubah wiring DI | `presentation/providers/app_providers.dart` |
| Menambah rute | `routes/app_router.dart` + `presentation/widgets/app_shell.dart` |
| Mengubah base URL | `core/constants/api_constants.dart` (atau `--dart-define`) |
| Mengubah pemetaan error | `services/api/api_service.dart` + `core/errors/app_exception.dart` |
| Mengubah warna | `presentation/theme/app_colors.dart` + `app_theme.dart` + `neo_theme.dart` |
| Mengubah jarak/ukuran | `presentation/theme/app_spacing.dart` |
| Integrasi RFID | `services/rfid/` + `android/.../UrovoDt50RfidBridge.kt` |
| Perilaku offline | `data/repositories/movement_repository_impl.dart` + `core/storage/hive_storage_service.dart` |
| Alur autentikasi | `presentation/providers/auth_controller.dart` + `core/utils/session_coordinator.dart` |

## Lampiran B — Dependensi

| Paket | Versi | Fungsi |
|---|---|---|
| `flutter_riverpod` | ^2.6.1 | State management + DI |
| `dio` | ^5.9.0 | HTTP client |
| `go_router` | ^14.8.1 | Routing deklaratif |
| `hive` / `hive_flutter` | ^2.2.3 / ^1.1.0 | Penyimpanan lokal antrean offline |
| `flutter_secure_storage` | ^9.2.4 | Penyimpanan token terenkripsi |
| `connectivity_plus` | ^6.1.4 | Deteksi status jaringan |
| `intl` | ^0.20.2 | Format tanggal |
| `vibration` | ^3.1.3 | Umpan balik haptic |
| `collection` | ^1.19.1 | Utilitas koleksi |
| `cupertino_icons` | ^1.0.8 | Ikon |
| `flutter_lints` | ^6.0.0 | Aturan lint (dev) |
