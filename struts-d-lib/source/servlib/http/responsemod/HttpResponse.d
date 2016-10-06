module servlib.http.responsemod.HttpResponse;
import std.outbuffer;
import std.datetime;
import std.conv;

/**
 Une reponse a une requete HTTP
*/
enum HttpResponseCode : ushort {
    OK = 200,
	NOT_FOUND = 404,
	INTERNAL_ERROR = 500
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
	buf.write (" " ~ to!string(cast(ushort)_code) ~ " " ~ to!string(_code) ~ "\r\n");
	buf.write ("Date: " ~ to!string(_date.dayOfWeek));
	buf.write (", " ~ to!string (_date.day) ~ " " ~ to!string(_date.month) ~ " ");
	buf.write (to!string(_date.year) ~ " " ~ to!string(_date.hour) ~ ":" ~ to!string (_date.minute) ~ ":" ~ to!string(_date.second));
	buf.write (" " ~ to!string(_date.timezone.stdName) ~ "\r\n");
	buf.write ("Server: server-d\r\n");
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
    }

}
