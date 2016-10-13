module servlib.dsp.HtmlValueParser;

import servlib.dsp.HtmlTagParser;
import servlib.dsp.HTMLoader;
import servlib.utils.xml;
import servlib.utils.lexer;
import servlib.control.Controller;
import servlib.utils.Log;
import std.container, std.algorithm;

import std.conv, std.stdio;
import std.container, std.traits, std.array;

class HtmlValueParser : HtmlInHerit ! ("dsp:value", HtmlValueParser) {
    override Balise [] execute (Balise element, Balise [] delegate (Balise, string, ControllerAncestor) callBack, string app, ControllerAncestor session) {
	Log.instance.addInfo ("HtmlValueParser execution");
	try {
	    string value = element ["value"];
	    if (value is null) {
		throw new Exception ("Pas d'element value dans la balise " ~ element.toStr);
	    } 
	    auto var = session.getValue (value);
	    if (var.name != value) {
		throw new Exception ("Var not found '" ~ value ~ "' " ~ element.toStr);
	    } else {
		string text;
		switch (var.type) {
		case "int":
		    text = to!string (*cast(int*) var.value); break;
		case "bool":
		    text = to!string (*cast(bool*) var.value); break;
		case "float":
		    text = to!string (*cast(float*) var.value); break;
		case "string":
		    text = (*cast(string*) var.value); break;
		default:
		    throw new Exception ("Var Type not supported");
		}
		return [new Text (text)];
	    }
	} catch (Exception e) {
	    writeln (e);
	    return [];
	}
    }
}
