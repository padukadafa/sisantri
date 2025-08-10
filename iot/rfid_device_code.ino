// IoT RFID Device Configuration for SiSantri
// Arduino/ESP32 Code Template

#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <MFRC522.h>
#include <LiquidCrystal_I2C.h>
#include <NTPClient.h>
#include <WiFiUdp.h>

// ===== CONFIGURATION =====
// WiFi Settings
const char* WIFI_SSID = "YourWiFiNetwork";
const char* WIFI_PASSWORD = "YourWiFiPassword";

// Firebase Configuration
const char* FIREBASE_PROJECT_ID = "sisantri-project";
const char* FIREBASE_API_KEY = "your-api-key";
const char* FIREBASE_DATABASE_URL = "https://sisantri-project-default-rtdb.firebaseio.com";

// Device Settings
const String DEVICE_ID = "rfid_reader_001";
const String DEVICE_LOCATION = "Masjid Utama";
const String DEVICE_SECRET = "your-device-secret-key";

// Hardware Pins
#define RST_PIN 22
#define SS_PIN 21
#define BUZZER_PIN 19
#define LED_GREEN_PIN 18
#define LED_RED_PIN 5
#define LED_BLUE_PIN 17

// ===== GLOBAL OBJECTS =====
MFRC522 mfrc522(SS_PIN, RST_PIN);
LiquidCrystal_I2C lcd(0x27, 16, 2);
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org", 25200, 60000); // GMT+7 Indonesia

// ===== SETUP =====
void setup() {
  Serial.begin(115200);
  
  // Initialize hardware
  initializePins();
  initializeLCD();
  initializeRFID();
  
  // Connect to WiFi
  connectToWiFi();
  
  // Initialize NTP
  timeClient.begin();
  
  // Device ready
  displayMessage("SiSantri RFID", "System Ready");
  Serial.println("RFID Presensi System Ready");
}

// ===== MAIN LOOP =====
void loop() {
  // Update time
  timeClient.update();
  
  // Check for RFID card
  if (mfrc522.PICC_IsNewCardPresent() && mfrc522.PICC_ReadCardSerial()) {
    String rfidUid = readRFIDUID();
    Serial.println("RFID Detected: " + rfidUid);
    
    // Process presensi
    processRFIDTap(rfidUid);
    
    // Halt card and wait
    mfrc522.PICC_HaltA();
    delay(2000);
  }
  
  // Display current time every 10 seconds
  static unsigned long lastTimeDisplay = 0;
  if (millis() - lastTimeDisplay > 10000) {
    displayCurrentTime();
    lastTimeDisplay = millis();
  }
  
  delay(100);
}

// ===== INITIALIZATION FUNCTIONS =====
void initializePins() {
  pinMode(BUZZER_PIN, OUTPUT);
  pinMode(LED_GREEN_PIN, OUTPUT);
  pinMode(LED_RED_PIN, OUTPUT);
  pinMode(LED_BLUE_PIN, OUTPUT);
  
  // Turn off all LEDs
  digitalWrite(LED_GREEN_PIN, LOW);
  digitalWrite(LED_RED_PIN, LOW);
  digitalWrite(LED_BLUE_PIN, LOW);
}

void initializeLCD() {
  lcd.init();
  lcd.backlight();
  lcd.clear();
  displayMessage("SiSantri RFID", "Starting...");
}

void initializeRFID() {
  SPI.begin();
  mfrc522.PCD_Init();
  
  // Test RFID reader
  if (mfrc522.PCD_PerformSelfTest()) {
    Serial.println("RFID Reader OK");
  } else {
    Serial.println("RFID Reader Failed");
    displayMessage("RFID Error", "Check Hardware");
    while (1) delay(1000);
  }
  
  mfrc522.PCD_Init(); // Re-init after self test
}

void connectToWiFi() {
  displayMessage("WiFi", "Connecting...");
  
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 30) {
    delay(1000);
    Serial.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi Connected!");
    Serial.println("IP: " + WiFi.localIP().toString());
    displayMessage("WiFi Connected", WiFi.localIP().toString());
    indicatorBlink(LED_BLUE_PIN, 3);
  } else {
    Serial.println("\nWiFi Connection Failed!");
    displayMessage("WiFi Failed", "Check Network");
    while (1) {
      indicatorBlink(LED_RED_PIN, 1);
      delay(1000);
    }
  }
}

// ===== RFID FUNCTIONS =====
String readRFIDUID() {
  String rfidUid = "";
  
  for (byte i = 0; i < mfrc522.uid.size; i++) {
    if (mfrc522.uid.uidByte[i] < 0x10) rfidUid += "0";
    rfidUid += String(mfrc522.uid.uidByte[i], HEX);
    if (i != mfrc522.uid.size - 1) rfidUid += ":";
  }
  
  rfidUid.toUpperCase();
  return rfidUid;
}

void processRFIDTap(String rfidUid) {
  displayMessage("Processing...", rfidUid.substring(0, 11));
  
  // Get current timestamp
  String timestamp = getCurrentTimestamp();
  
  // Find user by RFID
  String userId = findUserByRFID(rfidUid);
  
  if (userId != "") {
    // Create presensi record
    bool success = createPresensiRecord(userId, rfidUid, timestamp);
    
    if (success) {
      String userName = getUserName(userId);
      displayMessage("Sukses!", userName.substring(0, 16));
      indicatorSuccess();
      playSuccessSound();
    } else {
      displayMessage("Error Server", "Coba Lagi");
      indicatorError();
      playErrorSound();
    }
  } else {
    displayMessage("Kartu Tidak", "Terdaftar");
    indicatorError();
    playErrorSound();
  }
}

// ===== FIREBASE FUNCTIONS =====
String findUserByRFID(String rfidUid) {
  if (WiFi.status() != WL_CONNECTED) {
    return "";
  }
  
  HTTPClient http;
  String url = String(FIREBASE_DATABASE_URL) + "/users.json?orderBy=\"rfidUid\"&equalTo=\"" + rfidUid + "\"";
  
  http.begin(url);
  http.addHeader("Content-Type", "application/json");
  
  int httpResponseCode = http.GET();
  
  if (httpResponseCode == 200) {
    String response = http.getString();
    
    // Parse JSON response
    DynamicJsonDocument doc(1024);
    deserializeJson(doc, response);
    
    // Check if user found
    for (JsonPair kv : doc.as<JsonObject>()) {
      String userId = kv.key().c_str();
      return userId;
    }
  }
  
  http.end();
  return "";
}

String getUserName(String userId) {
  if (WiFi.status() != WL_CONNECTED) {
    return "Unknown";
  }
  
  HTTPClient http;
  String url = String(FIREBASE_DATABASE_URL) + "/users/" + userId + "/nama.json";
  
  http.begin(url);
  int httpResponseCode = http.GET();
  
  if (httpResponseCode == 200) {
    String response = http.getString();
    response.replace("\"", ""); // Remove quotes
    return response;
  }
  
  http.end();
  return "Unknown";
}

bool createPresensiRecord(String userId, String rfidUid, String timestamp) {
  if (WiFi.status() != WL_CONNECTED) {
    return false;
  }
  
  // Create presensi data
  DynamicJsonDocument doc(512);
  doc["userId"] = userId;
  doc["tanggal"] = timestamp;
  doc["status"] = "hadir";
  doc["keterangan"] = "RFID Tap - " + DEVICE_LOCATION;
  doc["rfidUid"] = rfidUid;
  doc["deviceId"] = DEVICE_ID;
  doc["poinDiperoleh"] = 10;
  doc["createdAt"] = timestamp;
  
  String jsonString;
  serializeJson(doc, jsonString);
  
  HTTPClient http;
  String url = String(FIREBASE_DATABASE_URL) + "/presensi.json";
  
  http.begin(url);
  http.addHeader("Content-Type", "application/json");
  
  int httpResponseCode = http.POST(jsonString);
  
  bool success = (httpResponseCode == 200);
  http.end();
  
  return success;
}

// ===== UTILITY FUNCTIONS =====
String getCurrentTimestamp() {
  return String(timeClient.getEpochTime() * 1000); // Convert to milliseconds
}

void displayMessage(String line1, String line2) {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(line1);
  lcd.setCursor(0, 1);
  lcd.print(line2);
}

void displayCurrentTime() {
  String timeString = timeClient.getFormattedTime();
  displayMessage("SiSantri RFID", timeString);
}

void indicatorSuccess() {
  for (int i = 0; i < 3; i++) {
    digitalWrite(LED_GREEN_PIN, HIGH);
    delay(200);
    digitalWrite(LED_GREEN_PIN, LOW);
    delay(200);
  }
}

void indicatorError() {
  for (int i = 0; i < 5; i++) {
    digitalWrite(LED_RED_PIN, HIGH);
    delay(100);
    digitalWrite(LED_RED_PIN, LOW);
    delay(100);
  }
}

void indicatorBlink(int pin, int times) {
  for (int i = 0; i < times; i++) {
    digitalWrite(pin, HIGH);
    delay(300);
    digitalWrite(pin, LOW);
    delay(300);
  }
}

void playSuccessSound() {
  // Two short beeps
  tone(BUZZER_PIN, 1000, 100);
  delay(150);
  tone(BUZZER_PIN, 1200, 100);
}

void playErrorSound() {
  // One long beep
  tone(BUZZER_PIN, 400, 500);
}

// ===== DIAGNOSTIC FUNCTIONS =====
void printSystemInfo() {
  Serial.println("=== SiSantri RFID System Info ===");
  Serial.println("Device ID: " + DEVICE_ID);
  Serial.println("Location: " + DEVICE_LOCATION);
  Serial.println("WiFi SSID: " + String(WIFI_SSID));
  Serial.println("IP Address: " + WiFi.localIP().toString());
  Serial.println("RFID Reader Version: " + String(mfrc522.PCD_ReadRegister(mfrc522.VersionReg), HEX));
  Serial.println("Current Time: " + timeClient.getFormattedTime());
  Serial.println("==============================");
}

// ===== ERROR HANDLING =====
void handleWiFiDisconnect() {
  if (WiFi.status() != WL_CONNECTED) {
    displayMessage("WiFi Lost", "Reconnecting...");
    connectToWiFi();
  }
}

void watchdogReset() {
  // Reset system if hang
  ESP.restart();
}
