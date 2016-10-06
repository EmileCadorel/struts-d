module servlib.utils.exceptionmod.Server;
import servlib.utils.exception;
import servlib.utils.Log;

/**
 Erreur du serveur ne pouvant etre rattrape
 */
class ServerError : StrutsException {
  this (string msg) {
    Log.instance.addError (msg);
    super ("Erreur fatale : " ~ msg);
  }
}
