import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;
boolean isSent = false;

void setup() {
  size(400, 400);
  frameRate(30);
  oscP5 = new OscP5(this, "127.0.0.1", 54445, OscP5.UDP);
  myRemoteLocation = new NetAddress("192.168.0.101", 54321);
}

void draw() {
  if (isSent) {
    background(255);
    isSent = false;
  } else {
    background(0);
  }
}

void mousePressed() {
  OscMessage myMessage = new OscMessage("/bang");
  int val = (int)map(mouseX, 0, width, 0, 255);
  myMessage.add(val);
  oscP5.send(myMessage, myRemoteLocation);
  isSent = true;
}

void oscEvent(OscMessage theOscMessage) {
  print("### received an osc message.");
  print(String.format(" addrpattern: %s", theOscMessage.addrPattern()));
  print(String.format(" addrpattern: %s", theOscMessage.typetag()));
}
