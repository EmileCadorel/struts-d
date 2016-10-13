module http.SessionCreator;
import servlib.control.Session;
import servlib.utils.Singleton;

class SessionCreator {

    Session getSession (string ssid) {
	auto it = (ssid in sessions);
	if (it !is null) return *it;
	else {
	    Session ret = new Session;
	    sessions [ssid] = ret;
	    return ret;
	}
    }
        

    private Session [string] sessions;
    
    mixin Singleton!SessionCreator;
}
