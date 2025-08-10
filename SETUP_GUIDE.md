# SiSantri RFID IoT Setup Guide

## Aplikasi Mobile

✅ **Selesai**: Aplikasi telah diperbarui untuk menampilkan data presensi dari sistem RFID

### Fitur yang Telah Diimplementasi:

1. **Halaman Presensi RFID**
   - Info sistem RFID dengan status aktif
   - Presensi hari ini dengan badge RFID
   - Statistik bulanan (tingkat kehadiran, breakdown status)
   - Riwayat presensi dengan indikator RFID

2. **UI/UX Improvements**
   - Icon contactless untuk tema RFID
   - Badge "RFID" pada setiap entri presensi
   - Loading states dan error handling
   - Pull-to-refresh functionality

3. **Data Model Updates**
   - Tambahan status "Alpha" untuk absen
   - Property `color` dan `icon` untuk StatusPresensi
   - Property `formattedTime` dan `formattedDate` untuk PresensiModel

## Hardware Setup

### 1. Komponen yang Dibutuhkan
- ESP32 Development Board
- MFRC522 RFID Reader Module
- LCD Display 16x2 dengan I2C
- LED RGB (3 warna)
- Buzzer
- Resistors dan jumper wires
- Power supply 5V

### 2. Wiring Diagram
```
ESP32  →  MFRC522
22     →  RST
21     →  SDA(SS)
18     →  SCK
23     →  MOSI
19     →  MISO
3.3V   →  3.3V
GND    →  GND

ESP32  →  Components
18     →  LED Green (+)
5      →  LED Red (+)
17     →  LED Blue (+)
19     →  Buzzer (+)
22     →  LCD SDA
21     →  LCD SCL
```

### 3. Arduino Libraries Required
```
- WiFi (ESP32 Core)
- HTTPClient (ESP32 Core)
- ArduinoJson (by Benoit Blanchon)
- MFRC522 (by GithubCommunity)
- LiquidCrystal_I2C (by Frank de Brabander)
- NTPClient (by Fabrice Weinberg)
```

## Firebase Configuration

### 1. Database Structure Update
Tambahkan field berikut ke collection `users`:
```json
{
  "users": {
    "userId123": {
      "nama": "Ahmad Santri",
      "email": "ahmad@example.com",
      "rfidUid": "04:52:8E:2A:3B:80",
      "role": "santri",
      "poin": 250,
      "statusAktif": true,
      "createdAt": "timestamp",
      "updatedAt": "timestamp"
    }
  }
}
```

### 2. Presensi Collection
```json
{
  "presensi": {
    "presensiId123": {
      "userId": "userId123",
      "tanggal": "timestamp",
      "status": "hadir",
      "keterangan": "RFID Tap - Masjid Utama",
      "rfidUid": "04:52:8E:2A:3B:80",
      "deviceId": "rfid_reader_001",
      "poinDiperoleh": 10,
      "createdAt": "timestamp"
    }
  }
}
```

### 3. Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null;
    }
    
    // Presensi collection
    match /presensi/{presensiId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null || 
                      resource.data.deviceId in ['rfid_reader_001', 'rfid_reader_002'];
    }
    
    // Device collection for IoT authentication
    match /devices/{deviceId} {
      allow read: if request.auth != null;
    }
  }
}
```

## Deployment Steps

### 1. Setup Hardware
1. Rakit komponen sesuai wiring diagram
2. Test koneksi dengan multimeter
3. Upload kode Arduino ke ESP32
4. Test RFID reader dengan kartu sample

### 2. Konfigurasi Software
1. Update `iot/rfid_device_code.ino` dengan:
   - WiFi credentials
   - Firebase project ID dan API key
   - Device ID unik
   - Lokasi perangkat

2. Install libraries yang diperlukan di Arduino IDE

### 3. Register RFID Cards
1. Buat halaman admin untuk register kartu RFID
2. Scan UID kartu dan assign ke user
3. Test dengan tap kartu pada reader

### 4. Testing System
1. Test koneksi WiFi
2. Test Firebase connectivity
3. Test RFID reading dan writing to database
4. Test aplikasi mobile menerima data real-time

## Monitoring dan Maintenance

### 1. System Monitoring
- Monitor device status melalui Firebase Console
- Check logs di Serial Monitor untuk debugging
- Monitor network connectivity

### 2. Troubleshooting Common Issues
- **RFID tidak terbaca**: Check wiring dan power supply
- **WiFi disconnect**: Implement auto-reconnect
- **Firebase error**: Check API quotas dan authentication

### 3. Regular Maintenance
- Clean RFID reader setiap bulan
- Update firmware quarterly
- Backup database configuration
- Monitor system performance

## Admin Features (Future Development)

### 1. Device Management
- Dashboard untuk monitor semua RFID readers
- Remote configuration updates
- Device status monitoring

### 2. RFID Card Management
- Bulk import/export RFID cards
- Card replacement workflow
- Lost card reporting

### 3. Analytics
- Attendance pattern analysis
- Device usage statistics
- Performance metrics

## Security Considerations

### 1. Device Security
- Use HTTPS untuk semua komunikasi
- Implement device authentication
- Regular security updates

### 2. Data Privacy
- Encrypt sensitive RFID data
- Implement access controls
- GDPR compliance measures

## Status Implementasi

✅ **Completed**:
- Mobile app presensi page redesigned for RFID
- Data models updated with new fields
- UI components with RFID theming
- Error handling and loading states

🔄 **In Progress**:
- Hardware setup dan testing
- Firebase security rules optimization
- Admin panel untuk RFID management

📋 **Planned**:
- Multi-device support
- Advanced analytics
- Parent notification system
- Integration dengan sistem akademik

## Contact dan Support

Untuk pertanyaan teknis atau dukungan implementasi:
- GitHub Issues: (repository link)
- Email: support@sisantri.com
- Documentation: /docs/rfid-setup.md
