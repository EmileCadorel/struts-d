import std.stdio;
import http.HttpServer;
import driver.BaseDriver;
import utils.Option;

void main (string[] args) {
  writeln (" ## Prototype de serveur ## ");

  Option.instance.config_file_path = "config.xml";
  HttpServer!BaseDriver serv = new HttpServer!BaseDriver ([]);
}