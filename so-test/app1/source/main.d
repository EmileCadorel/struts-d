module main;
import std.stdio;
import clielib.SoLinkage;
import servlib.control.Controller;

class Test : Controller!Test {
    string execute () {
	return "SUCCESS";
    }

    string toString () {
	return "ici:Main:Test";
    }
}

