module utils.Singleton;

mixin template Singleton (T) {
  static ref T instance () {
    if (inst is null) inst = new T;
    return inst;
  }
private:
  this () {}
  static T inst = null;
}