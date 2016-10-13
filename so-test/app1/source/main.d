module main;
import std.stdio;
import std.conv;
import struts.control;

class Foo : Bindable {

    string name;

    this () {
	super (this);
    }
    
    override string toString () {
	return "C'est la folie";
    }
};

class Home : Controller!Home {

    string test;

    int test2 = 8;
    
    Foo foo;
    
    this () {
	super (this);
	foo = new Foo ();
	foo.name = "Test";
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

