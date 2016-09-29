module servlib.utils.Singleton;

mixin template Singleton (T) {
    
    static ref T instance () {
	if (inst is null) {
	    synchronized {
		if (inst is null) {
		    writeln ("Singleton:ici:" ~ T.classinfo.name);
		    inst = new T;
		}
	    }
	}
	return inst;
    }

private:
       
    __gshared static T inst = null;
    
}
