module servlib.dsp.HtmlTextFieldParser;


import servlib.dsp.HtmlTagParser;
import servlib.dsp.HTMLoader;
import servlib.utils.xml;
import servlib.utils.lexer;
import servlib.control.Controller;
import servlib.control.Bindable;
import servlib.utils.Log;
import std.container, std.algorithm;

import std.conv, std.stdio;
import std.container, std.traits, std.array;


class HtmlTextFieldParser : HtmlInHerit ! ("dsp:textfield", HtmlTextFieldParser) {
    
    override Balise [] execute (Balise element, Balise [] delegate (Balise, string, ControllerAncestor) callBack, string app, ref ControllerAncestor session) {
	try {
	    Balise retour = new Balise (new Identifiant ("input"));
	    retour.attrs[new Identifiant ("type")] = "text";
	    foreach (key, value ; element.attrs) {
		retour.attrs[key] = value;
	    }
	    return [retour];
	} catch (Exception e) {
	    writeln ("At ", element.toStr);
	    writeln (e);
	    return [];
	}
    }
    
}

