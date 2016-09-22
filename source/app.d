// import std.stdio;
// import control.Session;

// class A {
//   string toString () {
//     return "A";
//   }
// }

// void fill_session (Session session) {
//   session["salut"] = new A ();
//   session ["comment"] = new int(89);
// }

// void main (string [] args) {
//   Session session = new Session;
//   fill_session (session);
//   auto res = session.get!A ("salut");
//   if (res !is null)
//     writeln (res.toString);

//   auto b = session.get!int ("comment");
//   if (b !is null)
//     writeln (*b);
// }

import std.stdio, std.socket, std.container;
import http.HttpSession, http.HttpServer, http.HttpRequest, http.HttpResponse;
import utils.LexerString;

class Session : HttpSession {
  this (Socket socket) {
    super (socket);
  }

  void on_begin (Address addr) {
    writeln ("Nouvelle connexion : ");
    writeln (addr.toAddrString());

    // while (true) {
      string data = this.recv_request ();
      HttpRequest request = this.toRequest (data);
      writeln (request.toString());
      HttpResponse response = new HttpResponse;
      response.code = HttpResponseCode.NOT_FOUND;
      response.proto = "HTTP/1.1";
      response.type = "text/html";
      string content = "404 Not Found";
      response.content = cast(byte[])content;
      this.send_response (response);
    // }
  }

  void on_end () {
    writeln ("Deconnexion !");
  }

  HttpRequest toRequest (string data) {
    LexerString lex = new LexerString (data);
    lex.setKeys (make!(Array!string)([":", ",", " ", "\n", "\r"]));
    lex.setSkip (make!(Array!string)([" ", "\n", "\r"]));
    return HttpRequestParser.parser (lex);
  }

  string recv_request () {
    byte[] total;
    while (true) {
      byte[] data;
      data.length = 256;
      auto length = this.socket.receive (data);
      total ~= data;
      if (length < 256) return cast(string)total;
    }
  }

  void send_response (HttpResponse response) {
    auto error = this.socket.send (response.enpack());
    if (error == Socket.ERROR) {
      writeln ("Error !");
      writeln (this.socket.getErrorText());
    } else {
      writeln ("No error while sending : ");
      writeln (cast(string)response.enpack());
    }
  }
}

void main (string[] args) {
  writeln (" ## Prototype de serveur ## ");

  HttpServer!Session serv = new HttpServer!Session ([]);
}