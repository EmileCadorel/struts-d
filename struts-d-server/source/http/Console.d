module http.Console;

import std.stdio;
import http.HttpServer;
import core.thread;
import servlib.utils.Log;
import servlib.utils.lexer;
import std.container, std.outbuffer;
import servlib.application.Application;

class Console : Thread {

    this (HttpServerBase server) {
	super (&run);
	this.server = server;
	commands = ["not_found" : &notFoundCom,
		    "kill" : &killCom,
		    "deploy" : &deployCom,
		    "help" : &helpCom];
    }
    
    void onBegin () {
	Log.instance.add_info ("Console start");
	this.startRoutine ();
    }

    void startRoutine () {
	string line;
	while (!this.end) {
	    writeln (">");
	    line = readln ();
	    string [] s = split (line, [" ", "\n"]);
	    auto it = (s[0] in commands);
	    if (it !is null) (*it)(s);
	    else commands["not_found"](s);
	}
    }

    void kill () {
	this.end = true;
    }

    void killCom (string [] data) {
	if (data.length > 1 && (data[1] == "-h" || data[1] == "--help")) {
	    Log.instance.add_info ("kill [-s] [-a name] : this will kill the server or an application (based on its name)");
	} else {
	    if (data.length > 1 && data[1] == "-a") {
		//TODO kill application
	    } else {
		this.server.kill ();
	    }
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
	    Log.instance.add_info ("deploy [-a] name : this will deploy or redeploy an application (based on its name)");
	} else if (data.length == 1) {
	    Log.instance.add_info ("deploy [-a] name : this will deploy or redeploy an application (based on its name)");
	} else {
	    if (data.length > 1) {
		string path = data[1];
		ApplicationLoader.instance.load (path);
	    }
	} 
    }    
	    
    void notFoundCom (string [] data) {
	Log.instance.add_info ("Commande introuvable " ~ data[0]);
    }
    
    void onEnd () {
	Log.instance.add_info ("Console stop");
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
    
    private HttpServerBase server;
    private void delegate(string[]) [string] commands;
    private bool end = false;
}

