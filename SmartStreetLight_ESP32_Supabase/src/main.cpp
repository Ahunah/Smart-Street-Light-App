#include <Arduino.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <LiquidCrystal_I2C.h>
#include <ArduinoJson.h>
#include <WiFiClientSecure.h>

#define WIFI_SSID "Wokwi-GUEST"
#define WIFI_PASSWORD ""

// paste your Supabase project URL here
#define SUPABASE_URL "https://ixemmcjfzgydfrjieoii.supabase.co"

// paste your Supabase anon key here
#define SUPABASE_API_KEY "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml4ZW1tY2pmemd5ZGZyamllb2lpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIwOTU0MDcsImV4cCI6MjA5NzY3MTQwN30.HlVWnt66J18RCdqCu0w4tYHiTcpPNS3em50KJPSQiOg"

LiquidCrystal_I2C lcd(0x27, 16, 2); // Set the LCD I2C address and dimensions

#define LDR_PIN 34 // GPIO pin connected to the LDR
#define RED_LED_PIN 13
#define GREEN_LED_PIN 12
#define BLUE_LED_PIN 14
#define STREET_LED_PIN 5

unsigned long lastSend = 0;
const unsigned long interval = 5000;

int previousIntensity = -1;
String previousStatus = "";
String previousLedState = "";

bool blinkState = false;

void connectWiFI();
void setRGB(bool r, bool g, bool b);
void sendDataToSupabase(int intensity, String status, String led_state);

void setup()
{
  Serial.begin(115200);

  pinMode(LDR_PIN, INPUT);
  pinMode(RED_LED_PIN, OUTPUT);
  pinMode(GREEN_LED_PIN, OUTPUT);
  pinMode(BLUE_LED_PIN, OUTPUT);
  pinMode(STREET_LED_PIN, OUTPUT);
  lcd.init();      // Initialize the LCD
  lcd.backlight(); // Turn on the backlight
  lcd.print("Smart Street");
  lcd.setCursor(0, 1);
  lcd.print("Light System");
  delay(2000);
  lcd.clear();

  connectWiFI();
}

void loop()
{
  int ldrvalue = analogRead(LDR_PIN);
  int intensity = map(ldrvalue, 0, 4095, 0, 100); // Map LDR value to percentage (0-100)

  String status = "OFF";
  String led_state = "UNKNOWN";

  if (intensity > 70)
  {
    setRGB(false, true, false); // Green
    digitalWrite(STREET_LED_PIN, LOW);
    led_state = "GREEN";
  }

  else if (intensity >= 30)
  {
    setRGB(false, false, true); // blue
    digitalWrite(STREET_LED_PIN, LOW);
    led_state = "BLUE";
  }

  else if (intensity > 15)
  {
    setRGB(true, false, false); // Red
    digitalWrite(STREET_LED_PIN, HIGH);
    led_state = "RED";
    status = "ON";
  }
  else
  {
    static unsigned long blinkTimer = 0;

    if (millis() - blinkTimer >= 500)
    {
      blinkTimer = millis();
      blinkState = !blinkState;
    }

    setRGB(blinkState, false, false);
    digitalWrite(STREET_LED_PIN, HIGH);
    status = "ON";
    led_state = "RED_BLINK";
  }

  lcd.setCursor(0, 0);
  lcd.print("Light: ");
  lcd.print(intensity);
  lcd.print("%");

  lcd.setCursor(0, 1);
  lcd.print("street : ");
  lcd.print(status);
  lcd.print(" ");

  if (millis() - lastSend >= interval)
  {
    lastSend = millis();

    sendDataToSupabase(intensity, status, led_state);
  }
}

void connectWiFI()
{
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
    Serial.print(".");
  }
  Serial.println("wifi Connected!");
}

void setRGB(bool r, bool g, bool b)
{
  digitalWrite(RED_LED_PIN, r);
  digitalWrite(GREEN_LED_PIN, g);
  digitalWrite(BLUE_LED_PIN, b);
}

void sendDataToSupabase(int intensity, String status, String led_state)
{
  if (WiFi.status() != WL_CONNECTED)
    return;

  WiFiClientSecure client;
  client.setInsecure(); // Required for Wokwi

  HTTPClient http;

  String url = String(SUPABASE_URL) + "/rest/v1/esp_data";

  client.setTimeout(15000);
  client.setInsecure();

  delay(100);

  http.begin(client, url);

  http.addHeader("Content-Type", "application/json");
  http.addHeader("apikey", SUPABASE_API_KEY);
  http.addHeader("Authorization", "Bearer " + String(SUPABASE_API_KEY));
  http.addHeader("Prefer", "return=representation");

  StaticJsonDocument<200> doc;
  doc["light_intency"] = intensity;
  doc["status"] = status;
  doc["led_state"] = led_state;

  String payload;
  serializeJson(doc, payload);

  Serial.println("Sending:");
  Serial.println(payload);

  int httpCode = -1;

  for (int i = 0; i < 3; i++)
  {
    httpCode = http.POST(payload);

    if (httpCode == 201)
      break;

    Serial.println("Retry...");
    delay(1000);
  }
  Serial.print("HTTP Code: ");
  Serial.println(httpCode);

  Serial.print("Response: ");
  Serial.println(http.getString());

  http.end();
}