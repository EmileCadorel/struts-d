module main;
import std.stdio;
import std.conv;
import struts.control;

class Home : Controller!Home {

    string test;

    int test2 = 8;

    this () {
	super (this);
    }

    override string execute() {
	if (test is null) return "INPUT";
	else return "SUCCESS";
    }
}

class Page : Controller!Page {

    this () {
	super (this);
    }
    
    override string execute () {
	return "";
    }
}


class Search : Controller!Search {

    this () {
	super (this);
    }
    
    override string execute () {
	return "SUCCESS";
    }
}

