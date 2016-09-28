module utils.exceptionmod.ConfigFile;
import utils.exception;
import utils.Log;

class ConfigFileError : StrutsException {
  this (string msg) {
    Log.instance.add_err (msg);
    super(RED ~ "Erreur : " ~ RESET ~ msg);
  }
}