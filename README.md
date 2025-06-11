# Tugas Akhir Mobile

Aplikasi mobile menggunakan Flutter (frontend) dan Laravel (backend).

## Struktur Folder
- `frontend-flutter/` → Aplikasi Flutter
- `backend-laravel/` → API Laravel

## Cara Menjalankan

### Laravel:
1. `cd backend-laravel`
2. `composer install`
3. `cp .env.example .env`
4. `php artisan key:generate`
5. Atur database di `.env`
6. `php artisan migrate`
7. `php artisan serve`

### Flutter:
1. `cd frontend-flutter`
2. `flutter pub get`
3. Jalankan dengan `flutter run`
