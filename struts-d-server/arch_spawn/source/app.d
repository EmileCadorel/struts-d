import std.stdio;
import http.HttpServer;
import driver.BaseDriver;
import servlib.dsp.TagImport;
import servlib.utils.Option;
import servlib.utils.exception;
import servlib.utils.Log, servlib.control.Controller;
import servlib.application.Application;
import servlib.utils.SoLoader;
import servlib.utils.xml;
import servlib.dsp.HTMLoader;
import std.conv;

void main (string [] args) {
    Log.instance.addInfo ("Lancement d'un archive" ~ args[1]);
    try {
	Option.instance.load_config ("test");
	ApplicationLoader.instance.load (args[1]);	
	HttpServer!BaseDriver serv = new HttpServer!BaseDriver ([args[2]]);
	SoLoader.instance.stop ();
    } catch (StrutsException e) {
	writeln (e);
    } catch (Exception e) {
	writeln (e);
    }    
}
