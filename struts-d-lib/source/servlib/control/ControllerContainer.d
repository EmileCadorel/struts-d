module servlib.control.ControllerContainer;
import servlib.control.Controller;
import servlib.utils.Option;
import servlib.utils.XMLoader;

class ControllerContainer {

  string opIndex (string name) {
    auto it = name in this._controllers;
    if (it !is null) return *it;
    else return null;
  }

  void opIndexAssign (string value, string name) {
    this._controllers[name] = value;
  }

  ref string [string] controllers () { return this._controllers; }

  private  {
    string [string] _controllers;
  }
}
