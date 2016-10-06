import std.stdio, std.outbuffer;
import http.HttpServer;
import driver.BaseDriver;
import servlib.utils.Option;
import servlib.utils.exception;
import servlib.utils.Log, servlib.control.Controller;
import servlib.application.Application;
import servlib.utils.SoLoader;
import servlib.utils.xml;

void main (string[] args) {
    writeln (" ## Prototype de serveur ## ");
    Option opt = Option.instance;
    Log.instance.addInfo ("Lancement du serveur.");
    
    try {

	opt.load_config ("test");
	writeln (ControllerTable.instance.toString());
	HttpServer!BaseDriver serv = new HttpServer!BaseDriver ([]);
	SoLoader.instance.stop ();
	
    } catch (StrutsException e) {
	writeln (e);
    } catch (Exception e) {
	writeln (e);
    }
}
