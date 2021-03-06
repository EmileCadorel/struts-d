module servlib.control.Session;


/**
 La session est la classe qui va etre instancie afin d'enregistrer des informations sur l'utilisateur en cours
*/
class Session {
    
    void opIndexAssign (T : Object) (T elem, string name) {
     	datas[name] = cast(void*)elem;
    }
    
    void opIndexAssign (T) (T * elem, string name) {
    	datas[name] = (elem);
    }
    
    T get (T : Object) (string name) {
	auto elem = (name in datas);
	if (elem is null) return null;
	else return cast (T) (*elem);
    }

    T * get (T) (string name) {
	auto elem = (name in datas);
	if (elem is null) return null;
	else return cast (T*) (*elem);
    }

    private {
	void* [string] datas;
    }

}
