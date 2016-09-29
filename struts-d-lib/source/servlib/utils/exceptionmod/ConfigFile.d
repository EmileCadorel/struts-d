module servlib.utils.exceptionmod.ConfigFile;
import servlib.utils.exception;
import servlib.utils.Log;

class ConfigFileError : StrutsException {
  this (string msg) {
    Log.instance.add_err (msg);
    super(msg);
  }
}
