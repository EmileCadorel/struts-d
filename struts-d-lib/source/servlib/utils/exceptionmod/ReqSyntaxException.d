module servlib.utils.exceptionmod.ReqSyntaxException;
import servlib.utils.exception;
import servlib.utils.lexer;
import servlib.utils.Log;

class ReqSyntaxError : StrutsException {
    this (Word word) {
      Log.instance.add_err ("Syntaxe : ", word.str);
      super ("Syntaxe : " ~ word.str);
    }
}
