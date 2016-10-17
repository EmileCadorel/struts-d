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

class Index : Controller!Index {
    this () {
	super (this);
    }
    
    override string execute () {
	return "SUCCESS";
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

class Test : Bindable {
    string name;
    string value;

    this (string name, string value) {
	super (this);
	this.name = name;
	this.value = value;
    }
    
}


class Logged : Controller!Logged {

    User user;
    
    int [] myList;
    
    this () {
	super (this);
	user = new User ();
	myList = [1, 3, 4, 90];
    }
    
    override string execute () {
	return "SUCCESS";
    }
    
}
