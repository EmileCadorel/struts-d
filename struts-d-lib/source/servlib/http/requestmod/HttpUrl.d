module servlib.http.requestmod.HttpUrl;
import std.container, std.outbuffer, std.conv;
import servlib.http.requestmod.HttpParameter;

/**
 Un url d'une requete HTTP
 */
class HttpUrl {

    this (Array!string path) {
	this._path = path;
    }

    this (Array!string path, HttpParameter[string] params) {
	this._path = path;
	this._params = params;
    }

    /**
     Le path de la requete (mot par mot)
     */
    ref Array!string path () {
	return this._path;
    }

    /**
     Le parametre de la requete
     */
    ref HttpParameter param (string name) {
	auto it = (name in _params);
	if (it !is null) return *it;
	else return HttpParameter.empty;
    }


  /**
     Les paramètres de la requete
   */
  ref HttpParameter [string] params () {
    return  this._params;
  }

    override string toString () {
	OutBuffer buf = new OutBuffer;
	buf.write ("PATH : /");
	foreach (it ; path) {
	    buf.write (it);
	    buf.write (" / ");
	}
	buf.write ("?" ~ to!string (_params));
	return buf.toString ();
    }

    private {
	/// machin/true/fin
	Array!string _path;

	/// ... ?param=&param2=8
	HttpParameter [string] _params;
    }
}
