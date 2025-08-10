# Integrasi Sistem IoT RFID untuk Presensi

## Overview
Aplikasi SiSantri telah diperbarui untuk mengintegrasikan sistem presensi berbasis RFID IoT. Santri tidak lagi melakukan presensi manual melalui aplikasi, melainkan dengan mengetap kartu RFID mereka pada reader yang tersedia.

## Arsitektur Sistem

```
[Kartu RFID Santri] → [RFID Reader] → [IoT Device] → [Firebase Firestore] → [Aplikasi Mobile]
```

## Komponen Sistem

### 1. Perangkat IoT RFID
- **RFID Reader**: Untuk membaca kartu RFID santri
- **Microcontroller**: ESP32/Arduino dengan WiFi untuk komunikasi ke Firebase
- **Display**: LCD untuk menampilkan status presensi
- **LED Indicator**: Indikator status (hijau=berhasil, merah=gagal)

### 2. Kartu RFID Santri
- Setiap santri memiliki kartu RFID unik
- UID kartu terdaftar di database dengan ID user
- Kartu berisi informasi identitas santri

### 3. Database Structure
```
users/{userId}
├── nama: "Ahmad Santri"
├── rfidUid: "04:52:8E:2A:3B:80"
└── ...

presensi/{presensiId}
├── userId: "user123"
├── tanggal: Timestamp
├── status: "hadir|izin|sakit|alpha"
├── keterangan: "Tap RFID - Reader 1"
├── rfidUid: "04:52:8E:2A:3B:80"
├── deviceId: "reader_001"
└── poinDiperoleh: 10
```

## Fitur Aplikasi Mobile

### 1. Info Sistem RFID
- Status sistem (aktif/tidak aktif)
- Instruksi penggunaan
- Icon contactless untuk indikasi RFID

### 2. Presensi Hari Ini
- Menampilkan status presensi terkini
- Badge "RFID" untuk menunjukkan sumber data
- Waktu tap dan lokasi reader

### 3. Statistik Bulanan
- Persentase kehadiran
- Total hadir, izin, sakit, alpha
- Visualisasi data dalam card

### 4. Riwayat Presensi
- Daftar presensi dengan badge RFID
- Informasi reader dan waktu
- Filter berdasarkan periode

## Implementasi IoT Device

### Hardware Requirements
```
- ESP32/Arduino Uno + WiFi Shield
- MFRC522 RFID Reader Module
- LCD Display 16x2
- LED RGB
- Buzzer
- Power Supply 5V
```

### Software (Arduino/ESP32)
```cpp
#include <WiFi.h>
#include <FirebaseESP32.h>
#include <MFRC522.h>
#include <LiquidCrystal_I2C.h>

// Firebase Config
#define FIREBASE_HOST "your-project.firebaseio.com"
#define FIREBASE_AUTH "your-auth-token"

// WiFi Config
const char* ssid = "YourWiFi";
const char* password = "YourPassword";

// RFID Pins
#define RST_PIN 9
#define SS_PIN 10

MFRC522 mfrc522(SS_PIN, RST_PIN);
LiquidCrystal_I2C lcd(0x27, 16, 2);

void setup() {
  // Initialize components
  Serial.begin(115200);
  SPI.begin();
  mfrc522.PCD_Init();
  lcd.init();
  lcd.backlight();
  
  // Connect to WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  
  // Initialize Firebase
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  
  lcd.setCursor(0, 0);
  lcd.print("RFID Ready");
}

void loop() {
  // Check for RFID card
  if (mfrc522.PICC_IsNewCardPresent() && mfrc522.PICC_ReadCardSerial()) {
    String rfidUid = "";
    
    // Read UID
    for (byte i = 0; i < mfrc522.uid.size; i++) {
      rfidUid += String(mfrc522.uid.uidByte[i] < 0x10 ? "0" : "");
      rfidUid += String(mfrc522.uid.uidByte[i], HEX);
      if (i != mfrc522.uid.size - 1) rfidUid += ":";
    }
    
    rfidUid.toUpperCase();
    
    // Process presensi
    processPresensi(rfidUid);
    
    mfrc522.PICC_HaltA();
    delay(2000);
  }
}

void processPresensi(String rfidUid) {
  // Find user by RFID UID
  String userId = findUserByRfid(rfidUid);
  
  if (userId != "") {
    // Create presensi record
    createPresensiRecord(userId, rfidUid);
    
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Presensi Berhasil");
    
    // Green LED
    digitalWrite(LED_GREEN, HIGH);
    delay(1000);
    digitalWrite(LED_GREEN, LOW);
  } else {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Kartu Tidak");
    lcd.setCursor(0, 1);
    lcd.print("Terdaftar");
    
    // Red LED
    digitalWrite(LED_RED, HIGH);
    delay(1000);
    digitalWrite(LED_RED, LOW);
  }
}

String findUserByRfid(String rfidUid) {
  // Query Firebase to find user with matching RFID UID
  // Return userId if found, empty string if not found
}

void createPresensiRecord(String userId, String rfidUid) {
  // Create presensi record in Firebase
  // Include timestamp, device info, etc.
}
```

## Setup dan Konfigurasi

### 1. Database Setup
1. Tambahkan field `rfidUid` ke collection `users`
2. Setup security rules untuk IoT device
3. Create collection `rfid_devices` untuk management

### 2. RFID Card Registration
1. Admin page untuk register kartu RFID
2. Scanner RFID UID dan assign ke user
3. Bulk import dari file CSV

### 3. Device Management
1. Device registration dan authentication
2. Remote configuration update
3. Monitoring status device

## Security Considerations

### 1. Device Authentication
- Unique device ID dan secret key
- Token-based authentication ke Firebase
- Network security (WPA2/WPA3)

### 2. Data Validation
- Validate RFID UID format
- Check duplicate presensi (prevent double tap)
- Verify device authorization

### 3. Privacy Protection
- Encrypt sensitive data
- Log access attempts
- GDPR compliance

## Troubleshooting

### Common Issues
1. **RFID Reader Not Working**
   - Check wiring connections
   - Verify power supply
   - Test with known good card

2. **WiFi Connection Issues**
   - Check network credentials
   - Verify signal strength
   - Reset network settings

3. **Firebase Connection Issues**
   - Verify project configuration
   - Check authentication tokens
   - Monitor quota usage

### Monitoring Tools
- Firebase Console untuk real-time data
- Device logs via serial monitor
- Network diagnostics tools

## Future Enhancements

1. **Multi-Location Support**
   - Different readers for different activities
   - Location-based presensi rules

2. **Advanced Analytics**
   - Attendance patterns analysis
   - Predictive analytics
   - Custom reports

3. **Integration Features**
   - SMS notifications to parents
   - Integration with school management system
   - API untuk third-party systems

## Maintenance

### Regular Tasks
- Clean RFID readers monthly
- Update device firmware quarterly
- Backup database weekly
- Monitor system performance daily

### Emergency Procedures
- Manual presensi backup system
- Device replacement procedures
- Data recovery protocols
