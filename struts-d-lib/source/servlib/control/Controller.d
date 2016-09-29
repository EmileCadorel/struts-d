module servlib.control.Controller;
import servlib.http.request;
import servlib.utils.Singleton;
import std.stdio;
import std.outbuffer, std.conv;

class ControllerTable {
        
    void insert (string name, ControllerAncestor control) {
	_global [name] = control;
    }

    ControllerAncestor opIndex (string name) {
	auto it = name in _global;
	if (it !is null) return *it;
	else return null;
    }

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

template ControlInsert (T : ControllerAncestor) {
    static this () {
	writeln ("insert : " ~ T.classinfo.name);
	ControllerTable.instance.insert (T.classinfo.name, new T);
    }
}

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

abstract class Controller (T) : ControllerAncestor {
    mixin ControlInsert!T;
}
				
				 
				
				
				
				
				
