module main;
import std.stdio;
import struts.control;

class Home : Controller!Home {
    override string execute () {
	return "<h1>HOME</h1>";
    }   
}

class Search : Controller!Search {
    override string execute () {
	return "<H1>SEARCH</h1>";
    }
}

