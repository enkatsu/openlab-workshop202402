import processing.sound.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress[] addresses = new NetAddress[8];

int euclidRythmN = 5;
int euclidRythmLen = 8;
float bpm = 120;
float interval = 60 * 1000 / bpm;
int pMillis = -1;
int currentStep = 0;
boolean[] steps;
// マシンから音を鳴らす場合はこれをtrueにする
boolean playSound = false;
SoundFile sound;

void setup() {
  size(800, 150);
  EuclidRythmMachine erm = new EuclidRythmMachine(euclidRythmN, euclidRythmLen);
  steps = erm.calcBeats();
  printBeats(steps);

  oscP5 = new OscP5(this, "127.0.0.1", 54445, OscP5.UDP);
  addresses[0] = new NetAddress("192.168.0.101", 54321);
  addresses[1] = new NetAddress("192.168.0.102", 54321);
  addresses[2] = new NetAddress("192.168.0.103", 54321);
  addresses[3] = new NetAddress("192.168.0.104", 54321);
  addresses[4] = new NetAddress("192.168.0.105", 54321);
  addresses[5] = new NetAddress("192.168.0.106", 54321);
  addresses[6] = new NetAddress("192.168.0.107", 54321);
  addresses[7] = new NetAddress("192.168.0.108", 54321);

  sound = new SoundFile(this, "../../sounds/snare.wav");
}

void draw() {
  // *** グリッドの描画 ***
  background(0);
  float w = width / steps.length;
  for (int i = 0; i < steps.length; i++) {
    strokeWeight(1);
    if (steps[i]) {
      stroke(0);
      fill(255);
    } else {
      stroke(255);
      fill(0);
    }
    rect(w * i, 0, w, 100);
  }
  // 現在のステップの描画
  strokeWeight(3);
  stroke(255, 0, 0);
  noFill();
  rect(w * currentStep, 0, w, 100);
  // BPMのステップの描画
  noStroke();
  fill(255);
  textSize(20);
  text("BPM: " + bpm + ", E(" + euclidRythmN + ", " + euclidRythmLen + ")", 20, 130);

  int now = millis();
  if (now - pMillis > interval) {
    // *** ステップを進める処理 ***
    currentStep++;
    if (currentStep >= steps.length) {
      currentStep = 0;
    }
    // *** OSCの送信処理 ***
    if (steps[currentStep]) {
      OscMessage message = new OscMessage("/bang");
      oscP5.send(message, addresses[currentStep]);
      println(addresses[currentStep], message);
      if (playSound) {
        sound.play();
      }
    }
    pMillis = millis();
  }
}

void keyPressed() {
  if (keyCode == RIGHT && euclidRythmN < euclidRythmLen) {
    euclidRythmN++;
  } else if (keyCode == LEFT && euclidRythmN > 1) {
    euclidRythmN--;
  } else if (keyCode == UP) {
    bpm++;
  } else if (keyCode == DOWN) {
    bpm--;
  }
  interval = 60 * 1000 / bpm;

  currentStep = 0;
  EuclidRythmMachine erm = new EuclidRythmMachine(euclidRythmN, euclidRythmLen);
  steps = erm.calcBeats();
  printBeats(steps);
}

void printBeats(boolean[] steps) {
  for (int i = 0; i < steps.length; i++) {
    if (steps[i]) {
      print('*');
    } else {
      print('_');
    }
  }
  println();
}
