module http.HttpServer;
import std.container;
import std.socket;
import http.HttpSession;

class HttpServer (T : HttpSession) {

  this (string [] options) {
    //TODO, charger les parametres
    init ();
  }

  static this () {
    // on ira chercher le fichier des sessions ici eventuellement
  }

  void kill () {
    foreach (it ; this.view_states) {
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
	this.view_states.insertFront (session);
	session.start ();
      }
    }

  }

  // static SessionController getSessions() {
  //   return sessions;
  // }

  private {
    ushort nb_stack = 1;
    ushort port = 8080;
    Socket socket;
    SList!T view_states;
    // static SessionController sessions;
    bool end = false;
  }

};
