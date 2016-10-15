module main;
import std.stdio;
import std.conv;
import struts.control;

class User : Bindable {

    string name;
    
    string pass;    
    
    this () {
	super (this);
    }

    
    
}


class Home : Controller!Home {

    User user;
    
    this () {
	super (this);
	user = new User ();
    }
    
    override string execute() {	
	if (user.name is null || user.pass is null) {
	    return "INPUT";
	} else {
	    return "SUCCESS";
	}
    }

}


class Logged : Controller!Logged {

    User user;
    
    int[] myList = [0,3,4,8];
    
    this () {
	super (this);
	user = new User ();
    }
    
    override string execute () {
	return "SUCCESS";
    }
    
}
