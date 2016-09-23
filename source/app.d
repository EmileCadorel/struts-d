import std.stdio;
import http.HttpServer;
import driver.BaseDriver;

void main (string[] args) {
  writeln (" ## Prototype de serveur ## ");

  HttpServer!BaseDriver serv = new HttpServer!BaseDriver ([]);
}
