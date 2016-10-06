module servlib.utils.exceptionmod.SoError;
import servlib.utils.exception;
import std.outbuffer;

/**
 Le chargement d'un .so a echoue
 */
class SoError : StrutsException {
    this (string name, string data) {
	super ("");
	OutBuffer buf = new OutBuffer;
	buf.write ("Chargement de ");
	buf.write (name);
	buf.write (" impossible ~> \n");
	buf.write (data);
	msg = buf.toString ();
    }
    
    override string toString () {
	return msg;
    }    
}
