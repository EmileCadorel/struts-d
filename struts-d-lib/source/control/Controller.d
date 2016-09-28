module control.Controller;
import http.request;
import utils.Singleton;

class ControllerTable {


    void insert (string name, ControllerAncestor control) {
	//TODO throw exception, multiple definition
	_global [name] = control;
    }

    ControllerAncestor opIndex (string name) {
	auto it = name in _global;
	if (it !is null) return *it;
	else return null;
    }

    mixin Singleton!ControllerTable;
    private {
	static ControllerAncestor[string] _global;	
    }
}

template ControlInsert (T : ControllerAncestor) {
    static this () {
	ControllerTable.instance.insert (T.classinfo.name, new T);
    }
}

abstract class ControllerAncestor {

    /**
     Unpack la request et rempli les attributs du controller en consequence
    */
    void unpackRequest (HttpRequest request) {
    }

    abstract string execute ();

    
    HttpParameter get (string key) {
	return this._request.url.param(key);
    }

    HttpParameter post (string key) {
	return this._request.post_value.params[key];
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
