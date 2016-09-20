import std.stdio;
import netez = netez;
import HttpRequestMod;
import std.string, std.conv;
import LexerMod;
import std.container;

class Protocol : netez.EzProto {
    this (netez.EzSocket socket) {
	super (socket);
    }
}

class Session : netez.EzServSession!Protocol {

    this (netez.EzSocket socket) {
	super (socket);
    }

    HttpRequest toRequest (string value) {
	//TODO, transformation de la chaine en requete http
	Lexer lex = new Lexer (value);
	lex.setKeys (make!(Array!string)([":", ",", " ", "\n", "\r"]));
	lex.setSkip (make!(Array!string)([" ", "\n", "\r"]));
	Word word;
	return HttpRequestParser.parser (lex);
    }
    
    void on_begin (netez.EzAddress client) {
	writeln (client.address, ":", client.port);
	//reception de la requete http
	auto data = this.socket.recv_all ();
	auto request = toRequest (cast(string)data);
	writeln (request.toString);
    }

    void on_end () {
    }

}

void main () {
    netez.EzServer!Session session = new netez.EzServer!Session (8080);
}
