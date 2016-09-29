module main;
import std.stdio;
import clielib.SoLinkage;
import servlib.control.Controller;

class Test : Controller!Test {
    override string execute () {
	return "SUCCESS";
    }
}

