module http.HttpUrl;
import std.container;

class HttpUrl {

    enum ParamEnum {
	STRING,
	INT,
	FLOAT,
	VOID
    }

    struct Parameter {
	ParamEnum type;
	void * data;
		
	T * to (T) () {
	    return cast(T*)this.data;
	}

	static ref Parameter empty () {
	    return _empty;
	}

	private {
	    static Parameter _empty = Parameter (ParamEnum.VOID, null);
	}
	
    }

    this (Array!string path) {
	this._path = path;
    }

    this (Array!string path, Parameter[string] params, string anchor) {
	this._path = path;
	this._params = params;
	this._anchor = anchor;
    }

    this (Array!string path, Parameter[string] params) {
	this._path = path;
	this._params = params;
    }

    this (Array!string path, string anchor) {
	this._path = path;
	this._anchor = anchor;
    }
    
    ref Array!string path () {
	return this._path;
    }

    ref string anchor () {
	return this._anchor;
    }

    ref Parameter param (string name) {
	auto it = (name in _params);
	if (it !is null) return *it;
	else return Parameter.empty;
    }
    
    private {
	Array!string _path;
	string _anchor;
	Parameter [string] _params;
    }
}
