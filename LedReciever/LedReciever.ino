#include <Adafruit_NeoPixel.h>
#include <ArduinoOSCWiFi.h>
#include <M5StickC.h>

#define PIN 26
#define NUMPIXELS 40
Adafruit_NeoPixel pixels(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);

const char* ssid = "YOUR_SSID";
const char* pwd = "";
const int recvPort = 54321;

void onOscReceived(const OscMessage& m);
void connectWiFi();

void setup() {
  M5.begin();
  Serial.begin(115200);
  delay(5000);
  connectWiFi();
  OscWiFi.subscribe(recvPort, "/light", onOscReceived);

  pixels.begin();
  pixels.setBrightness(50);
  pixels.clear();
  pixels.show();
}

void loop() {
  OscWiFi.update();
}

void connectWiFi() {
  Serial.println("*** connect Wi-Fi ***");
#if defined(ESP_PLATFORM) || defined(ARDUINO_ARCH_RP2040)
#ifdef ESP_PLATFORM
  WiFi.disconnect(true, true);
#else
  WiFi.disconnect(true);
#endif
  delay(1000);
  WiFi.mode(WIFI_STA);
#endif
  WiFi.begin(ssid, pwd);
  // WiFi.config(ip, gateway, subnet);
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }
  Serial.print("WiFi connected, IP = ");
  Serial.println(WiFi.localIP());

  M5.Lcd.setRotation(1);
  M5.Lcd.fillScreen(BLACK);
  M5.Lcd.setTextColor(WHITE);
  M5.Lcd.setTextSize(2);
  M5.Lcd.setCursor(0, 10);
  M5.Lcd.println(WiFi.localIP().toString());
  M5.Lcd.println(WiFi.macAddress());
}

void onOscReceived(const OscMessage& m) {
  Serial.print(m.remoteIP());
  Serial.print(" ");
  Serial.print(m.remotePort());
  Serial.print(" ");
  Serial.print(m.size());
  Serial.print(" ");
  Serial.print(m.address());
  Serial.println();

  for (int i = 0; i < NUMPIXELS; i++) {
    int color = m.arg<int>(i);
    int r = (color & 0xFF0000) >> 16;
    int g = (color & 0x00FF00) >> 8;
    int b = (color & 0x0000FF);
    Serial.print("(");
    Serial.print(r);
    Serial.print(", ");
    Serial.print(g);
    Serial.print(", ");
    Serial.print(b);
    Serial.print(")");
    pixels.setPixelColor(i, pixels.Color(r, g, b));
  }
  Serial.println();
  pixels.show();
}
