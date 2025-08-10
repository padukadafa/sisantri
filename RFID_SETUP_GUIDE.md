# RFID Integration - Setup Guide

## 🏷️ Overview

Sistem RFID SiSantri memungkinkan santri melakukan presensi otomatis dengan tap kartu RFID tanpa perlu input manual. Sistem ini terintegrasi penuh dengan aplikasi mobile dan memblokir akses santri yang belum setup RFID.

## ✨ Fitur Utama

### 1. **RFID Card Management**
- Setup dan assign RFID card untuk setiap santri
- Edit dan hapus RFID card assignment
- Real-time monitoring status RFID santri

### 2. **Access Control**
- Santri tanpa RFID tidak dapat mengakses aplikasi
- Halaman khusus "Contact Admin" untuk santri tanpa RFID
- Admin dapat mengakses aplikasi tanpa setup RFID

### 3. **User Model Enhancement**
- Field `rfidCardId` di UserModel
- Method `hasRfidSetup` dan `needsRfidSetup`
- Support untuk ID kartu RFID alfanumerik

## 📱 Flow Aplikasi

### Untuk Santri:
1. **Login** → Sistem cek status RFID
2. **Jika RFID belum setup** → Tampil halaman "Contact Admin"
3. **Jika RFID sudah setup** → Akses normal ke aplikasi
4. **Presensi otomatis** dengan tap kartu RFID di reader

### Untuk Admin:
1. **Login** → Akses langsung (tidak perlu RFID)
2. **Admin Panel** → Menu "Manajemen RFID"
3. **Setup RFID** untuk santri baru
4. **Monitor status** RFID semua santri

## 🔧 Technical Implementation

### Database Schema Update

```yaml
users/{userId}:
  # Existing fields...
  rfidCardId: string  # ID kartu RFID (nullable)
  
  # New computed properties:
  hasRfidSetup: boolean      # rfidCardId != null && !empty
  needsRfidSetup: boolean    # isSantri && !hasRfidSetup
```

### New Files Created

```
lib/
├── features/
│   ├── admin/presentation/
│   │   └── rfid_management_page.dart    # Admin RFID management UI
│   └── auth/presentation/
│       └── rfid_setup_required_page.dart # Santri blocked access page
└── shared/models/
    └── user_model.dart                   # Updated with RFID fields
```

### Modified Files

```
lib/
├── features/auth/presentation/
│   └── auth_wrapper.dart                 # Added RFID access control
└── pages/
    └── admin_page.dart                   # Added RFID management menu
```

## 📋 Admin Guide - RFID Management

### Accessing RFID Management
1. Login sebagai Admin
2. Pergi ke **Admin Panel**
3. Klik **"Manajemen RFID"**

### Setup RFID untuk Santri Baru
1. Di halaman RFID Management, cari santri yang belum setup
2. Klik **"Setup RFID"** pada card santri
3. Masukkan RFID Card ID (contoh: A1B2C3D4, 12345678)
4. Klik **"Simpan"**

### Edit RFID Card
1. Cari santri yang sudah ada RFID
2. Klik **"Edit RFID"**
3. Ubah RFID Card ID
4. Klik **"Simpan"**

### Hapus RFID Card
1. Klik **"Hapus"** pada santri dengan RFID aktif
2. Konfirmasi penghapusan
3. ⚠️ **Warning**: Santri tidak akan bisa akses aplikasi setelah RFID dihapus

### Search & Filter
- Gunakan search bar untuk cari santri berdasarkan:
  - Nama santri
  - Email
  - RFID Card ID

## 🔒 Access Control Logic

### AuthWrapper Logic
```dart
// Check user authentication
if (user.isAuthenticated) {
  if (user.needsRfidSetup) {
    // Show RfidSetupRequiredPage
    return RfidSetupRequiredPage();
  } else {
    // Normal app access
    return MainNavigation();
  }
}
```

### User Model Properties
```dart
class UserModel {
  final String? rfidCardId;
  
  // Computed properties
  bool get hasRfidSetup => rfidCardId != null && rfidCardId!.isNotEmpty;
  bool get needsRfidSetup => isSantri && !hasRfidSetup;
}
```

## 🎯 RFID Card ID Format

### Supported Formats
- **Alphanumeric**: A1B2C3D4, F7E8D9C0
- **Numeric**: 12345678, 87654321
- **Mixed**: ABC123, 123DEF

### Validation Rules
- Minimum 4 characters
- Maximum 16 characters
- Case insensitive (auto-converted to uppercase)
- No special characters except numbers and letters

### Examples
```
Valid:   A1B2C3D4, 12345678, ABC123, F7E8D9C0
Invalid: A1-B2-C3, @#$%, AB, 123456789012345678
```

## 🚨 Error Handling

### Santri Blocked Access
- **Trigger**: Login santri tanpa RFID setup
- **Action**: Redirect ke RfidSetupRequiredPage
- **Solution**: Contact admin untuk setup RFID

### RFID Update Errors
- **Network error**: Show retry option
- **Duplicate RFID**: Validation di Firestore rules
- **Permission error**: Check admin role

### Data Sync Issues
- **Real-time updates**: Provider auto-refresh setelah RFID update
- **Cache invalidation**: Manual refresh button tersedia
- **Offline mode**: Queue updates ketika online kembali

## 📱 UI Components

### RfidSetupRequiredPage Features
- 🎨 **Modern Design**: Card-based layout dengan icons
- 📞 **Contact Info**: Admin contact details
- 🔄 **Refresh Option**: Check RFID status button
- 🚪 **Logout Button**: Clean exit dari aplikasi

### RfidManagementPage Features
- 🔍 **Search**: Real-time search santri
- 📊 **Status Cards**: Visual RFID status indicators
- ✏️ **Inline Editing**: Quick RFID setup/edit
- 🗑️ **Safe Deletion**: Confirmation dialogs

## 🔄 Integration Points

### dengan Presensi System
- RFID Card ID digunakan untuk identify santri di IoT device
- Auto-match dengan UserModel berdasarkan rfidCardId
- Backup manual entry jika RFID reader offline

### dengan Analytics
- Track RFID setup completion rate
- Monitor santri yang belum setup RFID
- RFID usage statistics untuk admin

### dengan Notifications
- Push notification ke santri saat RFID di-setup
- Admin notification untuk santri yang perlu setup RFID
- Weekly reminder untuk santri belum setup

## 🛠️ Troubleshooting

### Santri Tidak Bisa Login
1. **Check**: Apakah santri sudah punya RFID di database?
2. **Action**: Admin setup RFID via RFID Management page
3. **Test**: Santri logout dan login kembali

### RFID Card Tidak Terdeteksi
1. **Check**: RFID Card ID format benar?
2. **Check**: RFID reader device online?
3. **Action**: Test card di reader lain atau ganti card

### Data Tidak Sinkron
1. **Refresh**: Gunakan refresh button di RFID Management
2. **Logout**: Admin logout dan login kembali
3. **Cache**: Clear app cache jika perlu

## 📈 Future Enhancements

### Phase 2 Features
- **Bulk RFID Import**: CSV upload untuk batch setup
- **RFID History**: Log semua perubahan RFID
- **Card Printing**: Integration dengan printer untuk RFID cards
- **NFC Support**: Smartphone sebagai RFID reader

### Analytics Dashboard
- **RFID Coverage**: Persentase santri dengan RFID
- **Usage Statistics**: Presensi via RFID vs manual
- **Device Health**: RFID reader status monitoring
- **Performance Metrics**: Response time dan success rate

---

## 📞 Support

Untuk bantuan implementasi RFID system:
- **Technical**: tech@sisantri.com
- **Hardware**: hardware@sisantri.com
- **WhatsApp**: +62-812-3456-7890

---

*Created: December 2024*  
*Version: 1.0.0*  
*Compatible: SiSantri Mobile App v2.0+*
