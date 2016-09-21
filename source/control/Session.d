module control.Session;


class Session {

    void opIndexAssign (T : Object) (T elem, string name) {
	datas[name] = cast(Object) (elem);
    }
    
    T get (T : Object) (string name) {
	auto elem = (name in datas);
	if (elem is null) return null;
	else return cast(T) *elem;
    }
    
    private {
	Object [string] datas;
    }
    
}
