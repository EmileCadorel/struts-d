module main;
import std.stdio;
import std.conv;
import struts.control;


class Home : Controller!Home {

    string name;
    
    string pass;
    
    string error = "";

    string user;

    Session session;

    int[] myList = [0,3,4,8];
    
    this () {
	super (this);
    }

    override string execute() {
	writeln (this.session);
	/*
	if (this.session is null || this.session.get!(string*)("login") is null) {
	    if (name is null || pass is null) {
		error = "Impossible sans nom ou pass";
		return "INPUT";
	    } else {
		session ["login"] = &name;
		user = name;
		return "SUCCESS";
	    }
	}
	user = *(this.session.get!(string) ("login"));*/
	return "SUCCESS";
    }

    override void setSession (Session session) {
	this.session = session;
    }
}
