module servlib.utils.exceptionmod.ReqSyntaxException;
import servlib.utils.exception;
import servlib.utils.lexer;
import servlib.utils.Log;

/**
 Erreur de syntaxe dans une requete HTTP
 */
class ReqSyntaxError : StrutsException {
    this (Word word) {
      Log.instance.addError ("Syntaxe : ", word.str);
      super ("Syntaxe : " ~ word.str);
    }
}
