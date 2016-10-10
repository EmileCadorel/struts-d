module main;
import std.stdio;
import std.conv;
import struts.control;

class Home : Controller!Home {

    string test;

    int test2;

    override string execute() {
	string a = null;
	return to!string(a[0]);
    }
}

class Page : Controller!Page {

    override string execute () {
	return "";
    }
}


class Search : Controller!Search {
    override string execute () {
	return "SUCCESS";
    }
}

