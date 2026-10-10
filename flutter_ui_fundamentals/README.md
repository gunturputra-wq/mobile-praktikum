# Aplikasi Praktikum Flutter - Seri Pertemuan 5
**Responsive Layout, Navigation & User Interaction**

 Sektor Informasi Mahasiswa:
- **Nama:** I Ketut Guntur Putra Dangin
- **NIM:** 2415051056
- **Prodi:** Pendidikan Teknik Informatika

---

## 🚀 Deskripsi Proyek
Aplikasi ini dikembangkan menggunakan Flutter untuk memenuhi seluruh tugas praktikum (Tahap 1 - 15). Aplikasi mencakup modul responsif layout, navigasi antar-halaman, pengelolaan form/input, umpan balik visual pengguna, hingga unit & widget testing.

## ✨ Fitur Utama
1. **Responsive Dashboard:** Penggunaan `MediaQuery` dan `LayoutBuilder` untuk menyesuaikan tampilan di layar HP maupun Web/Tablet.
2. **Navigation & Data Passing:** Perpindahan antar-halaman daftar *course* ke halaman detail dengan membawa data dinamis melalui *constructor*.
3. **Interactive Form:** Penggunaan `TextFormField`, validasi input, serta kontrol `Slider`.
4. **Advanced Feedback UI:** Penggunaan `SnackBar`, `AlertDialog` konfirmasi, `BottomSheet`, dan `CircularProgressIndicator` untuk simulasi *loading*.
5. **Widget Testing:** Pengujian UI otomatis menggunakan `flutter test`.

---

## 🛠️ Cara Menjalankan Proyek

1. **Clone Repositori:**
   ```bash
   git clone [https://github.com/USERNAME/aplikasi_pertama_I_Ketut_Guntur_Putra_Dangin.git](https://github.com/USERNAME/aplikasi_pertama_I_Ketut_Guntur_Putra_Dangin.git)
   cd aplikasi_pertama_I_Ketut_Guntur_Putra_Dangin/flutter_ui_fundamentals
## Architecture and Folder Responsibilities

The application follows a layered architecture with the dependency direction:
Screen/Widget -> Provider -> Repository -> Service/Data Source.

- `lib/`: Contains the main Dart source code.
- `lib/models/`: Defines data models and JSON-to-object conversion.
- `lib/providers/`: Manages application state and notifies UI listeners.
- `lib/repositories/`: Provides an abstraction between providers and data services.
- `lib/services/`: Loads and parses course data from the JSON asset.
- `lib/screens/`: Intended for page-level UI, such as the home page and course detail page.
- `lib/widgets/`: Intended for reusable UI components, such as course cards.
- `lib/constants/`: Intended for shared constants used across the application.
- `assets/data/`: Stores JSON data used by the application.
- `assets/images/`: Stores image assets used by the application.
- `test/`: Contains automated unit and widget tests.

### Architecture Audit Findings

- JSON loading and parsing are handled by `CourseService`, not by screen or widget files.
- `CourseRepository` delegates data loading to `CourseService`.
- `CourseState` uses `ChangeNotifier` and accesses course data through the repository.
- No `BuildContext` state was found in `CourseState`.
- Some UI classes remain in `main.dart`; further UI extraction can be performed in a separate refactoring step.
