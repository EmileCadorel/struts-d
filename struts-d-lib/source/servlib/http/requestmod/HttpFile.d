module servlib.http.requestmod.HttpFile;
import servlib.http.request;
import std.container, std.outbuffer;
import std.conv;

class HttpFile {

    ref string name () {
	return this._name;
    }

    ref string filename () {
	return this._filename;
    }

    ref HttpParameter [string] content_type () {
	return this._content_type;
    }

    ref HttpParameter [string] content_disp () {
	return this._content_disp;
    }

    ref byte[] content () {
	return this._content;
    }
    
    override string toString () {
	OutBuffer buf = new OutBuffer;
	buf.write ("NAME : " ~ _name ~ "\n");
	buf.write ("FILENAME : " ~ _filename ~ "\n");
	buf.write ("CONTENT_TYPE : " ~ to!string(_content_type) ~ "\n");
	buf.write ("CONTENT_DISP : " ~ to!string(_content_disp) ~ "\n");
	buf.write ("CONTENT : " ~ to!string (cast(string)_content) ~ "\n");
	return buf.toString ();
    }
    
    private {
	string _name; // Le nom donne par le client
	string _filename; // Le nom du fichier
	string _form_type;
	HttpParameter [string] _content_type;
	HttpParameter [string] _content_disp;
	byte [] _content;
    }
    
}
