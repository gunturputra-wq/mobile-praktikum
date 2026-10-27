## Tahap 1 — Membaca REST Endpoint dan JSON

### Informasi REST Endpoint

- **Nama endpoint:** List courses
- **URL:** `https://course-api-pearl.vercel.app/courses`
- **HTTP Method:** GET
- **Fungsi:** Mengambil seluruh data mata kuliah dari REST API.
- **Format respons:** JSON berupa array objek mata kuliah.
- **Status code yang diharapkan:** 200 OK.

### Struktur JSON

Respons API memiliki enam field utama:

| Field | Tipe Data | Keterangan |
|---|---|---|
| `id` | Integer | ID unik mata kuliah |
| `code` | String | Kode mata kuliah |
| `title` | String | Nama mata kuliah |
| `credits` | Integer | Jumlah SKS |
| `status` | String | Status mata kuliah |
| `created_at` | String | Waktu pembuatan data dalam format ISO 8601 |

### Contoh Respons JSON

```json
{
  "id": 3,
  "code": "MOB03",
  "title": "Flutter Widgets & Layout",
  "credits": 3,
  "status": "planned",
  "created_at": "2026-10-21T03:28:09.361747Z"
}
```

### Hasil Pengamatan

Endpoint berhasil menampilkan daftar mata kuliah dalam format JSON. Data yang terlihat terdiri dari 10 objek mata kuliah dengan kode, nama, jumlah SKS, status, dan waktu pembuatan masing-masing. Data ini akan menjadi acuan untuk memahami struktur model Course pada aplikasi Flutter.