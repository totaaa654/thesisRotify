#include <Arduino.h>
#include <WiFi.h>
#include <FirebaseESP32.h>

// --- THESE HEADERS FIX THE "tokenStatusCallback" ERROR ---
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

// --- CONFIGURATION ---
#define WIFI_SSID "BAHAY NI KUYA 2.4"
#define WIFI_PASSWORD "adobongmanok2002"
#define API_KEY "AIzaSyCh0TDsH0b8wjs2CJsqQZKX92ZpeHOmTxs"
#define DATABASE_URL "https://rotify-8f4b8-default-rtdb.asia-southeast1.firebasedatabase.app"

// --- THE LEGAL HANDSHAKE CREDENTIALS ---
#define USER_EMAIL "esp32@rotify.com"
#define USER_PASSWORD "esp32password"

// MUX select pins
#define S0 18
#define S1 19
#define S2 21
#define S3 22
#define MUX_SIG 34

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

void selectChannel(uint8_t channel) {
  digitalWrite(S0, channel & 0x01);
  digitalWrite(S1, channel & 0x02);
  digitalWrite(S2, channel & 0x04);
  digitalWrite(S3, channel & 0x08);
}

void setup() {
  Serial.begin(115200);

  pinMode(S0, OUTPUT); pinMode(S1, OUTPUT); 
  pinMode(S2, OUTPUT); pinMode(S3, OUTPUT);
  analogReadResolution(12);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) { delay(500); Serial.print("."); }
  Serial.println("\n✓ WiFi Connected!");

  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  // --- THE FIX: USE THE ACCOUNT YOU CREATED ---
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  // Necessary for managing security tokens
  config.token_status_callback = tokenStatusCallback; 

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  // AUTHENTICATION GUARD: Wait here until the handshake is official
  Serial.println("Performing Handshake with Firebase...");
  while (auth.token.uid == "") {
    delay(1000);
    Serial.print("Checking credentials...");
  }
  Serial.println("\n✓ Handshake Successful! Pumping Raw Data.");
}

void loop() {
  if (Firebase.ready()) {
    for (uint8_t ch = 0; ch < 9; ch++) {
      selectChannel(ch);
      
      // Keeping your specific timing logic here
      delayMicroseconds(20); 
      int value = analogRead(MUX_SIG);

      // --- YOUR MAPPING LOGIC FOR 9 SENSORS ---
      int containerNum = (ch % 3) + 1; // 0,3,6 -> C1 | 1,4,7 -> C2 | 2,5,8 -> C3
      
      const char* sensor;
      if (ch < 3) sensor = "mq137";        // Channels 0, 1, 2
      else if (ch < 6) sensor = "mq135";   // Channels 3, 4, 5
      else sensor = "mq136";               // Channels 6, 7, 8

      char path[60];
      snprintf(path, sizeof(path), "/containers/container%d/%s", containerNum, sensor);
      
      // Upload raw integer values
      if (Firebase.setInt(fbdo, path, value)) {
        Serial.printf("✓ Sent %s: %d\n", path, value);
      } else {
        Serial.print("✗ Firebase Error: ");
        Serial.println(fbdo.errorReason()); 
      }
    }
    Serial.println("--- All 9 Sensors Synced ---");
    delay(5000); 
  }
}