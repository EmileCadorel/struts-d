module utils.SoLoader;
import servlib.utils.Singleton;
import servlib.control.Controller;
import std.container, std.outbuffer, std.conv;
import core.stdc.stdio;
import std.stdio;
import core.stdc.stdlib;
import core.sys.posix.dlfcn;
import servlib.utils.Log;


class SoError : Exception {
    this (string name, string data) {
	super ("");
	OutBuffer buf = new OutBuffer;
	buf.write ("Chargement de ");
	buf.write (name);
	buf.write (" impossible ~> \n");
	buf.write (data);
	msg = buf.toString ();
    }
}

class SoLoader {

    void load (string name) {
	void * lh = dlopen (name.ptr, RTLD_LAZY);
	if (!lh)
	    throw new SoError (name, to!string (dlerror ()));	
	Log.instance.add_info ("Dll open : " ~ name);
	void function(ControllerTable) fn = cast(void function (ControllerTable)) dlsym (lh, LOAD_FUN.ptr);
	auto error = dlerror ();
	if (error) throw new SoError (name, to!string(error));
	fn (ControllerTable.instance);
	alls [name] = (lh);
    }

    mixin Singleton!SoLoader;
    
    private {
	static immutable string LOAD_FUN = "_D7clielib9SoLinkage6Shared15loadControllersUC7servlib7control10Controller15ControllerTableZv";
;
	
	this () {}
	void* [string] alls;
	~this() {
	    foreach (key, value ; alls) {
		Log.instance.add_info ("Close Dll : " ~ key);
		dlclose (value);
	    }
	}
    }
    
}
