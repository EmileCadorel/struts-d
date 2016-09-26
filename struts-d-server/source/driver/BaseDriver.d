module driver.BaseDriver;

import std.stdio, std.socket, std.container, std.conv;
import http.HttpSession;
import http.HttpServer;
import http.request;
import http.response;
import utils.Log;
import control.Controller;
import control.NotFoundController;
import control.ControllerContainer;
import utils.XMLoader;

// Pour le test
import HomeController;

class BaseDriver : HttpSession {
    this (Socket socket) {
	super (socket);
	container = new ControllerContainer;
	log = Log.instance;
    }

    void on_begin (Address addr) {
	log.add_info ("Nouvelle connexion -> " ~ addr.toAddrString());
	writeln ("Nouvelle connexion : ");
	writeln (addr.toAddrString());

	// on récupère la liste des controleurs
	this.get_controllers (container);
	this.start_routine ();
    }

    void on_end () {
	log.add_info ("Deconnexion !");
	writeln ("Deconnexion !");
    }

    // tmp, on va appeler un fichier xml par la suite...
    void get_controllers (ControllerContainer s) {
	s["home"] = new HomeController;
    }

    /**
     On va chercher le SESSID dans la première requete.
     Si il est présent, on va pouvoir utiliser les variables de sessions
     Sinon on va créer une instance
    */
    void start_routine () {
	string data = "";
	int status_recv;

	auto root = XMLoader.root ("../xml-test/test1.xml");
	writeln (root.toStr ());
    
	status_recv = this.recv_request (data);
	
	writeln (data);
    
	writeln ("Reception...");
	HttpRequest request = this.toRequest (data);
	writeln (request);
	HttpResponse response = new HttpResponse;

	/* Test simple, si on ajoute 'home' a l'url, ca marche, sinon on affiche not found page */
	HttpUrl url = request.url;
	string controller_name = "test";
	if (url.path.length > 0)
	    controller_name = url.path[0];

	Controller controller = this.container.get!HomeController (controller_name);
	if (controller is null)
	    controller = new NotFoundController;
	controller.unpackRequest (request);

	string[string] cookies = request.cookies();
	if (cookies.length > 0) {
	    if ("SESSID" in cookies) {
		this.sessid = cookies["SESSID"];
	    } else {
		this.sessid = this.create_sessid ();
	    }
	} else {
	    this.sessid = this.create_sessid ();
	}
	// writeln ("Sessid : " ~ this.sessid);
	response.cookies["SESSID"] = this.sessid;
	response.addContent (controller.execute ());
	response.code = HttpResponseCode.OK;
	response.proto = "HTTP/1.1";
	response.type = "text/html";

	// writeln ("Envoie de...");
	this.send_response (response);
    
	if (status_recv < 0)
	    writeln (this.socket.getErrorText());
    }

    // va falloir voir ça plus serieusement
    string create_sessid () {
	return "1234";
    }

    HttpRequest toRequest (string data) {
	return HttpRequestParser.parser (data);
    }

    int recv_request (ref string data) {
	byte[] total;
	while (true) {
	    byte[] buffer;
	    buffer.length = 256;
	    auto length = this.socket.receive (buffer);
	    total ~= buffer;
	    if (length <= 0) {
		return cast(int)length;
	    } else if (length < 256) {
		data = cast(string)total;
		return 1;
	    }
	}
    }

    void send_response (HttpResponse response) {
	auto error = this.socket.send (response.enpack());
	if (error == Socket.ERROR) {
	    writeln ("Error !");
	    writeln (this.socket.getErrorText());
	}
    }

    private {
	ControllerContainer container;
	string sessid;
	Log log;
    }
}
