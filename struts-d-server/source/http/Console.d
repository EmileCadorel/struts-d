module http.Console;

import std.stdio;
import core.thread;
import servlib.utils.Log;
import servlib.utils.lexer;
import std.container, std.outbuffer;
import utils.Process;
import std.stdio, std.array;

class Console : Thread {

    this () {
	super (&run);
	commands = ["not_found" : &notFoundCom,
		    "kill" : &killCom,
		    "deploy" : &deployCom,
		    "help" : &helpCom];
    }
    
    void onBegin () {
	writeln ("Console start");
	while (!this.end) 
	    routine ();
    }

    void routine () {
	write ("> ");
	string line = readln ();
	string [] s = split (line, [" ", "\n"]);
	auto it = (s[0] in commands);
	if (it !is null) (*it)(s);
	else commands["not_found"](s);    
    }

    void kill () {
	this.end = true;
    }

    void killCom (string [] data) {
	if (data.length > 1 && (data[1] == "-h" || data[1] == "--help")) {
	    Log.instance.addInfo ("kill [-s] [-a name] : this will kill the server or an application (based on its name)");
	} else {
	    this.end = true;
	    ProcessLauncher.instance.killAll ();
	}
    }

    void helpCom (string[]) {
	foreach (key, value ; commands) {
	    if (key != "help" && key != "not_found")
		value ([key, "-h"]);
	}
    }
    
    void deployCom (string[] data) {
	if (data.length > 1 && (data[1] == "-h" || data[1] == "--help")) {
	    Log.instance.addInfo ("deploy [-a] name : this will deploy or redeploy an application (based on its name)");
	} else if (data.length == 1) {
	    Log.instance.addInfo ("deploy [-a] name : this will deploy or redeploy an application (based on its name)");
	} else {
	    if (data.length > 1) {
		string path = data[1];
		ProcessLauncher.instance.launch (path);
	    }
	} 
    }    
	    
    void notFoundCom (string [] data) {
	Log.instance.addInfo ("Commande introuvable " ~ data[0]);
    }
    
    void onEnd () {
	Log.instance.addInfo ("Console stop");
    }
    
    private void run () {	
	onBegin ();
	onEnd ();
    }    

    private string [] split (string line, string [] cutter) {
	string [] total;
	LexerString lexer = new LexerString (line);
	lexer.setKeys (make!(Array!string)(cutter));
	lexer.setSkip (make!(Array!string)(cutter));
	Word word;
	while (lexer.getNext (word)) {
	    total ~= [word.str];
	}
	return total;
    }
    
    private void delegate(string[]) [string] commands;
    bool end = false;
}

