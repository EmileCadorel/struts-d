import std.stdio, std.socket, std.container;
import http.HttpSession;
import http.HttpServer;
import http.HttpRequest;
import http.HttpResponse;
import utils.LexerString;
import control.Session;
import control.Controller;
// import control.NotFoundController;

import HomeController;

void fill_session (Session s) {
  s["home"] = new HomeController;
}

class HSession : HttpSession {
  this (Socket socket) {
    super (socket);
  }

  void on_begin (Address addr) {
    writeln ("Nouvelle connexion : ");
    writeln (addr.toAddrString());

    // on récupère la liste des controleurs
    Session session = new Session;
    fill_session (session); // tmp, on va appeler un fichier xml par la suite...

    string data = "";
    int status_recv;
    while ((status_recv = this.recv_request (data)) > 0) {
      HttpRequest request = this.toRequest (data);
      Controller controller = session.get!HomeController ("home");
      HttpResponse response = null;
      // if (controller is null)
      // 	controller = new NotFoundController;
      controller.unpackRequest (request);
      response = this.build_response (controller.execute());
      this.send_response (response);
    }

    if (status_recv == Socket.ERROR)
      writeln (this.socket.getErrorText());
  }

  void on_end () {
    writeln ("Deconnexion !");
  }

  HttpResponse build_response (string content) {
    HttpResponse response = new HttpResponse;
    response.code = HttpResponseCode.OK;
    response.proto = "HTTP/1.1";
    response.type = "text/html";
    response.content = cast(byte[])content;
    return response;
  }

  HttpRequest toRequest (string data) {
    LexerString lex = new LexerString (data);
    lex.setKeys (make!(Array!string)([":", ",", " ", "\n", "\r"]));
    lex.setSkip (make!(Array!string)([" ", "\n", "\r"]));
    return HttpRequestParser.parser (lex);
  }

  int recv_request (string data) {
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
}

void main (string[] args) {
  writeln (" ## Prototype de serveur ## ");

  HttpServer!HSession serv = new HttpServer!HSession ([]);
}