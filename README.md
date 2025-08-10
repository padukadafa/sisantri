# SiSantri - Sistem Gamifikasi Pondok Pesantren Modern

Aplikasi gamifikasi untuk Pondok Pesantren Mahasiswa Al-Awwabin Sukarame – Bandar Lampung yang memberikan pengalaman digital bagi santri untuk melihat jadwal pengajian, jadwal kegiatan, melakukan presensi otomatis dengan RFID, melihat leaderboard santri paling rajin, autentikasi, dan menerima pengumuman.

> **PENTING**: Aplikasi ini menggunakan sistem presensi otomatis dengan teknologi IoT RFID untuk pengalaman santri yang seamless.

## 🚀 Fitur Utama

### 🔐 Autentikasi & Manajemen User
- Login & Register via email/password
- Google Sign-In integration
- Role-based access control (admin & santri)
- Password reset functionality
- Auto user setup dan profile management
- Logout system dengan konfirmasi

### 📅 Jadwal Pengajian
- Menampilkan daftar pengajian real-time dari Firestore
- Filter berdasarkan minggu/bulan/tahun
- Detail tema, pemateri, dan lokasi
- Notifikasi reminder otomatis
- CRUD operations untuk admin

### 🎯 Jadwal Kegiatan
- Daftar kegiatan pondok dengan timeline
- Notifikasi pengingat sehari sebelumnya
- Status kegiatan (hari ini/besok/selesai)
- Manajemen kegiatan untuk admin

### 🏷️ **Presensi Otomatis RFID (IoT System)**
- **Hardware**: ESP32 + MFRC522 RFID Reader
- **Otomatis**: Tap kartu RFID untuk presensi
- **Real-time**: Data langsung tersinkron ke Firestore
- **Status**: Hadir/Izin/Sakit/Alpha dengan timestamp
- **Dashboard**: Info sistem RFID, statistik harian/bulanan
- **History**: Riwayat presensi dengan badge status
- **Poin System**: Otomatis memberikan poin berdasarkan kehadiran

### 🏆 Leaderboard Gamifikasi
- Ranking berdasarkan poin akumulasi
- Filter periode (mingguan/bulanan/tahunan)
- Podium visual untuk top 3 santri
- Badge dan medal achievement system
- Progress tracking dan streak counter

### 📢 Sistem Pengumuman
- Admin dapat membuat pengumuman multimedia
- Push notification real-time
- Marker prioritas untuk pengumuman penting
- Rich text dan media attachment support

### 👤 Profil & Dashboard
- Dashboard personal dengan statistik lengkap
- Edit profil dengan foto upload
- Tracking poin dan achievement
- Pengaturan notifikasi dan preferensi
- Logout functionality di semua halaman

## 🛠 Teknologi & Arsitektur

### Mobile App (Flutter)
- **Framework**: Flutter 3+ dengan Material Design 3
- **Language**: Dart 3+
- **State Management**: Riverpod untuk reactive programming
- **Navigation**: Go Router untuk navigation management
- **UI Components**: Custom widgets dengan konsistensi design system

### Backend & Database
- **Authentication**: Firebase Authentication
- **Database**: Firebase Firestore (NoSQL)
- **File Storage**: Firebase Storage untuk media files
- **Push Notifications**: Firebase Cloud Messaging (FCM)
- **Functions**: Firebase Cloud Functions untuk server-side logic

### IoT RFID System
- **Hardware**: ESP32 microcontroller + MFRC522 RFID module
- **Connectivity**: WiFi untuk komunikasi dengan Firebase
- **Protocol**: HTTP REST API calls ke Firestore
- **Cards**: RFID cards/tags untuk identifikasi santri

### Development Tools
- **IDE**: VS Code / Android Studio
- **Version Control**: Git
- **Testing**: Flutter test framework
- **Analytics**: Firebase Analytics untuk user behavior tracking

## 🔧 Setup dan Instalasi

### 1. Prerequisites Mobile App

```bash
# Install Flutter
flutter --version  # Minimum Flutter 3.0+
dart --version     # Minimum Dart 3.0+

# Check flutter doctor
flutter doctor
```

### 2. Clone Repository

```bash
git clone <repository-url>
cd sisantri
flutter pub get
```

### 3. Firebase Configuration

#### 3.1 Firebase Project Setup
1. Buat project di [Firebase Console](https://console.firebase.google.com/)
2. Enable services:
   - Authentication (Email/Password, Google)
   - Firestore Database
   - Storage
   - Cloud Messaging
   - Analytics

#### 3.2 Android Configuration
```bash
# Download google-services.json ke android/app/
# Update android/app/build.gradle dengan Firebase plugins
```

#### 3.3 iOS Configuration
```bash
# Download GoogleService-Info.plist ke ios/Runner/
# Update ios/Runner/Info.plist dengan URL schemes
```

### 4. IoT RFID System Setup

#### 4.1 Hardware Requirements
- ESP32 Development Board
- MFRC522 RFID Reader Module
- RFID Cards/Tags untuk setiap santri
- Breadboard dan jumper wires
- Power supply 5V

#### 4.2 Wiring Diagram
```
ESP32    MFRC522
-----    --------
3.3V  -> 3.3V
GND   -> GND
D21   -> SDA
D18   -> SCK
D23   -> MOSI
D19   -> MISO
D22   -> RST
```

#### 4.3 Arduino Code Deployment
```cpp
// Upload code dari file: iot/rfid_device_code.ino
// Configure WiFi credentials dan Firebase URL
// Test koneksi dan RFID reading
```

### 5. Environment Variables

```dart
// lib/core/config/app_config.dart
class AppConfig {
  static const String firebaseApiKey = 'your-api-key';
  static const String firebaseProjectId = 'your-project-id';
  static const String firebaseStorageBucket = 'your-storage-bucket';
}
```

### 6. Run Application

```bash
# Development
flutter run --debug

# Production
flutter build apk --release
flutter build ios --release
```

## 📱 Panduan Penggunaan

### Untuk Santri (Mobile App)
- **Dashboard**: Overview poin, kegiatan hari ini, ranking personal
- **Presensi RFID**: Tap kartu di reader untuk presensi otomatis
- **Jadwal**: Lihat jadwal pengajian dan kegiatan terkini
- **Ranking**: Monitor posisi di leaderboard dan achievement
- **Profil**: Kelola informasi pribadi dan statistik
- **Pengumuman**: Baca pengumuman penting dari admin

### Untuk Admin (Mobile App + Web Dashboard)
- **Dashboard**: Overview analytics dan statistik sistem
- **Manajemen Santri**: CRUD data santri dan assignment RFID
- **Jadwal**: Tambah/edit jadwal pengajian dan kegiatan
- **Presensi**: Monitor real-time presensi dan generate laporan
- **Pengumuman**: Buat pengumuman dengan rich media
- **Sistem**: Kelola IoT devices dan troubleshooting

## 🎮 Sistem Gamifikasi

### Point System
```yaml
Presensi Hadir: +10 poin
Presensi Izin: +5 poin  
Presensi Sakit: +5 poin
Bonus Streak 7 hari: +20 poin
Bonus Streak 30 hari: +100 poin
```

### Achievement Badges
- 🥇 **Top Performer**: Ranking 1 bulanan
- 🔥 **Streak Master**: 30 hari berturut-turut hadir
- ⭐ **Consistent**: 90% kehadiran bulanan
- 🎯 **Perfect Week**: 7 hari berturut-turut hadir

### Leaderboard Categories
- **Weekly**: Reset setiap Senin
- **Monthly**: Reset setiap tanggal 1
- **Yearly**: Reset setiap 1 Januari
- **All Time**: Akumulasi sepanjang masa

## �️ Struktur Database Firestore

### 👥 users
```yaml
/{userId}:
  # Profile Information
  nama: string
  email: string
  nim: string
  fakultas: string
  
  # Role & Status
  role: string  # 'admin' | 'santri'
  statusAktif: boolean
  tanggalDaftar: timestamp
  
  # Gamification
  poin: number
  totalKehadiran: number
  streakHarian: number
  maxStreak: number
  
  # RFID Integration
  rfidCardId: string  # ID kartu RFID santri
  
  # Media
  fotoProfil: string  # Firebase Storage URL
  
  # Settings
  notificationEnabled: boolean
  language: string  # 'id' | 'en'
```

### 📅 jadwal_pengajian
```yaml
/{jadwalId}:
  tanggal: timestamp
  waktuMulai: string  # "08:00"
  waktuSelesai: string  # "10:00"
  tema: string
  pemateri: string
  lokasi: string
  deskripsi: string
  isActive: boolean
  createdBy: string  # userId admin
  createdAt: timestamp
  updatedAt: timestamp
```

### 🎯 jadwal_kegiatan
```yaml
/{kegiatanId}:
  namaKegiatan: string
  tanggal: timestamp
  waktuMulai: string
  waktuSelesai: string
  lokasi: string
  deskripsi: string
  kategori: string  # 'umum' | 'khusus' | 'wajib'
  maxPeserta: number
  jumlahPeserta: number
  isActive: boolean
  requiresRegistration: boolean
  createdBy: string
  createdAt: timestamp
```

### ✅ presensi (IoT RFID Data)
```yaml
/{presensiId}:
  # User Info
  userId: string
  nama: string
  
  # Timestamp
  tanggal: timestamp
  waktuPresensi: timestamp
  
  # Status
  status: string  # 'Hadir' | 'Izin' | 'Sakit' | 'Alpha'
  statusColor: string  # hex color untuk UI
  statusIcon: string  # icon name untuk UI
  
  # RFID Metadata
  rfidCardId: string
  deviceId: string  # ID perangkat RFID reader
  deviceLocation: string  # lokasi perangkat
  
  # Gamification
  poinDiperoleh: number
  isBonus: boolean
  bonusReason: string  # 'streak_weekly' | 'perfect_month'
  
  # Admin Override
  isManualEntry: boolean  # false untuk RFID, true untuk manual
  manualEntryBy: string  # userId admin (jika manual)
  keterangan: string  # catatan tambahan
```

### 📢 pengumuman
```yaml
/{pengumumanId}:
  judul: string
  isi: string  # support markdown/rich text
  tanggal: timestamp
  
  # Media
  gambarUrl: string[]  # array of image URLs
  attachmentUrl: string[]  # array of file URLs
  
  # Metadata
  isPenting: boolean
  kategori: string  # 'umum' | 'akademik' | 'keuangan'
  targetAudience: string[]  # ['all'] | ['santri'] | ['admin']
  
  # Admin Info
  createdBy: string
  authorName: string
  
  # Engagement
  viewCount: number
  likeCount: number
  commentCount: number
  
  # Scheduling
  publishAt: timestamp  # untuk scheduled posts
  expireAt: timestamp   # auto-delete date
  isActive: boolean
```

### 🏆 rankings (Aggregated Data)
```yaml
/{period}/{userId}:  # period: 'weekly' | 'monthly' | 'yearly' | 'alltime'
  nama: string
  poin: number
  totalKehadiran: number
  persentaseKehadiran: number
  rank: number
  achievement: string[]
  lastUpdated: timestamp
```

### 🔧 system_config (IoT & App Settings)
```yaml
/app_settings:
  version: string
  maintenanceMode: boolean
  pointSettings:
    hadirPoin: number
    izinPoin: number
    sakitPoin: number
    streakBonusWeekly: number
    streakBonusMonthly: number

/rfid_devices:
  /{deviceId}:
    deviceName: string
    location: string
    lastHeartbeat: timestamp
    isOnline: boolean
    totalScans: number
    lastScanAt: timestamp
    firmwareVersion: string
```

## 🌐 Web Dashboard Development Reference

### 🎯 Arsitektur Web Dashboard

Untuk membuat web dashboard admin yang terintegrasi dengan sistem SiSantri, berikut adalah panduan komprehensif:

#### � Dashboard Overview Components
```javascript
// Dashboard Stats Cards
const dashboardStats = {
  totalSantri: 150,
  hadirHariIni: 142,
  persentaseKehadiran: 94.7,
  totalPoin: 125400,
  deviceOnline: 5,
  deviceOffline: 1
}

// Chart Data Structure
const attendanceChart = {
  labels: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
  datasets: [{
    label: 'Kehadiran',
    data: [145, 142, 138, 147, 150, 89, 92],
    backgroundColor: '#4CAF50'
  }]
}
```

#### 🔌 Real-time Data Integration
```javascript
// Firebase Real-time Listener untuk Web
import { onSnapshot, collection, query, where } from 'firebase/firestore'

// Listen to real-time presensi updates
const listenToPresensi = () => {
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  
  const q = query(
    collection(db, 'presensi'),
    where('tanggal', '>=', today)
  )
  
  return onSnapshot(q, (snapshot) => {
    const todayPresensi = []
    snapshot.forEach(doc => {
      todayPresensi.push({ id: doc.id, ...doc.data() })
    })
    updateDashboardStats(todayPresensi)
  })
}

// RFID Device Status Monitoring
const monitorDevices = () => {
  const devicesRef = collection(db, 'system_config/rfid_devices')
  return onSnapshot(devicesRef, (snapshot) => {
    const devices = []
    snapshot.forEach(doc => {
      const device = { id: doc.id, ...doc.data() }
      device.isOnline = (Date.now() - device.lastHeartbeat.toMillis()) < 300000 // 5 minutes
      devices.push(device)
    })
    updateDeviceStatus(devices)
  })
}
```

#### 📋 Santri Management CRUD
```javascript
// Create Santri dengan RFID Assignment
const createSantri = async (santriData) => {
  try {
    const docRef = await addDoc(collection(db, 'users'), {
      ...santriData,
      role: 'santri',
      statusAktif: true,
      tanggalDaftar: new Date(),
      poin: 0,
      totalKehadiran: 0,
      streakHarian: 0,
      rfidCardId: santriData.rfidCardId, // Assign RFID card
      createdAt: new Date()
    })
    
    // Send welcome notification
    await sendNotification(docRef.id, {
      title: 'Selamat Datang di SiSantri',
      body: `Akun Anda telah dibuat. RFID Card ID: ${santriData.rfidCardId}`
    })
    
    return docRef.id
  } catch (error) {
    console.error('Error creating santri:', error)
    throw error
  }
}

// Update Santri dengan RFID Re-assignment
const updateSantri = async (userId, updateData) => {
  const userRef = doc(db, 'users', userId)
  await updateDoc(userRef, {
    ...updateData,
    updatedAt: new Date()
  })
  
  // If RFID changed, update related presensi records
  if (updateData.rfidCardId) {
    await updateRFIDAssignment(userId, updateData.rfidCardId)
  }
}
```

#### 📊 Analytics & Reporting
```javascript
// Generate Attendance Report
const generateAttendanceReport = async (startDate, endDate, format = 'weekly') => {
  const presensiQuery = query(
    collection(db, 'presensi'),
    where('tanggal', '>=', startDate),
    where('tanggal', '<=', endDate),
    orderBy('tanggal', 'desc')
  )
  
  const snapshot = await getDocs(presensiQuery)
  const data = []
  
  snapshot.forEach(doc => {
    data.push({ id: doc.id, ...doc.data() })
  })
  
  // Process data berdasarkan format
  switch (format) {
    case 'weekly':
      return processWeeklyData(data)
    case 'monthly':
      return processMonthlyData(data)
    case 'detailed':
      return processDetailedData(data)
    default:
      return data
  }
}

// Ranking Analytics
const calculateRankings = async (period = 'monthly') => {
  const usersSnapshot = await getDocs(
    query(collection(db, 'users'), where('role', '==', 'santri'))
  )
  
  const rankings = []
  
  for (const userDoc of usersSnapshot.docs) {
    const userData = userDoc.data()
    const presensiData = await getUserPresensiData(userDoc.id, period)
    
    rankings.push({
      userId: userDoc.id,
      nama: userData.nama,
      poin: calculatePeriodPoin(presensiData),
      kehadiran: presensiData.length,
      persentase: calculatePersentase(presensiData, period)
    })
  }
  
  return rankings.sort((a, b) => b.poin - a.poin)
}
```

#### 🔧 IoT Device Management
```javascript
// Device Configuration Panel
const deviceConfig = {
  // RFID Reader Settings
  scanInterval: 1000, // ms
  retryAttempts: 3,
  timeoutDuration: 5000,
  
  // Network Settings
  wifiSSID: 'PesantrenWiFi',
  firebaseUrl: 'https://sisantri-project.firebaseio.com',
  apiEndpoint: '/api/presensi',
  
  // Hardware Settings
  buzzerEnabled: true,
  ledIndicator: true,
  displayTimeout: 5000
}

// Send Configuration to Device
const updateDeviceConfig = async (deviceId, config) => {
  try {
    // Update in Firestore
    await updateDoc(doc(db, 'system_config/rfid_devices', deviceId), {
      config: config,
      lastConfigUpdate: new Date()
    })
    
    // Send MQTT command to device (if using MQTT)
    await sendMQTTCommand(deviceId, 'config_update', config)
    
    return { success: true }
  } catch (error) {
    console.error('Device config update failed:', error)
    throw error
  }
}

// Device Health Monitoring
const checkDeviceHealth = async () => {
  const devicesSnapshot = await getDocs(collection(db, 'system_config/rfid_devices'))
  const healthReport = []
  
  devicesSnapshot.forEach(doc => {
    const device = { id: doc.id, ...doc.data() }
    const lastSeen = Date.now() - device.lastHeartbeat.toMillis()
    
    healthReport.push({
      deviceId: device.id,
      status: lastSeen < 300000 ? 'online' : 'offline', // 5 minutes threshold
      lastSeen: lastSeen,
      location: device.location,
      totalScans: device.totalScans || 0,
      uptime: calculateUptime(device.firstHeartbeat, device.lastHeartbeat)
    })
  })
  
  return healthReport
}
```

#### 🎨 UI Components untuk Web Dashboard

```html
<!-- Dashboard Layout Structure -->
<div class="dashboard-container">
  <!-- Sidebar Navigation -->
  <nav class="sidebar">
    <div class="logo">
      <img src="sisantri-logo.png" alt="SiSantri">
    </div>
    <ul class="nav-menu">
      <li><a href="#dashboard" class="active">📊 Dashboard</a></li>
      <li><a href="#santri">👥 Santri</a></li>
      <li><a href="#presensi">✅ Presensi</a></li>
      <li><a href="#jadwal">📅 Jadwal</a></li>
      <li><a href="#pengumuman">📢 Pengumuman</a></li>
      <li><a href="#ranking">🏆 Ranking</a></li>
      <li><a href="#devices">🔧 IoT Devices</a></li>
      <li><a href="#reports">📊 Laporan</a></li>
    </ul>
  </nav>
  
  <!-- Main Content -->
  <main class="main-content">
    <!-- Top Bar -->
    <header class="top-bar">
      <div class="search-bar">
        <input type="text" placeholder="Cari santri, presensi, atau pengumuman...">
      </div>
      <div class="user-menu">
        <span class="notification-bell">🔔</span>
        <div class="user-avatar">Admin</div>
      </div>
    </header>
    
    <!-- Dashboard Content -->
    <div class="dashboard-content">
      <!-- Stats Cards -->
      <div class="stats-grid">
        <div class="stat-card">
          <div class="stat-icon">👥</div>
          <div class="stat-info">
            <h3>150</h3>
            <p>Total Santri</p>
          </div>
        </div>
        
        <div class="stat-card">
          <div class="stat-icon">✅</div>
          <div class="stat-info">
            <h3>142</h3>
            <p>Hadir Hari Ini</p>
          </div>
        </div>
        
        <div class="stat-card">
          <div class="stat-icon">📊</div>
          <div class="stat-info">
            <h3>94.7%</h3>
            <p>Persentase Kehadiran</p>
          </div>
        </div>
        
        <div class="stat-card">
          <div class="stat-icon">🔧</div>
          <div class="stat-info">
            <h3>5/6</h3>
            <p>Device Online</p>
          </div>
        </div>
      </div>
      
      <!-- Charts Section -->
      <div class="charts-section">
        <div class="chart-container">
          <h3>Kehadiran Mingguan</h3>
          <canvas id="attendanceChart"></canvas>
        </div>
        
        <div class="chart-container">
          <h3>Top 10 Santri</h3>
          <div id="topSantriList"></div>
        </div>
      </div>
      
      <!-- Recent Activity -->
      <div class="recent-activity">
        <h3>Aktivitas Terbaru</h3>
        <div class="activity-list">
          <div class="activity-item">
            <span class="activity-time">08:15</span>
            <span class="activity-desc">Ahmad Fauzi melakukan presensi (RFID: A1B2C3)</span>
            <span class="activity-status success">Hadir</span>
          </div>
          <div class="activity-item">
            <span class="activity-time">08:12</span>
            <span class="activity-desc">Device RFID-002 offline</span>
            <span class="activity-status error">Offline</span>
          </div>
        </div>
      </div>
    </div>
  </main>
</div>
```

#### 🎨 CSS Styling untuk Dashboard
```css
/* Dashboard Styling */
.dashboard-container {
  display: grid;
  grid-template-columns: 250px 1fr;
  min-height: 100vh;
  background: #f5f6fa;
}

.sidebar {
  background: #2c3e50;
  color: white;
  padding: 20px 0;
}

.sidebar .logo {
  text-align: center;
  margin-bottom: 30px;
}

.nav-menu {
  list-style: none;
  padding: 0;
}

.nav-menu li a {
  display: block;
  padding: 15px 25px;
  color: #ecf0f1;
  text-decoration: none;
  transition: background 0.3s;
}

.nav-menu li a:hover,
.nav-menu li a.active {
  background: #34495e;
  border-right: 3px solid #3498db;
}

.main-content {
  overflow-y: auto;
}

.top-bar {
  background: white;
  padding: 15px 30px;
  border-bottom: 1px solid #e9ecef;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin: 30px;
}

.stat-card {
  background: white;
  padding: 25px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  display: flex;
  align-items: center;
}

.stat-icon {
  font-size: 2.5rem;
  margin-right: 20px;
}

.charts-section {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 30px;
  margin: 30px;
}

.chart-container {
  background: white;
  padding: 25px;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

/* Responsive Design */
@media (max-width: 768px) {
  .dashboard-container {
    grid-template-columns: 1fr;
  }
  
  .sidebar {
    position: fixed;
    top: 0;
    left: -250px;
    width: 250px;
    height: 100vh;
    transition: left 0.3s;
    z-index: 1000;
  }
  
  .sidebar.active {
    left: 0;
  }
}
```

#### 📡 API Endpoints untuk Integration
```javascript
// REST API Structure untuk Web Dashboard
const apiEndpoints = {
  // Authentication
  auth: {
    login: 'POST /api/auth/login',
    logout: 'POST /api/auth/logout',
    refresh: 'POST /api/auth/refresh'
  },
  
  // Santri Management
  santri: {
    getAll: 'GET /api/santri',
    getById: 'GET /api/santri/:id',
    create: 'POST /api/santri',
    update: 'PUT /api/santri/:id',
    delete: 'DELETE /api/santri/:id',
    assignRFID: 'POST /api/santri/:id/rfid'
  },
  
  // Presensi Data
  presensi: {
    getToday: 'GET /api/presensi/today',
    getByDate: 'GET /api/presensi/:date',
    getByUser: 'GET /api/presensi/user/:userId',
    manualEntry: 'POST /api/presensi/manual',
    export: 'GET /api/presensi/export'
  },
  
  // IoT Devices
  devices: {
    getAll: 'GET /api/devices',
    getStatus: 'GET /api/devices/status',
    updateConfig: 'PUT /api/devices/:id/config',
    restart: 'POST /api/devices/:id/restart',
    logs: 'GET /api/devices/:id/logs'
  },
  
  // Analytics
  analytics: {
    dashboard: 'GET /api/analytics/dashboard',
    attendance: 'GET /api/analytics/attendance',
    rankings: 'GET /api/analytics/rankings',
    trends: 'GET /api/analytics/trends'
  }
}
```

#### 🔒 Security Implementation
```javascript
// Role-based Access Control
const checkPermission = (userRole, requiredPermission) => {
  const permissions = {
    admin: ['read', 'write', 'delete', 'manage_devices', 'view_analytics'],
    santri: ['read_own', 'write_own']
  }
  
  return permissions[userRole]?.includes(requiredPermission) || false
}

// API Authentication Middleware
const authenticateAdmin = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(' ')[1]
    const decodedToken = await admin.auth().verifyIdToken(token)
    
    if (decodedToken.role !== 'admin') {
      return res.status(403).json({ error: 'Admin access required' })
    }
    
    req.user = decodedToken
    next()
  } catch (error) {
    res.status(401).json({ error: 'Unauthorized' })
  }
}
```

### � Deployment Recommendations

#### Frontend (Web Dashboard)
- **Framework**: React.js / Vue.js / Next.js
- **State Management**: Redux / Zustand / Pinia  
- **Charts**: Chart.js / Recharts / D3.js
- **UI Library**: Material-UI / Ant Design / Chakra UI
- **Build Tool**: Vite / Webpack
- **Hosting**: Vercel / Netlify / Firebase Hosting

#### Backend API (Optional)
- **Runtime**: Node.js / Python Flask / Go
- **Framework**: Express.js / FastAPI / Gin
- **Database**: Firebase Firestore (primary) + PostgreSQL (analytics)
- **Cache**: Redis untuk real-time data
- **Hosting**: Google Cloud Run / AWS Lambda / Railway

#### Real-time Features
- **WebSocket**: Socket.io untuk real-time updates
- **Server-Sent Events**: Untuk live dashboard updates
- **Firebase Realtime**: Direct integration untuk device status

## 📚 Learning Resources & References

### 📖 Documentation Links
- [Flutter Documentation](https://docs.flutter.dev/) - Official Flutter docs
- [Firebase Documentation](https://firebase.google.com/docs) - Firebase integration guide
- [Riverpod Documentation](https://riverpod.dev/) - State management best practices
- [Material Design 3](https://m3.material.io/) - UI design system guidelines

### 🎓 Tutorial Series untuk Web Dashboard
1. **Firebase Integration**: [Web SDK Setup](https://firebase.google.com/docs/web/setup)
2. **Real-time Database**: [Firestore Web Guide](https://firebase.google.com/docs/firestore/quickstart)
3. **Authentication**: [Firebase Auth Web](https://firebase.google.com/docs/auth/web/start)
4. **Chart.js Integration**: [Data Visualization](https://www.chartjs.org/docs/latest/)
5. **Responsive Design**: [CSS Grid & Flexbox](https://css-tricks.com/snippets/css/complete-guide-grid/)

### 🔧 Development Tools
- **Code Editor**: VS Code dengan extensions Flutter, Firebase
- **API Testing**: Postman / Insomnia untuk endpoint testing
- **Database Viewer**: Firebase Console / Firestore extension
- **Version Control**: Git dengan conventional commits
- **Design Tool**: Figma untuk UI mockups

### 🎯 Project Structure untuk Web Dashboard
```
sisantri-dashboard/
├── src/
│   ├── components/
│   │   ├── common/          # Reusable components
│   │   ├── charts/          # Chart components
│   │   ├── forms/           # Form components
│   │   └── layout/          # Layout components
│   ├── pages/
│   │   ├── Dashboard.jsx    # Main dashboard
│   │   ├── Santri.jsx       # Santri management
│   │   ├── Presensi.jsx     # Attendance monitoring
│   │   ├── Devices.jsx      # IoT device management
│   │   └── Reports.jsx      # Analytics & reports
│   ├── services/
│   │   ├── firebase.js      # Firebase configuration
│   │   ├── api.js           # API calls
│   │   └── auth.js          # Authentication logic
│   ├── utils/
│   │   ├── helpers.js       # Utility functions
│   │   ├── constants.js     # App constants
│   │   └── validators.js    # Form validations
│   └── styles/
│       ├── globals.css      # Global styles
│       ├── components.css   # Component styles
│       └── dashboard.css    # Dashboard specific styles
├── public/
│   ├── assets/
│   └── favicon.ico
├── package.json
└── README.md
```

## 🚀 Quick Start untuk Web Dashboard

### 1. Setup Project Baru
```bash
# Create React app
npx create-react-app sisantri-dashboard
cd sisantri-dashboard

# Install dependencies
npm install firebase chart.js react-chartjs-2 date-fns
npm install @mui/material @mui/icons-material
npm install react-router-dom axios
```

### 2. Firebase Configuration
```javascript
// src/services/firebase.js
import { initializeApp } from 'firebase/app'
import { getFirestore } from 'firebase/firestore'
import { getAuth } from 'firebase/auth'

const firebaseConfig = {
  // Copy from Firebase Console
  apiKey: "your-api-key",
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789",
  appId: "your-app-id"
}

const app = initializeApp(firebaseConfig)
export const db = getFirestore(app)
export const auth = getAuth(app)
export default app
```

### 3. Basic Dashboard Component
```jsx
// src/pages/Dashboard.jsx
import React, { useState, useEffect } from 'react'
import { collection, onSnapshot, query, where } from 'firebase/firestore'
import { db } from '../services/firebase'
import { Chart as ChartJS, CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend } from 'chart.js'
import { Bar } from 'react-chartjs-2'

ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend)

function Dashboard() {
  const [stats, setStats] = useState({
    totalSantri: 0,
    hadirHariIni: 0,
    persentaseKehadiran: 0,
    deviceOnline: 0
  })

  useEffect(() => {
    // Listen to real-time data
    const unsubscribe = onSnapshot(collection(db, 'users'), (snapshot) => {
      const santri = snapshot.docs.filter(doc => doc.data().role === 'santri')
      setStats(prev => ({ ...prev, totalSantri: santri.length }))
    })

    return () => unsubscribe()
  }, [])

  return (
    <div className="dashboard">
      <h1>Dashboard SiSantri</h1>
      
      <div className="stats-grid">
        <div className="stat-card">
          <h3>{stats.totalSantri}</h3>
          <p>Total Santri</p>
        </div>
        <div className="stat-card">
          <h3>{stats.hadirHariIni}</h3>
          <p>Hadir Hari Ini</p>
        </div>
        <div className="stat-card">
          <h3>{stats.persentaseKehadiran}%</h3>
          <p>Persentase Kehadiran</p>
        </div>
        <div className="stat-card">
          <h3>{stats.deviceOnline}</h3>
          <p>Device Online</p>
        </div>
      </div>
      
      {/* Add charts and other components here */}
    </div>
  )
}

export default Dashboard
```

## 📞 Support & Community

### 🔗 Useful Links
- **GitHub Repository**: [sisantri-mobile](https://github.com/username/sisantri)
- **Firebase Console**: [Your Firebase Project](https://console.firebase.google.com/)
- **Flutter Community**: [Flutter Discord](https://discord.gg/N7Yshp4)
- **Firebase Community**: [Firebase Slack](https://firebase.community/)

### 📧 Contact Information
- **Developer**: sisantri.dev@gmail.com
- **Technical Support**: tech@sisantri.com
- **WhatsApp Support**: +62-812-3456-7890
- **Documentation Issues**: docs@sisantri.com

### 🐛 Bug Reporting
Untuk melaporkan bug atau request fitur:
1. Buka issue di GitHub repository
2. Gunakan template yang disediakan
3. Sertakan screenshot dan log error
4. Jelaskan steps to reproduce

### 🤝 Contributing
Kontribusi sangat diterima! Silakan:
1. Fork repository
2. Buat feature branch
3. Commit dengan conventional commits
4. Buat pull request dengan deskripsi lengkap

---

**SiSantri** - Digitalisasi Kehidupan Pesantren Modern 🕌

> Dokumentasi ini dibuat sebagai panduan lengkap untuk pengembangan aplikasi mobile SiSantri dan referensi untuk pembuatan dashboard web admin. Sistem ini mengintegrasikan teknologi IoT RFID untuk presensi otomatis dengan gamifikasi yang mendorong partisipasi aktif santri.

**Version**: 2.0.0  
**Last Updated**: December 2024  
**Compatibility**: Flutter 3+, Firebase v9+, Web Modern Browsers
