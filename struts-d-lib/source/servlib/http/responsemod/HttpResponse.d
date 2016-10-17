module servlib.http.responsemod.HttpResponse;
import std.outbuffer;
import std.datetime;
import std.conv, std.typecons;


alias HttpCode = Tuple!(ushort, "code", string, "text");

/**
 Une reponse a une requete HTTP
*/
enum HttpResponseCode : HttpCode {
    OK = HttpCode (200, "OK"),
	REDIRECT = HttpCode(301, "Moved Permanently"),
	NOT_FOUND = HttpCode (404, "Not Found"),
	INTERNAL_ERROR = HttpCode (500, "Internal Server Error")
	}

/**
 Cette classe va servir a code la reponse HTTP
*/
class HttpResponse {

    this () {
	this._date = Clock.currTime ();
    }

    /**
     le code de la reponse
     */
    ref HttpResponseCode code () {
	return this._code;
    }

    /**
     Le contenu de la reponse
     */
    ref byte [] content () {
	return this._content;
    }

    /**
     Le type de protocol utilise
     */
    ref string proto () {
	return this._proto;
    }

    /**
     Le type de contenu envoye
     */
    ref string type () {
	return this._type;
    }

    /**
     Les cookies
     */
    ref string[string] cookies () {
	return this._cookies;
    }

    /**
     l'url de redirection
     */
    ref string location () {
	return this._location;
    }
    
    /**
     ajoute le contenu dans la reponse
     */
    void addContent (string content) {
	this._content ~= cast(byte[])content;
    }

    /**
     creer un paquet a envoye en reponse
     */
    byte [] enpack () {
	OutBuffer buf = new OutBuffer;
	buf.write (_proto);
	buf.write (" " ~ to!string(_code.code) ~ " " ~ _code.text ~ "\r\n");
	buf.write ("Date: " ~ to!string(_date.dayOfWeek));
	buf.write (", " ~ to!string (_date.day) ~ " " ~ to!string(_date.month) ~ " ");
	buf.write (to!string(_date.year) ~ " " ~ to!string(_date.hour) ~ ":" ~ to!string (_date.minute) ~ ":" ~ to!string(_date.second));
	buf.write (" " ~ to!string(_date.timezone.stdName) ~ "\r\n");
	buf.write ("Server: server-d\r\n");
	if (_location !is null) {
	    buf.write ("Location: " ~ _location ~ "\r\n");
	}
	buf.write ("Content-Type: " ~ _type ~ "; charset=UTF-8\r\n");
	buf.write ("Content-Length: " ~ to!string(_content.length) ~ "\r\n\r\n");
	byte [] total = cast(byte[])(buf.toString) ~ _content;
	return total;
    }

    private {
	HttpResponseCode _code;
	string _proto;
	SysTime _date;
	byte [] _content;
	string _type;
	string[string] _cookies;
	string _location = null;
    }

}
