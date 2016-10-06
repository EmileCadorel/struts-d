module servlib.http.requestmod.HttpFile;
import servlib.http.request;
import std.container, std.outbuffer;
import std.conv;

/**
 Stocke une entree fichier d'une requete Http
*/
class HttpFile {

    /**
     Le nom de l'input dans lequel a ete place le fichier
     */
    ref string name () {
	return this._name;
    }
    
    /**
     Le nom du fichier envoye dans la requete
     */
    ref string filename () {
	return this._filename;
    }

    /**
     Les informations content-type de la requete
     */
    ref HttpParameter [string] content_type () {
	return this._content_type;
    }

    /**
     Les information content-disp de la requete
     */
    ref HttpParameter [string] content_disp () {
	return this._content_disp;
    }

    /**
     Le contenu du fichier
     */
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
	
	/// Le nom donne par le client
	string _name;

	/// Le nom du fichier
	string _filename;

	/// Content-type: ...
	HttpParameter [string] _content_type;

	/// Content-disp: ...
	HttpParameter [string] _content_disp;

	/// Le contenu du fichier
	byte [] _content;
    }
    
}
