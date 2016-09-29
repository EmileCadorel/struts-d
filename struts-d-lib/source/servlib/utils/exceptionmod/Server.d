module servlib.utils.exceptionmod.Server;
import servlib.utils.exception;
import servlib.utils.Log;

class ServerError : StrutsException {
  this (string msg) {
    Log.instance.add_err (msg);
    super ("Erreur fatale : " ~ msg);
  }
}
