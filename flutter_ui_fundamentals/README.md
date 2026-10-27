# Course Explorer

Course Explorer adalah aplikasi Flutter untuk menampilkan dan mengelola data mata kuliah melalui operasi CRUD dengan backend Supabase.

## Fitur
- Menampilkan daftar mata kuliah.
- Menambahkan mata kuliah.
- Memperbarui data mata kuliah.
- Menghapus mata kuliah.
- Menangani loading dan error.
- Mengelola state menggunakan Provider.

## Teknologi
- Flutter dan Dart
- Material Design 3
- Provider
- Supabase
- Git dan GitHub

## Persyaratan
- Flutter SDK
- Browser Chrome atau perangkat yang mendukung Flutter
- Proyek Supabase yang telah dikonfigurasi

## Cara Menjalankan

Instal dependensi:

```bash
flutter pub get
```

Jalankan aplikasi menggunakan konfigurasi Supabase:

```powershell
flutter run -d chrome --dart-define=SUPABASE_URL=URL_SUPABASE_ANDA --dart-define=SUPABASE_PUBLISHABLE_KEY=PUBLISHABLE_KEY_ANDA
```

Ganti nilai URL dan publishable key dengan konfigurasi proyek Supabase milikmu. Jangan menggunakan service role key di aplikasi klien.

Periksa kualitas kode dan pengujian:

```bash
flutter analyze
flutter test
```

## Arsitektur

- **Models:** mendefinisikan struktur data mata kuliah.
- **Services:** menangani komunikasi dengan backend.
- **Repositories:** menjadi perantara antara provider dan layanan data.
- **Providers:** mengelola state dan operasi data.
- **UI:** menampilkan data serta menerima interaksi pengguna.

Alur data:

`UI -> Provider -> Repository -> Service -> Supabase`

## Backend

Supabase digunakan sebagai backend dan database untuk operasi CRUD. Pastikan tabel, hak akses, dan kebijakan Row Level Security (RLS) dikonfigurasi dengan benar.

Konfigurasi URL dan publishable key diberikan saat menjalankan aplikasi melalui `--dart-define`, bukan ditulis sebagai credential rahasia di source code.

## Repository GitHub

https://github.com/gunturputra-wq/mobile-praktikum
