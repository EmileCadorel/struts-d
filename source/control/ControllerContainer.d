module control.ControllerContainer;
import std.stdio;


class ControllerContainer {

  this (string[string] list_controllers) {
    foreach (name, class_name ; list_controllers) {
      datas[name] = cast(void*)Object.factory(class_name);
      writeln (name, " -> ", class_name, " charge.");
    }
  }

  void opIndexAssign (T : Object) (T elem, string name) {
    datas[name] = cast(void*)elem;
  }

  void opIndexAssign (T) (T * elem, string name) {
    datas[name] = elem;
  }

  T get (T : Object) (string name) {
    writeln ("{");
    foreach (key, value ; datas) {
      writeln (key, " -> ", value);
    }
    writeln ("elem recherche : ", name, "}");
    auto elem = (name in datas);
    writeln(elem);
    if (elem is null) return null;
    else return cast (T) (*elem);
  }

  T * get (T) (string name) {
    auto elem = (name in datas);
    if (elem is null) return null;
    else return cast (T*) (*elem);
  }

  private {
    void* [string] datas;
  }

}
