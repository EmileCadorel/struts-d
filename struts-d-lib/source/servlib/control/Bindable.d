module servlib.control.Bindable;

import std.container;
import std.typecons, std.conv;
import std.path, std.outbuffer;
import std.array;
import std.stdio;

alias ObjAttrInfo = Tuple!(string, "name", Object*, "value");
alias AttrInfo = Tuple!(string, "name", void*, "value", string, "type");

template BindableDef () {
    
    Array!ObjAttrInfo infos () {
	return this._attrs;
    }

    void opIndexAssign (T : Object) (T value, string name) {
	foreach (it ; this._attrs) {
	    if (it.name == name)
		*it.value = value;
	}
    }

    void opIndexAssign (T) (T value, string name) {
	foreach (ref it ; this._std) {
	    if (it.name == name){
		if(it.value is null)
		    it.value = [value].ptr;
		else
		    *(cast(T*)it.value) = value;
	    }
	}
    }

    T getValue (T : Object) (string name) {
	foreach (it ; this._attrs) {
	    if (it.name == name) {
		return cast(T)(*it.value);
	    }
	}
	return null;
    }

    T * getValue (T : T *) (string name) {
	foreach (it ; this._std) {
	    if (it.name == name) {
		return cast(T*)it.value;
	    }
	}
	return null;
    }

    Array!AttrInfo all () {
	return this._std;
    }
    
    AttrInfo getValue () (string name) {
	foreach (it ; this._std) {
	    if (it.name == name) {
		return it;
	    }
	}
	return AttrInfo ("", null, "");
    }

    void addAttr(AttrInfo attr){
	import  std.algorithm, std.array;
        auto elem = find!"a.name == b"(_std.array, attr.name);
        writeln(elem);
	if (elem == [])
	    _std.insertBack(attr);
	else
	    throw new Exception("Controller Variable already defined: " ~ attr.name);
    }
    
    private {
	       
	void init (T) (T elem) {
	    pack ! ((elem).tupleof.length, T) (elem);
	}
	
	void pack (int nb, T) (T elem) {
	    pack !(nb - 1, T) (elem);
	    string name = extension (elem.tupleof[nb - 1].stringof);
	    name = name [1 .. name.length];
	    fill ! (typeof ((elem).tupleof[nb - 1])) (name, cast(void*) (&(elem).tupleof[nb - 1]));	 
	}
	
	void fill (T : Array!ObjAttrInfo) (string, void*) {}
	void fill (T : Array!AttrInfo) (string, void*) {}
	
	void fill (T : Object) (string name, void* value) {
	    this._attrs.insertBack (ObjAttrInfo (name, cast(Object*)value));
	}
	
	void fill (T) (string name, void * value) {
	    this._std.insertBack (AttrInfo (name, value, to!string(typeid (T))));
	}

	void fill (T:string) (string name, void * value) {
	    this._std.insertBack (AttrInfo (name, value, "string"));
	}
	
	void pack (int nb : 0, T) (T) {}
	
	Array!ObjAttrInfo _attrs;
	Array!AttrInfo _std;
    }    

    
}

class Bindable {
    this (T)(T elem) {
	init (elem);
    }

    mixin BindableDef;
}
