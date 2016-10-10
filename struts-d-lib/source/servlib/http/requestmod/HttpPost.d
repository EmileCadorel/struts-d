module servlib.http.requestmod.HttpPost;
import servlib.http.requestmod.HttpParameter;
import servlib.http.requestmod.HttpFile;
import std.outbuffer, std.conv;

/**
 Enregistrement des information d'une requete POST
*/
class HttpPost {

    /**
     Retourne l'ensemble des parametre de la requete
     */
    ref HttpParameter [string] params () {
	return this._params;
    }

    HttpParameter param (string name) {
	auto it = (name in _params);
	if (it !is null) return *it;
	return HttpParameter.empty;
    }
    
    /**
     Retourne l'ensemble des fichiers des la requete
     */
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
	/// Les parametre de la requete
	HttpParameter [string] _params;

	/// Les fichiers de la requetes
	HttpFile [] _files;	
    }
    
}
