module main;
import std.stdio;
import struts.control;

class Test : Controller!Test {
    override string execute () {
	return "SUCCESS";
    }
}

