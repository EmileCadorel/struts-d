module servlib.utils.SoLoader;
import servlib.utils.Singleton;
import servlib.control.Controller;
import std.container, std.outbuffer, std.conv;
import core.stdc.stdio;
import std.stdio;
import core.stdc.stdlib;
import core.sys.posix.dlfcn;
import servlib.utils.Log;
import servlib.utils.exception;

/**
 Charge une shared lib, et lance le chargement de controller
 */
class SoLoader {

    /**
     Params:
     name, le path du .so
     */
    void load (string name) {
	auto it = (name in alls);
	if (it !is null) {
	    close (*it);
	}
	void * lh = dlopen (name.ptr, RTLD_LAZY);
	if (!lh)
	    throw new SoError (name, to!string (dlerror ()));
	Log.instance.addInfo ("Dll open : %s", name);
	void function(ControllerTable) fn = cast(void function (ControllerTable)) dlsym (lh, LOAD_FUN.ptr);
	auto error = dlerror ();
	if (error) throw new SoError (name, to!string(error));
	fn (ControllerTable.instance);
	alls [name] = (lh);
    }

    /**
     Ferme tout les .so et les runtime D lance par chacune d'entre elle.
     */
    void stop () {
	foreach (key, value ; alls) {
	  Log.instance.addInfo ("Close Dll : ", key);
	    dlclose (value);
	}
    }

    mixin Singleton!SoLoader;

    private {

	static immutable string LOAD_FUN = "_D6struts9SoLinkage6Shared15loadControllersUC7servlib7control10Controller15ControllerTableZv";

	this () {}

	void* [string] alls;
	
	void close (void * value) {
	    dlclose (value);
	}

	~this() {
	    stop ();
	}
    }

}
