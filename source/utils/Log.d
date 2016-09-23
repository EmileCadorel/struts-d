module utils.Log;

import utils.Singleton;
import utils.Option;
import std.stdio;
import std.datetime;
import std.conv;

class Log {

  this () {
    this.option = Option.instance;
    if (this.option.log_file_path != "") {
      this.file = File(this.option.log_file_path, "a");
    } else {
      this.file = File(this.default_file_name, "a");
    }
  }

  ~this () {
    this.file.close();
  }

  void add_info (string text) {
    SysTime date = Clock.currTime ();
    string line = "(" ~ to!string(date.day) ~ "-" ~ to!string(date.month) ~ "-" ~ to!string(date.year) ~ " : INFO : ";
    line ~= text;
    writeln ("line : " ~ line);
    this.file.writeln (line);
    this.file.flush();
  }

  void add_err (string text) {
    SysTime date = Clock.currTime ();
    string line = "(" ~ to!string(date.day) ~ "-" ~ to!string(date.month) ~ "-" ~ to!string(date.year) ~ " : ERROR : ";
    line ~= text;
    this.file.writeln (line);
    this.file.flush();
  }

  void add_war (string text) {
    SysTime date = Clock.currTime ();
    string line = "(" ~ to!string(date.day) ~ "-" ~ to!string(date.month) ~ "-" ~ to!string(date.year) ~ " : WARNING : ";
    line ~= text;
    this.file.writeln (line);
    this.file.flush();
  }

  ref string file_path () {
    return this.file_path;
  }

  mixin Singleton!Log;

  private {
    immutable string default_file_name = "log_server.txt";
    File file;
    Option option;
  }
}