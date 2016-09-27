import std.stdio;
import http.HttpServer;
import driver.BaseDriver;
import utils.Option;
import utils.exception;
import utils.Log;

void main (string[] args) {
  writeln (" ## Prototype de serveur ## ");
  Option opt = Option.instance;
  Log.instance.add_info ("Lancement du serveur.");

  try {
    opt.load_config ("test");
    HttpServer!BaseDriver serv = new HttpServer!BaseDriver ([]);
  } catch (StrutsException e) {}
}
