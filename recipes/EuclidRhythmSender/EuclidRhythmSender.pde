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
int beatIndex = 0;
boolean[] beats;
// マシンから音を鳴らす場合はこれをtrueにする
boolean playSound = false;
SoundFile sound;

void setup() {
  size(800, 150);
  EuclidRythmMachine erm = new EuclidRythmMachine(euclidRythmN, euclidRythmLen);
  beats = erm.calcBeats();
  printBeats(beats);

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
  background(0);
  float w = width / beats.length;
  for (int i = 0; i < beats.length; i++) {
    strokeWeight(1);
    if (beats[i]) {
      stroke(0);
      fill(255);
    } else {
      stroke(255);
      fill(0);
    }
    rect(w * i, 0, w, 100);
  }

  strokeWeight(3);
  stroke(255, 0, 0);
  noFill();
  rect(w * beatIndex, 0, w, 100);

  noStroke();
  fill(255);
  textSize(20);
  text("BPM: " + bpm + ", E(" + euclidRythmN + ", " + euclidRythmLen + ")", 20, 130);

  int now = millis();
  if (now - pMillis > interval) {
    // *** ステップを進める処理 ***
    beatIndex++;
    if (beatIndex >= beats.length) {
      beatIndex = 0;
    }
    // *** OSCの送信処理 ***
    if (beats[beatIndex]) {
      OscMessage message = new OscMessage("/bang");
      oscP5.send(message, addresses[beatIndex]);
      println(addresses[beatIndex], message);
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

  beatIndex = 0;
  EuclidRythmMachine erm = new EuclidRythmMachine(euclidRythmN, euclidRythmLen);
  beats = erm.calcBeats();
  printBeats(beats);
}

void printBeats(boolean[] beats) {
  for (int i = 0; i < beats.length; i++) {
    if (beats[i]) {
      print('*');
    } else {
      print('_');
    }
  }
  println();
}
