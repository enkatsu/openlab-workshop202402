import oscP5.*;
import netP5.*;

OscP5 oscP5;
// ロボティックドラムマシンのM5StickCのアドレス
NetAddress[] left = new NetAddress[3];
NetAddress[] right = new NetAddress[3];
NetAddress[] doncama = new NetAddress[2];
// LEDを制御しているM5StickCのアドレス
NetAddress ledAddress = new NetAddress("192.168.0.114", 54321);
// この数値が高くなるとテンポが速くなる（Beats Per Minute, 1分に何拍打つか）
float bpm = 120;
float interval = 60 * 1000 / bpm;
int pMillis = -1;
// アクティブなステップの色
color activeHandLedColor = color(255, 0, 0);
// 非アクティブなステップの色（color(0, 0, 0)は黒なので光らない）
color inactiveHandLedColor = color(0, 0, 0);
// アクティブなステップの色
color activeDoncamaLedColor = color(255, 255, 0);
// 非アクティブなステップの色（color(0, 0, 0)は黒なので光らない）
color inactiveDoncamaLedColor = color(0, 0, 0);
boolean leftIsCurrent = true;
int leftState = 2;
int rightState = 0;

void setup() {
  size(400, 300);
  oscP5 = new OscP5(this, "127.0.0.1", 54445, OscP5.UDP);
  left[0] = new NetAddress("192.168.0.101", 54321);
  left[1] = new NetAddress("192.168.0.102", 54321);
  left[2] = new NetAddress("192.168.0.103", 54321);
  right[0] = new NetAddress("192.168.0.105", 54321);
  right[1] = new NetAddress("192.168.0.106", 54321);
  right[2] = new NetAddress("192.168.0.107", 54321);
  doncama[0] = new NetAddress("192.168.0.104", 54321);
  doncama[1] = new NetAddress("192.168.0.108", 54321);
}

void draw() {
  background(0);
  float w = width / 4;
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 2; j++) {
      float x = w * i;
      float y = w * j;
      fill(0);
      stroke(255);
      rect(x, y, w, w);
    }
  }

  fill(0);
  stroke(activeHandLedColor);
  if (leftIsCurrent) {
    rect(leftState * w, 0, w, w);
  } else {
    rect(rightState * w, w, w, w);
  }
  stroke(activeDoncamaLedColor);
  if (leftIsCurrent) {
    rect(3 * w, 0, w, w);
  } else {
    rect(3 * w, w, w, w);
  }

  int now = millis();
  if (now - pMillis > interval) {
    if (leftIsCurrent) {
      leftState = (6 - (leftState + rightState)) % 3;
    } else {
      rightState = (6 - (rightState + leftState)) % 3;
    }
    if (leftIsCurrent) {
      OscMessage message = new OscMessage("/bang");
      oscP5.send(message, left[leftState]);
      println(left[leftState], message);
      OscMessage doncamaMessage = new OscMessage("/bang");
      oscP5.send(doncamaMessage, doncama[0]);
      println(doncama[0], doncamaMessage);
    } else {
      OscMessage message = new OscMessage("/bang");
      oscP5.send(message, right[rightState]);
      println(right[rightState], message);
      OscMessage doncamaMessage = new OscMessage("/bang");
      oscP5.send(doncamaMessage, doncama[1]);
      println(doncama[1], doncamaMessage);
    }
    pMillis = millis();
    leftIsCurrent = !leftIsCurrent;
  }

  sendLedColors();
}

/**
 * LED用のESP-32に色データを送信する
 **/
void sendLedColors() {
  OscMessage msg = new OscMessage("/light");
  // 左手（上段）
  for (int i = 0; i < left.length; i++) {
    if (leftIsCurrent && leftState == i) {
      int r = (int)red(activeHandLedColor);
      int g = (int)green(activeHandLedColor);
      int b = (int)blue(activeHandLedColor);
      int c = (r << 16) + (g << 8) + b;
      msg.add(c);
    } else {
      int r = (int)red(inactiveHandLedColor);
      int g = (int)green(inactiveHandLedColor);
      int b = (int)blue(inactiveHandLedColor);
      int c = (r << 16) + (g << 8) + b;
      msg.add(c);
    }
  }
  // 上段のメトロノーム
  if (leftIsCurrent) {
    int r = (int)red(activeDoncamaLedColor);
    int g = (int)green(activeDoncamaLedColor);
    int b = (int)blue(activeDoncamaLedColor);
    int c = (r << 16) + (g << 8) + b;
    msg.add(c);
  } else {
    int r = (int)red(inactiveDoncamaLedColor);
    int g = (int)green(inactiveDoncamaLedColor);
    int b = (int)blue(inactiveDoncamaLedColor);
    int c = (r << 16) + (g << 8) + b;
    msg.add(c);
  }
  // 右手（下段）
  for (int i = 0; i < left.length; i++) {
    if (!leftIsCurrent && leftState == i) {
      int r = (int)red(activeHandLedColor);
      int g = (int)green(activeHandLedColor);
      int b = (int)blue(activeHandLedColor);
      int c = (r << 16) + (g << 8) + b;
      msg.add(c);
    } else {
      int r = (int)red(inactiveHandLedColor);
      int g = (int)green(inactiveHandLedColor);
      int b = (int)blue(inactiveHandLedColor);
      int c = (r << 16) + (g << 8) + b;
      msg.add(c);
    }
  }
  // 下段のメトロノーム
  if (leftIsCurrent) {
    int r = (int)red(activeDoncamaLedColor);
    int g = (int)green(activeDoncamaLedColor);
    int b = (int)blue(activeDoncamaLedColor);
    int c = (r << 16) + (g << 8) + b;
    msg.add(c);
  } else {
    int r = (int)red(inactiveDoncamaLedColor);
    int g = (int)green(inactiveDoncamaLedColor);
    int b = (int)blue(inactiveDoncamaLedColor);
    int c = (r << 16) + (g << 8) + b;
    msg.add(c);
  }

  oscP5.send(msg, ledAddress);
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
