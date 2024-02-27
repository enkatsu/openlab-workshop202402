import oscP5.*;
import netP5.*;

OscP5 oscP5;
// ロボティックドラムマシンのM5StickCのアドレス
NetAddress[] addresses = new NetAddress[8];
// LEDを制御しているM5StickCのアドレス
NetAddress ledAddress = new NetAddress("192.168.0.114", 54321);
// この数値が高くなるとテンポが速くなる（Beats Per Minute, 1分に何拍打つか）
float bpm = 120;
float interval = 60 * 1000 / bpm;
int pMillis = -1;
int beatIndex = 0;
// ステップの状態
boolean[] beats;
// 現在のステップのLEDの色
color currentStepLedColor = color(255, 0, 0);
// アクティブなステップの色
color activeStepLedColor = color(255, 255, 255);
// 非アクティブなステップの色（color(0, 0, 0)は黒なので光らない）
color inactiveStepLedColor = color(0, 0, 0);

void setup() {
  size(800, 250);
  oscP5 = new OscP5(this, "127.0.0.1", 54445, OscP5.UDP);
  addresses[0] = new NetAddress("192.168.0.101", 54321);
  addresses[1] = new NetAddress("192.168.0.102", 54321);
  addresses[2] = new NetAddress("192.168.0.103", 54321);
  addresses[3] = new NetAddress("192.168.0.104", 54321);
  addresses[4] = new NetAddress("192.168.0.105", 54321);
  addresses[5] = new NetAddress("192.168.0.106", 54321);
  addresses[6] = new NetAddress("192.168.0.107", 54321);
  addresses[7] = new NetAddress("192.168.0.108", 54321);
  // ステップの状態を初期化
  beats = new boolean[addresses.length];
  for (int i = 0; i < beats.length; i++) {
    beats[i] = false;
  }
}

void draw() {
  background(0);
  // ステップの状態を描画
  float w = width / beats.length;
  for (int i = 0; i < beats.length; i++) {
    strokeWeight(1);
    if (beats[i]) {
      stroke(inactiveStepLedColor);
      fill(activeStepLedColor);
    } else {
      stroke(activeStepLedColor);
      fill(inactiveStepLedColor);
    }
    rect(w * i, 0, w, 100);
  }
  // 現在のステップを描画
  strokeWeight(3);
  stroke(currentStepLedColor);
  noFill();
  rect(w * beatIndex, 0, w, 100);
  // 現在のBPMを描画
  noStroke();
  fill(255);
  textSize(20);
  text("BPM: " + bpm, 20, 130);

  // *** ステップを次に進める処理 ***
  int now = millis();
  if (now - pMillis > interval) {
    // もし現在のステップがtrueならOSCを送信する
    if (beats[beatIndex]) {
      OscMessage message = new OscMessage("/bang");
      oscP5.send(message, addresses[beatIndex]);
      println(addresses[beatIndex], message);
    }
    beatIndex++;
    if (beatIndex >= beats.length) {
      beatIndex = 0;
    }
    pMillis = millis();
  }
  
  sendLedColors();
}

/**
 * LED用のESP-32に色データを送信する
 **/
void sendLedColors() {
  int boxNum = 8;
  int ledNumContainsBox = 5;
  int totalLedNum = boxNum * ledNumContainsBox;
  OscMessage msg = new OscMessage("/light");
  for (int i = 0; i < totalLedNum; i++) {
    if (ledNumContainsBox * beatIndex <= i && i < ledNumContainsBox * beatIndex + ledNumContainsBox) {
      // *** 現在のステップの色 ***
      int r = (int)red(currentStepLedColor);
      int g = (int)green(currentStepLedColor);
      int b = (int)blue(currentStepLedColor);
      int c = (r << 16) + (g << 8) + b;
      msg.add(c);
    } else if (beats[floor(i / ledNumContainsBox)]) {
      // *** アクティブなステップの色 ***
      int r = (int)red(activeStepLedColor);
      int g = (int)green(activeStepLedColor);
      int b = (int)blue(activeStepLedColor);
      int c = (r << 16) + (g << 8) + b;
      msg.add(c);
    } else {
      // *** どれでもない場合は光らせない ***
      int r = (int)red(inactiveStepLedColor);
      int g = (int)green(inactiveStepLedColor);
      int b = (int)blue(inactiveStepLedColor);
      int c = (r << 16) + (g << 8) + b;
      msg.add(c);
    }
  }
  oscP5.send(msg, ledAddress);
}

/**
 * マウスをクリックした時の処理
 */
void mousePressed() {
  float w = width / beats.length;
  for (int i = 0; i < beats.length; i++) {
    if (w * i < mouseX && mouseX < w * i + w) {
      if (0 < mouseY && mouseY < 100) {
        beats[i] = !beats[i];
        break;
      }
    }
  }
}

/**
 * キーを押した時の処理
 */
void keyPressed() {
  if (keyCode == UP) {
    bpm++;
  } else if (keyCode == DOWN) {
    bpm--;
  }
  interval = 60 * 1000 / bpm;
}
