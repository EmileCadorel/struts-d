module http.HttpServer;
import std.container;
import std.socket;
import http.HttpSession;
import http.Console;
import std.datetime;

class HttpServerBase {
    abstract void kill ();
}

class HttpServer (T : HttpSession) : HttpServerBase {

    this (string [] options) {
	//TODO, charger les parametres
	init ();
    }
    
    override void kill () {
	foreach (it ; this.view_states) {
	    it.kill ();
	}
	this.end = true;
	this.socket.close ();
	this.console.kill ();	
    }

    private {

	void init () {
	    this.socket = new TcpSocket ();
	    this.socket.setOption (SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);

	    this.socket.bind (new InternetAddress (this.port));
	    this.socket.listen (this.nb_stack);
	    this.socket.blocking = true;
	    this.run ();
	}

	void run () {
	    this.console = new Console (this);
	    this.console.start ();
	    while (!this.end) {
		auto client = this.socket.accept ();
		auto session = new T (client);
		this.view_states.insertFront (session);
		session.start ();		    		
	    }
	}
    }

    private {
	
	ushort nb_stack = 1;
	ushort port = 8080;
	Socket socket;
	SList!T view_states;
	bool end = false;
	Console console;
	
    }

};
