import std.stdio, std.outbuffer, std.file;
import http.Console;
import servlib.utils.exception;
import utils.Process;

void main (string[] args) {
    writeln (" ## Prototype de serveur ## ");
    try {
	Console console = new Console;
	console.start ();
	console.join ();
    } catch (StrutsException e) {
	writeln (e);
    } catch (Exception e) {
	writeln (e);
    }
}
