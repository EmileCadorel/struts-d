module servlib.dsp.HtmlForEachParser;

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

class HtmlForEachParser : HtmlInHerit ! ("dsp:forEach", HtmlForEachParser) {
  
    override Balise[] execute (Balise element, Balise[] delegate (Balise, string, ControllerAncestor) callBack, string app, ControllerAncestor session) {
	Log.instance.addInfo("HtmlForEach execute");
	try{
	    string list = element["list"];
	    string itemName = element["item"];
	    if (list !is null && itemName !is null) {
		auto myList = session.getValue (list);
		auto myListObj = session.getValue !(Object) (list);
		if (myList.name != list && myListObj is null)
		    throw new Exception("Variable not defined " ~ list ~ " " ~ element.toStr());
		if (myListObj is null && myList.type.length >= 2 && myList.type[$-2..$] == "[]") {
		    return iterateList (myList, itemName, element, callBack, app, session);
		} else if (myListObj !is null) {
		    //iterateList(myListObj, element, callBack, app, session);
		    throw new Exception("Not implemented");
		} else {
		    throw new Exception("Variable is not enumerable " ~ list ~ " " ~ element.toStr());
		}
	    }else{
		if(list is null)
		    throw new Exception("List is not defined " ~ element.toStr());
		else
		    throw new Exception("Item name is not defined " ~ element.toStr());
	    }
	}catch (Exception e){
	    writeln(e);
	    return [];
	}
    }

    private Balise[] iterateList(AttrInfo list, string itemName, Balise element, Balise[] delegate (Balise, string, ControllerAncestor) callBack, string app, ControllerAncestor session){	
	Log.instance.addInfo("HtmlForEach execute Name " ~ list.type);
	string name;
	if(canFind(list.type,".")){
	    name = split(list.type,".")[$];
	}
	else{
	    name = list.type;
	}
	switch(name){
	case "int[]":	        
	    return iterateList !(int) (*cast(int[]*)list.value, itemName, element, callBack, app, session);
	case "float[]":	        
	    return iterateList !(float) (*cast(float[]*)list.value, itemName, element, callBack, app, session);
	case "string[]":	        
	    return iterateList !(string) (*cast(string[]*)list.value, itemName, element, callBack, app, session);
	    /*	    case "Array"
		    return iterateList (Array) (*cast(Array*)list.value, element, callBack, app, session);*/
	default:
	    throw new Exception("Type Not supported " ~ list.type);
	}
    }

    

    /*	     
	     private Balise[] iterateList(Object list, Balise element, Balise[] delegate (Balise, string, ControllerAncestor) callBack, string app, ControllerAncestor session){
    
	     }*/

    private Balise[] iterateList (T) (T[] list, string itemName, Balise element, Balise[] delegate (Balise, string, ControllerAncestor) callBack, string app, ControllerAncestor session){
	Balise[] balises;
	session.addAttr(AttrInfo(itemName, null, to!string(typeid (T))));
	foreach (elem ; list) {
	    session.opIndexAssign !(T)(elem,itemName);
	    foreach(balise; element.childs){
		balises ~= callBack(balise, app, session);
	    }
	}
	return balises;
    }
    
}
