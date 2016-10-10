module http.HttpSession;
import core.thread;
import std.socket;

abstract class HttpSession : Thread {

    this (Socket socket) {
	super (&run);
	this.socket = socket;
    }

    void on_begin (Address addr) {}
    void on_end () {}

    final void kill () {
	//TODO
    }

    ~this () {}

    private {

	void run () {
	    on_begin (this.socket.remoteAddress ());
	    on_end ();
	    this.socket.shutdown (SocketShutdown.BOTH);
	    this.socket.close ();
	}

    }

    public {
	Socket socket;
    }

}
