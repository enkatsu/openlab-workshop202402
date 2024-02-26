#include <ArduinoOSCWiFi.h>
#include <M5StickC.h>
#include <Stepper.h>

int sp_speed = 100; //回転スピード
int sp_step = 100; //ステップ数
int round_step = 400;
Stepper stepper(round_step, 32, 33, 26, 0);
bool isRotated = false;

const char* ssid = "YOUR_SSID";
const char* pwd = "";
const int recvPort = 54321;

void onOscReceived(const OscMessage& m) {
  int val = m.arg<int>(0);
  Serial.print(m.remoteIP());
  Serial.print(" ");
  Serial.print(m.remotePort());
  Serial.print(" ");
  Serial.print(m.size());
  Serial.print(" ");
  Serial.print(m.address());
  Serial.print(" ");
  Serial.print(val);
  Serial.println();

  if (!isRotated) {
    isRotated = true;
    stepper.step(sp_step);
    delay(10);
    stepper.step(-sp_step / 2);
    isRotated = false;
  }
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
  // WiFi.localIP().printTo(M5.Lcd);
  // M5.Lcd.setCursor(0, 20);
  M5.Lcd.println(WiFi.localIP().toString());
  M5.Lcd.println(WiFi.macAddress());
  stepper.setSpeed(sp_speed);
}

void setup() {
  M5.begin();
  Serial.begin(115200);
  delay(5000);
  connectWiFi();
  OscWiFi.subscribe(recvPort, "/bang", onOscReceived);
}

void loop() {
  OscWiFi.update();
}
