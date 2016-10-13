module servlib.control.Controller;
import servlib.http.request;
import servlib.utils.Singleton;
import std.stdio, std.path;
import std.outbuffer, std.conv, std.typecons;
import std.container;
import servlib.control.Bindable;
import servlib.control.Session;

alias ControllerInfo = Tuple!(TypeInfo, "type", string, "name");

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
    void insert (string name, ControllerInfo control) {
	_global [name] = control;
    }

    /**
     Params:
     name, le nom du controller
     Return:
     un controller en fonction de son nom
     */
    ControllerInfo opIndex (string name) {
	auto it = name in _global;
	if (it !is null) return *it;
	else return ControllerInfo (null, "");
    }

    /**
     Return:
     tout les controller
     */
    ref ControllerInfo [string] getAll () {
	return this._global;
    }

    override string toString () {
	OutBuffer buf = new OutBuffer;
	buf.write (to!string (_global));
	return buf.toString();
    }

    mixin Singleton!ControllerTable;

    private {
	ControllerInfo [string] _global;
    }
}

/**
 Permet d'instancier les controller statiquement
 */
template ControlInsert (T : ControllerAncestor) {

    static this () {
	writeln ("insert : " ~ T.classinfo.name);
	ControllerTable.instance.insert (T.classinfo.name, ControllerInfo (T.classinfo, T.classinfo.name));
    }
    
}

/**
 L'ancetre de tout les controller
 */
class ControllerAncestor {

    this (T) (T elem) {
	init (elem);
    }
    
    /**
     Unpack la request et rempli les attributs du controller en consequence
    */
    void unpackRequest (HttpRequest request) {
	foreach (it ; this.all ()) {
	    if (it.type == "string") {
		*(cast(string*)it.value) = null;
	    }	    
	}
	
	foreach (key, value ; request.url.params) {
	    auto it = this.getValue (key);
	    if (it.name == key)
		setValue (it, value);
	}

	if (request.post_value !is null) {
	    foreach (key, value ; request.post_value.params) {
		auto it = this.getValue (key);
		if (it.name == key)
		    setValue (it, value);
	    }
	}
    }

    void setSession (Session) {}

    private void setValue (AttrInfo info, HttpParameter param) {
	if (param.Is (HttpParamEnum.STRING) && info.type == "string") {
	    *(cast(string*)info.value) = param.to!string;
	} else if (param.Is (HttpParamEnum.INT) && info.type == "string") {
	    *(cast(string*)info.value) = to!string (param.to!int);
	} else if (param.Is (HttpParamEnum.FLOAT) && info.type == "string") {
	    *(cast(string*)info.value) = to!string (param.to!float);
	} else if (param.Is (HttpParamEnum.INT) && info.type == "int") {
	    *(cast(int*)info.value) = param.to!int;
	} else if (param.Is (HttpParamEnum.INT) && info.type == "float") {
	    *(cast(float*)info.value) = param.to!int;
	} else if (param.Is (HttpParamEnum.FLOAT) && info.type == "int") {
	    *(cast(int*)info.value) = to!int(param.to!float);
	} else if (param.Is (HttpParamEnum.FLOAT) && info.type == "float") {
	    *(cast(float*)info.value) = param.to!float;
	}	    	
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

    mixin BindableDef;
    
}


class Controller (T) : ControllerAncestor {
    this (T elem) {
	super (elem);
    }

    mixin ControlInsert!T;
}






