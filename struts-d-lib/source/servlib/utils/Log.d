module servlib.utils.Log;

import servlib.utils.Singleton;
import servlib.utils.Option;
import std.stdio;
import std.datetime;
import std.conv;

class Log {

    this () {
	this.file = File(Option.instance.log_file_path, "a");
    }

    ~this () {
	this.file.close();
    }

    void add_info (string text) {
	SysTime date = Clock.currTime ();
	string line = "(" ~ to!string(date.day) ~ "-" ~ to!string(date.month) ~ "-" ~ to!string(date.year) ~ " " ~ to!string(date.hour) ~ ":" ~ to!string(date.minute) ~ ":" ~ to!string(date.second) ~ ") INFO : ";
	line ~= text;
	this.file.writeln (line);
	this.file.flush();
	if (Option.instance.debug_mode)
	    writeln (line);
    }

    void add_err (string text) {
	SysTime date = Clock.currTime ();
	string line = "(" ~ to!string(date.day) ~ "-" ~ to!string(date.month) ~ "-" ~ to!string(date.year) ~ " " ~ to!string(date.hour) ~ ":" ~ to!string(date.minute) ~ ":" ~ to!string(date.second) ~ ") " ~ RED ~ "ERROR" ~ RESET ~ " : ";
	line ~= text;
	this.file.writeln (line);
	this.file.flush();
	if (Option.instance.debug_mode)
	    writeln (line);
    }

    void add_war (string text) {
	SysTime date = Clock.currTime ();
	string line = "(" ~ to!string(date.day) ~ "-" ~ to!string(date.month) ~ "-" ~ to!string(date.year) ~ " " ~ to!string(date.hour) ~ ":" ~ to!string(date.minute) ~ ":" ~ to!string(date.second) ~ ") " ~ PURPLE ~ "WARNING" ~ RESET ~ " : ";
	line ~= text;
	this.file.writeln (line);
	this.file.flush();
	if (Option.instance.debug_mode)
	    writeln (line);
    }

    ref string file_path () {
	return this.file_path;
    }

    mixin Singleton!Log;

    private {
	File file;

	string RESET = "\u001B[0m";
	string PURPLE = "\u001B[46m";
	string RED = "\u001B[41m";
	string GREEN = "\u001B[42m";
    }
}
