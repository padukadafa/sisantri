# SiSantri IoT Backend

Backend API untuk sistem presensi RFID SiSantri menggunakan Node.js dan Express.

## Fitur

- ✅ Autentikasi dengan API Key dan Device Credentials
- ✅ Integrasi Firebase Firestore
- ✅ Recording presensi dari RFID scan
- ✅ Validasi kartu RFID terdaftar
- ✅ Cek duplikasi presensi harian
- ✅ Logging aktivitas device
- ✅ Statistik kehadiran
- ✅ Rate limiting
- ✅ Security headers (Helmet)
- ✅ CORS support

## Instalasi

### 1. Install Dependencies

```bash
cd iot/backend
npm install
```

### 2. Konfigurasi Environment Variables

Copy file `.env.example` menjadi `.env`:

```bash
cp .env.example .env
```

Edit `.env` dan isi dengan kredensial Anda:

```env
PORT=3000
NODE_ENV=development

# Firebase Admin SDK
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour private key here\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=your-service-account@your-project.iam.gserviceaccount.com

# API Security
API_KEY=your-secret-api-key-here
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Device Settings
DEVICE_ID=rfid-reader-001
DEVICE_SECRET=your-device-secret-here
```

### 3. Setup Firebase Admin SDK

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih project Anda
3. Masuk ke **Project Settings** > **Service Accounts**
4. Klik **Generate new private key**
5. Download file JSON
6. Copy nilai `project_id`, `private_key`, dan `client_email` ke file `.env`

## Menjalankan Server

### Development Mode (dengan auto-reload)

```bash
npm run dev
```

### Production Mode

```bash
npm start
```

Server akan berjalan di `http://localhost:3000`

## API Endpoints

### 1. Health Check

**Public endpoint** - Tidak memerlukan autentikasi

```
GET /health
```

**Response:**

```json
{
  "success": true,
  "message": "SiSantri IoT Backend is running",
  "timestamp": "2025-10-28T10:30:00.000Z",
  "version": "1.0.0"
}
```

### 2. Record Attendance (RFID Scan)

**Endpoint untuk device IoT** - Memerlukan API Key dan Device Credentials

```
POST /api/attendance/scan
```

**Headers:**

```
x-api-key: your-secret-api-key-here
x-device-id: rfid-reader-001
x-device-secret: your-device-secret-here
Content-Type: application/json
```

**Request Body:**

```json
{
  "rfidUid": "A1B2C3D4"
}
```

**Response Success (201):**

```json
{
  "success": true,
  "message": "Presensi berhasil dicatat",
  "data": {
    "user": {
      "id": "user123",
      "nama": "Ahmad Santri",
      "nim": "2024001"
    },
    "attendance": {
      "id": "attendance123",
      "status": "hadir",
      "timestamp": "2025-10-28T10:30:00.000Z",
      "method": "rfid"
    },
    "stats": {
      "total": 20,
      "hadir": 18,
      "izin": 1,
      "sakit": 1,
      "alpha": 0
    }
  }
}
```

**Response Error - RFID Not Registered (404):**

```json
{
  "success": false,
  "error": "RFID not registered",
  "message": "Kartu RFID tidak terdaftar"
}
```

**Response Error - Already Recorded (409):**

```json
{
  "success": false,
  "error": "Already recorded",
  "message": "Presensi hari ini sudah tercatat",
  "data": {
    "user": {
      "id": "user123",
      "nama": "Ahmad Santri",
      "nim": "2024001"
    },
    "attendance": {
      "id": "attendance123",
      "status": "hadir",
      "timestamp": "2025-10-28T07:00:00.000Z"
    }
  }
}
```

### 3. Check Attendance Status

**Cek status presensi berdasarkan RFID**

```
GET /api/attendance/status/:rfidUid
```

**Headers:**

```
x-api-key: your-secret-api-key-here
x-device-id: rfid-reader-001
x-device-secret: your-device-secret-here
```

**Response Success (200):**

```json
{
  "success": true,
  "data": {
    "user": {
      "id": "user123",
      "nama": "Ahmad Santri",
      "nim": "2024001"
    },
    "todayAttendance": {
      "id": "attendance123",
      "status": "hadir",
      "timestamp": "2025-10-28T07:00:00.000Z"
    },
    "stats": {
      "total": 20,
      "hadir": 18,
      "izin": 1,
      "sakit": 1,
      "alpha": 0
    }
  }
}
```

## Struktur Database

### Collection: `users`

```javascript
{
  id: "user123",
  nama: "Ahmad Santri",
  nim: "2024001",
  rfidUid: "A1B2C3D4",  // UID dari kartu RFID
  email: "ahmad@example.com",
  // ... field lainnya
}
```

### Collection: `presensi`

```javascript
{
  id: "attendance123",
  userId: "user123",
  userName: "Ahmad Santri",
  userNim: "2024001",
  status: "hadir",  // hadir, izin, sakit, alpha
  method: "rfid",
  rfidUid: "A1B2C3D4",
  deviceId: "rfid-reader-001",
  timestamp: Timestamp,
  createdAt: Timestamp
}
```

### Collection: `device_logs`

```javascript
{
  deviceId: "rfid-reader-001",
  action: "rfid_scan",
  rfidUid: "A1B2C3D4",
  userId: "user123",
  userName: "Ahmad Santri",
  status: "success",  // success, user_not_found, duplicate_attendance
  attendanceStatus: "hadir",
  timestamp: Timestamp
}
```

## Keamanan

1. **API Key Authentication** - Semua endpoint `/api/*` memerlukan API key di header
2. **Device Credentials** - Endpoint attendance memerlukan device ID dan secret
3. **Rate Limiting** - Maksimal 100 request per 15 menit per IP
4. **Helmet.js** - Security headers untuk melindungi dari common vulnerabilities
5. **CORS** - Konfigurasi CORS untuk membatasi origin yang diizinkan

## Testing dengan cURL

### Record Attendance

```bash
curl -X POST http://localhost:3000/api/attendance/scan \
  -H "Content-Type: application/json" \
  -H "x-api-key: your-secret-api-key-here" \
  -H "x-device-id: rfid-reader-001" \
  -H "x-device-secret: your-device-secret-here" \
  -d '{"rfidUid": "A1B2C3D4"}'
```

### Check Status

```bash
curl -X GET http://localhost:3000/api/attendance/status/A1B2C3D4 \
  -H "x-api-key: your-secret-api-key-here" \
  -H "x-device-id: rfid-reader-001" \
  -H "x-device-secret: your-device-secret-here"
```

## Integration dengan IoT Device

Contoh kode untuk ESP32/Arduino yang mengirim data RFID:

```cpp
#include <WiFi.h>
#include <HTTPClient.h>

const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";
const char* serverUrl = "http://your-server-ip:3000/api/attendance/scan";
const char* apiKey = "your-secret-api-key-here";
const char* deviceId = "rfid-reader-001";
const char* deviceSecret = "your-device-secret-here";

void sendAttendance(String rfidUid) {
  if(WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin(serverUrl);
    http.addHeader("Content-Type", "application/json");
    http.addHeader("x-api-key", apiKey);
    http.addHeader("x-device-id", deviceId);
    http.addHeader("x-device-secret", deviceSecret);

    String jsonPayload = "{\"rfidUid\":\"" + rfidUid + "\"}";
    int httpResponseCode = http.POST(jsonPayload);

    if(httpResponseCode > 0) {
      String response = http.getString();
      Serial.println(response);
    }

    http.end();
  }
}
```

## Logging

Server menggunakan Morgan untuk logging HTTP requests. Semua request akan dicatat dengan format:

```
:remote-addr - :remote-user [:date[clf]] ":method :url HTTP/:http-version" :status :res[content-length] ":referrer" ":user-agent"
```

Device logs disimpan di collection `device_logs` di Firestore.

## Error Handling

Semua error akan dikembalikan dalam format:

```json
{
  "success": false,
  "error": "Error message here",
  "stack": "Stack trace (hanya di development mode)"
}
```

## Production Deployment

1. Set `NODE_ENV=production`
2. Gunakan process manager seperti PM2:

```bash
npm install -g pm2
pm2 start server.js --name sisantri-iot
pm2 save
pm2 startup
```

3. Setup reverse proxy dengan Nginx
4. Gunakan HTTPS dengan SSL certificate
5. Configure firewall rules

## License

ISC
