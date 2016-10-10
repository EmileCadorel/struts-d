module servlib.dsp.HtmlIncludeParser;

import servlib.dsp.HtmlTagParser;
import servlib.dsp.HTMLoader;
import servlib.utils.xml;
import servlib.utils.lexer;
import servlib.control.Session;
import servlib.utils.Log;
import std.container, std.algorithm;

import std.conv, std.stdio;
import std.container, std.traits;

class HtmlIncludeParser : HtmlInHerit ! ("dsp:include", HtmlIncludeParser) {
  
    override Balise[] execute (Balise element, Balise[] delegate (Balise, string, Session) callBack, string app, Session session) {
	Log.instance.addInfo("HtmlInclude execute");
	try{
	    auto it = element["link"];
	    return [HTMLoader.instance.load(it, app, session)];
	}catch(Exception e){
	    writeln(e);
	    return [];
	}
    }
	
}
