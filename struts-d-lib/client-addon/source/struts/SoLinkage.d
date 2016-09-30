module struts.SoLinkage;
import servlib.control.Controller;
import core.runtime;
import std.stdio;

shared static this () {
    Runtime.initialize ();
    writeln ("Runtime launched");
}

shared static ~this () {
    Runtime.terminate ();
    writeln ("Runtime quit");
}

extern (C) {
    class Shared {	
	static void loadControllers (ControllerTable table) {
	    foreach (key, value ; ControllerTable.instance.getAll()) {
		table.insert (key, value);
	    }
	}
    }
}
