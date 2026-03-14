#include <Arduino.h>
#include <WiFi.h>
#include <FirebaseESP32.h>

#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

// --- CONFIGURATION ---
#define WIFI_SSID "BAHAY NI KUYA 2.4"
#define WIFI_PASSWORD "adobongmanok2002"
#define API_KEY "AIzaSyDLk9YNxHEIfdBgQrJMw_w0dLJmMrpljpY"
#define DATABASE_URL "https://thesis-rotify-default-rtdb.asia-southeast1.firebasedatabase.app"

// --- AUTH ---
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

unsigned long lastLogTime = 0;
const unsigned long logInterval = 10000; // 10 seconds

// =========================
// DISH PER CONTAINER
// =========================
const char *CONTAINER_DISH[3] = {
    "chicken curry", // container1
    "bicol express", // container2
    "menudo"         // container3
};

// =========================
// EMPTY BASELINES PER CONTAINER
// =========================
const int EMPTY_BASELINE_MQ136[3] = {10, 10, 5};
const int EMPTY_BASELINE_MQ137[3] = {300, 300, 100};

// =========================
// ADJUSTED THRESHOLDS PER DISH
// =========================
const int THRESHOLD_MQ136[3] = {20, 40, 10};   // curry, bicol, menudo
const int THRESHOLD_MQ137[3] = {700, 550, 500};

// =========================
// STATUS HISTORY
// 0 = FRESH, 1 = MID, 2 = SPOILED, -1 = empty
// =========================
const int STATUS_HISTORY_WINDOW = 5;
int statusHistory[3][STATUS_HISTORY_WINDOW];
int historyCount[3] = {0, 0, 0};
int historyIndex[3] = {0, 0, 0};

unsigned long cycleCount[3] = {0, 0, 0};

void selectChannel(uint8_t channel)
{
  digitalWrite(S0, channel & 0x01);
  digitalWrite(S1, channel & 0x02);
  digitalWrite(S2, channel & 0x04);
  digitalWrite(S3, channel & 0x08);
}

int clampToZero(int value)
{
  return (value < 0) ? 0 : value;
}

int statusToCode(const String &status)
{
  if (status == "FRESH")
    return 0;
  if (status == "MID")
    return 1;
  if (status == "SPOILED")
    return 2;
  return -1;
}

String majorityVoteStatus(int containerIdx)
{
  int freshCount = 0;
  int midCount = 0;
  int spoiledCount = 0;

  for (int i = 0; i < historyCount[containerIdx]; i++)
  {
    int code = statusHistory[containerIdx][i];
    if (code == 0)
      freshCount++;
    else if (code == 1)
      midCount++;
    else if (code == 2)
      spoiledCount++;
  }

  if (spoiledCount >= midCount && spoiledCount >= freshCount)
    return "SPOILED";
  if (midCount >= freshCount && midCount >= spoiledCount)
    return "MID";
  return "FRESH";
}

void appendStatusHistory(int containerIdx, const String &status)
{
  int code = statusToCode(status);
  if (code < 0)
    return;

  statusHistory[containerIdx][historyIndex[containerIdx]] = code;
  historyIndex[containerIdx] = (historyIndex[containerIdx] + 1) % STATUS_HISTORY_WINDOW;

  if (historyCount[containerIdx] < STATUS_HISTORY_WINDOW)
    historyCount[containerIdx]++;
}

String getFinalPrediction(int containerIdx, const String &rawStatus)
{
  if (rawStatus == "SPOILED")
  {
    return "SPOILED";
  }
  else if (rawStatus == "MID")
  {
    return "MID";
  }
  else
  {
    return majorityVoteStatus(containerIdx);
  }
}

String detectStatusWithBaseline(int containerIdx, int mq136, int mq137,
                                int &adj136, int &adj137, int &th136, int &th137)
{
  int base136 = EMPTY_BASELINE_MQ136[containerIdx];
  int base137 = EMPTY_BASELINE_MQ137[containerIdx];

  adj136 = clampToZero(mq136 - base136);
  adj137 = clampToZero(mq137 - base137);

  th136 = THRESHOLD_MQ136[containerIdx];
  th137 = THRESHOLD_MQ137[containerIdx];

  if (adj136 >= th136 && adj137 >= th137)
    return "SPOILED";
  else if (adj136 < th136 && adj137 < th137)
    return "FRESH";
  else
    return "MID";
}

void writeRealtimeContainerMinimal(int containerNum, int mq135, int mq136, int mq137,
                                   const String &finalPrediction,
                                   unsigned long timestamp)
{
  char basePath[64];
  snprintf(basePath, sizeof(basePath), "/containers/container%d", containerNum);

  FirebaseJson json;
  json.set("mq135", mq135);
  json.set("mq136", mq136);
  json.set("mq137", mq137);
  json.set("prediction", finalPrediction);
  json.set("timestamp", timestamp);

  if (Firebase.updateNode(fbdo, basePath, json))
  {
    Serial.printf("✓ Updated %s with prediction %s\n", basePath, finalPrediction.c_str());
  }
  else
  {
    Serial.print("✗ Update Error: ");
    Serial.println(fbdo.errorReason());
  }
}

void logSnapshot(int containerNum, int mq135, int mq136, int mq137,
                 int adj136, int adj137,
                 int th136, int th137,
                 const String &rawStatus,
                 const String &finalPrediction,
                 unsigned long timestamp)
{
  FirebaseJson json;
  json.set("dish", CONTAINER_DISH[containerNum - 1]);
  json.set("mq135", mq135);
  json.set("mq136", mq136);
  json.set("mq137", mq137);
  json.set("timestamp", timestamp);
  json.set("mq136_adjusted", adj136);
  json.set("mq137_adjusted", adj137);
  json.set("mq136_adjusted_threshold", th136);
  json.set("mq137_adjusted_threshold", th137);
  json.set("raw_status", rawStatus);
  json.set("prediction", finalPrediction);

  char logPath[64];
  snprintf(logPath, sizeof(logPath), "/container_logs/container%d", containerNum);

  if (Firebase.pushJSON(fbdo, logPath, json))
  {
    Serial.printf("✓ Logged full snapshot to %s\n", logPath);
  }
  else
  {
    Serial.print("✗ Log Error: ");
    Serial.println(fbdo.errorReason());
  }
}

void setup()
{
  Serial.begin(115200);

  pinMode(S0, OUTPUT);
  pinMode(S1, OUTPUT);
  pinMode(S2, OUTPUT);
  pinMode(S3, OUTPUT);
  analogReadResolution(12);

  for (int c = 0; c < 3; c++)
  {
    for (int i = 0; i < STATUS_HISTORY_WINDOW; i++)
    {
      statusHistory[c][i] = -1;
    }
  }

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\n✓ WiFi Connected!");

  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  config.token_status_callback = tokenStatusCallback;

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  Serial.println("Performing Handshake with Firebase...");
  while (auth.token.uid == "")
  {
    delay(1000);
    Serial.print("Checking credentials...");
  }
  Serial.println("\n✓ Handshake Successful! Pumping Raw Data.");
}

void loop()
{
  if (Firebase.ready())
  {
    int mq135_vals[3] = {0, 0, 0};
    int mq136_vals[3] = {0, 0, 0};
    int mq137_vals[3] = {0, 0, 0};

    // =========================
    // 1) READ ALL 9 CHANNELS
    // =========================
    for (uint8_t ch = 0; ch < 9; ch++)
    {
      selectChannel(ch);
      delayMicroseconds(20);
      int value = analogRead(MUX_SIG);

      int containerNum = (ch % 3) + 1;
      int containerIdx = ch % 3;

      if (ch < 3)
      {
        mq137_vals[containerIdx] = value;
      }
      else if (ch < 6)
      {
        mq135_vals[containerIdx] = value;
      }
      else
      {
        mq136_vals[containerIdx] = value;
      }
    }

    // =========================
    // 2) COMPUTE PREDICTION PER CONTAINER
    // =========================
    unsigned long currentMillis = millis();

    for (int i = 0; i < 3; i++)
    {
      int containerNum = i + 1;

      int mq135 = mq135_vals[i];
      int mq136 = mq136_vals[i];
      int mq137 = mq137_vals[i];

      int adj136 = 0;
      int adj137 = 0;
      int th136 = 0;
      int th137 = 0;

      String rawStatus = detectStatusWithBaseline(i, mq136, mq137, adj136, adj137, th136, th137);

      appendStatusHistory(i, rawStatus);
      String finalPrediction = getFinalPrediction(i, rawStatus);

      cycleCount[i]++;

      Serial.println("\n============================================================");
      Serial.printf("CONTAINER: container%d\n", containerNum);
      Serial.printf("CYCLE: %lu\n", cycleCount[i]);
      Serial.printf("Dish: %s\n", CONTAINER_DISH[i]);
      Serial.printf("Raw MQ135: %d\n", mq135);
      Serial.printf("Raw MQ136: %d\n", mq136);
      Serial.printf("Raw MQ137: %d\n", mq137);
      Serial.printf("Empty baseline MQ136: %d\n", EMPTY_BASELINE_MQ136[i]);
      Serial.printf("Empty baseline MQ137: %d\n", EMPTY_BASELINE_MQ137[i]);
      Serial.printf("Adjusted MQ136: %d\n", adj136);
      Serial.printf("Adjusted MQ137: %d\n", adj137);
      Serial.printf("Adjusted threshold MQ136: %d\n", th136);
      Serial.printf("Adjusted threshold MQ137: %d\n", th137);
      Serial.printf("Raw status: %s\n", rawStatus.c_str());
      Serial.printf("PREDICTION: %s\n", finalPrediction.c_str());

      // minimal realtime upload
      writeRealtimeContainerMinimal(containerNum, mq135, mq136, mq137,
                                    finalPrediction, currentMillis);
    }

    // =========================
    // 3) LOG FULL SNAPSHOT PER CONTAINER EVERY logInterval
    // =========================
    if (currentMillis - lastLogTime >= logInterval)
    {
      for (int i = 0; i < 3; i++)
      {
        int containerNum = i + 1;

        int mq135 = mq135_vals[i];
        int mq136 = mq136_vals[i];
        int mq137 = mq137_vals[i];

        int adj136 = 0;
        int adj137 = 0;
        int th136 = 0;
        int th137 = 0;

        String rawStatus = detectStatusWithBaseline(i, mq136, mq137, adj136, adj137, th136, th137);
        String finalPrediction = getFinalPrediction(i, rawStatus);

        logSnapshot(containerNum, mq135, mq136, mq137,
                    adj136, adj137, th136, th137,
                    rawStatus, finalPrediction, currentMillis);
      }

      lastLogTime = currentMillis;
    }

    Serial.println("--- All 9 Sensors Synced ---");
    delay(5000);
  }
}