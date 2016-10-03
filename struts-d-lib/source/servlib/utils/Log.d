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

  void add_info (T, TArgs...) (T msg, TArgs values) {
    SysTime date = Clock.currTime ();
    string line = "(" ~ to!string(date.day)
      ~ "-" ~ to!string(date.month) ~ "-"
      ~ to!string(date.year) ~ " "
      ~ to!string(date.hour) ~ ":"
      ~ to!string(date.minute) ~ ":"
      ~ to!string(date.second) ~ ") INFO : ";
    line ~= msg;
    this.file.write (line);
    if (Option.instance.debug_mode)
      write (line);
    this._add_info (values);
  }

  void add_err (T, TArgs...) (T msg, TArgs values) {
    SysTime date = Clock.currTime ();
    string line = "(" ~ to!string(date.day) ~ "-"
      ~ to!string(date.month) ~ "-"
      ~ to!string(date.year) ~ " "
      ~ to!string(date.hour) ~ ":"
      ~ to!string(date.minute) ~ ":"
      ~ to!string(date.second) ~ ") "
      ~ RED ~ "ERROR" ~ RESET ~ " : ";
    line ~= msg;
    this.file.write (line);
    if (Option.instance.debug_mode)
      write (line);
    this._add_err (values);
  }

  void add_war (T, TArgs...) (T msg, TArgs values) {
    SysTime date = Clock.currTime ();
    string line = "(" ~ to!string(date.day) ~ "-"
      ~ to!string(date.month) ~ "-"
      ~ to!string(date.year) ~ " "
      ~ to!string(date.hour) ~ ":"
      ~ to!string(date.minute) ~ ":"
      ~ to!string(date.second) ~ ") "
      ~ PURPLE ~ "WARNING" ~ RESET ~ " : ";
    line ~= msg;
    this.file.write (line);
    if (Option.instance.debug_mode)
      write (line);
    this._add_war (values);
  }

  void _add_war (T, TArgs...) (T msg, TArgs values) {
    this.file.write (msg);
    if (Option.instance.debug_mode)
      write (msg);
    this._add_war (values);
  }

  ref string file_path () {
    return this.file_path;
  }

  mixin Singleton!Log;

  private {
    void _add_info (T, TArgs...) (T msg, TArgs values) {
      this.file.write (msg);
      if (Option.instance.debug_mode)
	write (msg);
      this._add_info (values);
    }

    void _add_info () () {
      this.file.writeln ("");
      this.file.flush();
      if (Option.instance.debug_mode)
	writeln ("");
    }

    void _add_err (T, TArgs...) (T msg, TArgs values) {
      this.file.write (msg);
      if (Option.instance.debug_mode)
	write (msg);
      this._add_err (values);
    }

    void _add_err () () {
      this.file.writeln ("");
      this.file.flush ();
      if (Option.instance.debug_mode)
	writeln ("");
    }

    void _add_war () () {
      this.file.writeln ("");
      this.file.flush ();
      if (Option.instance.debug_mode)
	this.writeln ("");
    }

    File file;

    string RESET = "\u001B[0m";
    string PURPLE = "\u001B[46m";
    string RED = "\u001B[41m";
    string GREEN = "\u001B[42m";
  }
}
