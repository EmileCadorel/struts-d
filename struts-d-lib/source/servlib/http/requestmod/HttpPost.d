module servlib.http.requestmod.HttpPost;
import servlib.http.requestmod.HttpParameter;
import servlib.http.requestmod.HttpFile;
import std.outbuffer, std.conv;

class HttpPost {

    ref HttpParameter [string] params () {
	return this._params;
    }

    ref HttpFile [] files () {
	return this._files;
    }

    override string toString () {
	OutBuffer buf = new OutBuffer;
	buf.write ("PARAMETERS : " ~ to!string (_params) ~ "\n");
	buf.write ("FILES : "~ to!string (_files) ~ "\n");
	return buf.toString ();
    }
    
    private {
	
	HttpParameter [string] _params;
	HttpFile [] _files;
	
    }
    
}
