import std.stdio;
import http.HttpServer;
import driver.BaseDriver;
import servlib.utils.Option;
import servlib.utils.exception;
import servlib.utils.Log, servlib.control.Controller;
import servlib.application.Application;
import utils.SoLoader;

void main (string[] args) {
    writeln (" ## Prototype de serveur ## ");
    Option opt = Option.instance;
    Log.instance.add_info ("Lancement du serveur.");
    
    try {

	opt.load_config ("test");
	SoLoader.instance.load ("../so-test/app1/libapp1.so");
	writeln (ControllerTable.instance.toString());
	HttpServer!BaseDriver serv = new HttpServer!BaseDriver ([]);
	SoLoader.instance.stop ();
    
    } catch (StrutsException e) {
	writeln (e);
    } catch (Exception e) {
	writeln (e);
    }
}
