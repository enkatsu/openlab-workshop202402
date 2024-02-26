// 参考URL: https://fantasysound.net/2019/07/28/euclidean-rhythm/

class EuclidRythmMachine {
  int n;
  int len;
  int[] l;
  int[] r;
  int stepCount = 1;

  EuclidRythmMachine(int n, int len) {
    this.n = n;
    this.len = len;
    l = new int[n];
    r = new int[len - n];
    for (int i = 0; i < n; i++) {
      l[i] = 1;
    }
  }

  boolean[] calcBeats() {
    return calcBeats(false);
  }

  boolean[] calcBeats(boolean printProgress) {
    if (printProgress) {
      println(this);
    }
    while (r.length != 0) {
      step();
      if (printProgress) {
        println(this);
      }
    }
    boolean[] beats = new boolean[len];
    int idx = 0;
    for (int i = 0; i < l.length; i++) {
      String str = Integer.toBinaryString(l[i]);
      for (int j = 0; j < str.length(); j++) {
        beats[idx] = '1' == str.charAt(j);
        idx++;
      }
    }
    return beats;
  }

  void step() {
    int joinLength = min(l.length, r.length);
    for (int i = 0; i < joinLength; i++) {
      int rightLength = Integer.toBinaryString(r[i]).length();
      l[i] = (l[i] << rightLength) + r[i];
    }
    if (l.length < r.length) {
      r = subset(r, min(l.length, r.length));
    } else {
      r = subset(l, joinLength);
      l = subset(l, 0, joinLength);
    }
  }

  /**
   * 確認用
   **/
  String toString() {
    String str = "";
    for (int i = 0; i < l.length; i++) {
      str += '[';
      str += Integer.toBinaryString(l[i]);
      str += ']';
    }
    str += '|';
    for (int i = 0; i < r.length; i++) {
      str += '[';
      str += Integer.toBinaryString(r[i]);
      str += ']';
    }
    return str;
  }
}
