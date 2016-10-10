module main;
import std.stdio;
import struts.control;

class Home : Controller!Home {

    string test;

    int test2;

    override string execute() {
      return "SUCCESS";
    }

    // override string execute () {

    // 	if (test is null)
    // 	    return "<h1>HOME</h1>";
    // 	else return "<h1>Home : " ~ test ~ "</h1>";
    // }
}

class Search : Controller!Search {
    override string execute () {
	return "SUCCESS";
    }
}

