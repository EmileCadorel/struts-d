module http.requestmod.HttpUrl;
import std.container, std.outbuffer, std.conv;
import http.requestmod.HttpParameter;

class HttpUrl {

    this (Array!string path) {
	this._path = path;
    }

    this (Array!string path, HttpParameter[string] params) {
	this._path = path;
	this._params = params;
    }
    
    ref Array!string path () {
	return this._path;
    }

    ref HttpParameter param (string name) {
	auto it = (name in _params);
	if (it !is null) return *it;
	else return HttpParameter.empty;
    }

    string toString () {
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
	Array!string _path;
	HttpParameter [string] _params;
    }
}
