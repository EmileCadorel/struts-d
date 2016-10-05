module servlib.control.Controller;
import servlib.http.request;
import servlib.utils.Singleton;
import std.stdio;
import std.outbuffer, std.conv;

/**
 Singleton stockant les instances de controller
*/
class ControllerTable {

    /**
     Ajoute un controller a la base des controller
     Params:
     name, le nom du controller
     control, le controller
     */
    void insert (string name, ControllerAncestor control) {
	_global [name] = control;
    }

    /**
     Params:
     name, le nom du controller
     Return:
     un controller en fonction de son nom
     */
    ControllerAncestor opIndex (string name) {
	auto it = name in _global;
	if (it !is null) return *it;
	else return null;
    }

    /**
     Return:
     tout les controller
     */
    ref ControllerAncestor [string] getAll () {
	return this._global;
    }

    override string toString () {
	OutBuffer buf = new OutBuffer;
	buf.write (to!string (_global));
	return buf.toString();
    }

    mixin Singleton!ControllerTable;

    private {
	ControllerAncestor[string] _global;
    }
}

/**
 Permet d'instancier les controller statiquement
 */
template ControlInsert (T : ControllerAncestor) {
    static this () {
	writeln ("insert : " ~ T.classinfo.name);
	ControllerTable.instance.insert (T.classinfo.name, new T);
    }
}

/**
 L'ancetre de tout les controller
 */
abstract class ControllerAncestor {

    /**
     Unpack la request et rempli les attributs du controller en consequence
    */
    void unpackRequest (HttpRequest request) {
	this._request = request;
    }

    abstract string execute ();

    HttpParameter get (string key) {
	return this._request.url.param(key);
    }

    HttpParameter post (string key) {
	if (this._request.post_value !is null)
	    return this._request.post_value.params[key];
	else return HttpParameter.empty;
    }

    HttpParameter cookie (string key) {
	return this._request.cookies()[key];
    }

    ref HttpRequest request () {
	return this._request;
    }

    private {
	HttpRequest _request;
    }

}

/**
 Cette classe est celle que l'utilisateur va herite afin de creer une instance de controller au demarrage de la runtime D.
*/
abstract class Controller (T) : ControllerAncestor {
    mixin ControlInsert!T; /// ce mixin va instancier statiquement la classe controller
}







