module servlib.control.ControllerContainer;
import servlib.control.Controller;
import servlib.utils.Option;
import servlib.utils.XMLoader;
import servlib.utils.Singleton;

class ApplicationContainer {
    
    ControllerContainer[string] all () {
	return this._controllers;
    }
    
    ControllerContainer getApp (string value) {
	auto it = (value in _controllers);
	if (it is null) return null;
	else return *it;
    }

    void addApp(string value) {
	this._controllers[value] = new ControllerContainer;
    }    
    
    private ControllerContainer [string] _controllers;
    
    mixin Singleton!ApplicationContainer;    
}


class ControllerContainer {

    ControllerInfos opIndex (string name) {
	auto it = name in this._controllers;
	if (it !is null) return *it;
	else return ControllerInfos.empty;
    }

    void opIndexAssign (ControllerInfos value, string name) {
	this._controllers[name] = value;
    }
    
    ref ControllerInfos [string] controllers () { return this._controllers; }
    
    private  {
	ControllerInfos [string] _controllers;
    }
    
}

struct ControllerInfos {
    string name;
    string control;
    string [string] results;
    string def;

    static ControllerInfos empty () {
	return ControllerInfos(null, null, null, null);
    }

    bool isNull () {
	return this.name == null;
    }
    
}
