module servlib.dsp.HtmlForEachParser;

import servlib.dsp.HtmlTagParser;
import servlib.dsp.HTMLoader;
import servlib.utils.xml;
import servlib.utils.lexer;
import servlib.control.Controller;
import servlib.utils.Log;
import std.container, std.algorithm;

import std.conv, std.stdio;
import std.container, std.traits, std.array;

class HtmlForEachParser : HtmlInHerit ! ("dsp:forEach", HtmlForEachParser) {
  
    override Balise[] execute (Balise element, Balise[] delegate (Balise, string, ControlVars) callBack, string app, ControlVars session) {
	Log.instance.addInfo("HtmlForEach execute");
	try{
	    int nb = to!int(element["count"]);
	    Balise [] array;
	    for(int i=0;i<nb;i++){
		array ~= element.childs.array;
	    }
	    return array;
	}catch(Exception e){
	    writeln(e);
	    return [];
	}
    }	
}
