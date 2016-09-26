module utils.exceptionmod.Server;
import utils.exception;
import utils.Log;

class ServerError : StrutsException {
  this (string msg) {
    Log.instance.add_err (msg);
    super (RED ~ "Erreur fatale : " ~ RESET ~ msg);
  }
}