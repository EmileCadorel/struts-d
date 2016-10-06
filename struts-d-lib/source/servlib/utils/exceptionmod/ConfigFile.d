module servlib.utils.exceptionmod.ConfigFile;
import servlib.utils.exception;
import servlib.utils.Log;

/**
 Erreur renvoye si il y a une erreur dans le fichier de configuration du serveur
 */
class ConfigFileError : StrutsException {
  this (string msg) {
    Log.instance.addError (msg);
    super(msg);
  }
}
