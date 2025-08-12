# RFID/NFC Implementation Notes

## Current Implementation Status

### ✅ **Completed Features:**
1. **User Management RFID Integration**
   - Dialog untuk mengelola kartu RFID per user
   - Manual input ID kartu RFID
   - Mock NFC scanning functionality (demo mode)
   - RFID status indicator di user cards
   - Validasi duplikasi kartu antar user
   - Activity logging untuk operasi RFID

2. **Database Integration**
   - Field `rfidCardId` di UserModel
   - Firestore update untuk assign/unassign kartu
   - Real-time sync dengan user interface

3. **Android Permissions**
   - NFC permission ditambahkan ke AndroidManifest.xml
   - Hardware feature declaration (optional)

### 🔄 **Demo Mode (Current):**
Implementasi saat ini menggunakan **mock NFC service** untuk demonstrasi:
- Generate random card ID untuk simulasi
- Delay yang realistis untuk user experience
- Error handling yang proper
- Interface yang sama dengan implementasi real

### 🚀 **For Real NFC Implementation:**

#### **1. Update NFC Service**
File: `lib/shared/services/nfc_service.dart`

Uncomment dan aktifkan real NFC implementation:
```dart
// Replace mock functions with real nfc_manager implementation
return await NfcManager.instance.isAvailable();

// Use actual NFC session
await NfcManager.instance.startSession(
  pollingOptions: {NfcPollingOption.iso14443},
  onDiscovered: (NfcTag tag) async {
    // Real tag processing
  },
);
```

#### **2. Add Proper NFC Tag Processing**
```dart
// Example for Mifare Classic cards
final mifareClassic = MifareClassic.from(tag);
if (mifareClassic != null) {
  final cardId = mifareClassic.identifier
    .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
    .join('')
    .toUpperCase();
  return cardId;
}
```

#### **3. iOS Configuration**
Add to `ios/Runner/Info.plist`:
```xml
<key>NFCReaderUsageDescription</key>
<string>This app uses NFC to read RFID cards for attendance tracking</string>

<key>com.apple.developer.nfc.readersession.iso7816.select-identifiers</key>
<array>
  <string>A0000002471001</string>
</array>
```

## Testing Instructions

### **Demo Mode Testing:**
1. Open User Management sebagai admin
2. Pilih user → Menu ⋮ → "Kelola RFID"
3. Tap "Scan Kartu RFID" untuk simulasi
4. Atau input manual: contoh `A1B2C3D4E5F6`
5. Save dan lihat status RFID di user card

### **Real Device Testing:**
1. Deploy ke device dengan NFC hardware
2. Enable NFC di device settings
3. Gunakan kartu Mifare untuk testing
4. Monitor debug console untuk tag detection

## Supported Card Types

### **Target Cards:**
- **Mifare Classic 1K/4K** (Most common)
- **Mifare Ultralight** (Budget option)
- **ISO14443-A** compatible cards

### **Card ID Format:**
- Length: 8-16 hex characters
- Format: `AABBCCDD` atau `AABBCCDDEEFF`
- Display: `AABB-CCDD` atau `AABB-CCDD-EEFF`

## Security Considerations

### **Current Implementation:**
- ID kartu disimpan plain text di Firestore
- Validasi duplikasi untuk prevent card sharing
- Activity logging untuk audit trail

### **Production Recommendations:**
1. **Encrypt card IDs** sebelum disimpan
2. **Hash verification** untuk detect card cloning
3. **Expiry dates** untuk kartu
4. **Rate limiting** untuk prevent brute force
5. **Audit logs** dengan timestamp dan location

## Integration dengan Attendance System

### **Database Schema:**
```firestore
// Collection: users
{
  "id": "user123",
  "nama": "Ahmad Santri",
  "rfidCardId": "A1B2C3D4E5F6",
  // ... other fields
}

// Collection: attendance (future)
{
  "userId": "user123",
  "cardId": "A1B2C3D4E5F6", 
  "timestamp": "2025-08-12T10:30:00Z",
  "location": "Mushalla",
  "verified": true
}
```

### **Attendance Flow:**
1. **RFID Reader** baca kartu → dapat Card ID
2. **Query Firestore** dengan cardId → dapat userId
3. **Create attendance record** dengan timestamp
4. **Real-time update** ke mobile app

## Hardware Requirements

### **Mobile Device:**
- Android 4.4+ dengan NFC hardware
- iOS 13.0+ dengan NFC capability
- NFC enabled di device settings

### **RFID Cards:**
- Frequency: 13.56 MHz
- Protocol: ISO14443-A (Mifare)
- Memory: 1KB+ (recommended)
- Physical: Standard credit card size

### **Optional: External RFID Reader**
Untuk fixed installation (mushalla entrance):
- Arduino/ESP32 dengan RFID module
- WiFi connectivity untuk cloud sync
- Power supply dan housing

## Troubleshooting

### **Common Issues:**

1. **"NFC tidak tersedia"**
   - Check device memiliki NFC hardware
   - Enable NFC di Settings
   - Restart aplikasi

2. **"Kartu tidak terbaca"**
   - Pastikan kartu compatible (Mifare)
   - Tempelkan kartu dekat NFC area (biasanya bagian belakang phone)
   - Coba kartu berbeda

3. **"ID kartu tidak valid"**
   - Format harus hexadecimal (0-9, A-F)
   - Minimal 8 karakter
   - Contoh valid: `AABBCCDD`

4. **"Kartu sudah digunakan"**
   - Check user mana yang sudah assign kartu tersebut
   - Unassign dari user lama atau gunakan kartu berbeda

## Future Enhancements

### **Phase 2 Features:**
- [ ] Bulk card assignment dari CSV
- [ ] Card history dan usage analytics  
- [ ] Card expiry date management
- [ ] Clone detection algorithm
- [ ] Geographic restriction per card

### **Phase 3 Features:**
- [ ] Integration dengan hardware RFID reader
- [ ] Real-time attendance dashboard
- [ ] SMS/Email notification untuk presensi
- [ ] Offline capability untuk attendance
- [ ] Backup/restore card assignments

## Development Notes

### **Code Structure:**
```
lib/
├── shared/
│   ├── models/
│   │   ├── user_model.dart (has rfidCardId field)
│   │   └── rfid_card_model.dart (future use)
│   └── services/
│       └── nfc_service.dart (NFC operations)
└── features/
    └── admin/
        └── presentation/
            └── user_management_page.dart (RFID dialogs)
```

### **Dependencies:**
- `nfc_manager: ^4.0.2` (added to pubspec.yaml)
- Platform permissions configured
- Firebase Firestore untuk data storage

### **Testing:**
- Unit tests untuk NFC service methods
- Widget tests untuk RFID dialogs
- Integration tests untuk end-to-end flow
