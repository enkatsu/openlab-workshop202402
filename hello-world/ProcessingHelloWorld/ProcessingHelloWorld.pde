import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress[] addresses = new NetAddress[16];
int clickedIndex = -1;
int clickedMillis = -1;

void setup() {
  size(800, 400);
  oscP5 = new OscP5(this, "127.0.0.1", 54445, OscP5.UDP);
  addresses[0] = new NetAddress("192.168.0.101", 54321);
  addresses[1] = new NetAddress("192.168.0.102", 54321);
  addresses[2] = new NetAddress("192.168.0.103", 54321);
  addresses[3] = new NetAddress("192.168.0.104", 54321);
  addresses[4] = new NetAddress("192.168.0.105", 54321);
  addresses[5] = new NetAddress("192.168.0.106", 54321);
  addresses[6] = new NetAddress("192.168.0.107", 54321);
  addresses[7] = new NetAddress("192.168.0.108", 54321);
  addresses[8] = new NetAddress("192.168.0.201", 54321);
  addresses[9] = new NetAddress("192.168.0.202", 54321);
  addresses[10] = new NetAddress("192.168.0.203", 54321);
  addresses[11] = new NetAddress("192.168.0.204", 54321);
  addresses[12] = new NetAddress("192.168.0.205", 54321);
  addresses[13] = new NetAddress("192.168.0.206", 54321);
  addresses[14] = new NetAddress("192.168.0.207", 54321);
  addresses[15] = new NetAddress("192.168.0.208", 54321);
}

void draw() {
  background(0);

  textAlign(CENTER, CENTER);
  for (int i = 0; i < 8; i++) {
    float angle = map(i, 0, 8, 0, PI * 2);
    float x = cos(angle) * (width / 4 - 25) + width / 4 * 3;
    float y = sin(angle) * (width / 4 - 25) + height / 2;
    noStroke();
    if (clickedIndex == i) {
      fill(255, 0, 0);
    } else {
      fill(255);
    }
    ellipse(x, y, 50, 50);
    fill(0);
    text(addresses[i].address().split("\\.")[3], x, y);
  }

  for (int i = 0; i < 8; i++) {
    float angle = map(i, 0, 8, 0, PI * 2);
    float x = cos(angle) * (width / 4 - 25) + width / 4 * 1;
    float y = sin(angle) * (width / 4 - 25) + height / 2;
    noStroke();
    if (clickedIndex == i + 8) {
      fill(255, 0, 0);
    } else {
      fill(255);
    }
    ellipse(x, y, 50, 50);
    fill(0);
    text(addresses[i + 8].address().split("\\.")[3], x, y);
  }
  
  if (clickedMillis != -1 && clickedMillis + 500 < millis()) {
    clickedMillis = -1;
    clickedIndex = -1;
  }
}

void mousePressed() {
  for (int i = 0; i < 8; i++) {
    float angle = map(i, 0, 8, 0, PI * 2);
    float x = cos(angle) * (width / 4 - 25) + width / 4 * 3;
    float y = sin(angle) * (width / 4 - 25) + height / 2;
    if (dist(mouseX, mouseY, x, y) < 25) {
      sendHello(i);
      clickedIndex = i;
      clickedMillis = millis();
      return;
    }
  }

  for (int i = 0; i < 8; i++) {
    float angle = map(i, 0, 8, 0, PI * 2);
    float x = cos(angle) * (width / 4 - 25) + width / 4 * 1;
    float y = sin(angle) * (width / 4 - 25) + height / 2;
    if (dist(mouseX, mouseY, x, y) < 25) {
      sendHello(i + 8);
      clickedIndex = i + 8;
      clickedMillis = millis();
      return;
    }
  }
}

void sendHello(int i) {
  OscMessage message = new OscMessage("/hello");
  oscP5.send(message, addresses[i]);
  println(addresses[i], message);
}

void oscEvent(OscMessage theOscMessage) {
  print("### received an osc message.");
  print(String.format(" addrpattern: %s", theOscMessage.addrPattern()));
  print(String.format(" addrpattern: %s", theOscMessage.typetag()));
}
