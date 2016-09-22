module http.HttpServer;
import std.container;
import http.HttpSession;
import std.socket;

class HttpServer (T : HttpSession) {

    this (string [] options) {
	//TODO, charger les parametres
	init ();
    }

    void kill () {
	foreach (it ; this.sessions) {
	    it.kill ();
	}
	this.end = true;
    }

    private {
	void init () {
	    this.socket = new TcpSocket ();
	    this.socket.setOption (SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);

	    this.socket.bind (new InternetAddress (this.port));
	    this.socket.listen (this.nb_stack);
	    this.run ();
	}

	void run () {
	    while (!end) {
		auto client = this.socket.accept ();
		auto session = new T (client);
		this.sessions.insertFront (session);
		session.start ();
	    }
	}

    }

    private {
	ushort nb_stack = 1;
	ushort port = 8080;
	Socket socket;
	SList!T sessions;
	bool end = false;
    }

};
