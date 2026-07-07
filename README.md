# 🛒 E-Commerce App — UAS Praktikum Pemrograman Mobile

## 👤 Identitas

| Keterangan | Isi |
|------------|-----|
| **Nama** | Sintia Juniarti |
| **NIM** | 2306008 |
| **Kelas** | *(Isi kelas di sini)* |
| **Mata Kuliah** | Praktikum Pemrograman Mobile |
| **Tahun Akademik** | 2025/2026 |

---

# 📖 Deskripsi Aplikasi

Aplikasi **E-Commerce berbasis Flutter** yang terintegrasi dengan **REST API** menggunakan **Node.js, Express, dan Supabase**. Aplikasi ini mendukung proses belanja secara lengkap mulai dari autentikasi pengguna, katalog produk, keranjang belanja, checkout, riwayat pesanan, wishlist, dark mode, hingga notifikasi lokal.

---

# 🛠️ Tech Stack

- **Frontend** : Flutter (Dart)
- **Backend** : Node.js + Express
- **Database** : Supabase (PostgreSQL)
- **State Management** : Provider
- **Local Storage** :
  - SharedPreferences (Token Login & Dark Mode)
  - Hive (Wishlist)
- **HTTP Client** : Dio

---

# ✅ Fitur yang Diimplementasikan

## 1. Autentikasi & Profil

- ✅ Register (Validasi Nama, Email, Password minimal 6 karakter)
- ✅ Login menggunakan Token Authentication
- ✅ Auto Login menggunakan SharedPreferences
- ✅ Update Profil (Nama & Nomor Telepon)
- ✅ Logout

---

## 2. Katalog Produk

- ✅ Daftar Produk (GridView + Pagination)
- ✅ Format Harga Rupiah
- ✅ Pencarian Produk
- ✅ Filter Berdasarkan Kategori
- ✅ Sorting (Termurah, Termahal, Terbaru)
- ✅ Detail Produk
- ✅ Daftar Ulasan Produk
- ✅ Tambah Ulasan (Rating & Komentar)
- ✅ Tambah ke Keranjang

---

## 3. Keranjang Belanja

- ✅ Daftar Item Keranjang
- ✅ Update Quantity (+ / -)
- ✅ Hapus Item
- ✅ Kosongkan Keranjang
- ✅ Grand Total
- ✅ Badge Jumlah Keranjang
- ✅ Tampilan Keranjang Kosong

---

## 4. Checkout & Riwayat Pesanan

- ✅ Halaman Checkout
- ✅ Ringkasan Pesanan
- ✅ Input Alamat Pengiriman
- ✅ Catatan Pesanan
- ✅ Dialog Konfirmasi Checkout
- ✅ Halaman Checkout Berhasil
- ✅ Riwayat Pesanan
- ✅ Detail Pesanan

---

## 5. Fitur Tambahan

### Wishlist

- ✅ Simpan Produk ke Wishlist
- ✅ Hapus Wishlist
- ✅ Penyimpanan Lokal Menggunakan Hive

### Dark Mode

- ✅ Toggle Dark Mode
- ✅ Tersimpan di SharedPreferences

### Local Notification

- ✅ Notifikasi Saat Checkout Berhasil
- ✅ Menggunakan flutter_local_notifications

---

# 🚀 Cara Menjalankan Aplikasi

## 1. Backend (API-TB)

Masuk ke folder backend

```bash
cd API-TB
npm install
```

Buat file `.env`

```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=xxxxx
SUPABASE_SERVICE_ROLE_KEY=xxxxx
PORT=3000
NODE_ENV=development
```

Import database Supabase secara berurutan:

1. `database/schema.sql`
2. `database/policies.sql`
3. `database/seed.sql`
4. `database/seed-users.sql`

Jalankan server

```bash
npm run dev
```

Server berjalan pada:

```
http://localhost:3000
```

Dokumentasi API:

```
http://localhost:3000/api-docs
```

---

## 2. Frontend (Flutter)

Masuk ke folder Flutter

```bash
cd ecommerce_app
flutter pub get
```

Pastikan Base URL API pada:

```
lib/config/api_config.dart
```

mengarah ke:

```
http://localhost:3000/api
```

Generate file Hive

```bash
dart run build_runner build --delete-conflicting-outputs
```

Jalankan aplikasi

```bash
flutter run
```

---

# 👥 Akun Testing

| Role | Email | Password |
|------|-------|----------|
| Customer | Daftar melalui halaman Register | - |
| Admin | admin@admin.com | admin123 |

---

# 📸 Screenshot Aplikasi

Tambahkan screenshot minimal:

- Home
- Detail Produk
- Keranjang
- Checkout
- Riwayat Pesanan
- Wishlist
- Profile

Contoh:

```text
screenshots/
│
├── home.png
├── detail_produk.png
├── keranjang.png
├── checkout.png
├── riwayat_pesanan.png
├── wishlist.png
└── profile.png
```

---

# 📂 Struktur Folder Flutter

```text
lib/
│
├── config/
├── models/
├── providers/
├── services/
├── screens/
│   ├── auth/
│   ├── home/
│   ├── product/
│   ├── cart/
│   ├── order/
│   ├── wishlist/
│   ├── profile/
│   └── admin/
│
└── main.dart
```

---

# 📝 Catatan

Project ini dibuat sebagai pemenuhan **UAS Praktikum Pemrograman Mobile** dengan menerapkan konsep **REST API**, **Flutter**, **Provider State Management**, **Supabase**, serta penyimpanan lokal menggunakan **Hive** dan **SharedPreferences**.
