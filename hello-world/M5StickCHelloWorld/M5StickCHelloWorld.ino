#include <ArduinoOSCWiFi.h>
#include <M5StickC.h>

const char* ssid = "YOUR_SSID"; // 接続するWi-FiのSSID
const char* pwd = "";           // 接続するWi-Fiのパスワード
const int recvPort = 54321;     // OSCのポート番号

void onOscReceived(const OscMessage& m);
void connectWiFi();
void printAddress();

void setup() {
  M5.begin();
  Serial.begin(115200);
  delay(5000);
  connectWiFi();
  OscWiFi.subscribe(recvPort, "/hello", onOscReceived);
}

void loop() {
  OscWiFi.update();
}

/**
 * Wi-Fiに接続する関数
 */
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
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }
  Serial.print("WiFi connected, IP = ");
  Serial.println(WiFi.localIP());
  printAddress();
}

/**
 * OSCを受信した時に呼び出される関数
 * OSCメッセージを受け取ったらディスプレイに "Hello, world!" と表示する
 */
void onOscReceived(const OscMessage& m) {
  M5.Lcd.fillScreen(RED);
  M5.Lcd.setTextColor(WHITE);
  M5.Lcd.setTextSize(2);
  M5.Lcd.setCursor(0, 10);
  M5.Lcd.println("Hello, world!");
  delay(1000);
  printAddress();
}

/**
 * ディスプレイにIPアドレスとMACアドレスを表示する関数
 */
void printAddress() {
  M5.Lcd.setRotation(1);
  M5.Lcd.fillScreen(BLACK);
  M5.Lcd.setTextColor(WHITE);
  M5.Lcd.setTextSize(2);
  M5.Lcd.setCursor(0, 10);
  M5.Lcd.println(WiFi.localIP().toString());
  M5.Lcd.println(WiFi.macAddress());
}
