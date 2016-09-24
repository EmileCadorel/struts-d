module utils.Log;

import utils.Singleton;
import utils.Option;
import std.stdio;
import std.datetime;
import std.conv;

class Log {

  this () {
    this.option = Option.instance;
    this.file = File(this.option.log_file_path, "a");
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
  }

  void add_err (string text) {
    SysTime date = Clock.currTime ();
    string line = "(" ~ to!string(date.day) ~ "-" ~ to!string(date.month) ~ "-" ~ to!string(date.year) ~ " " ~ to!string(date.hour) ~ ":" ~ to!string(date.minute) ~ ":" ~ to!string(date.second) ~ ") ERROR : ";
    line ~= text;
    this.file.writeln (line);
    this.file.flush();
  }

  void add_war (string text) {
    SysTime date = Clock.currTime ();
    string line = "(" ~ to!string(date.day) ~ "-" ~ to!string(date.month) ~ "-" ~ to!string(date.year) ~ " " ~ to!string(date.hour) ~ ":" ~ to!string(date.minute) ~ ":" ~ to!string(date.second) ~ ") WARNING : ";
    line ~= text;
    this.file.writeln (line);
    this.file.flush();
  }

  ref string file_path () {
    return this.file_path;
  }

  mixin Singleton!Log;

  private {
    File file;
    Option option;
  }
}