module http.HttpServer;
import std.container;
import std.socket;
import http.HttpSession;
import std.datetime;
import std.conv;
import std.stdio;
import servlib.utils.Log;

class HttpServerBase {
    abstract void kill ();
}

class HttpServer (T : HttpSession) : HttpServerBase {

    this (string [] options) {
	if (options.length == 1) {
	    this.port = to!ushort (options[0]);
	}
	foreach (it ; 0 .. 100) {
	    try {
		init ();		
		break;
	    } catch (Exception e) {
		this.port++;
	    }
	}
	this.run;
    }
    
    override void kill () {
	foreach (it ; this.view_states) {
	    it.kill ();
	}
	this.end = true;
	this.socket.close ();
    }
   
    private {

	void init () {
	    this.socket = new TcpSocket ();
	    this.socket.setOption (SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);

	    this.socket.bind (new InternetAddress (this.port));
	    this.socket.listen (this.nb_stack);
	    this.socket.blocking = true;
	}

	void run () {
	    Log.instance.addInfo ("Server lance sur port %u", port);
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
	
    }

};
