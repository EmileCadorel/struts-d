module servlib.dsp.HtmlValueParser;

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

class HtmlValueParser : HtmlInHerit ! ("dsp:value", HtmlValueParser) {
    override Balise [] execute (Balise element, Balise [] delegate (Balise, string, ControllerAncestor) callBack, string app, ControllerAncestor session) {
	try {
	    string value = element ["value"];
	    if (value is null) {
		throw new Exception ("Pas d'element value dans la balise ");
	    }
	    auto alls = split (value, ".");
	    auto var = session.getValue (alls[0]);
	    auto varObj = session.getValue !(Object) (alls[0]);
	    if (var.name != value && varObj is null) {
		throw new Exception ("Var not found '" ~ alls[0] ~ "'");
	    } else if (var.name == alls[0]) {
		return [new Text (fromSimple (alls [1 .. $], var))];
	    } else {
		return [new Text (getNext (alls [1 .. $], varObj))];
	    }
	} catch (Exception e) {
	    writeln ("At ", element.toStr);
	    writeln (e);
	    return [];
	}
    }
    
    private string fromSimple (string [] attrs, AttrInfo var) {
	if (attrs != [])
	    throw new Exception ("Pas de propriete " ~ attrs[1] ~ " pour le type " ~ var.type);
	switch (var.type) {
	case "int":
	    return to!string (*cast(int*) var.value); 
	case "bool":
	    return to!string (*cast(bool*) var.value); 
	case "float":
	    return to!string (*cast(float*) var.value); 
	case "string":
	    return (*cast(string*) var.value); 
	default:
	    throw new Exception ("Var Type not supported");
	}
    }
    
    private string getNext (string [] attrs, Object elem) {
	if (attrs == []) {
	    return  elem.toString;
	} else {
	    auto bindable = cast(Bindable) (elem);
	    if (bindable is null) {
		throw new Exception ("Impossible de recuperer des attributs dans un objet n'heritant pas de Bindable ");
	    } else {
		auto var = bindable.getValue (attrs [0]);
		auto varObj = bindable.getValue!Object (attrs[0]);
		if (var.name == attrs[0]) return fromSimple (attrs[1 .. $], var);
		else if (varObj !is null)
		    return getNext (attrs[1 .. $], varObj);
		else
		    throw new Exception ("attributs inexistant " ~ attrs[0]);
	    }
	}
    }
    
}
