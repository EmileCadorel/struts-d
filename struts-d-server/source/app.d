import std.stdio;
import http.HttpServer;
import driver.BaseDriver;
import utils.Option;
import utils.exception;

void main (string[] args) {
  writeln (" ## Prototype de serveur ## ");

  Option opt = Option.instance;
  try {
    opt.load_config ();
    HttpServer!BaseDriver serv = new HttpServer!BaseDriver ([]);
  } catch (StrutsException e) {
    // writeln ("test", e);
  }
}
