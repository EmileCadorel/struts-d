module control.ControllerContainer;
import control.Controller;
import utils.Option;
import utils.XMLoader;

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
