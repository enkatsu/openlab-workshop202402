import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress address;

void setup() {
  size(400, 400);
  frameRate(30);
  oscP5 = new OscP5(this, "127.0.0.1", 54445, OscP5.UDP);
  address = new NetAddress("192.168.0.101", 54321);
}

void draw() {
  background(255);
}

void mousePressed() {
  OscMessage message = new OscMessage("/bang");
  int val = (int)map(mouseX, 0, width, 0, 255);
  oscP5.send(message, address);
}

void oscEvent(OscMessage message) {
  print("### received an osc message.");
  print(String.format(" addrpattern: %s", message.addrPattern()));
  print(String.format(" addrpattern: %s", message.typetag()));
}
