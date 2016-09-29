module servlib.utils.exceptionmod.ReqSyntaxException;
import servlib.utils.exception;
import servlib.utils.lexer;

class ReqSyntaxError : StrutsException {
    this (Word word) {
	super ("Syntaxe : " ~ word.str);
    }
}
