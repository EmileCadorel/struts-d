module servlib.utils.Log;

import servlib.utils.Singleton;
import servlib.utils.Option;
import std.stdio;
import std.datetime;
import std.conv;
import std.outbuffer;

/**
 La classe Log permet d'enregistrer les log dans un fichier
*/
class Log {

    this () {
	this._file_path = this._default_file_path;
	this._open_file ();
    }

    this (string file_path) {
	this._file_path = file_path;
	this._open_file ();
    }

    ~this () {
	this.file.close();
    }

    /**
     Ajoute une information dans les log
     Params:
     msg, le message (format)
     values, les informations a mettre dans le format
     */
    void addInfo (TArgs...) (string msg, TArgs values) {
	SysTime date = Clock.currTime ();
	OutBuffer buf = new OutBuffer;
	buf.write ("(" ~ to!string(date.day)
		   ~ "-" ~ to!string(date.month) ~ "-"
		   ~ to!string(date.year) ~ " "
		   ~ to!string(date.hour) ~ ":"
		   ~ to!string(date.minute) ~ ":"
		   ~ to!string(date.second) ~ ") INFO : ");
	buf.writefln (msg, values);
	this.file.write (buf.toString);
	this.file.flush ();
	if (Option.instance.debug_mode)
	    write (buf.toString);
    }

    /**
     Ajoute une erreur dans le fichier de log
     Params:
     msg, le message (format)
     values, les informations a mettre dans le format
     */
    void addError (TArgs...) (string msg, TArgs values) {
	SysTime date = Clock.currTime ();
	OutBuffer buf = new OutBuffer;
	buf.write ("(" ~ to!string(date.day) ~ "-"
		   ~ to!string(date.month) ~ "-"
		   ~ to!string(date.year) ~ " "
		   ~ to!string(date.hour) ~ ":"
		   ~ to!string(date.minute) ~ ":"
		   ~ to!string(date.second) ~ ") "
		   ~ RED ~ "ERROR" ~ RESET ~ " : ");
	buf.writefln (msg, values);
	this.file.write (buf.toString);
	this.file.flush ();
	if (Option.instance.debug_mode)
	    write (buf.toString);
    }

    /**
     Ajoute un warning dans le fichier de log
     */
    void addWarning (T, TArgs...) (T msg, TArgs values) {
	SysTime date = Clock.currTime ();
	OutBuffer buf = new OutBuffer;
	buf.write ("(" ~ to!string(date.day) ~ "-"
		   ~ to!string(date.month) ~ "-"
		   ~ to!string(date.year) ~ " "
		   ~ to!string(date.hour) ~ ":"
		   ~ to!string(date.minute) ~ ":"
		   ~ to!string(date.second) ~ ") "
		   ~ RED ~ "WARNING" ~ RESET ~ " : ");
	buf.writefln (msg, values);
	this.file.write (buf.toString);
	this.file.flush ();
	if (Option.instance.debug_mode)
	    write (buf.toString);
    }

    /**
     L'emplacement du fichier de log
     */
    ref string file_path () {
	return this._file_path;
    }

    mixin Singleton!Log;

    private {
	void _open_file () {
	    this.file = File(this._file_path, "a");
	}

	File file;
	string _file_path;
	string RESET = "\u001B[0m";
	string PURPLE = "\u001B[46m";
	string RED = "\u001B[41m";
	string GREEN = "\u001B[42m";

	immutable string _default_file_path = "logs.txt";
    }
}
