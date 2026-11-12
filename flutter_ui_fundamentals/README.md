
@'
# Course Explorer

Aplikasi Flutter untuk menampilkan dan mengelola data mata kuliah. Aplikasi menerapkan pola arsitektur berlapis, state management menggunakan Provider, serta operasi CRUD yang terhubung dengan backend Supabase.

## Fitur

- Menampilkan daftar mata kuliah.
- Menambahkan mata kuliah.
- Memperbarui data mata kuliah.
- Menghapus mata kuliah.
- Menangani kondisi loading dan error.
- Mengelola state aplikasi menggunakan Provider.

## Teknologi

- Flutter dan Dart
- Material Design 3
- Provider
- Supabase sebagai backend dan database
- Git dan GitHub

## Persyaratan

- Flutter SDK dan Dart SDK
- Browser Chrome atau perangkat yang mendukung Flutter
- Proyek Supabase yang telah dikonfigurasi

## Cara Menjalankan

1. Clone repository dan masuk ke folder proyek.
2. Instal dependensi:

   ```bash
   flutter pub get
   ```

3. Jalankan aplikasi dengan konfigurasi Supabase:

   ```bash
   flutter run -d chrome --dart-define=SUPABASE_URL=URL_SUPABASE_ANDA --dart-define=SUPABASE_PUBLISHABLE_KEY=PUBLISHABLE_KEY_ANDA
   ```

   Ganti kedua nilai tersebut dengan URL proyek Supabase dan publishable key milik proyek. Jangan memasukkan secret key atau service role key ke aplikasi Flutter.

4. Periksa kode dan pengujian:

   ```bash
   flutter analyze
   flutter test
   ```

## Arsitektur Singkat

- **Models:** merepresentasikan struktur data mata kuliah.
- **Services:** menangani akses data dan komunikasi dengan backend.
- **Repositories:** menjadi perantara antara sumber data dan state aplikasi.
- **Providers:** mengelola state serta menyediakan operasi data untuk UI.
- **UI:** menampilkan daftar mata kuliah dan menyediakan interaksi pengguna.

Alur data secara umum:

`UI → Provider → Repository → Service → Supabase`

## Backend

Backend menggunakan Supabase untuk menyimpan dan mengelola data mata kuliah melalui operasi CRUD. URL dan publishable key dikonfigurasi saat aplikasi dijalankan menggunakan `--dart-define`, bukan ditulis langsung sebagai credential rahasia di source code.

Pastikan tabel, izin akses, dan kebijakan Row Level Security (RLS) Supabase telah dikonfigurasi sesuai kebutuhan aplikasi.

## Repository

Source code proyek tersedia di:

https://github.com/gunturputra-wq/mobile-praktikum
'@ | Set-Content -Path README.md -Encoding utf8

Write-Host "`n=== README BERHASIL DIPERBARUI ==="
Get-Content README.md
