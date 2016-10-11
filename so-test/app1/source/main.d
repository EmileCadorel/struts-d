module main;
import std.stdio;
import std.conv;
import struts.control;

class Home : Controller!Home {

    string test;

    int test2 = 8;

    override string execute() {
	return "SUCCESS";
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

