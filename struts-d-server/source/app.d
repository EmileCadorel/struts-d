import std.stdio, std.outbuffer, std.file;
import http.HttpServer;
import servlib.dsp.HtmlIfParser;
import driver.BaseDriver;
import servlib.utils.Option;
import servlib.utils.exception;
import servlib.utils.Log, servlib.control.Controller;
import servlib.application.Application;
import servlib.utils.SoLoader;
import servlib.utils.xml;
import servlib.dsp.HTMLoader;

void main (string[] args) {
    writeln (" ## Prototype de serveur ## ");
    Option opt = Option.instance;
    Log.instance.addInfo ("Lancement du serveur.");
    
    try {
        Balise b = HTMLoader.load("hello.dsp","/home/thenawaker/projet/Perso/D/struts-d/zip-files/arch1", null);
	OutBuffer buf = new OutBuffer();
	b.toXml(buf);
	std.file.write("/home/thenawaker/projet/Perso/D/struts-d/answer.html",buf.toString());
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
