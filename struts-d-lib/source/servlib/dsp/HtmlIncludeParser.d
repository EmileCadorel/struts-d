module servlib.dsp.HtmlIncludeParser;

import servlib.dsp.HtmlTagParser;
import servlib.dsp.HTMLoader;
import servlib.utils.xml;
import servlib.utils.lexer;
import servlib.control.Controller;
import servlib.utils.Log;
import std.container, std.algorithm;

import std.conv, std.stdio;
import std.container, std.traits, std.array;

class HtmlIncludeParser : HtmlInHerit ! ("dsp:include", HtmlIncludeParser) {
  
    override Balise[] execute (Balise element, Balise[] delegate (Balise, string, ControllerAncestor) callBack, string app, ref ControllerAncestor session) {
	Log.instance.addInfo("HtmlInclude execute");
	try{
	    string link = element["link"];
	    Balise root = HTMLoader.instance.load(link, app, session);
	    if(root.name == Identifiant.eof){
	        return root.childs.array();
	    }else
		return [root];
	}catch(Exception e){
	    writeln(e);
	    return [];
	}
    }
	
}
