import std.stdio;
import http.HttpRequest;
import http.HttpServer;
import http.HttpSession;
import http.HttpResponse;
import std.string, std.conv;
import utils.LexerString;
import std.container;
import std.socket;


class Session : HttpSession {

    this (Socket socket) {
	super (socket);
    }

    HttpRequest toRequest (string value) {
	//TODO, transformation de la chaine en requete http
	LexerString lex = new LexerString (value);
	lex.setKeys (make!(Array!string)([":", ",", " ", "\n", "\r"]));
	lex.setSkip (make!(Array!string)([" ", "\n", "\r"]));
	Word word;
	return HttpRequestParser.parser (lex);
    }

    void [] recv_all () {
	byte [] total;
	while (true) {
	    byte [] data;
	    data.length = 256;
	    auto length = this.socket.receive (data);
	    total ~= data;
	    if (length < 256) return total;
	}
    }
    
    void on_begin (Address client) {
	writeln (client.toAddrString(), ":", client.toPortString ());
	//reception de la requete http
	auto data = this.recv_all ();
	auto request = toRequest (cast(string) data);
	writeln (request.toString);
	this.socket.send ("bonjour");
    }

    void on_end () {
    }

}

void main (string [] args) {
    HttpServer!Session session = new HttpServer!Session (args);
}
