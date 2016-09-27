module utils.exceptionmod.ReqSyntaxException;
import utils.exception;
import utils.lexer;

class ReqSyntaxError : StrutsException {
    this (Word word) {
	super ("Erreur de syntaxe " ~ word.str);
    }
}
