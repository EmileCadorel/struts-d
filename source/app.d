import std.stdio, std.socket, std.container, std.conv;
import http.HttpSession;
import http.HttpServer;
import http.HttpRequest;
import http.HttpResponse;
import utils.LexerString;
import control.Controller;
import control.NotFoundController;
import control.ControllerContainer;

import HomeController;


class HSession : HttpSession {
  this (Socket socket) {
    super (socket);
    container = new ControllerContainer;
  }

  void on_begin (Address addr) {
    writeln ("Nouvelle connexion : ");
    writeln (addr.toAddrString());

    // on récupère la liste des controleurs
    this.get_controllers (container);
    this.start_routine ();
  }

  void on_end () {
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

    while ((status_recv = this.recv_request (data)) > 0) {
      writeln ("Reception...");
      HttpRequest request = this.toRequest (data);
      HttpResponse response = new HttpResponse;

      Controller controller = this.container.get!HomeController ("home");
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
      writeln ("Sessid : " ~ this.sessid);
      response.cookies["SESSID"] = this.sessid;
      response.addContent (controller.execute ());
      response.code = HttpResponseCode.OK;
      response.proto = "HTTP/1.1";
      response.type = "text/html";

      writeln ("Envoie de...");
      this.send_response (response);
    }
    if (status_recv < 0)
      writeln (this.socket.getErrorText());
  }

  // va falloir voir ça plus serieusement
  string create_sessid () {
    return "1234";
  }

  HttpRequest toRequest (string data) {
    LexerString lex = new LexerString (data);
    lex.setKeys (make!(Array!string)([":", ",", " ", "\n", "\r"]));
    lex.setSkip (make!(Array!string)([" ", "\n", "\r"]));
    return HttpRequestParser.parser (lex);
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
  }
}

void main (string[] args) {
  writeln (" ## Prototype de serveur ## ");

  HttpServer!HSession serv = new HttpServer!HSession ([]);
}