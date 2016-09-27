module utils.Singleton;

mixin template Singleton (T) {
  static ref T instance () {
    if (inst is null) {
      inst = new T;
      import std.stdio; writeln("inst !", inst);
    }
    return inst;
  }
private:
  static T inst = null;
}